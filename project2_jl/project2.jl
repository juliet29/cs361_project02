# PROJECT2.JL

# code that is actually evaluated using the "main" function
# written in helpers.jl. the optimize function is shared with run.jl
# which has a seperate implementation of main that enables graphing

#TODO include just the optimize funtion or just copy and paste it over
include("helpers.jl")
include("work.jl")
include("secret2.jl")
include("pop.jl")

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
function span10()
    # create set of positive spanning vectors 
    x = randn(10)
    D = nullspace(x')
    d = [(D[:, i]) for i=1:2]
    return d
end


function optimize(f, g, c, x0, n_eval_allowed, prob, dev=false)
    # error("hello!")
    evals_break = 100
    p = Penalty_Params(100, 100)
    if prob == "simple1"
        h = Direct_Hparams(0.1, 0.01, 0.5)
        xhist, fhist, method = direct_penalty_opt(f, g, c, x0, n_eval_allowed, h)
    elseif prob == "simple2"
        h = Direct_Hparams(10, 0.01, 0.5)
        xhist, fhist, method = direct_penalty_opt(f, g, c, x0, n_eval_allowed,  h) # evals_break, p, "not_hj"
    elseif prob == "simple3"
        pop_p = Pop_Params(7, 50, TruncationSelection(2), InterpolationCrossover(0.5), GaussianMutation(0.1))
        e = EvalCount(n_eval_allowed, evals_break, g, c)
        xhist, fhist, method = pop_penalty_opt(f, x0, pop_p, e)

        # h = Direct_Hparams(0.1, 0.01, 0.5)
        # xhist, fhist, method = direct_penalty_opt(f, g, c, x0, n_eval_allowed, h)

    # elseif prob == "secret0"
    #     h = Direct_Hparams(10, 0.01, 0.5)
    #     p = Penalty_Params(10e6, 10e6)
    #     evals_break = 100
    #     D = span10()
    #     xhist, fhist, method = direct_penalty_opt(f, g, c, x0, n_eval_allowed, h, evals_break, p, "not_hj", D)
    elseif prob == "secret1"
        h = Direct_Hparams(10, 0.01, 0.5)
        p = Penalty_Params(10e6, 10e6)
        evals_break = 100
        D = [[1,0],  [1,2], [-1,-1]]
        xhist, fhist, method = direct_penalty_opt(f, g, c, x0, n_eval_allowed, h, evals_break, p, "not_hj", D)
    elseif prob == "secret2"
        evals_break = 500
        p = Penalty_Params(10e6, 10e6)
        pop_p = Pop_Params(13, 100, TruncationSelection(2), InterpolationCrossover(0.80), GaussianMutation(0.09))
        e = EvalCount(n_eval_allowed, evals_break, g, c)
        xhist, fhist, method = pop_penalty_opt(f, x0, pop_p, e)
        # h = Direct_Hparams(100, 0.1, 0.1)
        # p = Penalty_Params(10e11, 10e11)
        # evals_break = 10
        # D = span10()
        # xhist, fhist, method = secret2_opt(f, g, c, x0, n_eval_allowed, h, evals_break, p, D)
    end 
    
    x_best = xhist[argmin(fhist)]
    
    if dev == true
        return (x_best, xhist, fhist, method, x0) 
    else
        return (x_best)
    end
end

# main("simple1", 1, optimize)