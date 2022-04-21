include("helpers.jl")

using Plots


function plot_constraint(c, constraint_num)
    println(constraint_num)
    c1 = []
    # square matrix, so s1 and s2 will be the same
    s1 = size(c, 1)
    for row = 1:s1
        for col = 1:s1
            push!(c1, c[row, col][constraint_num])
        end
    end
    c1 = reshape(c1, s1, s1)';
    c1_filt = ifelse.(c1 .< 0, c1, 0);
    contour!(xr, yr, c1_filt, xlims=(-3,3), ylims=(-3,3),aspectratio=:equal, colorbar_entry=false, linecolor=cgrad(:greys))
end

function make_contour_plot(probname)
    println("making a contour plot")
    # visualize function problem
    prob = PROBS[probname]

    xr = Vector(-3:0.1:3)
    yr = Vector(-3:0.1:3)
    z = [prob.f([a,b]) for a=xr, b=yr]
    
    c_plot = contour(xr, yr, z, xlims=(-3,3), ylims=(-3,3),aspectratio=:equal)

    # visialize constraints 
    c = [prob.c([a,b]) for a=xr, b=yr]
    for i = 1:length(c[1,1])
        plot_constraint(c, i)
    end

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




