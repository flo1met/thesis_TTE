using CSV
using Pkg
Pkg.develop(path = "../TargetTrialEmulation.jl")
using TargetTrialEmulation
using CategoricalArrays
using DataFrames

df = CSV.read("data/data_simulated.csv", DataFrame)

df[!, :x1] = CategoricalVector(df.x1)
df[!, :x3] = CategoricalVector(df.x3)

df_out, model, MRD_hat = TTE(df, 
    id_var = :id,
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    ipcw = true,
    censored = :censored,
    covariates = [:x1, :x2, :x3, :x4, :age], 
    method = "ITT",
    save_w_model = false,
    fill_missing_timepoints = false,
    estimate_surv = true,
    B = 500
    )

CSV.write("out/Simulation/Julia_surv.csv", MRD_hat)

