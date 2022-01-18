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
    niche1 ~ Normal(0,σ)
    niche2 ~ Normal(0,σ)
    niche3 ~ Normal(0,σ)
    niche4 ~ Normal(0,σ)
    niche5 ~ Normal(0,σ)
    niche6 ~ Normal(0,σ)
    niche7 ~ Normal(0,σ)

    center1 ~ Normal(0,σ)
    center2 ~ Normal(0,σ)
    center3 ~ Normal(0,σ)
    center4 ~ Normal(0,σ)
    center5 ~ Normal(0,σ)
    center6 ~ Normal(0,σ)
    center7 ~ Normal(0,σ)

    ex ~ Normal(0,σ)

    
    for i in 1:n
        probs = zeros(3)
        for j in 1:7 
            prob1 = exp((-1)*abs(((niche1*x[i,j])-(center1*x[i,j+7]))/(10/2))^ex)
            prob2 = exp((-1)*abs(((niche2*x[i,j])-(center2*x[i,j+7]))/(10/2))^ex)
            prob3 = exp((-1)*abs(((niche3*x[i,j])-(center3*x[i,j+7]))/(10/2))^ex)
            prob4 = exp((-1)*abs(((niche4*x[i,j])-(center4*x[i,j+7]))/(10/2))^ex)
            prob5 = exp((-1)*abs(((niche5*x[i,j])-(center5*x[i,j+7]))/(10/2))^ex)
            prob6 = exp((-1)*abs(((niche6*x[i,j])-(center6*x[i,j+7]))/(10/2))^ex)
            prob7 = exp((-1)*abs(((niche7*x[i,j])-(center7*x[i,j+7]))/(10/2))^ex)

            probs = prob1, prob2, prob3, prob4, prob5, prob6, prob7
        end 
        to_sample = logistic(0.9999 * prod(probs))
        y[i] ~ Bernoulli(to_sample)
    end 
end;

# attempt simple fit 
sim_stomachs_1000 = readdlm(datadir("./stomach-data/sim_stomachs_1000.csv"),',', Any)

# put data in form it should be in so if I have 10 stomachs, I want a matrix 
# of 10*50, where each observation is a binary and the other value is the 
# prey item's trait value 
trainset = zeros(50000,15)
split_easy = sim_stomachs_1000[:,2:end]

q = 1
for i in 1:size(split_easy,1)
    for j in 1:size(split_easy, 2)
        trainset[q,1] = split_easy[i,j]
        trainset[q,2] = prey_matrix[i,2]
        trainset[q,3] = prey_matrix[i,3]
        trainset[q,4] = prey_matrix[i,4]
        trainset[q,5] = prey_matrix[i,5]
        trainset[q,6] = prey_matrix[i,6]
        trainset[q,7] = prey_matrix[i,7]
        trainset[q,8] = prey_matrix[i,8]

        trainset[q,9] = c_num[1,2]
        trainset[q,10] = c_num[2,2]
        trainset[q,11] = c_num[3,2]
        trainset[q,12] = c_num[4,2]
        trainset[q,13] = c_num[5,2]
        trainset[q,14] = c_num[6,2]
        trainset[q,15] = c_num[7,2]

        q += 1
    end 
end

train = trainset[:,2:end]
train_label = trainset[:,1]


# get n 
n, _ = size(train)

# sample 
iterations = 1000
m = consumption_regression(train, train_label, n, 1)
chain = sample(m, HMC(0.05,10), MCMCThreads(), iterations, 3)

describe(chain)
plot(chain)

using Chain

@chain quantile(chain) begin 
    DataFrame
    select(_,
        :parameters,
        names(_, r"%") .=> ByRow(exp),
        renamecols = false)
end

function logodds2prob(logodds::Float64)
    return exp(logodds) / (1 + exp(logodds))
end

@chain quantile(chain) begin 
    DataFrame 
    select(_,
        :parameters,
        names(_, r"%") .=> ByRow(logodds2prob),
        renamecols = false)
end 


