################################################################################
#  model3_ws_homogeneous.jl                                                    #
#  Model 3 of the Replacement Model Hierarchy                                  #
#  Watts–Strogatz Network, Homogeneous Deposits                                #
#                                                                              #
#  Bank Run Paper — John S. Schuler                                            #
#                                                                              #
#  Under homogeneous deposits agents compute the closed-form survival          #
#  probability p_S(x) directly.  No Monte Carlo sub-models are needed.        #
#  This makes Model 3 much lighter than the full BankRuns5 simulation         #
#  (Model 4) and allows a fast sweep over network parameters.                 #
#                                                                              #
#  PARAMETER SWEEP — 360 replications                                          #
#    Fixed : N = 1000, delta_bar = 1.0, p0 = 0.1                              #
#    rho (reserve ratio) : [0.10, 0.15, 0.20]                                 #
#    ws_k (WS degree)    : [4, 8, 12]                                          #
#    ws_p (WS rewiring)  : [0.0, 0.25, 0.50, 1.0]                             #
#    network seeds       : 5 distinct draws per (rho, ws_k, ws_p) combination #
#    shock runs per seed : 2                                                   #
#    total replications  : 3 * 3 * 4 * 5 * 2 = 360                            #
#                                                                              #
#  OUTPUT — written to ../data_model3/ (one level above BankRuns5)            #
#    model3_results.csv                                                        #
#      seed1    : network-construction seed                                    #
#      seed2    : exogenous-shock seed                                         #
#      rho      : reserve ratio                                                #
#      ws_k     : Watts–Strogatz degree parameter                              #
#      ws_p     : Watts–Strogatz rewiring probability                          #
#      failed   : true if vault reached 0                                      #
#      ticks    : number of endogenous decision rounds before halt             #
#      exog_wd  : exogenous withdrawal count                                   #
#      endo_wd  : endogenous withdrawal count                                  #
#      total_wd : exog_wd + endo_wd                                            #
#                                                                              #
#  PARALLELISM — process-based via Distributed / pmap                         #
#    Spawns (CPU_THREADS - 1) workers using the active Julia project.          #
#    Uses newman_watts_strogatz (adds shortcuts, never removes edges) to       #
#    match the convention in parameterGen.jl / BankRuns5.                     #
################################################################################

using Distributed

const SYSIMAGE_PATH = joinpath(@__DIR__, "sysimage.so")
const N_CORES = Sys.CPU_THREADS

if nprocs() < N_CORES
    exeflags = isfile(SYSIMAGE_PATH) ?
        "--project=$(Base.active_project()) -J $(SYSIMAGE_PATH)" :
        "--project=$(Base.active_project())"
    addprocs(N_CORES - nprocs(); exeflags=exeflags)
end

@everywhere using Distributions
@everywhere using Random
@everywhere using Graphs
@everywhere using StatsBase

# ---------------------------------------------------------------------------
# Closed-form functions — valid only under homogeneous deposits
# ---------------------------------------------------------------------------

# Representativeness mapping τ(x): inferred system-wide withdrawal count
# from observing x withdrawn neighbors out of m.
# Returns 0 when m == 0 (isolated node — no signal, no inference).
@everywhere function tau_map(x::Int, m::Int, N::Int)::Int
    m == 0 && return 0
    return clamp(round(Int, N * x / m), 0, N - 1)
end

# Closed-form survival probability p_S(τ, C, N, q).
# Equals P(W ≤ C | W ≥ τ) under Geom(p0) truncated to [τ, N-1].
# Returns 0.0 if τ > C (agent believes failure is certain under its belief).
@everywhere function p_survival(tau::Int, C::Int, N::Int, q::Float64)::Float64
    tau > C  && return 0.0
    tau >= N && return 0.0
    num = 1.0 - q ^ (C + 1 - tau)
    den = 1.0 - q ^ (N     - tau)
    return num / den
end

# Principal-safety decision: withdraw iff p_S < 1.0 (safety tolerance ε = 0).
# In the pre-failure region p_W = 1, so the rule reduces to p_S < 1.
@everywhere function should_withdraw(x::Int, m::Int, N::Int, C::Int, q::Float64)::Bool
    return p_survival(tau_map(x, m, N), C, N, q) < 1.0
end

# ---------------------------------------------------------------------------
# Single replication
# ---------------------------------------------------------------------------

