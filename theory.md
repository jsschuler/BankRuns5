# Theoretical Development Notes

## Paper Argument Structure

### 1. The DD Critique

**Setup (follows White 1999):**
- N agents, deposit normalized to 1 each
- Long-term investment: 1 unit at t=1 → R > 1 at t=3, or r < 1 if liquidated at t=2
- Early withdrawal contract pays c1 = 1 + r1 per unit (r1 ≥ 0 is the insurance premium)
- Sequential service; fraction f withdraws at t=2
- Bank liquidates fc1/r of investment to meet early withdrawals
- Late withdrawers' payoff: c2(f) = R(1 - fc1/r) / (1-f)

**Core argument:**
The DD bad equilibrium is driven by c1 = 1 + r1 > 1. This makes early withdrawal
intrinsically rewarding — agents are exercising a put option, not fleeing a failing
bank. This premium is a model artifact: real demand deposits pay at most the
principal on early withdrawal.

**Theorem (DD Fragility Inflation):**
The good equilibrium (only type 1 agents withdraw) is locally stable iff λ < f*(c1):

  f*(c1) = r(R - c1) / (c1(R - r))

Proof: stability requires c2(λ) > c1, i.e., R(1 - λc1/r)/(1-λ) > c1.
Rearranging: λ < r(R-c1)/(c1(R-r)) = f*(c1).

df*/dc1 = -rR / (c1²(R-r)) < 0   [strictly decreasing in c1]

The stability gap between realistic (c1=1) and DD (c1=1+r1) contracts:

  Δf* = f*(1) - f*(1+r1) = rR·r1 / ((1+r1)(R-r))

Δf* > 0 for all r1 > 0, strictly increasing in r1, vanishes as r1 → 0. □

**Two key observations:**
1. The bad equilibrium exists under BOTH contracts (when vault runs out, staying
   gives zero regardless of c1). The artifact doesn't create the bad equilibrium —
   it artificially shrinks the basin of attraction of the good one.
2. Under c1 = 1, stability depends only on technology (r, R), not contract design.
   Under DD, the contract itself introduces fragility proportional to r1.

### 2. The Binary Payoff Lemma (homogeneous deposits)
Under homogeneous deposits (δ_i = δ for all i), the vault is initialized at ρNδ
and decreases by exactly δ per withdrawal. Therefore vault ∈ {0, δ, 2δ, ..., ρNδ}
at all times. The event vault ∈ (0, δ) has probability zero exactly.

**Lemma 1 (Binary Payoff):** Under homogeneous deposits, P(partial payment) = 0
exactly. Agent payoffs are Bernoulli: δ with probability p_S, 0 otherwise.

**Corollary:** The optimal withdrawal decision reduces to comparing
P(full deposit | WD now) vs P(full deposit | stay). This justifies the decision
rules in both Model 3 (closed-form p_S) and Model 4 (Monte Carlo).

For heterogeneous deposits, the partial payment region has positive probability but
the dominance direction is preserved: going earlier weakly reduces both P(partial)
and the expected partial amount. The binary payoff approximation holds approximately,
with error bounded by δ_i · P(partial).

### 3. Queue Dominance (any deposit distribution)
**Lemma 2 (Queue Dominance):** For any agent i, any simulation state, and any
deposit distribution:
  P(full deposit | WD now) ≥ P(full deposit | stay)

Proof: The vault is monotone decreasing. Withdrawing now places the agent earlier
in the queue, weakly increasing their chance of finding vault ≥ δ_i. □

This holds unconditionally — no distributional assumptions required. It is the
foundation of the decision rule in both models.

### 4. Monotone Response (Model 3, closed-form)
**Theorem 1 (Monotone Response):** p_survival(τ, C, N, q) is weakly decreasing in τ.
The withdrawal decision is monotone non-decreasing in observed neighbor withdrawals x.

Proof sketch: tau_map is weakly increasing in x (for fixed m, N). p_survival is
weakly decreasing in τ by stochastic dominance of the truncated geometric — shifting
the lower bound of support rightward reduces probability mass below C. Therefore:
more withdrawn neighbors ⟹ higher τ ⟹ lower p_S ⟹ withdrawal. □