# read in test data 
sim_stomachs_10000 = readdlm(datadir("./stomach-data/sim_stomachs_10000.csv"),',', Any)

testset = zeros(500000,15)
split_easy_test = sim_stomachs_10000[:,2:end]

q = 1
for i in 1:size(split_easy_test,1)
    for j in 1:size(split_easy_test, 2)
        testset[q,1] = split_easy_test[i,j]
        testset[q,2] = prey_matrix[i,2]
        testset[q,3] = prey_matrix[i,3]
        testset[q,4] = prey_matrix[i,4]
        testset[q,5] = prey_matrix[i,5]
        testset[q,6] = prey_matrix[i,6]
        testset[q,7] = prey_matrix[i,7]
        testset[q,8] = prey_matrix[i,8]

        testset[q,9] = c_num[1,2]
        testset[q,10] = c_num[2,2]
        testset[q,11] = c_num[3,2]
        testset[q,12] = c_num[4,2]
        testset[q,13] = c_num[5,2]
        testset[q,14] = c_num[6,2]
        testset[q,15] = c_num[7,2]

        q += 1
    end 
end

test = testset[:,2:end]
test_label = testset[:,1]

function prediction(x::Matrix, chain, threshold)
    
    # pull the means from each parameter's supplied values in the chain 
    niche1 = mean(chain[:niche1])
    niche2 = mean(chain[:niche2])
    niche3 = mean(chain[:niche3])
    niche4 = mean(chain[:niche4])
    niche5 = mean(chain[:niche5])
    niche6 = mean(chain[:niche6])
    niche7 = mean(chain[:niche7])

    center1 = mean(chain[:center1])
    center2 = mean(chain[:center2])
    center3 = mean(chain[:center3])
    center4 = mean(chain[:center4])
    center5 = mean(chain[:center5])
    center6 = mean(chain[:center6])
    center7 = mean(chain[:center7])

    ex = mean(chain[:ex])

    # get number of rows 
    n, _ = size(x)

    # get vector for predictions 
    v = Vector{Float64}(undef, n)

    # calculate the logistic function for each element in the test set 
    for i in 1:n
        probs = zeros(3)
        for j in 1:7 
            prob1 = exp((-1)*abs(((niche1*x[i,j])-(center1*x[i,j+7]))/(10/2))^ex)
            prob2 = exp((-1)*abs(((niche2*x[i,j])-(center2*x[i,j+7]))/(10/2))^ex)
            prob3 = exp((-1)*abs(((niche3*x[i,j])-(center3*x[i,j+7]))/(10/2))^ex)
            prob4 = exp((-1)*abs(((niche4*x[i,j])-(center4*x[i,j+7]))/(10/2))^ex)
            prob5 = exp((-1)*abs(((niche5*x[i,j])-(center5*x[i,j+7]))/(10/2))^ex)
            prob6 = exp((-1)*abs(((niche6*x[i,j])-(center6*x[i,j+7]))/(10/2))^ex)
            prob7 = exp((-1)*abs(((niche7*x[i,j])-(center7*x[i,j+7]))/(10/2))^ex)

            probs = prob1, prob2, prob3, prob4, prob5, prob6, prob7
        end 
        num = logistic(0.9999 * prod(probs))
        if num >= threshold 
            v[i] = 1
        else 
            v[i] =  0
        end 
    end 
    return v 
end; 

threshold = 0.01 

predictions = prediction(test, chain, threshold)

loss = sum((predictions = test_label).^2)/length(test_label)

eaten = sum(test_label)
not_eaten = length(test_label) - eaten

predicted_eaten = sum(test_label .== predictions .== 1)
predicted_not_eaten = sum(test_label .== predictions .== 0)

println("eaten: $eaten
    Predictions: $predicted_eaten
    Percentage eaten correct $(predicted_eaten/eaten)")

println("Not eaten: $not_eaten
    Predictions: $predicted_not_eaten
    Percentage non-eaten correct $(predicted_not_eaten/not_eaten)")