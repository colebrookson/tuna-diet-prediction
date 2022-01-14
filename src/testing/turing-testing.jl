using Turing
using LazyArrays
using Random:seed!
seed!(123)

@model logreg(X,  y; predictors=size(X, 2)) = begin
    #priors
    α ~ Normal(0, 2.5)
    β ~ filldist(TDist(3), predictors)

    #likelihood
    y ~ arraydist(LazyArray(@~ BernoulliLogit.(α .+ X * β)))
end;

using DataFrames, CSV, HTTP

url = "https://raw.githubusercontent.com/storopoli/Bayesian-Julia/master/datasets/wells.csv"
wells = CSV.read(HTTP.get(url).body, DataFrame)
describe(wells)

X = Matrix(select(wells, Not(:switch)))
y = wells[:, :switch]
model = logreg(X, y);

chain = sample(model, NUTS(), MCMCThreads(), 2_000, 4)
summarystats(chain)