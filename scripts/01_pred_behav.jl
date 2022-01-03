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

# decide predator trait values =================================================

######## BEGIN NOTE #########
# predator will have a range of prey trait values it can eat, and an optimal 
# value, all given by a normal distribution. For each trait, I define that 
# distribution randomly, have it bounded [0,1]. The limits are set by 
# randomizing some amount away from 0 and 1 that the distribution is 
# limited to and then putting the mean in the middle
######## END NOTE #########

C_object = zeros(7, 3)

for i in 1:7
    # for each trait draw from a distribution to get the values 
    lower = (0 + rand(Uniform(0,0.4)))
    upper = (1.0 - rand(Uniform(0,0.4)))
    mean = (upper-lower)*0.5
    
    C_object[i, :] = [lower, mean, upper]
end 

# write out the C_object 
writedlm(datadir("./pred_data/predator-traits.csv"), C_object, ",")