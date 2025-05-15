# initialization functions

function modelInit(seed::Int64,
                   probThresh::Float64,
                   network::SimpleGraph{Int64},
                   depositDistribution::Distribution)
    return Model(Agent[],
        Bank(0,0.0,Agent[],Agent[]),
        0.0,
        seed,
        Normal(0.0,1.0),
        network,
        probThresh
    )
end

function modelGen(seed::Int64,
                  agtCnt::Int64,
                  probThresh::Float64,
                  network::SimpleGraph{Int64},
                  depositDistribution::Distribution,
                  reserveRatio::Float64)
    # generate the model
    mod=modelInit(seed,
                   probThresh,
                   network,
                   depositDistribution)
    # generate the deposits
    deposits=rand(depositDistribution,agtCnt)
    # generate the agents
    for i in 1:agtCnt
        push!(mod.agtList,Agent(i,deposits,true))
    end
    bankingList::Array{Agent}=Agent[]
    for agt in mod.agtList
            push!(bankingList,agt)
    end
    # generate the bank
    theBank=bank(
        reserveRatio*sum(deposits),
        bankingList,
        Agent[]
    )
    mod=Model(
        mod.agtList,
        theBank,
        reserveRatio,
        seed,
        depositDistribution,
        network,
        probThresh
    )
    return mod
end


