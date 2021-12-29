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
include(srcdir("00_define_traits.jl"))

# get all species traits =======================================================

# set empty matrix
prey_matrix = zeros(50, 11)

# fill matrix
for i in 1:size(prey_matrix, 1)
    prey_matrix[i, 1] = i 
    prey_matrix[i, 2:end] = draw_sp()
end 
