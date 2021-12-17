########## 
##########
# Definition of functions used to create prey traits
##########
##########
# AUTHOR: Cole B. Brookson
# DATE OF CREATION: 2021-12-16
##########
##########

# set up =======================================================================
using DrWatson
@quickactivate "tuna-diet-prediction"

# define some set of 7 distributions to draw from for the continuous traits
import Pkg
Pkg.add(["StatsPlots", "Distributions"])
using StatsPlots, Distributions

M = randn(1000,4)
M[:,2] .+= 0.8sqrt.(abs.(M[:,1])) .- 0.5M[:,3] .+ 5
M[:,3] .-= 0.7M[:,1].^2 .+ 2
corrplot(M, label = ["x$i" for i=1:4])