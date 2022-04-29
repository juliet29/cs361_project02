include("work.jl")

function gp_search_secret2(;f, x, α, ϵ, γ, D, c)
    y, n = f(x), length(x)
    xhist = [x]
    fhist = [y]
    while α > ϵ
        improved = false
        for (i,d) in enumerate(D)
            x′ = x +  α*d
            # @warn "this is the size of x' $(size(x′))"
            y′ = f(x′)
            if y′ < y
                # check constraint
                # @warn "this is the value of y' $(y′)"
                # pass_constraint = p_count(c, x′)
                # if pass_constraint <= 0
                x, y, improved =  x′, y′, true
                D = pushfirst!(deleteat!(D, i), d)
                push!(xhist, x)
                push!(fhist, y)
                break
                # end
            end
            f_evals = count(f)
            
            if f_evals > 4000 - 200
                # secret 2 break case
                break
            end
        end
        if !improved
            α*= γ
        end
        f_evals = count(f)
        if f_evals > 4000  - 200
            # secret 2 break case
            break
        end
    end

   return x, xhist, fhist
end

function p_quad(c, x)
    # assuming all are inequality constraints for now 
    quad = 0
    c_eval = c(x)
    for i in c_eval
        quad_i = max(i, 0)^2
        quad += quad_i
    end

    return quad
    
end


function secret2_opt(f, g, c, x0, n_evals_allowed, hparams::Direct_Hparams, evals_break=100, pparams::Penalty_Params=default_pparams, D=nothing)
    method = "secret2_only"
    ρ1 = pparams.ρ1
    ρ2 = pparams.ρ1

    xhist = [x0]
    fhist = [f(x0)]

    n_evals = count(f, g) + count(c)

    while n_evals < n_evals_allowed - evals_break
        # print("evals to start $n_evals")
        fobj = x -> f(x) + p_mix(c, x, ρ1, ρ2)

        xnext, xhisto, fhisto = gp_search_secret2(f=fobj, x=xhist[end], α=hparams.α, ϵ=hparams.ϵ, γ=hparams.γ, D=D, c=c)

        xhist = xhisto
        fhist = fhisto
        x = xnext

        # check for convergence, constraints, and bounds 
        converged = check_convergence(fhist)
        evals_exceeded, n_evals = check_n_evals(f,g,c, n_evals_allowed, evals_break)
        pass_constraint = p_quad(c, x)
        
       
        if pass_constraint <= 0
            error("found one. n_evals $n_evals, pass_constraint $pass_constraint")
            break
        elseif evals_exceeded == true
            # find the last time it was in the thing 
            error("n_evals $n_evals, pass_constraint $pass_constraint")
            break
        elseif converged == true
            c_eval = p_count(c, x)
            if c_eval <= 0
                error("converged c_evals $c_eval")
                break
            end
        end
        

    end
    

    # println("n_evals are $n_evals, f_evals are $f_evals")

    return xhist, fhist, method

end