################################################################################
#              Replacement Bank Run Model                                      #
#               (networked)                                                    #
#               May 2025                                                       #
#               John S. Schuler                                                #
#               Parameter Sweep Generation Code                                #
################################################################################
using StatsBase
using DataFrames
using JLD2
using Dates
using CSV
##### PARAMETERS ######
# SEED
# AGENT COUNT
# WITHDRAWAL PERIODS :number of periods over which exogenous withdrawals become manifest
# search DEPTH (number or simulation rounds agents run when predicting probability
#       of default)
# RESERVE RATIO
# DEPOSIT DISTRIBUTION OBJECT

# Graph OBJECT
# Types are Watts-Strogatz, Barabasi-Albert, Erdos-Renyi, and complete
# and a vector of the needed parameters for each
# GRAPHS for each graph, a and b in (0,1)



dataDir="../BankRunData"
# how many model initializations to run?
seedRun=10
# and how many times to run each initialization?
runSize=20


#agtCnts=cat(collect(10:10:100),
#            collect(100:100:1000),
#            collect(1000:1000:5000),dims=1)

agtCnts=[1000]
#reserveRatio=collect(.05:.05:.2)
reserveRatio=[.05]
#depositDistributions=Distribution[Pareto(.5,10),Pareto(1.0,10),Pareto(1.5,10),Pareto(2.0,10),Pareto(2.5,10)]
depositDistributions=Distribution[Pareto(.5,10)]
depositInsuranceQuantile=[-.1,0.0,.5]
graphTypes=SimpleGraph{Int64}[newman_watts_strogatz(1000, 10, .2)]

#exogenousProb=Distribution[Binomial(1000,0.1),Binomial(1000,.2),Binomial(1000,.3)]
exogenousProb=Distribution[Binomial(1000,0.1)]
seed1=repeat(sample(1:1000000,seedRun,replace=false),seedRun)
seedIterations=DataFrame(iteration=1:runSize)
seedFrame=DataFrame(seed1=seed1)
depFrame=DataFrame(depositDist=depositDistributions)
graphFrame=DataFrame(network=graphTypes)
exogProbFrame=DataFrame(withdrawRV=exogenousProb)
reserveFrame=DataFrame(reserveRatio=reserveRatio)
depositInsuranceFrame=DataFrame(depositInsuranceQuantile=depositInsuranceQuantile)
jointFrame=crossjoin(seedFrame,seedIterations,depFrame,graphFrame,exogProbFrame,reserveFrame,depositInsuranceFrame)

# now we need to generate the parameters
jointFrame.seed2=sample(1:1000000,size(jointFrame,1),replace=false)
jointFrame.key=string(Dates.now())*"-".*string.(jointFrame.seed1).*"-".*string.(jointFrame.seed2)
jointFrame.started.=false
jointFrame.completed.=false

# subset to 16 rows
jointFrame=jointFrame[1:16,:]