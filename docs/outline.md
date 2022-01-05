---
title: Trait-based methods comparisons for identifying trait-based shifts in Albacore Tuna diets
author: Cole Brookson
---

## Introduction

Originally defined, a species' "niche" is ultimately based on the traits of that species. Whether conceptualized as being defined by the traits themselves (i.e. @eltonAnimalEcologyLondon1927; harmonConvergenceMultidimensionalNiche2005) or as the set of environments for which a particular set of traits are suitable (i.e. @hutchinsonConcludingRemarksCold1957; @harpoleGrasslandSpeciesLoss2007), species traits are fundamental to the concept of niches. Species niches have also been used prevalently to 

Food web rewiring is, at the base level, defined by the shifting of a) interactions in a network, and b) the strength of interactions in a network. 

* Given some event that predicates the event, consumers will shift the set of resources they consume by some non-zero amount, resulting in a new set of resource items
* Given the same or some different event that predicates the rewiring, the *strength* of interactions between a consumer and its set of resource prey items may change
* These two changes are likely to happen together, and therefore any method used to model how this rewiring event happens much account for both 1) the incorporation and/or disunion of resources, and 2) the shift of interaction strengths in interactions that stay consistent in their presence

There have been numerous methods proposed to identify how consumers select their resources and then subsequently how intensely they consume them, but a significant number rely on incorporating some conception of a species' "niche", perhaps most famously in williamsSimpleRulesYield2000a oft-cited first proposal of the aptly named "Niche Model"
* Whether the niche is defined, as originally posited, as simply the traits of the species at hand (i.e. @eltonAnimalEcologyLondon1927; harmonConvergenceMultidimensionalNiche2005) or as the set of environments for which a particular set of traits are suitable (i.e. @hutchinsonConcludingRemarksCold1957; @harpoleGrasslandSpeciesLoss2007), species traits are fundamental to the concept of niches. 
* Indeed, species traits lend themselves to myriad approaches that can address the question of how to model a species' trophic interactions (@ottoAllometricDegreeDistributions2007b; @rossbergHowTrophicInteraction2010; @pomeranzInferringPredatorPrey2019c)

The ways in which traits are most commonly used to model trophic interactions is through first determining the topological structure of the set of interactions, and then determining their strength. Traits can be used via to determine whether a given resource is a *possible* prey item for a consumer by determining whether some consumer $i$ and resource $j$ overlap in time and space through traits like habitat association or migration habits. Then, using some coarse measurements, a possible unidirectional consumer resource interaction between $i$ and $j$ can be deemed possible or not via traits like feeding habits and body size. Subsequently, the same traits in addition to others, can be used to determine not just the *possibility* but the *strength* of that consumer-resource interaction between $i$ and $j$. This process usually takes the form of estimating some probability $P(i,j)$ of consumer $i$ eating resource $j$, epitomized by the probabilistic niche model proposed as a follow-up to the classic niche model by @williamsProbabilisticNicheModel2010a. While most implementations of this approach consider only body size as the trait of interest, it is possible that for some consumers, including additional traits would actually improve estimates of interaction strength. 


## Methods

### Comparison of Niche-based Approaches

Multiple proposals have been made regarding how best to use likelihood methods to get at the question of interaction strength. @williamsProbabilisticNicheModel2010a proposed a relatively simple method, where a single trait can be used to estimate probabilities for any number of resource species. Using multiple traits is done by repeating this process for any trait of interest, and then finding the joint probability of all traits of interest. This contrasts slightly with the approach of @rossbergHowTrophicInteraction2010, who posit that the approach should *start* with the assumption of using multiple traits, and therefore estimate the interaction as the energy flow $a_{RC}$ from resource $R$ to consumer $C$ as being a function of the traits of both the consumer and the resource.  

**My Question: which niche-based approach provides a more accurate measure of interaction strength, and how can we apply these two approaches to a real data set?**



#### Probabalistic Niche Model [@williamsProbabilisticNicheModel2010a]

While this approach does not explicitly model interaction strength by name, the interest is in ascribing non-zero probabilities of consumption to every possible interaction. This can be interpreted as the interaction strength between a consumer and a resource, when considered in absence of consideration of abundance. 

