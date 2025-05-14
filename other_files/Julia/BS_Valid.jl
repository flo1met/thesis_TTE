# Bootsrap Validation

using DataFrames
using CSV
using Pkg
Pkg.develop(path = "../TargetTrialEmulation.jl")
using TargetTrialEmulation
using CategoricalArrays

df = CSV.read("data/sim_data_k1.csv", DataFrame)

@time df_out, model, MRD_hat = TTE(df, 
    id_var = :id,
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    ipcw = false,
    covariates = [:x1, :x2, :x3, :x4, :age], 
    method = "ITT",
    save_w_model = false,
    fill_missing_timepoints = false,
    estimate_surv = true,
    B = 1000
    )

MRD_hat

# B = 100k 16mins 10 failed
# 9 failed to converge
# 1 failed bc of not positive definite matrix

#─────────────────────────────────────────────────────────────────────────────────────, 1×9 DataFrame
# Row │ fup    S_0_mean  S_1_mean  MRD_hat    CIlow_emp   CIhigh_emp  BS_PE      CIlow_pct    CIhigh_pct 
#     │ Int64  Float64   Float64   Float64    Float64     Float64     Float64    Float64      Float64
#─────┼──────────────────────────────────────────────────────────────────────────────────────────────────
#   1 │     0   0.96329   0.98905  0.0257606  -0.0153819   0.0592996  0.0258849  -0.00777843   0.0669031


nrow(df_out)
ncol(df_out)




# Test 50k
df = CSV.read("data/sim_data_k1_50k.csv", DataFrame)

df[!, :x1] = CategoricalVector(df.x1)
df[!, :x3] = CategoricalVector(df.x3)

@time df_out, model, MRD_hat_out = TTE(df, 
    id_var = :id,
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    ipcw = false,
    covariates = [:x1, :x2, :x3, :x4, :age], 
    method = "ITT",
    save_w_model = false,
    fill_missing_timepoints = false,
    estimate_surv = true,
    B = 1000
    )

#    ────────────────────────────────────────────────────────────────────────────────────, 1×9 DataFrame
# Row │ fup    S_0_mean  S_1_mean  MRD_hat    CIlow_emp  CIhigh_emp  BS_PE      CIlow_pct  CIhigh_pct 
#     │ Int64  Float64   Float64   Float64    Float64    Float64     Float64    Float64    Float64
#─────┼───────────────────────────────────────────────────────────────────────────────────────────────
#   1 │     0  0.969948  0.989802  0.0198546  0.0164631   0.0230257  0.0198415  0.0166836   0.0232462)