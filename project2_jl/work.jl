include("helpers.jl")
using LinearAlgebra

# Gradient Descent Methods -----------------------------------------

abstract type DescentMethod end

struct GradientDescent <: DescentMethod 
    α
end

function stepGrad!(M::GradientDescent, ∇f, x)
    # normalized gradient descent 
    α, g = M.α, ∇f(x)
    g_to_norm = g[1]^2 + g[2]^2
    g_norm = g/g_to_norm
    return x - α*g_norm
end


# Direct Methods -----------------------------------------

function basis(i, n)
    # return the ith row of a nxn identity matrix
    mat = Matrix(1.0 * I, n, n)
    return mat[i, :]
end

function hook_jeeves(;f, x, α, ϵ, γ, g, c, n_evals_allowed, evals_break=100 )
    y, n = f(x), length(x)
    xhist = [x]
    fhist = [y]
    while α > ϵ
        improved = false
        x_best, y_best = x, y 
        for i in 1:n
            for sgn in (-1,1)
                basis_vector = sgn*basis(i,n)
                x′ = x + α*basis_vector
                y′ = f(x′)
                if y′ < y_best
                    x_best, y_best, improved = x′, y′, true
                end
                push!(xhist, x_best)
                push!(fhist, y_best)
                
                # check evals, bounds and break
                evals_exceeded, n_evals = check_n_evals(f,g,c, n_evals_allowed, evals_break)
                println("evals in hook jeeves $n_evals \n")
                if evals_exceeded
                    println("evals_exceeded in hook jeeves \n")
                    break
                elseif abs(x′[1]) > 5 || abs(x′[2]) > 5 # prev 5
                    println("out of bounds in hook_jeeves \n")
                    break
                end

            end
        end
        x, y = x_best, y_best

        if !improved
            α *= γ

        end
    end


    return x, xhist, fhist
    
end


# Optimizers -----------------------------------------
mutable struct Direct_Hparams
    α
    ϵ
    γ
end

function direct_penalty_opt(f, g, c, x0, n_evals_allowed, hparams::Direct_Hparams, evals_break=100)
    method = "direct_pmix_converge10"
    ρ1 = 100
    ρ2 = 100

    xhist = [x0]
    fhist = [f(x0)]

    n_evals = count(f, g) + count(c)

    while n_evals < n_evals_allowed - evals_break
        print("evals to start $n_evals")
        fobj = x -> f(x) + p_mix(c, x, ρ1, ρ2)
        xnext, xhisto, fhisto = hook_jeeves(f=fobj, x=xhist[end], α=hparams.α, ϵ=hparams.ϵ, γ=hparams.γ, g=g, c=c, n_evals_allowed=n_evals_allowed, evals_break=evals_break)

        xhist = xhisto
        fhist = fhisto
        x = xhist[end]

        # check for convergence, constraints, and bounds 
        converged = check_convergence(fhist)
        evals_exceeded, n_evals = check_n_evals(f,g,c, n_evals_allowed, evals_break)
        println("n_evals = $n_evals in optimizer")
        if converged == true
            c_eval = p_count(c, x)
            if c_eval <= 0
                break
            end
        elseif abs(xnext[1]) > 5 || abs(xnext[2]) > 5
            # println("out of bounds in optimizer \n")
            break
        elseif evals_exceeded == true
            # println("evals exceeded in optimizer \n")
            break
        end
        

    end

    return xhist, fhist, method

end

# Penalties -----------------------------------------

function p_count(c, x)
    # assuming all are inequality constraints for now 
    count = 0
    c_eval = c(x)
    for i in c_eval
        count_i = i > 0 ? 1 : 0
        count += count_i
    end

    return count
    
end

function p_mix(c, x, ρ1, ρ2)
    # assuming all are inequality constraints for now 
    count = 0
    quad = 0
    c_eval = c(x)
    for i in c_eval
        count_i = i > 0 ? 1 : 0
        quad_i = max(i, 0)^2
        count += count_i
        quad += quad_i
    end

    return ρ1* count + ρ2*quad
    
end

# Terminators  -----------------------------------------

function check_convergence(arr)
    len_arr = length(arr)
    check_length = Int(round(len_arr/2))
    total_diff = 0
    for i = 1:check_length
        diff = arr[end] - arr[end-i]
        total_diff += diff
    end

    if total_diff < 0.1
        # converged
        return true
    end
end


function check_n_evals(f,g,c, n_evals_allowed, ϵ=100)
    n_evals = count(f, g) + count(c)
    # n_evals = 2
    if n_evals > n_evals_allowed - ϵ
        # println("number of evaluations exceeded")
        return true, n_evals
    else
        return false, n_evals
    end
    
end