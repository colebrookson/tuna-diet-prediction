using Optim, NLSolversBase, Random
using LinearAlgebra: diag
Random.seed!(0); 

# online example ===============================================================

n = 500 
nvar = 2
β = ones(nvar) * 3.0 
x = [ones(n) randn(n, nvar - 1)]
ϵ = randn(n) * 0.5
y = x * β + ϵ;

function Log_Likelihood(X, Y, β, log_σ)
    σ = exp(log_σ)
    llike = -n/2*log(2π) - n/2* log(σ^2) - (sum((Y - X*β).^2)/(2σ^2))
    llike = -llike
end

func = TwiceDifferentiable(vars -> Log_Likelihood(x, y, vars[1:nvar], vars[nvar + 1]),
                           ones(nvar+1); autodiff=:forward);

opt = optimize(func, ones(nvar+1))

parameters = Optim.minimizer(opt)