########## 
##########
# Set up the prey items and their traits 
##########
##########
# AUTHOR: Cole B. Brookson
# DATE OF CREATION: 2021-12-28
##########
##########

# set up =======================================================================

include("00_setup.jl")

using DrWatson
@quickactivate "tuna-diet-prediction"
using Distributions, Random, StatsBase, DelimitedFiles

include(srcdir("00_trait_functions.jl"))

# get predator interaction strengths with all prey =============================

# read in predator traits 
C_num = readdlm(datadir("./trait_data/predator-numeric-traits.csv"), ',', Any)
C_cat = readdlm(datadir("./trait_data/predator-categorical-traits.csv"), ',', Any)
prey_matrix = readdlm(datadir("./trait_data/prey-matrix.csv"), ',', Any)
prey_abund = fill(1.0, 50)

prey_interactions = zeros(size(prey_matrix, 1),2)
prey_interactions[:,1] = prey_matrix[:,1]

# loop through all prey items and get the interaction strength 
for i in 1:size(prey_interactions, 1)
    prey_interactions[i,2] = functional_response(C_num, 
                                                    C_cat,
                                                    i, 
                                                    prey_matrix,
                                                    prey_abund)
end 

