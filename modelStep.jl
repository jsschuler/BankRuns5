# first, read a row from the parameter file

# then set up the model
mod=modelGen(sample(1:1000000,1)[1],
             1000,
             .05,
             newman_watts_strogatz(1000, 10, .2),
             Pareto(1.0,10),
             .15,
             0.0,
             Binomial(1000,.2))

# then run the model
rMod=modelRun(mod)
println(rMod)
println(mod.theBank.vault)


# indicate it is finished with a symbol
:complete