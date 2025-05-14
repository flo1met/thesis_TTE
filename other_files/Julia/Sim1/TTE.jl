using DataFrames
using CSV
using Pkg
Pkg.develop(path = "../TargetTrialEmulation.jl")
using TargetTrialEmulation
using CategoricalArrays

# Get seed from command-line argument
SEED = parse(Int, ARGS[1])

data = CSV.read("out/Sim1/data_gen_sim$(SEED).csv", DataFrame)

data[!, :x1] = CategoricalVector(data.x1)
data[!, :x3] = CategoricalVector(data.x3)

df_out, model, MRD_hat_out = TTE(data, 
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

CSV.write("out/Sim1/cumsurvJulia$SEED.csv", MRD_hat_out)