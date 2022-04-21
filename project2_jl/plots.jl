include("helpers.jl")

using Plots

function plot_constraint(c, constraint_num)
    c1 = []
    # square matrix, so s1 and s2 will be the same
    s1 = size(c, 1)
    for row = 1:s1
        for col = 1:s1
            push!(c1, c[row, col][constraint_num])
        end
    end
    c1 = reshape(c1, s1, s1);
    # println("constraint_reshape $([round.(x) for x in c1]) \n")
    println("constraint_reshape $([round.(x) for x in c1[1,61]]) \n")
    c1_filt = ifelse.(c1 .< 0, c1, 0);
    # println("c1_filt $c1_filt")
    contour!(xr, yr, c1_filt, xlims=(-3,3), ylims=(-3,3),aspectratio=:equal, colorbar_entry=false, fillalpha=0.5, linecolor=cgrad(:greys), linewidth=7, levels=40)
end

function make_contour_plot(probname)
    println("making a contour plot")
    # visualize function problem
    prob = PROBS[probname]

    xr = Vector(-3:0.1:3)
    yr = Vector(-3:0.1:3)
    z = [prob.f([a,b]) for a=xr, b=yr]
    
    c_plot = contour(xr, yr, z, xlims=(-3,3), ylims=(-3,3),aspectratio=:equal, dpi=300, size=(700, 500), levels=10, fill=true, fillalpha=0.8)

    # visialize constraints 
    c = [prob.c([a,b]) for a=xr, b=yr]
    for i = 1:length(c[1,1])
        plot_constraint(c, i)
    end

    println("constraint_og $([round.(x) for x in c[1,61]]) \n")

    return c_plot

end

function update_contour_plot(xhist, c_plot, probname)
    println("updating contour plot")
    # visualize progress
    x1 = [xhist[i][1] for i = 1:length(xhist)]
    x2 = [xhist[i][2] for i = 1:length(xhist)]
    plot!(c_plot, x1, x2, linewidth=7, markershape = :star5, markercolor = cgrad(:blues), linestyle = :solid)
    
    savefig("figures/contour_$probname.png")
end

function make_convergence_plot()
    # println("making a converg plot")
    return plot()
end


function update_convergence_plot(xhist, fhist, c_plot, probname)
    # println("updating converg plot")
    x = [index for (index, value) in enumerate(xhist)]
    plot!(c_plot, x, fhist, markershape = :star5, title=probname, dpi=300, size=(700, 500), markercolor=cgrad(:blues))

    fname = "figures/converg_$probname"
    savefig(c_plot, fname)
end


function make_violation_plot()
    # println("making a converg plot")
    return plot()
end

function update_violation_plot(xhist, c_plot, probname)
    prob = PROBS[probname]
    # maximum constraint violation versus iteration
    chist = [prob.c(x) for x in xhist]
    # println("xhist $(xhist[1:20]) \n")
    # println("chist $(chist[1:20]) \n")
    max_chist = [maximum(c) for c in chist]
    # println("max_chist $(max_chist[1:20]) \n")
    violation = [max(c, 0) for c in max_chist]
    # println("violation $(violation[1:1000]) \n")


    # # println("updating converg plot")
    x = [index for (index, value) in enumerate(xhist)]
    plot!(c_plot, x, violation, markershape = :star5, title=probname, dpi=300, size=(700, 500), markercolor=cgrad(:blues))

    fname = "figures/violation_$probname"
    savefig(c_plot, fname)
end