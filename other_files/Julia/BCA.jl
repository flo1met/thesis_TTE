using DataFrames
using CSV
using Pkg
Pkg.develop(path = "../TargetTrialEmulation.jl")
using TargetTrialEmulation
using CategoricalArrays

df = CSV.read("data/data_simulated.csv", DataFrame)

df_out, model, MRD_hat, BS = TTE(df, 
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
df_out
model
MRD_hat
BS


using Bootstrap
BS[2]
confint(BS[1], BCaConfInt(0.95)) # BCa CI for first follow-up time
BCaConfInt(0.95)

BS_sample = BootstrapSample(BS[1])

# save BS[1] as ::BootstrapSamples in order to use the BCaConfInt function
BS_sample = BootstrapSample(BS[1])
confint(BS_sample, BCaConfInt(0.95)) # BCa CI for first follow-up time

confint(BS[1], BCaConfInt(0.95)) # BCa CI for first follow-up time


using StatsBase
using Distributions

#https://blog.s-schoener.com/2020-07-12-bootstrap/

function BCaCI(sample, theta, alpha)
    
    
end



test = [1,2,3,4,5,6,7,8,9,10]
test = CategoricalArray(test)
typeof(test)