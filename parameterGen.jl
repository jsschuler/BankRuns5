################################################################################
#              Replacement Bank Run Model                                      #
#               (networked)                                                    #
#               June 2022                                                      #
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
runSize=100


#agtCnts=cat(collect(10:10:100),
#            collect(100:100:1000),
#            collect(1000:1000:5000),dims=1)

agtCnts=[1000]

reserveRatio=collect(.05:.05:.9)


graphParamA=collect(.05:.1:.95)
graphParamB=collect(.05:.1:.95)
exogP=collect(.05:.05:.5)
depth=[10000]
depsoitDistributions=Distribution[Pareto(.5,10),Pareto(1.0,10),Pareto(1.5,10),Pareto(2.0,10),Pareto(2.5.0,10)]


col17=[]
# take a random sample of a Cartesian join


    for t in 1:seedRun
        push!(col1,sample(agtCnts,1)[1])
        push!(col2,sample(withdrawalPeriods,1)[1])
        push!(col3,sample(reserveRatio,1)[1])
        push!(col4,sample(loP,1)[1])
        push!(col5,sample(hiP,1)[1])
        push!(col6,sample(depositParam,1)[1])
        push!(col7,sample(graphType,1)[1])
        push!(col8,sample(graphParamA,1)[1])
        push!(col9,sample(graphParamB,1)[1])
        push!(col10,sample(exogP,1)[1])
        push!(col11,sample(depth,1)[1])
        push!(col12,sample(["Gamma","Levy"],1)[1])
        push!(col13,sample(.5:.5:20,1)[1])
        push!(col14,sample(.5:.5:20,1)[1])
        push!(col15,sample(0:20,1)[1])
        push!(col16,sample(0:0.15:.9,1)[1])
        push!(col17,sample([true,false],1)[1])
    end

println(length(col1))

currTime=now()

ctrlFrame=DataFrame()
ctrlFrame[!,"dateTime"]=repeat([currTime],runSize*seedRun)
ctrlFrame[!,"seed1"]=repeat(sample(1:(100*runSize*seedRun),seedRun,replace=false),runSize)
ctrlFrame[!,"seed2"]=sample(1:(100*runSize*seedRun),runSize*seedRun,replace=false)
ctrlFrame[!,"key"]=string.(ctrlFrame[!,"dateTime"],":",ctrlFrame[!,"seed1"],":",ctrlFrame[!,"seed2"])
ctrlFrame[!,"agtCnt"]=repeat(col1,runSize)
ctrlFrame[!,"withdrawalPeriods"]=repeat(col2,runSize)
ctrlFrame[!,"reserveRatio"]=repeat(col3,runSize)
ctrlFrame[!,"loP"]=repeat(col4,runSize)
ctrlFrame[!,"hiP"]=repeat(col5,runSize)
ctrlFrame[!,"depositParam"]=repeat(col6,runSize)
ctrlFrame[!,"graphType"]=repeat(col7,runSize)
ctrlFrame[!,"graphParamA"]=repeat(col8,runSize)
ctrlFrame[!,"graphParamB"]=repeat(col9,runSize)
ctrlFrame[!,"exogP"]=repeat(col10,runSize)
ctrlFrame[!,"depth"]=repeat(col11,runSize)
ctrlFrame[!,"distributionType"]=repeat(col12,runSize)
ctrlFrame[!,"distributionParamA"]=repeat(col13,runSize)
ctrlFrame[!,"distributionParamB"]=repeat(col14,runSize)
ctrlFrame[!,"neighborDepth"]=repeat(col15,runSize)
ctrlFrame[!,"depositInsurance"]=repeat(col16,runSize)
ctrlFrame[!,"altInsurance"]=repeat(col17,runSize)
ctrlFrame[!,"complete"]=repeat([false],runSize*seedRun)
#println(ctrlFrame[1:10,:])
ctrlName="runCtrl_"*Dates.format(now(),"yyyymmddHHMMSS")*".jld2"
save_object(ctrlName,ctrlFrame)
CSV.write(dataDir*"/modRun"*ctrlFrame[1,:key]*".csv",ctrlFrame)
# now generate the bash file

sFile="script"*ctrlFrame[1,:key]*".bash"

    open(sFile,"w") do file
        write(sFile,repeat("/opt/julia-1.7.3/bin/julia main000001.jl "*ctrlName*" \n",seedRun*runSize))
end
