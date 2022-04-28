# PROJECT2.JL

# code that is actually evaluated using the "main" function
# written in helpers.jl. the optimize function is shared with run.jl
# which has a seperate implementation of main that enables graphing

#TODO include just the optimize funtion or just copy and paste it over
include("helpers.jl")
include("work.jl")

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
        h = Direct_Hparams(0.1, 0.01, 0.5)
        xhist, fhist, method = direct_penalty_opt(f, g, c, x0, n_eval_allowed, h)
    elseif prob == "simple2"
        h = Direct_Hparams(10, 0.01, 0.5)
        xhist, fhist, method = direct_penalty_opt(f, g, c, x0, n_eval_allowed, h)
    elseif prob == "simple3"
        h = Direct_Hparams(0.1, 0.01, 0.5)
        xhist, fhist, method = direct_penalty_opt(f, g, c, x0, n_eval_allowed, h)
    else
        h = Direct_Hparams(0.05, 0.01, 0.5)
        evals_break = 100
        xhist, fhist, method = direct_penalty_opt(f, g, c, x0, n_eval_allowed, h, evals_break)
    end 
    
    x_best = xhist[argmin(fhist)]
    
    if dev == true
        return (x_best, xhist, fhist, method, x0) 
    else
        return (x_best)
    end
end

# main("simple1", 1, optimize)