################################################################################
#              Replacement Bank Run Model                                      #
#               (networked)                                                    #
#               June 2022                                                      #
#               John S. Schuler                                                #
#                                                                              #
################################################################################
# we begin with functions to write out to csvs
function modWrite(term::Bool)
    # writes out model key and all parameters needed for reproduction
    # writes out initialization and termination
    # save the log object
    global ctrlFile
    global key
    global ctrlFrame
    global notFail
    if term
        df=DataFrame(KeyCol=[key],
                  DateTime=[Dates.format(now(),"yyyymmddHHMMSS")],
                  Failure=[!notFail],
                  Finish=[true]
                  )
                  currIndex=nrow(ctrlFrame)-nrow(ctrlFrame[ctrlFrame[:,"complete"].==false,:])+1
                  #println("File")
                  #println(ctrlFrame[currIndex,:complete])
                  ctrlFrame[currIndex,:complete]=true
                  #println(ctrlFrame[currIndex,:complete])
                  save_object(ctrlFile,ctrlFrame)


    else
        df=DataFrame(KeyCol=[key],
                  DateTime=[Dates.format(now(),"yyyymmddHHMMSS")],
                  Failure=[false],
                  Finish=[false])
    end
    #CSV.write("Data4/modelRun"*key*".csv", df,header = false,append=true)
end

function agtWrite(agt)
    # writes out an agent table
    global key
    global dataDir
    df=DataFrame(KeyCol=[key],
            idx=[agt.idx],
                    deposit=[agt.deposit],
                    p=[agt.p]
            )


    CSV.write(dataDir*"/agents"*key*".csv", df ,header = false,append=true)
end

function withdrawWrite(agt::Agent,exogenous::Bool,t::Int64,tCnt::Int64,result::Bool)
    global key
    global dataDir
    df=DataFrame(KeyCol=[key],
            tCol=[t],
            tCntCol=[tCnt],
            exog=[exogenous],
            deposit=[agt.deposit],
            res=[result]
            )


    CSV.write(dataDir*"/withdrawals"*key*".csv", df ,header = false,append=true)

end

function decisionWrite(agt::Agent,pval::Float64,decide::Bool,t::Int64,tCnt::Int64)
    global key
    global dataDir
    df=DataFrame(
    KeyCol=[key],
    tcol=[t],
    tCntCol=[tCnt],
    agtCol=[agt.idx],
    pVal=[pval],
    agtP=[agt.p],
    decidCol=[decide]
    )

    CSV.write(dataDir*"/decisions"*key*".csv", df ,header = false,append=true)

end

function withdrawWrite(agt::simAgent)

end

function graphWrite()
    global key
    global theGraph
    global dataDir
    save_object(dataDir*"/graph"*key*".jld2",theGraph)
    vertexCnt=nv(theGraph)
    adjMat=zeros(Int16,vertexCnt,vertexCnt)

    for edge in edges(theGraph)
        adjMat[src(edge),dst(edge)]=1
        adjMat[dst(edge),src(edge)]=1
    end
    # now convert the matrix to a string
    df=DataFrame(adjMat,:auto)
    df[!,:key].=key
    CSV.write(dataDir*"/graphs"*key*".csv", df ,header = true,append=false)
end

# we need functions to track cloning of agents and the agent who clones them
function cloneWrite(perspectiveAgt::Agent,clonedAgt::Agent)

end
# same for the bank
function cloneWrite(perspectiveAgt::Agent,theBank::Bank)

end

# sampler for the deposit distribution
function distGen()
    x=rand(dist)[1]
    return floor(Int64,x)
end
# sample for the threshold probability distribution for agents
function probGen()
    x=rand(probGenR)[1]
    return x
end
# function to generate the agents according to the parameters
function agtGen()
    global agtTicker
    #agtTicker=agtTicker+1
    dep=distGen()
    dep::Int64
    p=probGen()
    p::Float64
    currAgt=Agent(0,dep,p,true)
    currAgt::Agent
    push!(agtList,currAgt)
end
# we need another agent generation function for agents to use for the initial decision
# function to generate the agents according to the parameters
function agtGen(agt::Agent)
    dep=distGen()
    dep::Int64
    p=probGen()
    p::Float64
    currAgt::simAgent=simAgent(agtTicker,dep,p,true)
    return currAgt
end



