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
    # println("starting opt!")
    if prob == "simple1"
        h = Direct_Hparams(0.1, 0.01, 0.5)
        step_size = 0.01
        xhist, fhist, method = direct_penalty_opt(f, g, c, x0, n_eval_allowed, h)
    elseif prob == "simple2"
        h = Direct_Hparams(10, 0.01, 0.5)
        xhist, fhist, method = direct_penalty_opt(f, g, c, x0, n_eval_allowed, h)
    elseif prob == "simple3"
        h = Direct_Hparams(10, 0.01, 0.5)
        xhist, fhist, method = direct_penalty_opt(f, g, c, x0, n_eval_allowed, h)
    else
        step_size = 0.01
        xhist, fhist = bad_optimizer(f, g, c, x0, n_eval_allowed, step_size)
    end 
    
    x_best = xhist[argmin(fhist)]
    
    if dev == true
        return (x_best, xhist, fhist, method, x0) 
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
    if probname == "simple1" || probname == "simple2"
        contour_plot = make_contour_plot(probname)
        converg_plot = make_convergence_plot()
        vio_plot = make_violation_plot()
    end


    # Repeat the optimization with a different initialization
    for i in 1:repeat
        # print("iteration $i \n")
        empty!(COUNTERS) # fresh eval-count each time
        Random.seed!(seed + i)

        # in development 
        dev = true

        # print("about to optimize $i \n")
        # optimize
        # println("opt_func type, $(typeof(opt_func))")
        res = opt_func(f, g, c, x0(), n, probname, dev)
        # print("got res $i")
        # println("$i length of res $(length(res))  \n")
        optima = res[1] 
        # println("optima $optima \n")
         
        
        nevals[i], scores[i] = get_score(f, g, c, optima, n)

        
        # plotting
        if probname == "simple1" || probname == "simple2"
            if length(res) > 1
                
                xhist, fhist, method, xStart  = res[2:5]
                update_contour_plot(xStart, xhist, contour_plot, probname, method)
                update_convergence_plot(xhist, fhist, converg_plot, probname, method)
                update_violation_plot(xhist, vio_plot, probname, method)
                # println("plotting \n")
            end
        end
        
    end
    println(probname)

    return scores, nevals, optima
end
