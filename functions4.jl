# initialization functions


function modelGen(seed::Int64,
                  agtCnt::Int64,
                  probThresh::Float64,
                  network::SimpleGraph{Int64},
                  depositDistribution::Distribution,
                  reserveRatio::Float64,
                  depositInsurance::Float64,
                  exogProb::Distribution)
    # generate the deposits
    deposits=rand(depositDistribution,agtCnt)
    # generate the agents
    agtList::Array{Agent}=Agent[]
    for i in 1:agtCnt
        push!(agtList,Agent(i,deposits[i],true))
    end
    bankingList::Array{Agent}=Agent[]

    for agt in agtList
            push!(bankingList,agt)
    end
    # generate the bank
    theBank=Bank(
        reserveRatio*sum(deposits),
        bankingList,
        Agent[]
    )
    mod=Model(
        agtList,
        reserveRatio,
        theBank,
        depositInsurance,
        seed,
        depositDistribution,
        network,
        probThresh,
        exogProb
    )
    return mod
end

function neighborList(mod::Model,agt::Agent)
    # get the neighbors of the agent
    neighbors=all_neighbors(mod.network,agt.idx)
    # get the list of agents that are neighbors
    neighborAgents=Agent[]
    for n in neighbors
        push!(neighborAgents,mod.agtList[n])
    end
    return neighborAgents
end

# now the cloning function
function clone(mod::Model)
    # clone the model
   cloneAgtList::Array{simAgent}=simAgent[]
    for agt in mod.agtList
        push!(cloneAgtList,simAgent(agt.idx,agt.deposit,agt.banked))
    end

    theBank=simBank(
        mod.theBank.vault,
        Agent[],
        Agent[]
    )
    for agt in cloneAgtList
        if agt.banked
            push!(theBank.bankingList,agt)
        else
            push!(theBank.withdrawHistory,agt)
        end
        return simModel(
            cloneAgtList,
            theBank
        )
    end
end

function clone(mod::simModel)
    # clone the model
    cloneAgtList::Array{simAgent}=simAgent[]
    for agt in mod.agtList
        push!(cloneAgtList,simAgent(agt.idx,agt.deposit,agt.banked))
    end

    theBank=simBank(
        mod.theBank.vault,
        Agent[],
        Agent[]
    )
    for agt in cloneAgtList
        if agt.banked
            push!(theBank.bankingList,agt)
        else
            push!(theBank.withdrawHistory,agt)
        end
    end
    return simModel(
        cloneAgtList,
        theBank
    )
end

# we need a function to withdraw exogenously
function exogWithdrawals(mod::Model)

    # get the number of agents that will withdraw
    numWithdrawals=rand(mod.exogProb,1)[1]
    # get the list of agents that will withdraw
    withdrawList=sample(mod.agtList,numWithdrawals,replace=false)
    # set the banked status to false
    for agt in withdrawList
        println("Exogenous Withdrawal Agent ",agt.idx)
        agt.banked=false
        filter!(x->x.idx!=agt.idx,mod.theBank.bankingList)
    end
    for agt in withdrawList
        # add the agent to the withdraw history
        push!(mod.theBank.withdrawHistory,agt)
    end
    return withdrawList
end
# and a function to perform the withdrawal
function withdraw(mod::Model,agt::Agent)
    # withdraw the agent
    agt.banked=false
    # add the agent to the withdraw history
    push!(mod.theBank.withdrawHistory,agt)
    # remove the agent from the banking list
    mod.theBank.bankingList=filter(x->x.idx!=agt.idx,mod.theBank.bankingList)
    # what does the agent get out?
    if agt.deposit>mod.theBank.vault
        agtReturn=max(0.0,mod.theBank.vault)
    else
        agtReturn=agt.deposit
    end
    mod.theBank.vault-=agt.deposit
    return agtReturn
    # update the bank vault
    mod.theBank.vault-=agt.deposit
end

