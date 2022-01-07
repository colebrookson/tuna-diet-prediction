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

include("00_setup.jl")

using DrWatson
@quickactivate "tuna-diet-prediction"
using Distributions, Random, StatsBase, DelimitedFiles, Plots

prey_interactions = readdlm(datadir("./trait_data/interaction-strengths.csv"), ',', Any)

# specify niche model functions ================================================

