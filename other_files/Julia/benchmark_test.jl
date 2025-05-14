# Benchmark

using BenchmarkTools
using CSV
using Pkg
using DataFrames
Pkg.develop(path = "../TargetTrialEmulation.jl")
using TargetTrialEmulation
using CategoricalArrays


# Load the data
data = CSV.read("data/trial_example.csv", DataFrame)

# Convert the categorical variables to categorical arrays
data[!, :catvarA] = CategoricalVector(data.catvarA)
data[!, :catvarB] = CategoricalVector(data.catvarB)

#  Benchmark the TTE function

# run once to compile
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

@benchmark TTE(data, 
id_var = :id,
outcome = :outcome, 
treatment = :treatment, 
period = :period, 
eligible = :eligible, 
ipcw = false,
covariates = [:catvarA, :catvarB, :nvarA, :nvarB, :nvarC],
estimate_surv = false
)

#BenchmarkTools.Trial: 1 sample with 1 evaluation per sample.
# Single result which took 7.783 s (13.37% GC) to evaluate,
# with a memory estimate of 3.70 GiB, over 5081829 allocations.

# call R function
using RCall

R"""
library(TrialEmulation)
data <- read.csv("data/trial_example.csv")
data$catvarA <- as.factor(data$catvarA)
data$catvarB <- as.factor(data$catvarB)

bench::mark(initiators(
  data = data,
  id = "id",
  period = "period",
  eligible = "eligible",
  treatment = "treatment",
  estimand_type = "ITT",
  outcome = "outcome",
  model_var = "assigned_treatment",
  outcome_cov = c("catvarA", "catvarB", "nvarA", "nvarB", "nvarC"),
  use_censor_weights = FALSE
))
"""
## A tibble: 1 x 13
#expression      min median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
#<bch:expr>    <bch> <bch:>     <dbl> <bch:byt>    <dbl> <int> <dbl>   <bch:tm>
#1 "initiators(~ 50.2s  50.2s    0.0199    23.3GB    0.478     1    24      50.2s
## i 4 more variables: result <list>, memory <list>, time <list>, gc <list>





############### multiple iterations
using BenchmarkTools
using CSV
using DataFrames

# Define number of iterations
num_iters = 1  # Change as needed

# Store results
results = DataFrame(time = Float64[], memory = Float64[], allocations = Int64[])

for i in 1:num_iters
    trial = @benchmarkable TTE(data, 
        id_var = :id,
        outcome = :outcome, 
        treatment = :treatment, 
        period = :period, 
        eligible = :eligible, 
        ipcw = false,
        covariates = [:catvarA, :catvarB, :nvarA, :nvarB, :nvarC],
        estimate_surv = false
    ) evals=1 samples=1
    
    res = run(trial)
    push!(results, (time = minimum(res.times) / 1e9,  # Convert ns to seconds
                    memory = res.memory / (1024^3),  # Convert bytes to GB
                    allocations = res.allocs))
end

# Save to CSV
CSV.write("out/benchmark_results_julia.csv", results)

R"""
library(bench)
library(TrialEmulation)

data <- read.csv("data/trial_example.csv")
data$catvarA <- as.factor(data$catvarA)
data$catvarB <- as.factor(data$catvarB)

# Number of iterations
num_iters <- 1

# Run benchmarks multiple times and store results
results_list <- vector("list", num_iters)

for (i in 1:num_iters) {
  results_list[[i]] <- bench::mark(initiators(
    data = data,
    id = "id",
    period = "period",
    eligible = "eligible",
    treatment = "treatment",
    estimand_type = "ITT",
    outcome = "outcome",
    model_var = "assigned_treatment",
    outcome_cov = c("catvarA", "catvarB", "nvarA", "nvarB", "nvarC"),
    use_censor_weights = FALSE
  ), iterations = 1)
}

# Convert to a data frame
results_df <- do.call(rbind, results_list)

# Save results
#write.csv(results_df, "out/benchmark_results_r.csv", row.names = FALSE)
"""



R"""
results_df[, c("time", "memory", "gc/sec", "n_itr", "n_gc", "total_time")]


#write.csv(results_df, "out/benchmark_results_r.csv", row.names = FALSE)
"""
