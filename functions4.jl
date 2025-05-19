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
                  reserveRatio::Float64,
                  depositInsurance::Float64,
                  exogProb::Float64)
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
        probThresh
    )
    return mod
end

