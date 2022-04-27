include("helpers.jl")
using LinearAlgebra

# problem 1 focus, 2 inequality constraints

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
    # println("g $g")
    # println("g_to_norm $g_to_norm")
    # println("g_norm $g_norm")
    return x - α*g_norm
end


# Direct Methods -----------------------------------------

function basis(i, n)
    # return the ith row of a nxn identity matrix
    mat = Matrix(1.0 * I, n, n)
    return mat[i, :]
end

function hook_jeeves(;f, x, α, ϵ, γ=0.5 )
    y, n = f(x), length(x)
    xhist = [x]
    fhist = [y]
    while α > ϵ
        improved = false
        x_best, y_best = x, y 
        for i in 1:n
            for sgn in (-1,1)
                # TODO write basis function 
                basis_vector = sgn*basis(i,n)
                x′ = x + α*basis_vector
                y′ = f(x′)
                
                # println("basis is $basis_vector, x is $x′, y is $y′, n is $i , α is $α")
                if y′ < y_best
                    # println("improvement! y is $y")
                    x_best, y_best, improved = x′, y′, true
                end
                push!(xhist, x_best)
                push!(fhist, y_best)
                if  abs(x′[1]) > 5 || abs(x′[2]) > 5
                    break
                end
            end
        end
        x, y = x_best, y_best

        if !improved
            α *= γ

        # println("no improvement! α is $α")
        end
    end

    # println("xhist $xhist \n, fhist $fhist")

    return x, xhist, fhist
    
end


# Optimizers -----------------------------------------

function direct_penalty_opt(f, g, c, x0, n_eval_allowed)
    method = "direct_pmix_converge10"
    ρ1 = 100
    ρ2 = 100
    γ = 2

    xhist = [x0]
    fhist = [f(x0)]

    for n in 1:10
        fobj = x -> f(x) + p_mix(c, x, ρ1, ρ2)
        xnext, xhisto, fhisto = hook_jeeves(f=fobj, x=xhist[end], α=0.1, ϵ=0.01, γ=0.5 )

        xhist = xhisto
        fhist = fhisto

        # println("in hook jeeves, x is $xnext")

        
        converged = check_convergence(fhist)
        if converged == true
            c_eval = c(x)
            if c_eval <= 0
                println("converged and in contraint, $c_eval")
                break
        elseif abs(xnext[1]) > 5 || abs(xnext[2]) > 5
            println("out of bounds")
            break
        end
        # TODO add criteria that requires in constraint region 

        # push!(xhist, xnext)
        
        # push!(xhist, xnext)
        # push!(fhist, f(xnext))
        # ρ *= γ
    end

    # println("hook jeeves xhist $xhist \n, fhist $fhist")

    return xhist, fhist, method

end

# TODO convergence constraint

# Penalties -----------------------------------------

function p_mix(c, x, ρ1, ρ2)
    # assuming all are inequality constraints for now 
    count = 0
    quad = 0
    c_eval = c(x)
    for i in c_eval
        count_i = i > 0 ? 1 : 0
        quad_i = max(i, 0)^2
        # println("i $i, vio $vio")
        count += count_i
        quad += quad_i
    end

    return ρ1* count + ρ2*quad
    
end

# Terminators 

function check_convergence(arr)
    # println("checking conv $arr \n")
    len_arr = length(arr)
    check_length = Int(round(len_arr/2))
    total_diff = 0
    for i = 1:check_length
        diff = arr[end] - arr[end-i]
        total_diff += diff
    end

    # println("total dif $total_diff")

    if total_diff < 0.1
        # println("convergence! \n")
        return true
    end
    
end