################################################################################
#              Replacement Bank Run Model                                      #
#               (networked)                                                    #
#               May 2025                                                       #
#               John S. Schuler                                                #
#               Main Control Code                                              #
################################################################################
using Distributions
using Random
using Distributed
using CSV
using DataFrames
using Graphs
using StatsBase
using JLD2
using Dates

# major parameters
depth::Int64=1000
pause::Bool=true
include("objects.jl")

include("functions4.jl")


#println(depth)
# now, we summarize the model  

# model initialization
# generate the agents and their network 
# generate their deposits
# generate the bank 

# now the model begins and an exogenous number of agents withdraw

# each agent observes the percentage of its neighbors that have withdrawn
# and takes this as a random sample of the population
# the agent then calculates its probability of getting its full deposit back 
# while randomizing over which agents withdraw
# and its own place in line 

# now, the structs are generated once and for all
# so we can use processes based parallelism 

mod=modelGen(sample(1:1000000,1)[1],
             1000,
             .05,
             newman_watts_strogatz(1000, 10, .2),
             Pareto(1.0,10),
             .15,
             0.0,
             Binomial(1000,.2))
rMod=modelRun(mod)
println(rMod)
println(mod.theBank.vault)
println(mod.theBank.withdrawHistory)