function withdraw(mod::simModel,agt::simAgent)
    # withdraw the agent
    agt.banked=false
    # add the agent to the withdraw history
    push!(mod.theBank.withdrawHistory,agt)
    # remove the agent from the banking list
    mod.theBank.bankingList=filter(x->x.idx!=agt.idx,mod.theBank.bankingList)
    # what does the agent get out?
    if agt.deposit>mod.theBank.vault
        agtReturn=max(0.0,mod.theBank.vault)
    else
        agtReturn=agt.deposit
    end
    mod.theBank.vault-=agt.deposit
    # update the bank vault
    return agtReturn
end

function index(agt::Agent)
    return agt.idx
end
function index(agt::simAgent)
    return agt.idx
end

function subModelRun(mod::simModel,agt::Agent,withdrawingAgents::Array{Agent},additionalWithdrawals::Int64)
    # now, we debank the sim version of those neightbors
    for idx in index.(withdrawingAgents)
        # get the agent
        agt=mod.agtList[idx]
        # withdraw the agent
        agtReturn=withdraw(mod,agt)
    end
    stillBanking=Random.shuffle(mod.theBank.bankingList)
    # now, we remove the number of additional withdrawing agents from the sub model.
    # if the current agent is among them, we skip it. 
    numWithdrawn::Int64=0
    #println(additionalWithdrawals)
    while numWithdrawn<additionalWithdrawals && numWithdrawn > 0
        if stillBanking[numWithdrawn].idx!=agt.idx
            withdraw(mod,stillBanking[numWithdrawn])
            numWithdrawn+=1
        end
    end
    # now, the agent withdraws from the bank
    #println("Chk")
    #println(agt in mod.agtList
    currAgt=filter(x->x.idx==agt.idx,mod.agtList)[1]
    result=withdraw(mod,currAgt)
    #println("Agent Deposit was ",agt.deposit)
    #println("Result: ",result)
    return (result,result < agt.deposit)
end

# now the main model function
function modelRun(mod::Model)
    runState::Bool=false
    # set the seed
    Random.seed!(mod.seed)
    # make a copy of the model
    simModel=clone(mod)


    exogWithdrawals(mod)
    # now, randomize the order of the agents still banking
    stillBanking=Random.shuffle(mod.theBank.bankingList)
    # each agent observes the percentage of its neighbors that have withdrawn
    for agt in stillBanking
        #println("Running Agent ",agt.idx)
        # get the neighbors of the agent
        neighbors=neighborList(mod,agt)
        withdrawnNeighbors::Array{Agent}=Agent[]
        for n in neighbors
            if !n.banked
                push!(withdrawnNeighbors,n)
            end
        end
        # now calculate the proportion of neighbors that have withdrawn
        propWithdrawn=length(withdrawnNeighbors)/length(neighbors)
        # now calculate the count of agents that have withdrawn if this is a random sample
        totalWithdrawn=round(Int64,propWithdrawn*length(mod.agtList))
        # now calculate additional withdrawals
        additionalWithdrawals=totalWithdrawn-length(withdrawnNeighbors)
        # Now, run many versions of the sub-model where the neighbors and random k other agents withdraw
        subModResults=[]
        global depth
        #println("Simulating for agent ",agt.idx)
        for k in 1:depth
            #println("Simulating for agent ",agt.idx)
            push!(subModResults,subModelRun((clone(simModel),agt,withdrawnNeighbors,additionalWithdrawals)...))
        end
        # now, have the agent calculate its probability of getting less than its deposit
        results::Array{Bool}=Bool[]
        for el in subModResults
            push!(results,el[2])
        end
        # now calculate the probability of getting less than its deposit
        probLessThanDeposit=mean(results)
        # now if the probability is greater than the threshold, withdraw
        if probLessThanDeposit>mod.probThresh
            println("Endogenous Withdawal Agent ",agt.idx," at p=",probLessThanDeposit, " where deposit was ",agt.deposit," and vault was ",mod.theBank.vault)
            withdraw(mod,agt)
        end

        if mod.theBank.vault<=0.0
            # if the bank is bankrupt, we need to stop the simulation
            runState=true
            break
        end
    #readline()    
    end
    return runState
end
