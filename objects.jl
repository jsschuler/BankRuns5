################################################################################
#              Replacement Bank Run Model                                      #
#               (networked)                                                    #
#               June 2022                                                      #
#               John S. Schuler                                                #
#                                                                              #
################################################################################
# we need an agent
mutable struct Agent
    idx::Int64
    deposit::UInt64
    banked::Bool
end

# and a simAgent. They are not
# subTypes of a common agent since they never share a space.

mutable struct simAgent
    idx::UInt64
    deposit::UInt64
    banked::Bool
end

mutable struct Bank
    vault::Int64
    bankingList::Array{Agent}
    withdrawHistory::Array{Agent}
end

mutable struct simBank
    vault::Int64
    depositInsurance::Float64
    withdrawHistory::Array{Agent}
end

mutable struct Model
    agtList::Array{Agent}
    reserveRatio::Float64
    theBank::Bank
    depositInsurance::Float64
    seed::Int64
    depositDistribution::Distribution
    network::Graph
    probThresh::Float64
end

mutable struct simModel
    agtList::Array{simAgent}
    theBank::simBank
end