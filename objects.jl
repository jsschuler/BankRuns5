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
    p::Float64
    banked::Bool
end

# and a simAgent. They are not
# subTypes of a common agent since they never share a space.

mutable struct simAgent
    idx::UInt64
    deposit::UInt64
    p::Float64
    banked::Bool
end

mutable struct Bank
    vault::Int128
end

mutable struct simBank
    vault::Int128
end
