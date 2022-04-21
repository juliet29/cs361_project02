include("helpers.jl")


# problem specific optimizers
function bad_optimizer(f, g, c, x0, n_eval_allowed, step_size)
    xhist = [x0]
    fhist = [f(x0)]

    for i = 1:n_eval_allowed-1
        xnext = xhist[end] + step_size*(ones(length(x0)))
        push!(xhist, xnext)
        push!(fhist, f(xnext))
    
    end
    
    return xhist, fhist
end




