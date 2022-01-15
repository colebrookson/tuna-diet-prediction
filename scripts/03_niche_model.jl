########## 
##########
# Niche model specification  
##########
##########
# AUTHOR: Cole B. Brookson
# DATE OF CREATION: 2022-01-07
##########
##########

# set up =======================================================================

include("./00_setup.jl")

using DrWatson
@quickactivate "tuna-diet-prediction"
using Distributions, Random, StatsBase, DelimitedFiles, Plots, Turing

prey_interactions = readdlm(datadir("./trait-data/interaction-strengths.csv"), 
                                    ',', Any)
prey_matrix = readdlm(datadir("./trait-data/prey-matrix.csv"), ',', Any)
c_num = readdlm(datadir("./trait-data/predator-numeric-traits.csv"), ',', Any)

# specify niche model functions ================================================

@model consumption_regression(x, y, n, σ) = begin 

    #priors
    niche ~ Normal(0,σ)
    center ~ Normal(0,σ)
    center ~ Normal(0,σ)
    
    for i in 1:n
        probs = zeros(7)
        for j in 1:7 
            prob = exp((-1)*abs(((niche*x[i,j])-(center*x[i,j+1]))/(10/2))^ex)
            probs[i] = prob
        end 
        to_sample = 0.9999 * product(probs)
        y[i] ~ Bernoulli(to_sample)
    end 
end;

# attempt simple fit 
sim_stomachs_10 = readdlm(datadir("./stomach-data/sim_stomachs_10.csv"),',', Any)

# put data in form it should be in so if I have 10 stomachs, I want a matrix 
# of 10*50, where each observation is a binary and the other value is the 
# prey item's trait value 
trainset = zeros(500,3)
split_easy = sim_stomachs_10[:,2:end]

q = 1
for i in 1:size(split_easy,1)
    for j in 1:size(split_easy, 2)
        trainset[q,1] = split_easy[i,j]
        trainset[q,2] = prey_matrix[i,2]
        trainset[q,3] = c_num[1,2]
        q += 1
    end 
end

train = trainset[:,2:3]
train_label = trainset[:,1]


# get n 
n, _ = size(train)

# sample 
iterations = 1000
m = consumption_regression(train, train_label, n, 1)
chain = sample(m, HMC(0.05,10), MCMCThreads(), iterations, 3)

describe(chain)
plot(chain)


