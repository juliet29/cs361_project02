include("helpers.jl")
include("work.jl")
include("plots.jl")

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
        empty!(COUNTERS) # fresh eval-count each time
        Random.seed!(seed + i)

        # in development 
        dev = true

        res = opt_func(f, g, c, x0(), n, probname, dev)
        optima = res[1] 
 
        nevals[i], scores[i] = get_score(f, g, c, optima, n)

        
        # plotting
        if probname == "simple1" || probname == "simple2"
            if length(res) > 1
                xhist, fhist, method, xStart  = res[2:5]
                update_contour_plot(xStart, xhist, contour_plot, probname, method)
                update_convergence_plot(xhist, fhist, converg_plot, probname, method)
                update_violation_plot(xhist, vio_plot, probname, method)
            end
        end
        
    end
    println(probname)

    return scores, nevals, optima
end
