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
    neighbors=neighbors(mod.network,agt.idx)
    # get the list of agents that are neighbors
    neighborAgents=Agent[]
    for n in neighbors
        push!(neighborAgents,mod.agtList[n])
    end
    return neighborAgents
end

# now the cloning functions
function clone(agt::Agent)
    # clone the agent
    return simAgent(agt.idx,agt.deposit,agt.banked)
end
function cloneBank(theBank::Bank)
    # clone the bank
    return simBank(theBank.vault,theBank.depositInsurance,Agent[])
end
function cloneModel(mod::Model)
    # clone the model
    return simModel(
        [clone(agt) for agt in mod.agtList],
        cloneBank(mod.theBank)
    )
end
# now copy functions to copy the clones
function copy(agt::simAgent)
    # copy the agent
    return simAgent(agt.idx,agt.deposit,agt.banked)
end
function copyBank(theBank::simBank)
    # copy the bank
    return simBank(theBank.vault,theBank.depositInsurance,Agent[])
end
function copyModel(mod::simModel)
    # copy the model
    return simModel(
        [copy(agt) for agt in mod.agtList],
        copyBank(mod.theBank)
    )
end

# we need a function to withdraw exogenously
function exogWithdrawals(mod::Model)

    # get the number of agents that will withdraw
    numWithdrawals=round(Int64,mod.exogProb*length(mod.agtList))
    # get the list of agents that will withdraw
    withdrawList=rand(mod.seed,mod.agtList,numWithdrawals)
    # set the banked status to false
    for agt in withdrawList
        agt.banked=false
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

function withdraw(mod::SimModel,agt::simAgent)
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

function subModelRun(mod::simModel,agt::Agent,additionalWithdrawals::Int64)
    stillBanking=Random.shuffle(mod.theBank.bankingList)
    # now did the current agent withdraw?
    currAgtWithdraw=false
    for i in 1:additionalWithdrawals
        # get the agent to withdraw
        simAgt=stillBanking[i]
        if simAgt.idx==agt.idx
            currAgtWithdraw=true
        end
        # withdraw the agent
        agtReturn=withdraw(mod,agt)
        
    end

end

# now the main model function
function modelRun(mod::Model)
    # set the seed
    Random.seed!(mod.seed)
    # make a copy of the model for each
    exogWithdrawals(mod)
    # now, randomize the order of the agents still banking
    stillBanking=Random.shuffle(mod.theBank.bankingList)
    # each agent observes the percentage of its neighbors that have withdrawn
    for agt in stillBanking
        # get the neighbors of the agent
        neighbors=neighborList(mod,agt)
        # get the number of neighbors that have withdrawn
        numWithdrawn=0
        for n in neighbors
            if !n.banked
                numWithdrawn+=1
            end
        end
        # now calculate the proportion of neighbors that have withdrawn
        propWithdrawn=numWithdrawn/length(neighbors)
        # now calculate the count of agents that have withdrawn if this is a random sample
        totalWithdrawn=round(Int64,propWithdrawn*length(mod.agtList))
        # now calculate additional withdrawals
        additionalWithdrawals=totalWithdrawn-numWithdrawn


    end
    
