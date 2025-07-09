################################################################################
#              Replacement Bank Run Model                                      #
#               (networked)                                                    #
#               May 2025                                                       #
#               John S. Schuler                                                #
#               Parameter Sweep Generation Code                                #
################################################################################
#using StatsBase
#using DataFrames
#using JLD2
#using Dates
#using CSV
#using Random
#using Distributions
#using Graphs

# we need to sweep for parameters with the following behavior:
# Under the assumption of perfect information, the probability of bank failure is 0. 



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

genSeed=12346572
Random.seed!(genSeed)
@everywhere dataDir="../BankRunData"
# how many model initializations to run?
seedRun=2
# and how many times to run each initialization?
runSize=50


#agtCnts=cat(collect(10:10:100),
#            collect(100:100:1000),
#            collect(1000:1000:5000),dims=1)

agtCnts=[1000]
#reserveRatio=collect(.05:.05:.2)
reserveRatio=[.12,.15,.17,.2]
#depositDistributions=Distribution[Pareto(.5,10),Pareto(1.0,10),Pareto(1.5,10),Pareto(2.0,10),Pareto(2.5,10)]

function paretoGen(alpha)
    return Pareto(alpha,10)
end

function logNormalGen(mu, sigma)
    return LogNormal(mu, sigma)
end

#depositDistributions=paretoGen.(collect(.5:.5:2.5))
#depositDistributions=logNormalGen.([1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0],collect(1:1:10))
depositDistributions=[LogNormal(1.0, 2.0)]
depositInsuranceQuantile=[0.0]
graphParams1=[10,20,50,500,1000]
graphParams2=[.3, .3, .3, .3, 0.0]
graphTypes=SimpleGraph{Int64}[newman_watts_strogatz(1000, 10, .3),newman_watts_strogatz(1000, 20, .3),newman_watts_strogatz(1000, 50, .3),newman_watts_strogatz(1000, 500, .3),newman_watts_strogatz(1000, 999, 0.0)]

#exogenousProb=Distribution[Binomial(1000,0.1),Binomial(1000,.2),Binomial(1000,.3)]
exogenousProb=Distribution[truncated(Geometric(0.1),0,1000)]
seed1=repeat(sample(1:1000000,seedRun,replace=false),seedRun)
seedIterations=DataFrame(iteration=1:runSize)
seedFrame=DataFrame(seed1=seed1)
depFrame=DataFrame(depositDist=depositDistributions)
graphFrame=DataFrame(network=graphTypes,graphParams1=graphParams1,graphParams2=graphParams2)
exogProbFrame=DataFrame(withdrawRV=exogenousProb)
reserveFrame=DataFrame(reserveRatio=reserveRatio)
depositInsuranceFrame=DataFrame(depositInsuranceQuantile=depositInsuranceQuantile)
jointFrame=crossjoin(seedFrame,seedIterations,depFrame,graphFrame,exogProbFrame,reserveFrame,depositInsuranceFrame)

# now we need to generate the parameters
jointFrame.seed2=sample(1:1000000,size(jointFrame,1),replace=false)
jointFrame.key=string(Dates.now())*"-".*string.(jointFrame.seed1).*"-".*string.(jointFrame.seed2)
jointFrame.started.=false
jointFrame.completed.=false
save_object("../BankRunData/key"*string(genSeed)*string(Dates.now())*".jld2", jointFrame)
println(jointFrame)
# subset to 16 rows
#jointFrame=jointFrame[1:30,:]
CSV.write(dataDir*"/"*"bankRunParametersInit.csv",jointFrame,writeheader=true,append=false)
logNormal=DataFrame(params.(jointFrame.depositDist))
rename!(logNormal,:1 => :mu,:2 => :sigma)
CSV.write(dataDir*"/"*"bankRunlogNormal.csv",logNormal,writeheader=true,append=false)
geometric=DataFrame(params.(jointFrame.withdrawRV))
rename!(geometric,:1 => :p,:2 => :s0,:3 => :s1)
CSV.write(dataDir*"/"*"bankRunGeometric.csv",geometric,writeheader=true,append=false)
