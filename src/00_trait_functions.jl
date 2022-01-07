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

using Distributions, StatsBase, Random, DelimitedFiles

# predator position values
lower = 1
avg = 2
upper = 3

# make distributions ===========================================================

# define some set of 7 distributions to draw from for the continuous traits

# set random seed 

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
    trait_array[9] = sample([1,2,3,4,5], Weights([1,1,1,1,1]))
    trait_array[10] = sample([1,2,3,4,5], Weights([1,1,1,10,1]))

    return(trait_array)
end 

"""
    numeric_trait_preference(
        i::Int, 
        j::Int, 
        k::Int,
        prey_matrix::Matrix)

This function takes in two species i (consumer) and j (resource) and determines 
the trait-based preference. The idea here is to represent the predators 
consumption as a normal distribution, where f(X) = 1 when x = mu, and then scale 
the values of the actual predator max/min to the 0.01 and 0.99 interval, and 
then take the values and scale them to a distribution that gives f(X) ~= 1 when 
x = mu
"""
function numeric_trait_preference(
    C::Array, 
    j::Int, # the prey item number 
    k::Int, # the trait number 
    prey_matrix::Matrix
    )

    # define the consumer & resource
    R = prey_matrix[j,:]
    
    # get the value of the trait that sp R has 
    R_trait = R[k]
    # set standard deviation for the consumer distribution  
    sd_C = (C[k,upper] - C[k,avg])/3
    # get the mean and s.d. from the distributions of each trait 
    mus = [0.5, 0.2, 0.7, ((5)/(5+2)), ((1)/(1+4)), 
            mean(rand(truncated(Exponential(0.34), 0,1),10000)), 
            mean(rand(truncated(Exponential(0.6), 0,1),10000))]
    sds = [0.15, 0.4, 0.09, sqrt((5*2)/(((5+2)^2)*(5+2+1))), 
            sqrt((1*4)/(((1+4)^2)*(1+4+1))),
            std(rand(truncated(Exponential(0.34), 0,1),10000)),
            std(rand(truncated(Exponential(0.6), 0,1),10000))]

    mu = mus[k]
    sd = sds[k]
    # get the y value by getting the value away from the C_mean 
    if R_trait == C[k,avg]
        y = mu 
    elseif R_trait > C[k,avg]
        y = (R_trait - C[k,avg])/sd_C
    else 
        y = abs(R_trait - C[k,avg])/sd_C
    end 
    # now get x 
    x = mu + y*0.4

    # now get P_x through normal probability density function
    P_x_k = round((1/(sqrt(2*pi)*(sd)))*(exp((-0.5)*((x-mu)/sd)^2)), digits = 3)  

    ########## BEGIN NOTE ##########
    # So because the values of the PDF will be > 1 with particular mu and sd 
    # values, we need to scale it to a maximum of one. To do this, after 
    # calculating P_x_k, I will then calculate the value again but using the 
    # actual mean and sd of that distribution for the x and y values, then just 
    # divide by the value so it scales to one 
    ########## END NOTE ##########
    x = mu

    max_P_x_k = round((1/(sqrt(2*pi)*(sd)))*(exp((-0.5)*((x-mu)/sd)^2)), 
                        digits = 3)  

    # return the scaled value (i.e. divided by the max value )
    return(P_x_k/max_P_x_k)

end  

"""
    functional_response(C_num, C_cat, i, prey_matrix, prey_abund)

This function takes in a specific predator (i) and prey (j) and returns the 
result of the functional response for the consumption of j by i which takes the 
form:

F_i = frac{a_{ic}p_i}{1 + tau_c sum_j a_{jc}p_j}
"""
function functional_response(
    C_num::Array, 
    C_cat::Array,
    i::Int,
    prey_matrix::Matrix,
    prey_abund::Array
    )

    # define predator and prey
    R = prey_matrix[i,:]

    # make empty array for the preferences 
    pref = []
    # do the numeric preferences first
    for k in 1:7
        append!(pref, numeric_trait_preference(C_num, i, k, prey_matrix))
    end 
    # now do the categorical preferences 
    for k in 1:3 # go through the three categorical traits 
        for q in 1:5 # for each of the 5 trait options 
            if C_cat[k,q] == R[k+7] # check if the prey trait is one 
                                      # the predator can actually consume 
                # if the prey trait is one the predator can consume then give 
                # the value of 1.0 divided by the number of categories of that 
                # trait the predator can actually consume (i.e. the predator 
                # will prefer a prey trait that it can only consume versus one 
                # it can consume other options of)
                append!(pref, (1.0/sum(C_cat[k,:]))) 
            else 
                # if the prey trait isn't one the predator can consume, give 0.0
                append!(pref, 0.0) 
            end
        end 
    end 

    a_ic = sum(pref) # sum pref to get the preference for a single prey item 
    p_i = prey_abund[i] # get the abundance of focal prey item 
    a_ic_p_i = a_ic * p_i # get numerator of the functional response 

    # create sum of the denominator 
    denominator_sum = []
    for j in 1:size(prey_matrix, 1)
        pref_sum = []
        for k in 1:7
            append!(pref_sum, 
                    numeric_trait_preference(C_num, j, k, prey_matrix))
        end 
        append!(denominator_sum, (sum(pref_sum)*prey_abund[i]))
    end

    Fi = a_ic_p_i/(1 + 0.5*sum(denominator_sum))
    
    return(Fi)
end
