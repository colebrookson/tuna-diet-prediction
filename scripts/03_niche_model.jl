########## 
##########
# Niche model specification  
##########
##########
# AUTHOR: Cole B. Brookson
# DATE OF CREATION: 2022-01-07
##########
##########

# set up =======================================================================

include("./00_setup.jl")

using DrWatson
@quickactivate "tuna-diet-prediction"
using Distributions, Random, StatsBase, DelimitedFiles, Plots, Turing

prey_interactions = readdlm(datadir("./trait_data/interaction-strengths.csv"), ',', Any)

# specify niche model functions ================================================

@model consumption_regression(x, y, n, σ) = begin 
    intercept ~ Normal(0,σ)
    α ~ Normal(0,σ)
    n ~ Normal(0,σ)
    c ~ Normal(0,σ)
    r ~ Normal(0,σ)

    for i = 1:n
        prob = alpha*exp(-((n-c)/(r/2))^2)
        y[i] ~ Bernoulli(prob)
    end 
end;

