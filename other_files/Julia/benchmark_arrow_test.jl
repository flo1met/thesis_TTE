# benchmark arrow

using CSV
using Pkg
Pkg.develop(path = "../TargetTrialEmulation.jl")
using TargetTrialEmulation
using CategoricalArrays
using DataFrames
using BenchmarkTools

# Load the data
data = CSV.read("data/trial_example.csv", DataFrame)

# Convert the categorical variables to categorical arrays
data[!, :catvarA] = CategoricalVector(data.catvarA)
data[!, :catvarB] = CategoricalVector(data.catvarB)

# perform sequential TTE
b_1 = @benchmarkable TTE(data, 
    id_var = :id,
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    ipcw = false,
    covariates = [:catvarA, :catvarB, :nvarA, :nvarB, :nvarC],
    estimate_surv = false,
    use_arrow = true
) samples=50 seconds=60

b_2 = @benchmarkable TTE(data, 
    id_var = :id,
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    ipcw = false,
    covariates = [:catvarA, :catvarB, :nvarA, :nvarB, :nvarC],
    estimate_surv = false,
    use_arrow = false
) samples=50 seconds=60

run(b_1)
run(b_2)