@everywhere function run_replication(
    seed1     :: Int,       # seed for network construction
    seed2     :: Int,       # seed for exogenous shock draw and agent ordering
    rho       :: Float64,   # reserve ratio
    ws_k      :: Int,       # Watts–Strogatz degree parameter
    ws_p      :: Float64,   # Watts–Strogatz rewiring probability
    N         :: Int,       # number of depositors (fixed)
    delta_bar :: Float64,   # common deposit size (homogeneous)
    p0        :: Float64,   # Geometric rate = exogenous withdrawal probability
)::NamedTuple

    q     = 1.0 - p0
    vault = rho * N * delta_bar
    C     = floor(Int, vault / delta_bar)   # = floor(ρ * N) under homogeneous deposits

    # Build network.
    # newman_watts_strogatz adds ws_k/2 shortcuts per node (never removes edges),
    # matching the convention in BankRuns5/parameterGen.jl.
    Random.seed!(seed1)
    g = newman_watts_strogatz(N, ws_k, ws_p)

    banked     = fill(true, N)
    exog_count = 0
    endo_count = 0

    # --- Exogenous shock ---
    # Draw from the same truncated Geometric used in BankRuns5: support [0, N].
    Random.seed!(seed2)
    n_exog      = min(rand(truncated(Geometric(p0), 0, N)), N)
    exog_agents = sample(1:N, n_exog; replace=false)
    for i in exog_agents
        banked[i]   = false
        vault      -= delta_bar
        exog_count += 1
    end

    failed = vault <= 0.0
    tick   = 0

    # --- Endogenous cascade ---
    while !failed
        tick        += 1
        any_withdrew = false

        for i in shuffle(findall(banked))
            neighbors = all_neighbors(g, i)
            x_i       = count(j -> !banked[j], neighbors)

            if should_withdraw(x_i, length(neighbors), N, C, q)
                banked[i]    = false
                vault       -= delta_bar
                endo_count  += 1
                any_withdrew = true

                if vault <= 0.0
                    failed = true
                    break
                end
            end
        end

        !any_withdrew && break
    end

    return (
        seed1    = seed1,
        seed2    = seed2,
        rho      = rho,
        ws_k     = ws_k,
        ws_p     = ws_p,
        failed   = failed,
        ticks    = tick,
        exog_wd  = exog_count,
        endo_wd  = endo_count,
        total_wd = exog_count + endo_count,
    )
end

# ---------------------------------------------------------------------------
# Main — parameter grid and dispatch
# ---------------------------------------------------------------------------

using DataFrames
using CSV

# Fixed parameters
const N         = 1000
const DELTA_BAR = 1.0
const P0        = 0.1

# Sweep parameters (small setup sweep — extend ranges for production runs)
const RHO_VALS = [0.10, 0.15, 0.20]
const WSK_VALS = [4, 8, 12]
const WSP_VALS = [0.0, 0.25, 0.50, 1.0]
const N_SEEDS  = 5    # distinct network-construction seeds per combination
const N_RUNS   = 2    # independent shock draws per seed

# Output directory: one level above BankRuns5
const OUT_DIR = length(ARGS) >= 1 ? ARGS[1] :
                joinpath(@__DIR__, "..", "data_model3")

function build_param_grid(
    rho_vals, wsk_vals, wsp_vals, n_seeds, n_runs;
    master_seed = 42
)
    Random.seed!(master_seed)
    rows = NamedTuple[]
    for rho in rho_vals, ws_k in wsk_vals, ws_p in wsp_vals
        net_seeds = sample(1:10_000_000, n_seeds; replace=false)
        for s1 in net_seeds, _ in 1:n_runs
            s2 = rand(1:10_000_000)
            push!(rows, (rho=rho, ws_k=ws_k, ws_p=ws_p, seed1=s1, seed2=s2))
        end
    end
    return rows
end

mkpath(OUT_DIR)

params = build_param_grid(RHO_VALS, WSK_VALS, WSP_VALS, N_SEEDS, N_RUNS)

println("Model 3 — Watts–Strogatz, Homogeneous Deposits")
println("  N = $(N),  δ̄ = $(DELTA_BAR),  p₀ = $(P0)")
println("  ρ:            $(RHO_VALS)")
println("  ws_k:         $(WSK_VALS)")
println("  ws_p:         $(WSP_VALS)")
println("  Seeds × runs: $(N_SEEDS) × $(N_RUNS) per combination")
println("  Replications: $(length(params))")
println("  Workers:      $(nworkers())")
println("  Output dir:   $(OUT_DIR)")

results = pmap(params) do p
    run_replication(
        p.seed1, p.seed2,
        p.rho, p.ws_k, p.ws_p,
        N, DELTA_BAR, P0
    )
end

df       = DataFrame(results)
out_path = joinpath(OUT_DIR, "model3_results.csv")
CSV.write(out_path, df)
println("Done. Results written to $(out_path)")
