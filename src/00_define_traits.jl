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


# make distributions ===========================================================

# define some set of 7 distributions to draw from for the continuous traits
import Pkg
Pkg.add(["StatsPlots", "Distributions", "Random","StatsBase"])
Pkg.add("StatsBase")
using StatsPlots, Distributions, Random, StatsBase

M = zeros(100000,10)
for i in 1:size(M, 1)
    M[i,1] = rand(TruncatedNormal(0.5, 0.15, 0, 1))
    M[i,2] = rand(TruncatedNormal(0.2, 0.4, 0, 1))
    M[i,3] = rand(TruncatedNormal(0.7, 0.09, 0, 1))
    M[i,4] = rand(Beta(5,2))
    M[i,5] = rand(Beta(1,4))
    M[i,6] = rand(Exponential(0.34))
    M[i,7] = rand(truncated(Exponential(0.6), 0, 1))
    M[i,8] = sample([1,2,3,4,5], Weights([5,5,1,1,3]))
    M[i,9] = sample([1,2], Weights([1,1]))
    M[i,10] = sample([1,2,3,4,5], Weights([1,1,1,10,1]))
end
density(M[:,:])


"""
    draw_sp()
Generate values for all 10 traits for some given possible species and return 
as an array.
"""
function draw_sp()

    trait_array = zeros(10)
    trait_array[1] = rand(TruncatedNormal(0.5, 0.15, 0, 1))
    trait_array[2] = rand(TruncatedNormal(0.2, 0.4, 0, 1))
    trait_array[3] = rand(TruncatedNormal(0.7, 0.09, 0, 1))
    trait_array[4] = rand(Beta(5,2))
    trait_array[5] = rand(Beta(1,4))
    trait_array[6] = rand(Exponential(0.34))
    trait_array[7] = rand(truncated(Exponential(0.6), 0, 1))
    trait_array[8] = sample([1,2,3,4,5], Weights([5,5,1,1,3]))
    trait_array[9] = sample([1,2], Weights([1,1]))
    trait_array[10] = sample([1,2,3,4,5], Weights([1,1,1,10,1]))

    return(trait_array)
end 