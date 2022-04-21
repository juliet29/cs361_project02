include("helpers.jl")

using Plots


function make_contour_plot(probname)
    println("making a contour plot")
    # visualize function problem
    prob = PROBS[probname]

    xr = Vector(-3:0.1:3)
    yr = Vector(-3:0.1:3)
    z = [prob.f([a,b]) for a=xr, b=yr]
    
    c_plot = contour!(xr, yr, z, xlims=(-3,3), ylims=(-3,3),aspectratio=:equal)

    return c_plot

end

function update_contour_plot(xhist, c_plot)
    println("updating contour plot")
    # visualize progress
    x1 = [xhist[i][1] for i = 1:length(xhist)]
    x2 = [xhist[i][2] for i = 1:length(xhist)]
    plot!(c_plot, x1, x2, color=:black)
    
    savefig("figures/example.png")
end






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




