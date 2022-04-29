########### My "Secret" Problem Definitons ###########
using SymPy;

# starting with Ackley's function in 2D 
@counted function secret0(x::Vector, a=20, b=0.2, c=2π)
    d = length(x)
    return -a*exp(-b*sqrt(sum(x.^2)/d)) - exp(sum(cos.(c*xi) for xi in x)/d) + a + exp(1)
end

@counted function secret0_gradient(x::Vector)
    # for 2D 
    x1, x2 = symbols("x1, x2")
    X = [x1; x2;]
    # analytical function in 2 dimensions
    f = secret0(X)
    # analytical gradient 
    g = Sym[diff(f,var) for var in X] 
    # evaluate the gradient 
    eval = [e(X[1] => x[1], X[2] => x[2]) for e in g]
    return eval
end

@counted function secret0_constraints(x::Vector)
    return [x[1] + x[2]^2  - 1, x[1]^3 + x[2] - 20]
end

function secret0_init()
    b = 2.0 .* randn(10)
    a = -2.0 .* randn(10)
    return (b-a) + a
end