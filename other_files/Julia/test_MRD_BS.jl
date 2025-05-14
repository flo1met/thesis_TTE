# test MRD and BS

using CSV
using Pkg
Pkg.develop(path = "../TargetTrialEmulation.jl")
using TargetTrialEmulation
using CategoricalArrays
using DataFrames
using GLM
using StatsModels
using Statistics
using StatsBase
using BenchmarkTools

# Load the data
df = CSV.read("data/data_simulated.csv", DataFrame)

df[!, :x1] = CategoricalVector(df.x1)
df[!, :x3] = CategoricalVector(df.x3)

@time df_out, out_model, model_num, model_denom, MRD_hat_CI = TTE(df, 
    id_var = :id,
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    ipcw = true,
    censored = :censored,
    covariates = [:x1, :x2, :x3, :x4, :age], 
    method = "ITT",
    save_w_model = true,
    fill_missing_timepoints = false,
    estimate_surv = true,
    B = 500,
    use_arrow = false
    )

@time df_out, out_model, model_num, model_denom, MRD_hat_CI = TTE(df, 
    id_var = :id,
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    ipcw = true,
    censored = :censored,
    covariates = [:x1, :x2, :x3, :x4, :age], 
    method = "ITT",
    save_w_model = true,
    fill_missing_timepoints = false,
    estimate_surv = true,
    B = 500,
    use_arrow = true
    )

#B = 100k, 1.5h
#    Row │ fup    S_0_mean  S_1_mean  MRD_hat     CIlow_emp    CIhigh_emp  BS_PE       CIlow_pct    CIhigh_pct 
#    │ Int64  Float64   Float64   Float64     Float64      Float64     Float64     Float64      Float64
#─────┼─────────────────────────────────────────────────────────────────────────────────────────────────────
#  1 │     0  0.989766  0.990805  0.00103957  -0.00893657  0.00734932  0.00141985  -0.00527018   0.0110157
#  2 │     1  0.981159  0.983048  0.00188883  -0.0144843   0.0133422   0.00236206  -0.00956451   0.0182619
#  3 │     2  0.972151  0.974903  0.00275263  -0.019656    0.019779    0.00321903  -0.0142738    0.0251612
#  4 │     3  0.960511  0.964342  0.00383077  -0.0258855   0.0280666   0.0042323   -0.020405     0.033547
#  5 │     4  0.942189  0.947634  0.00544465  -0.0353335   0.0403727   0.00577299  -0.0294834    0.0462228)

df_out
model
model_num
model_denom
MRD_hat

@benchmark TTE(df, 
id_var = :id,
outcome = :outcome, 
treatment = :treatment, 
period = :period, 
eligible = :eligible, 
ipcw = true,
censored = :censored,
covariates = [:x1, :x2, :x3, :x4, :age], 
method = "ITT",
save_w_model = true,
fill_missing_timepoints = false,
estimate_surv = false,
B = 1000
)



    df_out, model, model_num, model_denom = TTE(df, 
    id_var = :id,
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    ipcw = true,
    censored = :censored,
    covariates = [:x1, :x2, :x3, :x4, :age], 
    method = "PP",
    save_w_model = true,
    fill_missing_timepoints = true
    )

df_out, model, model_num, model_denom = TTE(df, 
    id_var = :id,
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    ipcw = true,
    censored = :censored,
    covariates = [:x1, :x2, :x3, :x4, :age], 
    method = "ITT",
    save_w_model = true
    )

model
model_num
model_denom


df = CSV.read("data/data_censored.csv", DataFrame)
BS_CI(df, 5, :id, [:x1, :x2, :x3, :x4, :age]) # convergene issues (due to dataset)

df_2 = CSV.read("data/data_simulated.csv", DataFrame)
df_2[!, :x1] = CategoricalVector(df_2.x1)
df_2[!, :x3] = CategoricalVector(df_2.x3)
BS_CI(df_2, 5, :id, [:x1, :x2, :x3, :x4, :age]) 

# Why points estimates different in R and Julia?



#####
function newdata2(newdata::DataFrame, max_fup::Int64)
    newdata = filter(row -> row.fup == 0, newdata)
    n_baseline = nrow(newdata)
    
    followup_times = 0:max_fup
    repeat!(newdata, inner = length(followup_times))
    newdata.fup = repeat(followup_times, outer = n_baseline)
    
    return newdata
end

max_fup = maximum(df_out[!, :fup])
0:(max_fup-1)
newdat = newdata2(df_out, 4)

newdat
newdat.fup

# select only id, trialnr and fup colum
dat = newdat[!, [:id, :trialnr, :fup]]

newdata = filter(row -> row.fup == 0, df_out)
n_baseline = nrow(newdata)

followup_times = 0:max_fup
repeat(followup_times, outer = n_baseline)