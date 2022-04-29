using Distributions

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

function gen_alg(f, pop, k_max, S, C, M)
    for k in 1:k_max
        pop_scores = f.(pop)
        println("k $k, pop_scores $pop_scores")
        parents = select(S, pop_scores )
        children = [crossover(C,pop[p[1]], pop[p[2]]) for p in parents]
        pop .= mutate.(Ref(M), children)
    end
    pop[argmin(f.(pop))]
    
end

function pop_main(d)
    # initialization
    m  = 5 # number of design points
    μ = abs.(randn(d)) # means of distributions
    σ = abs.(randn(d)) # standard devs of distributions
    init_pop = rand_population_cauchy(m, μ, σ)
    for (i,x) in enumerate(init_pop)
        println("init pop \n $i $x \n")
    end
    # println("init_pop, $init_pop")
    
    keep = 2 # design points to select
    parents = select(keep, f.(init_pop))
    ch = [p for p in parents]
    ch2 = [p[2] for p in parents]
    println("parents $parents, ch $ch, ch2 $ch2 \n")

    λ = 0.5
    children = [crossover(λ, init_pop[p[1]], init_pop[p[2]]) for p in parents]
    for (i,x) in enumerate(children)
        println("children \n $i $x \n")
    end

    σ = 0.1
    init_pop .= mutate.(σ, children )
    for (i,x) in enumerate(init_pop)
        println("new_pop \n $i $x \n")
    end

end

# pop_main(10)