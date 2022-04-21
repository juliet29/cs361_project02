include("helpers.jl")
include("work.jl")
include("plots.jl")

"""
    optimize(f, g, c, x0, n, prob)

Arguments:
    - `f`: Function to be optimized
    - `g`: Gradient function for `f`
    - `c`: Constraint function for 'f'
    - `x0`: (Vector) Initial position to start from
    - `n`: (Int) Number of evaluations allowed. Remember `g` costs twice of `f`
    - `prob`: (String) Name of the problem. So you can use a different strategy for each problem. E.g. "simple1", "secret2", etc.

Returns:
    - The location of the minimum
"""


function optimize(f, g, c, x0, n_eval_allowed, prob, dev=false)
    if prob == "simple1"
        step_size = 0.01
        xhist, fhist = bad_optimizer(f, g, c, x0, n_eval_allowed, step_size)
    elseif prob == "simple2"
        step_size = 0.01
        xhist, fhist =bad_optimizer(f, g, c, x0, n_eval_allowed, step_size)
    elseif prob == "simple3"
        step_size = 0.01
        xhist, fhist = bad_optimizer(f, g, c, x0, n_eval_allowed, step_size)
    else
        step_size = 0.01
        xhist, fhist = bad_optimizer(f, g, c, x0, n_eval_allowed, step_size)
    end 
    
    x_best = xhist[argmin(fhist)]
    
    if dev == true
        return (x_best, xhist, fhist) 
    else
        return (x_best)
    end
end


#TODO need to store xhist and other things in a globar var

function dev_main(probname::String, repeat::Int, opt_func, seed = 42)
    prob = PROBS[probname]
    f, g, c, x0, n = prob.f, prob.g, prob.c, prob.x0, prob.n

    scores = zeros(repeat)
    nevals = zeros(Int, repeat)
    optima = Vector{typeof(x0())}(undef, repeat)

    # initialize plots 
    contour_plot = make_contour_plot(probname)
    converg_plot = make_convergence_plot()
    vio_plot = make_violation_plot()


    # Repeat the optimization with a different initialization
    for i in 1:repeat
        empty!(COUNTERS) # fresh eval-count each time
        Random.seed!(seed + i)

        # in development 
        dev = true

        # optimize
        res = opt_func(f, g, c, x0(), n, probname, dev)
        optima[i] = res[1]  
        nevals[i], scores[i] = get_score(f, g, c, optima[i], n)

        # plotting
        if probname == "simple1" || probname == "simple2"
            if length(res) > 1
                xhist, fhist  = res[2:3]
                update_contour_plot(xhist, contour_plot, probname)
                update_convergence_plot(xhist, fhist, converg_plot, probname)
                update_violation_plot(xhist, vio_plot, probname)
            end
        end
        
    end
    println(probname)

    return scores, nevals, optima
end
