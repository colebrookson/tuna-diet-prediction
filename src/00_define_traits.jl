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

# define some set of 7 distributions to draw from for the continuous traits
import Pkg
Pkg.add(["StatsPlots", "Distributions"])
using StatsPlots, Distributions
plot(Geometric(0.6))