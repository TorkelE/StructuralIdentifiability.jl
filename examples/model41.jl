include("../io_equation.jl")

# model 41, normalized (all state variables are divided by N)
logger = Logging.SimpleLogger(stdout, Logging.Debug)
global_logger(logger)

ode = @ODEmodel(
    S'(t) = -b * S(t) * (I(t) + J(t) + q * A(t)),
    E'(t) = b * S(t) * (I(t) + J(t) + q * A(t)) - k * E(t),
    A'(t) = k * (1 - r) * E(t) - g1 * A(t),
    I'(t) = k * r * E(t) - (alpha + g1) * I(t),
    J'(t) = alpha * I(t) - g2 * J(t),
    C'(t) = alpha * I(t)
)

g = C

@time io_equation = collect(values(find_ioequations(ode, [g])))[1]

println("The number of monomial in the IO-equation is $(length(io_equation))")

@time identifiability_report = check_identifiability(
    io_equation, 
    [b, k, g1, g2, alpha, r, q];
    method="GroebnerBasis"
)

println(identifiability_report)
