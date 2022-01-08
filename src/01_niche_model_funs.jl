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

# specify niche model functions ================================================

"""
    niche_position(d, j, prey_matrix)

Take in the dimension (trait number 1-10) and the prey identifier, and return 
the trait value for that prey item (i.e. it's niche position)
"""
function niche_position(
    d::int, # the dimension of the trait 
    j::int, # prey species 
    prey_matrix::Array # the array of all prey traits 
    )

    return(prey_matrix[j,d+1])

end 

"""
"""
function optimal_feeding_pos(
    d::int, # the dimension of the trait 
    C_num::Array, # the array of numeric predator values 
    C_cat::Array # array of categorical predator values 
    )

end 


function niche_model(
    alpha::
)


# tests 
C_num = readdlm(datadir("./trait_data/predator-numeric-traits.csv"), ',', Any)
C_cat = readdlm(datadir("./trait_data/predator-categorical-traits.csv"), ',', Any)
prey_matrix = readdlm(datadir("./trait_data/prey-matrix.csv"), ',', Any)
prey_abund = fill(1.0, 50)