# function to generate the graph
function graphGen()
    global graphParams
    global graphType
    global agtList 
    #println("Check")
    #println(agtCnt)
    #println(floor(Int64,graphParams[1]*agtCnt))
    #println(floor(Int64,graphParams[2]*agtCnt))
    if graphType=="Bara"
        #mn=min(floor(Int64,graphParams[1]*agtCnt),floor(Int64,graphParams[2]*agtCnt))
        #mx=max(floor(Int64,graphParams[1]*agtCnt),floor(Int64,graphParams[2]*agtCnt))
        lowerParam=minimum(graphParams)
        upperParam=maximum(graphParams)
        graph=barabasi_albert(agtCnt, floor(Int64,upperParam*agtCnt),floor(Int64,lowerParam*agtCnt))
    elseif graphType=="Watts"
        graph=watts_strogatz(agtCnt, floor(Int64,graphParams[1]*agtCnt), graphParams[2])
    elseif graphType=="Erdos"
        graph=erdos_renyi(agtCnt, floor(Int64,graphParams[1]*agtCnt))
    else
        graph=complete_graph(length(agtList))
    end
    return graph
end
# this function takes an agents index and returns the agent
function agtByNumber(k::Int64)
    return agtList[k]
end

# return an agent's graph neighbors
function neighbors(agt::Agent)
    global theGraph
    numNeighbors=all_neighbors(theGraph, agt.idx)
    neighborList=Agent[]
    for num in numNeighbors
        push!(neighborList,agtByNumber(num))
    end
    return neighborList
end

# these functions clone objects. They only exist within functions belonging to
# an agent. They are so agents can run simulations
function clone(agt::Agent)
    return(simAgent(agt.idx,agt.deposit,agt.p,agt.banked))
end

function clone(theBank::Bank)
    return(simBank(theBank.vault))
end
# this function generates the bank object
function bankGen()
    global agtList
    global reserveRatio
    totDeposit=0
    totDeposit::Int64
    for agt in agtList
        totDeposit=totDeposit+agt.deposit
    end
    return(Bank(floor(Int64,reserveRatio*totDeposit)))
end
# we need a function that returns the banked agents in a random order
function bankedAgts()
    stillBankers=Agent[]
    for agt in agtList
        if agt.banked
            push!(stillBankers,agt)
        end
    end
return(sample(stillBankers,length(stillBankers),replace=false))
end


# now, we need a function that generates a schedule for when agents exogenously
# withdraw. This depends on the withdrawal periods parameter.
# the idea is that not all agents see the other agents withdrawing at once.
function exogWithdraw()
    global exogDist
    global withdrawPeriods
    global agtCnt
    unif=DiscreteUniform(1,withdrawPeriods)
    # how many agents withdraw?
    withdrawals=min(rand(exogDist,1)[1],agtCnt)
    withdrawals::Int64
    #println("Agents withdrawing")
    #println(withdrawals)
    agtWithdawals=sample(agtList,withdrawals)
    # now schedule them
    schedule=Array{Array{Agent}}(undef,withdrawPeriods)
    for t in 1:withdrawPeriods
        schedule[t]=Agent[]
    end
    for agt in agtWithdawals
        loc=rand(unif,1)[1]
        loc::Int64
        #println("Debug")
        #println(schedule)
        #println(loc)
        #println(schedule[loc])
        push!(schedule[loc],agt)
    end
    return schedule
end
# as well as a function that performs the withdrawal and logs it
# this function also returns the status of the bank.
# the value is true if the bank has NOT failed
function withdraw(agt::Agent,exog::Bool,t::Int64,tCnt::Int64)
    global theBank
    # does the bank have enough to cover the deposit?
    if theBank.vault >= agt.deposit
        theBank.vault=theBank.vault-agt.deposit
        result=true
        result::Bool
    else
        #println("Oops")
        theBank.vault=0
        result=false
        result::Bool
    end
    agt.banked=false
    withdrawWrite(agt,exog,t,tCnt,result)
    return result
end

# this is the same function for the agent's simulated bank.
# it does not need an agent argument because each agent
# creates its own simulated bank.
function withdraw(agt::simAgent,theBank::simBank)
    # does the bank have enough to cover the deposit?
    if theBank.vault >= agt.deposit
        theBank.vault=theBank.vault-agt.deposit
        result=true
        result::Bool
    else
        theBank.vault=0
        result=false
        result::Bool
    end
    agt.banked=false
    withdrawWrite(agt)
    return result
