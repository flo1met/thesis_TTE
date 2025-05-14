# Julia Analysis Simulation 2
using DataFrames
using TargetTrialEmulation
using CSV
using Random

# Get command-line arguments
seed = parse(Int, ARGS[1])      # SLURM ID
nsample = parse(Int, ARGS[2])   # sample size

Random.seed!(seed)


function drop_missing_union!(df::DataFrame)
    for col in names(df)
        # Check if the column type is Union{T, Missing}
        eltype(df[!, col]) <: Union{Missing, Any} || continue
        
        # If the column has no missing values, convert it to its non-missing type
        if !any(ismissing, df[!, col])
            df[!, col] = convert(Vector{nonmissingtype(eltype(df[!, col]))}, df[!, col])
        end
    end
    return df
end

# Read data from csv
data = CSV.read("out/datasets/data_$(nsample)_$(seed).csv", DataFrame)
drop_missing_union!(data)

# Run TTE model
df_out, model = TTE(data, 
    id_var = :ID,
    outcome = :Y, 
    treatment = :A, 
    period = :t, 
    eligible = :eligible, 
    ipcw = true,
    censored = :C,
    covariates = [:X2, :X4],
    method = "ITT",
    save_w_model = false,
    estimate_surv = false,
    use_arrow = false
)

first(df_out, 5)
print(model)