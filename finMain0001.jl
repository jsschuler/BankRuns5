################################################################################
#              Replacement Bank Run Model                                      #
#               (networked)                                                    #
#               May 2025                                                       #
#               John S. Schuler                                                #
#               Main Control Code                                              #
################################################################################
using Distributed
@everywhere using Distributions
@everywhere using Random

@everywhere using CSV
@everywhere using DataFrames
@everywhere using Graphs
@everywhere using StatsBase
@everywhere using JLD2
@everywhere using Dates
cores=16
@everywhere workerCore=1
for c in 2:cores
    @spawnat c myCore(c)
end
# major parameters
@everywhere depth::Int64=1000

@everywhere include("objects.jl")

@everywhere include("functions4.jl")


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

# bring in the parameter generation code
include("parameterGen.jl")


# now we need to code the sweep to use all cores
coreDict=Dict()
resultDict=Dict()
rowDict=Dict()
for j in 2:cores
    coreDict[j]=nothing
end

# how many rows do we have in the control file?
while sum(jointFrame.completed) < size(jointFrame,1)
        for c in keys(coreDict)
            #println(sum(jointFrame.completed))
            #println("Core")
            #println(c)
            #println(coreDict[c])
            #println(isReady(coreDict[c]))
            #println(isnothing(coreDict[c]))
            #readline()
            if isnothing(coreDict[c])
                # if the core dictionary is nothing, we send it the parameters
                #println("Sending Parameters")
                #println("core")
                #println(c)
                #println(coreDict[c])
                # read parameters from the first row
                # step 1: get the index of the first non-started row
                
                coreDict[c]=@spawnat c modelCall()
                #println(coreDict[c])
                #println(resultDict==:complete)
            elseif isReady(coreDict[c])
                #println("Ready")
                #println(coreDict[c])
                coreDict[c]=fetch(coreDict[c])
                #println(coreDict[c])
                #println(sum(jointFrame.completed) < size(jointFrame,1))
                #println(sum(jointFrame.completed))
            end
        end    
end
CSV.write(dataDir*"/"*"bankRunParametersFin.csv",jointFrame,writeheader=true)