end

# this function generates a simulator from the perspective of a given agent.
# it runs this simulation in parallel for speed.
function agtSimulate(agt::Agent)
    # we need to generate an agent specific function to run many times in parallel
    myNeighbors=neighbors(agt)
    myNeighbors::Array{Agent}
    bailedNeighbors=Agent[]
    bailedNeighbors::Array{Agent}
    for nbh in myNeighbors
        if !nbh.banked
            push!(bailedNeighbors,nbh)
        end
    end
    # and what neighbors did not bail?
    stayNeighbors=setdiff(myNeighbors,bailedNeighbors)
    stayNeighbors::Array{Agent}
    # now, what percentage of neighbors bailed?
    if length(myNeighbors) > 1
        outPct=length(bailedNeighbors)/length(myNeighbors)
    else
        outPct=0
    end

    # now we need an array of all non-neighbors still banking
    nonNeighbors=setdiff(agtList,myNeighbors)
    # now, how many agents are assumed to have already withdrawn?
    #println(outPct)
    #println(length(nonNeighbors))
    #println(length(stayNeighbors))
    wdCnt=floor(Int64,outPct*(length(nonNeighbors)+length(stayNeighbors)))
    function withDrawSimul(k::Int64)
        # clone the bank
        simBank=clone(theBank)
        potentialBails=simAgent[]
        potentialBails::Array{simAgent}
        for nonNbh in nonNeighbors
            push!(potentialBails,clone(nonNbh))
        end
        for sNbh in stayNeighbors
            push!(potentialBails,clone(sNbh))
        end
        # now, how many more agents might withdraw?
        addWithdraw=rand(exogDist,1)[1]
        addWithdraw::Int64
        # now, sample from the remaining agents
        #println("Now Withdrawing")
        #println(wdCnt+addWithdraw)
        simWithdrawal=sample(potentialBails,min(wdCnt+addWithdraw,length(potentialBails)),replace=false)
        simWithdrawal::Array{simAgent}
        failure=false
        failure::Bool
        for sim in simWithdrawal
            status=!withdraw(sim,simBank)
            status::Bool
            if status
                failure=true
                break
            end
        end
    return failure
    end
    # now that we have defined the function for a single
    # simulation round, run many in parallel
    # debug this function first
    #println(withDrawSimul(1))

    global depth
    dummy=repeat(Int64[1],depth)
    out=Folds.map(withDrawSimul,dummy)
    return(mean(out))
end
# this is the decision function. if
# the agent decides to withdraw, it returns TRUE
function decision(agt::Agent,t::Int64,tCnt::Int64)
    simulP=agtSimulate(agt)
    simulP::Float64
    #println("Decision")
    #println(agt.p)
    #println(simulP)
    if agt.p >= simulP
        decisionWrite(agt,simulP,false,t,tCnt)
        return false
    else
        decisionWrite(agt,simulP,true,t,tCnt)
        return true
    end
end

# now, we need a similar function that is based on not the particular agents that exist but on 
# their probability distribution. 
# Thus, there is no local global distinction and agents decide whether or not to bank. 

function initSimulate(agt::Agent,pct::Float64)
    function withDrawSimul(k::Int64)
        # the percent of agents who bank is a parameter so we 
        # can use fixed point iteration to find what percentage 
        # results in the same percentage of agents banking
        agtBank=simBank(Int128(0))
        global agtCnt
        bankCount::Int64=round(Int64,pct*agtCnt)
        simuAgents=simAgent[]
        for i in 1:bankCount
            push!(simuAgents,agtGen(agt))
        end
        for sAgt in simuAgents
            agtBank.vault=agtBank.vault+round(Int128,reserveRatio*sAgt.deposit)
        end

        agtWithdraw=rand(exogDist,1)[1]
        simWithdrawal::Array{simAgent}=sample(simuAgents,min(agtWithdraw,length(simuAgents)),replace=false)
        failure::Bool=false
        for sim in simWithdrawal
            status=!withdraw(sim,agtBank)
            status::Bool
            if status
                failure=true
                break
            end
        end
    return failure
    end
    # now that we have defined the function for a single
    # simulation round, run many in parallel
    # debug this function first
    #println(withDrawSimul(1))

    global depth
    dummy=repeat(Int64[1],depth)
    out=Folds.map(withDrawSimul,dummy)
    return(mean(out))
end