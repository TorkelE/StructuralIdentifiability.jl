
@setup_workload begin
    # Putting some things in `@setup_workload` instead of `@compile_workload` can reduce the size of the
    # precompile file and potentially make loading faster.
    using Logging
    @compile_workload begin
        # all calls in this block will be precompiled, regardless of whether
        # they belong to your package or not (on Julia 1.8 and higher)
        with_logger(ConsoleLogger(stdout, Logging.Warn)) do
            ode = @ODEmodel(
                x1'(t) = -(a01 + a21) * x1(t) + a12 * x2(t) + u(t),
                x2'(t) = a21 * x1(t) - a12 * x2(t) - x3(t) / b,
                x3'(t) = x3(t),
                y(t) = x2(t)
            )
            assess_identifiability(ode)
        end
    end
end