In the original 2010 formulation, the probability that species $i$ would consume specie $j$ was given by $$ P(i,j,\theta) = \alpha ^{-(\frac{n_j - c_i}{r_i/2})^2}$$ where $P(i,j,\theta)$ is the probability that species $i$ eats species $j$ given a particular parameter set $\theta$, where $$\theta = \{{n_1 ... n_S, c_1 ... c_s, r_1 ... r_S\}};$$ $n_j$ is the niche position of $j$, $c_i$ is the optimal diet position of $i$, $r_i$ is the feeding range of $i$ and $\alpha$ is the probability that $i$ eats $j$ when the niche position of $j$ is exactly equal to the optimal diet position of $i$. 

For some number of species $S$, the parameter values given by $\theta$ and some data $\bold{X}$ (here $\bold{X}$ is an $S \times S$ matrix containing a binary observation $X_{ij}$ for each link $i,j$), then the maximum liklihood parameter set can be defined as $$\ell(\bold{X}|\theta) = \sum_i \sum_j ln\begin{cases}
P(i,j|\theta) \text{ if } X_{ij}=1 \\
1-P(i,j|\theta) \text{ if } X_{ij}=0\\
\end{cases} $$

The authors then used simulated annealing to fit the model to data. 

To expand this into higher dimensions (i.e. higher numbers of traits), @williamsProbabilisticNicheModel2011 provided a slightly expanded version of the original formulation for $P(i,j,\theta)$:

$$ P(i,j,\theta) = \alpha \prod^D_{d=1} exp \left(- \left|\frac{n_{d,j} - c_{d,i}}{r_{d,i}/2}\right|^e\right) $$ for some number of dimensions, $D$.

#### Multidimensional Trophic Niche Spaces [@rossbergHowTrophicInteraction2010]

This approach, contrary to the previous one, is explicitly designed to model interaction strength as one might conceive of it in the classical functional response:

$$ \frac{a_{ic}\rho_i}{1 + \tau_c \sum_j a_{jc}\rho_j } $$

where some consumer $c$ is consuming some $N$ number of resource species that have some known densities denoted $\rho_i (i = 1, ..., N)$, $a_{ic}$ is the consumption of resource $i$ by the consumer $c$, and $\tau_c$ is the handling time of the consumer. 

Assuming that phenotypic traits determine the values of $a_{ic}$ for all $i$, they define a vector, $\bold{t}_i$ as the *m*-dimensional vector containing the numerical values of the traits of the species $i$, where $\left|\bold{t}\right| > t_{max}$ bounds the phenotypic trait space. They then concatenate the trait vectors $\bold{t}_r$ and $\bold{t}_c$ for some resource $r$ and consumer $c$ as 

$$ 
\bold{v} = 
\begin{pmatrix}
\bold{t}_r \\
\bold{t}_c
\end{pmatrix}
$$

such that $\bold{v}$ defines a consumer resource pair, and thus $a_{rc}$ is a function only of $\bold{v}$. Given this, @rossbergHowTrophicInteraction2010 pose a simple polynomial for $\text{ln }  a_{rc}$:

$$ \text{ln }  a_{rc} = \text{ln } a_0 + \bold{b}^\intercal \bold{v} + \frac{1}{2} \bold{v}^\intercal C\bold{v} $$ where $\bold{b}$ is a 2*m* length vector, and $C$ is a symmetric $2m \times 2m$ matrix. 

They further use spectral decomposition theory to derive an approximation of the above equation 

$$ a_{rc} = a_1 \text{exp} \left[ V^* + F^* + \frac{1}{2} \sum^n_{i=1} \lambda_i (V_i - F_i)^2 \right]$$ where $n, a_1$ and $\lambda_i (i = 1,..,n)$ are constants, $V^*$ represent the vulnerability traits of the resource, and $F^*$ are the foraging traits of the consumer.  





## Summary of my Idea

Take the two approaches, and compare them with different simulated datasets, including different number of traits, and different numbers of observations. Quantify their data requirements and accuracy at different levels of "good" data. Then, take the albacore data and try to use both approaches (or the best approach) to figure out if I can actually fit the interaction strengths. 








#### NOTES

Could do something like looking at "perfect" data and seeing how much we can get out of it then working backwards to the data we have

#### Next Steps

1. Use approach from first paper to simulate some data from one predator
2. Take perfect data and use to compare to what Miram has for data
3. Write code for both approaches to try and fit the values from each one
4. Add some variability to perfect data
5. Do the fit again
6. Now do it with real data