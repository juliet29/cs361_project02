using Distributions
include("work.jl")

function f(x::Vector)
    val = 0
    for  i=1:length(x)
        val += x[i]
    end
    return val
end

function rand_population_cauchy(m, μ, σ )
    n = length(μ)
    return [[round.(rand(Cauchy(μ[j], σ[j] )); digits=2) for j in 1:n] for i in 1:m]
end

# Selection -----------------------
struct TruncationSelection
    k # top k to keep 
end

function select(t::TruncationSelection, y)
    # truncation selection 
    # println("y $y")
    p = sortperm(y)
    p_ix = rand(1:t.k, 2)
    # println("p $p --- p_ix", p_ix)
    return [p[p_ix] for i in y]
end

# Interpolation -----------------------
struct InterpolationCrossover
    λ # top k to keep 
end

function crossover(C::InterpolationCrossover, a, b )
    # interpolation crossover
    return (1 - C.λ)*a + C.λ*b
end

# Mutation -----------------------
struct GaussianMutation
    σ # top k to keep 
end


function mutate(M::GaussianMutation, child)
    return child + randn(length(child))*M.σ
    
end

# Algorithm -----------------------

struct EvalCount
    n_evals_allowed
    evals_break
    g
    c
end

struct Pop_Params
    m # number of design points per round
    k_max # number of runs 
    S::TruncationSelection
    C::InterpolationCrossover
    M::GaussianMutation
end

function gen_alg(f, pop, k_max, S, C, M, e::EvalCount)
    for k in 1:k_max
        # check if need to break 
        evals_exceeded, n_evals = check_n_evals(f, e.g, e.c, e.n_evals_allowed, e.evals_break)
        if evals_exceeded == true
            error("evals done, breaking $n_evals, k=$k")
            break
        end

        # continue 
        pop_scores = f.(pop)
        min_pop_score = minimum(pop_scores)
        if min_pop_score < 1
            break
        end
        println("k $k, mean $(round(mean(pop_scores);digits=3)) std $(round(std(pop_scores);digits=3)), evals $n_evals")

        parents = select(S, pop_scores )
        children = [crossover(C,pop[p[1]], pop[p[2]]) for p in parents]
        pop .= mutate.(Ref(M), children)

        # if k == k_max -2
        #     final_scores = f.(pop)
        #     x_best = pop[argmin(final_scores)]
        #     y_best = minimum(final_scores)
        #     error("x_best $(round.(x_best; digits=3)), y_best $(round(y_best; digits=3))")
            
        # end
    end
    # println("post break up :( 1")
    final_scores = f.(pop)
    x_best = pop[argmin(final_scores)]
    y_best = minimum(final_scores)
    
    return x_best, y_best
    
end



function pop_penalty_opt(f, x0, p::Pop_Params, e::EvalCount, pparams::Penalty_Params=default_pparams)
    # dimensions of the problem 
    d = length(x0)

    # initialization
    m  = p.m # number of design points
    μ = abs.(randn(d)) # means of distributions
    σ = abs.(randn(d)) # standard devs of distributions
    pop = rand_population_cauchy(m, μ, σ)

    # function redefinition to include penalties 
    fobj = x -> f(x) + p_mix(e.c, x, pparams.ρ1, pparams.ρ2)

    x_best, y_best = gen_alg(fobj, pop, p.k_max, p.S, p.C, p.M, e)

    # println("post break up :( 2")

    return [x_best], [y_best], "gen_alg"
    
end

# pop_main(10)

    # for (i,x) in enumerate(init_pop)
    #     println("init pop \n $i $x \n")
    # end
    # # println("init_pop, $init_pop")
    
    # keep = 2 # design points to select
    # parents = select(keep, f.(init_pop))
    # ch = [p for p in parents]
    # ch2 = [p[2] for p in parents]
    # println("parents $parents, ch $ch, ch2 $ch2 \n")

    # λ = 0.5
    # children = [crossover(λ, init_pop[p[1]], init_pop[p[2]]) for p in parents]
    # for (i,x) in enumerate(children)
    #     println("children \n $i $x \n")
    # end

    # σ = 0.1
    # init_pop .= mutate.(σ, children )
    # for (i,x) in enumerate(init_pop)
    #     println("new_pop \n $i $x \n")
    # end

# function pop_main(f, x0, p::Pop_Params, e::EvalCount)
#     # dimensions of the problem 
#     d = length(x0)

#     # initialization
#     m  = p.m # number of design points
#     μ = abs.(randn(d)) # means of distributions
#     σ = abs.(randn(d)) # standard devs of distributions
#     pop = rand_population_cauchy(m, μ, σ)

#     # run 
#     x_best, y_best = gen_alg(f, pop, p.k_max, p.S, p.C, p.M, e)
#     return x_best, y_best
# end