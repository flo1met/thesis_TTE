# replicate getting started TrialEmulation

using CSV
using Pkg
Pkg.develop(path = "../TargetTrialEmulation.jl")
using TargetTrialEmulation
using CategoricalArrays
using DataFrames
using GLM
using StatsModels

# Load the data
data = CSV.read("data/trial_example.csv", DataFrame)

# Convert the categorical variables to categorical arrays
data[!, :catvarA] = CategoricalVector(data.catvarA)
data[!, :catvarB] = CategoricalVector(data.catvarB)

# perform sequential TTE

df_out, model = TTE(data, 
    id_var = :id,
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    ipcw = false,
    covariates = [:catvarA, :catvarB, :nvarA, :nvarB, :nvarC],
    estimate_surv = false
)

# catA 3

model



##### Censored Dataset

# Load the data
df = CSV.read("data/data_censored.csv", DataFrame)

df[!, :x1] = CategoricalVector(df.x1)
df[!, :x3] = CategoricalVector(df.x3)

df_out, model, model_num, model_denom = TTE(df, 
    id_var = :id,
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    ipcw = true,
    censored = :censored,
    covariates = [:x1, :x2, :x3, :x4, :age], 
    save_w_model = true
    )

model
model_num
model_denom

# convergence issues, tolerance, starting values, etc.

## replicate TTE GLM
m1 = glm(@formula(outcome ~ treatment_first + x1_first + x2_first + x3_first + x4_first + age_first + fup + (fup ^ 2)), df_out, Bernoulli(), LogitLink(), wts = df_out.IPCW)

## fix starting values, iterations and tolerance
m2 = glm(@formula(outcome ~ treatment_first + x1_first + x2_first + x3_first + x4_first + age_first + trialnr + (trialnr ^ 2) + fup + (fup ^ 2)), 
        df_out, 
        Bernoulli(), LogitLink(), 
        wts = df_out.IPCW,
        start = zeros(11),
        maxiter = 100,
        atol = 1e-8,
        rtol = 1e-8
        )

    # multiply trial_period by 10 o solve convergence?
    # leave out trial period

```
R and Julia output differ slightly, even with fixed values for starting values, iterations and tolerance.
Possible reasons are discussed https://discourse.julialang.org/t/why-does-glm-jl-fail-to-fit-my-logistic-regression-model-but-scikit-learn-and-r-has-no-issues-i-think-i-found-the-reason/118553.
```

