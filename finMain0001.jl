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

mod=modelGen(35654,
             100,
             .05,
             newman_watts_strogatz(100, 20, .2),
             Levy(10,10),
             .3,
             .6,
             Binomial(100,.1))
modelRun(mod)