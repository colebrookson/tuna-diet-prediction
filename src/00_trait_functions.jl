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
using Distributions



# make distributions ===========================================================

# define some set of 7 distributions to draw from for the continuous traits
#import Pkg
#Pkg.add(["StatsPlots", "Distributions", "Random","StatsBase"])
#Pkg.add("StatsBase")
#using StatsPlots, Distributions, Random, StatsBase

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
    trait_array[6] = rand(truncated(Exponential(0.34), 0, 1))
    trait_array[7] = rand(truncated(Exponential(0.6), 0, 1))
    trait_array[8] = sample([1,2,3,4,5], Weights([5,5,1,1,3]))
    trait_array[9] = sample([1,2], Weights([1,1]))
    trait_array[10] = sample([1,2,3,4,5], Weights([1,1,1,10,1]))

    return(trait_array)
end 

"""
    trait_preference(i::Int, j::Int)

This function takes in two species i (consumer) and j (resource) and determines 
the trait-based preference. The idea here is to represent the predators 
consumption as a normal distribution, where f(X) = 1 when x = mu, and then scale 
the values of the actual predator max/min to the 0.01 and 0.99 interval, and 
then take the values and scale them to a distribution that gives f(X) ~= 1 when 
x = mu (in this case, mu = 0.5, sd = 0.4)
"""
function trait_preference(
    i::Array, 
    j::Int,
    prey_matrix::Matrix
    )

    # define the consumer & resource
    C = i
    R = prey_matrix[j]

    # for each trait, set the predator's distribution of preference 

    # get the means and sd's for each distribution above
    mus = [0.5, 0.2, 0.7, ((5)/(5+2)), ((1)/(1+4)), 
        mean(rand(truncated(Exponential(0.34), 0,1),10000)), 
        mean(rand(truncated(Exponential(0.6), 0,1),10000))]
    sds = [0.15, 0.4, 0.09, sqrt((5*2)/(((5+2)^2)*(5+2+1))), 
        sqrt((5*2)/(((5+2)^2)*(5+2+1))),
        sqrt((1*4)/(((1+4)^2)*(1+4+1))),
        std(rand(truncated(Exponential(0.34), 0,1),10000)),
        std(rand(truncated(Exponential(0.6), 0,1),10000))]
    
    # deal with the numeric traits first 
    for k in (size(prey_matrix, 2)-3)
        # limits are set by randomizing some amount away from zero and one that
        # the distribution is limited to and then putting the mean in the middle
        C_limits = [0 + rand(Uniform(0,0.3)), 1.0 - rand(Uniform(0,0.3))]
        C_mean = (C_limits[2]-C_limits[1])*0.5
        # get the value of the trait that sp R has 
        R_trait = R[k]
        # set standard deviation for the consumer distribution  
        sd_C = (C_limits[2] - C_mean)/3
        # get the mean and s.d. from the distributions of each trait 
        mu = mus[k]
        sd = sds[k]
        # get the y value by getting the value away from the C_mean 
        if R_trait == C_mean
            y = mu 
        elseif R_trait > C_mean
            y = (R_trait - C_mean)/sd_C
        else 
            y = abs(R_trait - C_mean)/sd_C
        end 
        # now get x 
        x = mu + y*0.4
        # now get P_x through ormal probability density function
        P_x = round((1/(sqrt(2*pi)*(sd)))*(exp((-0.5)*((x-mu)/sd)^2)), digits = 3)  

    return P_x
end
end  