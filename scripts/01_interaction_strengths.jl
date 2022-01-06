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

using DrWatson
@quickactivate "tuna-diet-prediction"
using Distributions, Random, StatsBase, DelimitedFiles

# get predator interaction strengths with all prey =============================

# read in predator traits 
C_num = readdlm(datadir("./trait_data/predator-numeric-traits.csv"), ',', Any)
C_cat = readdlm(datadir("./trait_data/predator-categorical-traits.csv"), ',', Any)