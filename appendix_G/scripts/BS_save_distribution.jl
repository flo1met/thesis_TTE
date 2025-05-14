# Bootsrap Validation

using DataFrames
using Arrow
using Pkg
#Pkg.develop(path = "../TargetTrialEmulation.jl")
using TargetTrialEmulation
using CategoricalArrays
using Plots
using CSV

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

df = Arrow.Table("03_appendix_G/datasets/data_200_-3.8_0.5_1.arrow") |> DataFrame

drop_missing_union!(df)

@time df_out, model, MRD_out, BS_sample_200 = TTE(df, 
    id_var = :ID,
    outcome = :Y, 
    treatment = :A, 
    period = :t, 
    eligible = :eligible, 
    censored = :C,
    ipcw = true,
    covariates = [:X2, :X4], 
    method = "ITT",
    save_w_model = false,
    fill_missing_timepoints = false,
    estimate_surv = true,
    B = 500,
    save_BS = true
    )
# save the BS_sample to a file to read in R
maxlen = maximum(length.(BS_sample_200))
cols = [vcat(vec, fill(missing, maxlen - length(vec))) for vec in BS_sample_200]
df_200 = DataFrame(cols, Symbol.("Iter", 1:5))

CSV.write("03_appendix_G/out/BS_sample_200.csv", df_200)

# histogram of BS_sample
histogram(BS_sample_200[1])
histogram(BS_sample_200[2])
histogram(BS_sample_200[3])
histogram(BS_sample_200[4])
histogram(BS_sample_200[5])

df = Arrow.Table("03_appendix_G/datasets/data_1000_-3.8_0.5_1.arrow") |> DataFrame

drop_missing_union!(df)

@time df_out, model, MRD_out, BS_sample_1000 = TTE(df, 
    id_var = :ID,
    outcome = :Y, 
    treatment = :A, 
    period = :t, 
    eligible = :eligible, 
    censored = :C,
    ipcw = true,
    covariates = [:X2, :X4], 
    method = "ITT",
    save_w_model = false,
    fill_missing_timepoints = false,
    estimate_surv = true,
    B = 500,
    save_BS = true
    )

# save the BS_sample to a file to read in R
maxlen = maximum(length.(BS_sample_1000))
cols = [vcat(vec, fill(missing, maxlen - length(vec))) for vec in BS_sample_1000]
df_1000 = DataFrame(cols, Symbol.("Iter", 1:5))

CSV.write("03_appendix_G/out/BS_sample_1000.csv", df_1000)

# histogram of BS_sample
histogram(BS_sample_1000[1])
histogram(BS_sample_1000[2])
histogram(BS_sample_1000[3])
histogram(BS_sample_1000[4])
histogram(BS_sample_1000[5])

df = Arrow.Table("03_appendix_G/datasets/data_5000_-3.8_0.5_1.arrow") |> DataFrame

drop_missing_union!(df)

@time df_out, model, MRD_out, BS_sample_5000 = TTE(df, 
    id_var = :ID,
    outcome = :Y, 
    treatment = :A, 
    period = :t, 
    eligible = :eligible, 
    censored = :C,
    ipcw = true,
    covariates = [:X2, :X4], 
    method = "ITT",
    save_w_model = false,
    fill_missing_timepoints = false,
    estimate_surv = true,
    B = 500,
    save_BS = true
    )

# save the BS_sample to a file to read in R
maxlen = maximum(length.(BS_sample_5000))
cols = [vcat(vec, fill(missing, maxlen - length(vec))) for vec in BS_sample_5000]
df_5000 = DataFrame(cols, Symbol.("Iter", 1:5))

CSV.write("03_appendix_G/out/BS_sample_5000.csv", df_5000)

# histogram of BS_sample

histogram(BS_sample_5000[1])
histogram(BS_sample_5000[2])
histogram(BS_sample_5000[3])
histogram(BS_sample_5000[4])
histogram(BS_sample_5000[5])

