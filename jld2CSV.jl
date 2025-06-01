# this code renders the extra columns in the jld2 dataframe readable by R
using StatsBase
using DataFrames
using JLD2
using Dates
using CSV
using Random
using Distributions
using Graphs

dataSource="key123465722025-05-22T18:19:54.319.jld2"
tst= jldopen(dataSource, "r")
jointFrame=tst["jointFrame"]