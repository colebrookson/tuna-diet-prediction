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

using Distributions, StatsBase, Random

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
    trait_array[9] = sample([1,2], Weights([1,1]))
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
x = mu (in this case, mu = 0.5, sd = 0.4)
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
    # now get P_x through ormal probability density function
    P_x_k = round((1/(sqrt(2*pi)*(sd)))*(exp((-0.5)*((x-mu)/sd)^2)), digits = 3)  

    return(P_x_k)


end  


"""
    functional_response(species_list, i, j, response_type)

This function takes in a specific predator (i) and prey (j) and returns the 
result of the functional response for the consumption of j by i which takes the 
form:

F_i(X_j)=frac{a_{ij}X^{q_{ij}}_{j}}{1+sum_{n=0}^{N-1}a_{in}h_{in}X^{q_{in}}_{n}}
Fi(Xj) = a_ij*X^qij / 1 + sum(a_in h_in X^qin)
"""
function functional_response(
    C::Array, 
    j::Int,
    prey_matrix::Matrix,
    prey_abund::Array
    )

    # define predator and prey
    R = prey_matrix[j,:]
    
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


    # get capture rate and capture exponent for focal prey 
    capture_rate = (habitat_overlap(i, j)*
                    size_preference(i,j)*
                    R[nutritional_value_pos])
    if response_type == 2
        capture_exp = 2
    elseif response_type == 3
        capture_exp = 3
    else 
        ArgumentError("response type not valid - only type II or III supported")
    end 

    # get all prey items for the bottom half of the functional response 
    prey_items = get_prey_items(species_list, network, i)
    
    # loop through them and get the capture rate, handling rate, and constant 
    # capture exponent
    denominator_sum = Float64[]
    for q in prey_items
        
        R_temp = get_species(species_list, q)

        capture_rate = (habitat_overlap(i, R_temp[organism_id_pos])*
                        size_preference(i, R_temp[organism_id_pos])*
                        R_temp[nutritional_value_pos])
        handling_time = 1
        capture_exp = response_type 

        F = capture_rate*handling_time*(x[q]^capture_exp)
        append!(denominator_sum, F)

    end 

    F = capture_rate*(x[j]^capture_exp) / (1 + sum(denominator_sum))
    
    return F

end