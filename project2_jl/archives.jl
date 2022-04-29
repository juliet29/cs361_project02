function grad_penalty_opt(f, g, c, x0, n_eval_allowed)
    method = "grad_desc_pmix"
    M = GradientDescent(0.1)
    ρ1 = 1
    ρ2 = 0.001
    γ = 2

    xhist = [x0]
    fhist = [f(x0)]
    phist = []

    for n in 1:n_eval_allowed
        # function pcount, pquad
        pcount, pquad = p_mix(c, xhist[end])
        # println(v)
        # push!(phist, p_value)
        # println("p_value $p_value")
        xvalue = xhist[end] + pcount*ρ1 + pquad*ρ2
        xnext = stepGrad!(M, g, xvalue) #+ ρ*p_value
        push!(xhist, xnext)
        push!(fhist, f(xnext))
        # ρ *= γ
    end
    # println("vios $phist")
    
    return xhist, fhist, method
end


# problem specific optimizers
# function bad_optimizer(f, g, c, x0, n_eval_allowed, step_size)
#     xhist = [x0]
#     fhist = [f(x0)]

#     for i = 1:n_eval_allowed-1
#         xnext = xhist[end] + step_size*(ones(length(x0)))
#         push!(xhist, xnext)
#         push!(fhist, f(xnext))
    
#     end
    
#     return xhist, fhist
# end