# Identifiability of Discrete-Time Models (Local)

Now we consider a discrete-time model in the state-space form. Such a model is typically written either in terms of **shift**:

$\begin{cases}
\mathbf{x}(t + 1) = \mathbf{f}(\mathbf{x}(t), \mathbf{p}, \mathbf{u}(t)),\\
\mathbf{y}(t) = \mathbf{g}(\mathbf{x}(t), \mathbf{p}, \mathbf{u(t)}),
\end{cases}$

or in terms of **difference**

$\begin{cases}
\Delta\mathbf{x}(t) = \mathbf{f}(\mathbf{x}(t), \mathbf{p}, \mathbf{u}(t)),\\
\mathbf{y}(t) = \mathbf{g}(\mathbf{x}(t), \mathbf{p}, \mathbf{u(t)}),
\end{cases} \quad \text{where} \quad \Delta \mathbf{x}(t) := \mathbf{x}(t + 1) - \mathbf{x}(t).$

In both cases,$\mathbf{x}(t), \mathbf{y}(t)$, and $\mathbf{u}(t)$ are time-dependent states, outputs, and inputs, respectively,
and $\mathbf{p}$ are scalar parameters.
As in the ODE case, we will call that a parameter or a states (or a function of them) is **identifiable** if its value can be recovered from
time series for inputs and outputs (in the generic case, see Definition 3 in [^1] for details).
Again, we will distinguish two types of identifiability

  - **local** identifiability: the value can be recovered up to finitely many options;

  - **global** identifiability: the value can be recovered uniquely.

Currently, `StructuralIdentifiability.jl` allows to assess only local identifiability for discrete-time models,
and below we will describe how this can be done.
As a running example, we will use the following discrete version of the [SIR](https://en.wikipedia.org/wiki/Compartmental_models_in_epidemiology#The_SIR_model) model:

$
\begin{cases}
S(t + 1) = S(t) - \beta S(t) I(t),\\
I(t + 1) = I(t) + \beta S(t) I(t) - \alpha I(t),\\
R(t + 1) = R(t) + \alpha I(t),\\
y(t) = I(t),
\end{cases}
\quad \text{or}
\quad
\begin{cases}
\Delta S(t) = -\beta S(t) I(t),\\
\Delta I(t) = \beta S(t) I(t) - \alpha I(t),\\
\Delta R(t) = \alpha I(t),\\
y(t) = I(t),
\end{cases}$

where the observable is `I`, the number of infected people.
The native way to define such a model in `StructuralIdentifiability` is to use `@DDSmodel` macro which
uses the shift notation:

```@example discrete_dds
using StructuralIdentifiability

dds = @DDSmodel(
    S(t + 1) = S(t) - β * S(t) * I(t),
    I(t + 1) = I(t) + β * S(t) * I(t) - α * I(t),
    R(t + 1) = R(t) + α * I(t),
    y(t) = I(t)
)
```

Then local identifiability can be assessed using `assess_local_identifiability` function:

```@example discrete_dds
assess_local_identifiability(dds)
```

For each parameter or state, the value in the returned dictionary is `true` (`1`) if the parameter is locally identifiable and `false` (`0`) otherwise.
We see that `R(t)` is not identifiable, which makes sense: it does not affect the dynamics of the observable in any way.

The `assess_local_identifiability` function has three important keyword arguments:

  - `funcs_to_check` is a list of functions for which one want to assess identifiability, for example, the following code
    will check if `β * S` is locally identifiable.

```@example discrete_dds
assess_local_identifiability(dds; funcs_to_check = [β * S])
```

  - `prob_threshold` is the probability of correctness (default value `0.99`, i.e., 99%). The underlying algorithm is a Monte-Carlo algorithm, so in
    principle it may produce incorrect result but the probability of correctness of the returned result is guaranteed to be at least `prob_threshold`
    (in fact, the employed bounds are quite conservative, so in practice incorrect result is almost never produced).

  - `known_ic` is a list of the states for which initial conditions are known. In this case, the identifiability results will be valid not
    at any time point `t` but only at `t = 0`.

As other main functions in the package, `assess_local_identifiability` accepts an optional parameter `loglevel` (default: `Logging.Info`)
to adjust the verbosity of logging.

If one loads `ModelingToolkit` (and thus the `ModelingToolkitSIExt` extension), one can use `DiscreteSystem` from `ModelingToolkit` to
describe the input model (now in terms of difference!):

```@example discrete_mtk
using ModelingToolkit
using StructuralIdentifiability

@parameters α β
@variables t S(t) I(t) R(t) y(t)
D = Difference(t; dt = 1.0)

eqs = [D(S) ~ S - β * S * I, D(I) ~ I + β * S * I - α * I, D(R) ~ R + α * I]
@named sir = DiscreteSystem(eqs)
```

Then the same computation can be carried out with the models defined this way:

```@example discrete_mtk
assess_local_identifiability(sir; measured_quantities = [y ~ I])
```

In principle, it is not required to give a name to the observable, so one can write this shorter

```@example discrete_mtk
assess_local_identifiability(sir; measured_quantities = [I])
```

The same example but with specified functions to check

```@example discrete_mtk
assess_local_identifiability(sir; measured_quantities = [I], funcs_to_check = [β * S])
```

The implementation is based on a version of the observability rank criterion and will be described in a forthcoming paper.

[^1]: > S. Nõmm, C. Moog, [*Identifiability of discrete-time nonlinear systems*](https://doi.org/10.1016/S1474-6670(17)31245-4), IFAC Proceedings Volumes, 2004.
