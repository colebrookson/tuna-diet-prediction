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
using Distributions, Random, StatsBase, DelimitedFiles, Plots

include(srcdir("00_trait_functions.jl"))

# get predator interaction strengths with all prey =============================

# read in predator traits 
C_num = readdlm(datadir("./trait-data/predator-numeric-traits.csv"), ',', Any)
C_cat = readdlm(datadir("./trait-data/predator-categorical-traits.csv"), ',',
                         Any)
prey_matrix = readdlm(datadir("./trait-data/prey-matrix.csv"), ',', Any)
prey_abund = fill(1.0, 50)

prey_interactions = zeros(size(prey_matrix, 1),3)
prey_interactions[:,1] = prey_matrix[:,1]

# loop through all prey items and get the interaction strength 
for i in 1:size(prey_interactions, 1)
    prey_interactions[i,2] = functional_response(C_num, 
                                                    C_cat,
                                                    i, 
                                                    prey_matrix,
                                                    prey_abund)
end 
# add normalized version
for i in 1:size(prey_interactions, 1)
    prey_interactions[i,3] = 
        (prey_interactions[i,2] - 
        minimum(prey_interactions[:,2]))/(maximum(prey_interactions[:,2]) - 
            minimum(prey_interactions[:,2]))   
end 

writedlm(datadir("./trait-data/interaction-strengths.csv"), 
                prey_interactions, ",")

# make fake data of stomachs ===================================================

# 10 stomachs 
sim_stomachs_10 = zeros(size(prey_matrix, 1), 11)
sim_stomachs_10[:,1] = prey_matrix[:,1]
for i in 1:size(sim_stomachs_10, 1)
    for j in 2:size(sim_stomachs_10, 2) 
        sim_stomachs_10[i,j] = sample([0,1],
                                    Weights([1-prey_interactions[i,3], 
                                                prey_interactions[i,3]]))
    end 
end 

# 100 stomachs
sim_stomachs_100 = zeros(size(prey_matrix, 1), 101)
sim_stomachs_100[:,1] = prey_matrix[:,1]
for i in 1:size(sim_stomachs_100, 1)
    for j in 2:size(sim_stomachs_100, 2) 
        sim_stomachs_100[i,j] = sample([0,1],
                                    Weights([1-prey_interactions[i,3], 
                                                prey_interactions[i,3]]))
    end 
end

# 1000 stomachs 
sim_stomachs_1000 = zeros(size(prey_matrix, 1), 1001)
sim_stomachs_1000[:,1] = prey_matrix[:,1]
for i in 1:size(sim_stomachs_1000, 1)
    for j in 2:size(sim_stomachs_1000, 2) 
        sim_stomachs_1000[i,j] = sample([0,1],
                                    Weights([1-prey_interactions[i,3], 
                                                prey_interactions[i,3]]))
    end 
end

# 10000 stomachs 
sim_stomachs_10000 = zeros(size(prey_matrix, 1), 10001)
sim_stomachs_10000[:,1] = prey_matrix[:,1]
for i in 1:size(sim_stomachs_10000, 1)
    for j in 2:size(sim_stomachs_10000, 2) 
        sim_stomachs_10000[i,j] = sample([0,1],
                                    Weights([1-prey_interactions[i,3], 
                                                prey_interactions[i,3]]))
    end 
end

# write out data 
writedlm(datadir("./stomach-data/sim_stomachs_10.csv"), 
                    sim_stomachs_10, ",")
writedlm(datadir("./stomach-data/sim_stomachs_100.csv"), 
                    sim_stomachs_100, ",")
writedlm(datadir("./stomach-data/sim_stomachs_1000.csv"), 
                    sim_stomachs_1000, ",")
writedlm(datadir("./stomach-data/sim_stomachs_10000.csv"), 
                    sim_stomachs_10000, ",")
