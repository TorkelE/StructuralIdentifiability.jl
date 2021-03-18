module StructuralIdentifiability

# General purpose packages
using Base.Iterators
using Dates
using IterTools
using LinearAlgebra
using Logging
using MacroTools
using Primes

# Algebra packages
using AbstractAlgebra
using Nemo
using Oscar
using GroebnerBasis

# defining a model
export ODE, @ODEmodel

# assessing identifiability
export assess_local_identifiability, assess_global_identifiability, assess_identifiability

# extra functionality
export find_ioequations, extract_identifiable_functions 

include("util.jl")
include("power_series_utils.jl")
include("ODE.jl")
include("local_identifiability.jl")
include("wronskian.jl")
include("elimination.jl")
include("primality_check.jl")
include("io_equation.jl")
include("global_identifiability.jl")

"""
    assess_identifiability(ode, [funcs_to_check, p=0.99])

Assesses identifiability of a given ODE model. The result is guaranteed to be correct with the probability
at least `p`.

If `funcs_to_check` are given, then the function will assess the identifiability of the provided functions
and return a list of the same length with each element being one of `:nonidentifiable`, `:locally`, `:globally`.

If `funcs_to_check` are not given, the function will assess identifiability of the parameters, and the result will
be a dictionary from the parameters to their identifiability properties (again, one of `:nonidentifiable`, `:locally`, `:globally`).
"""
function assess_identifiability(ode::ODE{P}, funcs_to_check::Array{<: RingElem, 1}, p::Float64=0.99) where P <: MPolyElem{fmpq} 
    p_glob = 1 - (1 - p) * 0.9
    p_loc = 1 - (1 - p) * 0.1

    @info "Assessing local identifiability"
    runtime = @elapsed local_result = assess_local_identifiability(ode, funcs_to_check, p_loc)
    @info "Local identifiability assessed in $runtime seconds"

    locally_identifiable = Array{Any, 1}()
    for (loc, f) in zip(local_result, funcs_to_check)
        if loc
            push!(locally_identifiable, f)
        end
    end

    @info "Assessing global identifiability"
    runtime = @elapsed global_result = assess_global_identifiability(ode, locally_identifiable, p_glob)
    @info "Global identifiability assessed in $runtime seconds"

    result = Array{Symbol, 1}()
    glob_ind = 1
    for i in 1:length(funcs_to_check)
        if !local_result[i]
            push!(result, :nonidentifiable)
        else
            if global_result[glob_ind]
                push!(result, :globally)
            else
                push!(result, :locally)
            end
            glob_ind += 1
        end
    end

    return result
end

function assess_identifiability(ode::ODE{P}, p::Float64=0.99) where P <: MPolyElem{fmpq}
    result_list = assess_identifiability(ode, ode.parameters, p)
    return Dict(param => res for (param, res) in zip(ode.parameters, result_list))
end

end
