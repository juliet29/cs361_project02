include("helpers.jl")

using Plots

function simple5(x,y)
    return -x * y + 2.0 / (3.0 * sqrt(3.0))
end

function contour_plot(xhist, probdef)
    # visualize function 
    xr = -3:0.1:3
    yr = -3:0.1:3
    levels = [10, 25, 50, 100, 200, 250, 300]
    contour(xr, yr, probdef, xlims=(-3,3), ylims=(-3,3),aspectratio=:equal)
    # contour(xr, yr, probdef, levels=levels, xlims=(-3,3), ylims=(-3,3), aspectratio=:equal)
    # visualize progress
    x1 = [xhist[i][1] for i = 1:length(xhist)]
    x2 = [xhist[i][2] for i = 1:length(xhist)]
    plot!(x1, x2, color=:black)
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