### 5. Reserve Ratio Monotonicity (Model 3)
**Theorem 2 (Reserve Ratio Monotonicity):** Expected endogenous withdrawal count is
weakly decreasing in ρ.

Proof sketch: C = ⌊ρN⌋ is non-decreasing in ρ. p_survival is non-decreasing in C
(larger capacity ⟹ more probability mass below threshold). Higher ρ ⟹ higher p_S
for all τ ⟹ fewer agents trigger withdrawal. □

Likely extends to: there exists a critical ρ* below which cascades are almost surely
positive. (To be formalized.)

### 6. Cascade Fixed Point (full network model, Model 4)
**Theorem 3 (Cascade Fixed Point):** In the full network model with any deposit
distribution, the cascade dynamics converge to a unique minimal set S* of withdrawing
agents satisfying:
  1. Every agent in S* has P(full | WD now, S*\{i}) > P(full | stay, S*\{i})
  2. No agent outside S* satisfies this condition given S*

Proof sketch: Define the best-response map B(S) = set of agents who withdraw given
withdrawal set S. By queue dominance, B is monotone: S ⊆ S' ⟹ B(S) ⊆ B(S').
By Tarski's fixed point theorem, a minimal fixed point S* exists. The cascade
dynamics S_0 ⊆ S_1 ⊆ ... are non-decreasing and bounded above by N, so they
converge. □

**Corollary (No-Run Condition):** The cascade is trivial (S* = S_0, no endogenous
withdrawals) iff for all agents i remaining after the exogenous shock:
  P(full | WD now) = P(full | stay) = 1
i.e., the vault is sufficient to cover all remaining deposits with certainty under
all anticipated withdrawal scenarios.

**Contrast with DD:** DD's bad equilibrium is a MAXIMAL fixed point selected by
coordination failure (everyone runs). The replacement model's S* is a MINIMAL fixed
point selected by rational updating through the network. These are structurally
opposite solution concepts.

### 7. High-Degree Trigger Proposition
**Proposition (High-Degree Trigger):** A cascade of size |S*| > |S_0| is more likely
when the exogenous shock disproportionately affects high-degree nodes. If exogenous
withdrawers are drawn from the top-k degree nodes rather than uniformly at random,
expected cascade size weakly increases.

Proof sketch: High-degree nodes have more neighbors. Their withdrawal raises τ_i for
more agents simultaneously. By monotone response (Theorem 1), more agents cross the
withdrawal threshold. □

## SVB Validation (March 2023)
SVB directly validates specific model features:

- **Network topology:** Tech startup ecosystem is a Watts-Strogatz small-world —
  highly clustered locally (VC portfolio companies) with long-range shortcuts (major
  VCs connected across clusters). The rewiring parameter p captures exactly this.

- **Cascade fixed point:** The run did NOT spread to all depositors — it converged
  to S*, the minimal rational withdrawal set. Some depositors stayed. The model
  predicts partial runs, not total collapse.

- **High-degree trigger:** Peter Thiel's Founders Fund was a high-degree node —
  its withdrawal was observed by hundreds of portfolio companies simultaneously,
  triggering the cascade. Directly instantiates the High-Degree Trigger Proposition.

- **Principal safety, not option exercise:** No SVB depositor was exercising an
  insurance option. Everyone was asking: will I get my money back? This is the
  replacement model's mechanism, not DD's.

- **Depositor homogeneity:** Tech startups with similar risk profiles and
  information sources approximates the model's assumptions.

## Paper Narrative Arc (for JPE)
1. DD is the wrong model — models option exercise not principal safety, no network
2. Replacement model is theoretically grounded — Lemmas 1-2, Theorems 1-3,
   Proposition 1
3. SVB confirms the mechanism — high-degree trigger, small-world propagation,
   convergence to partial run

## Outstanding Work
- Work through DD artifact theorem algebra formally (f* calculation under c1=1)
- Formalize the critical ρ* corollary from Theorem 2
- Fill in Model Results and Deposit Insurance subsections in draft.tex
- Fill in Literature Review section in draft.tex
- Simulation results to accompany theorems (Model 3 sweep already done)
- Proposition on high-degree trigger needs simulation validation
