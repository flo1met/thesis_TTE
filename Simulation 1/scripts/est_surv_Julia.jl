# Julia Analysis Simulation 1

#### TODO: Seed the analysis correctly (change to multiprocessing?)

using DataFrames
using Arrow
#using Pkg
#Pkg.develop(path = "../TargetTrialEmulation.jl")
using TargetTrialEmulation
using Random
using Base.Threads
using ProgressMeter

# set seed
Random.seed!(1337)

# Create log
log_file = "Simulation 1/out/Julia/error_log.txt"
mkpath("Simulation 1/out/Julia")

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

function process_file(file, p)
    try
        # Read data
        data = Arrow.Table("Simulation 1/datasets/" * file) |> DataFrame
        drop_missing_union!(data)

        # Run TTE model
        df_out, model, mrd_out = TTE(data, 
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
            estimate_surv = true,
            B = 500,
            use_arrow = false
        )

        # Save results
        Arrow.write("Simulation 1/out/Julia/Julia_MRD_" * file, mrd_out)
    catch e
        # Log error to file
        open(log_file, "a") do io
            println(io, "$(Dates.now()) - Error processing file $file: ", e)
        end
    finally
        next!(p)  # Update progress bar
    end
end

# Get list of files
files = readdir("Simulation 1/datasets/")
#files = ["data_200_1.arrow", "data_200_10.arrow","data_200_16.arrow","data_200_15.arrow","data_200_14.arrow","data_200_13.arrow","data_200_12.arrow"]

# Create a progress bar
p = Progress(length(files); desc="Processing files... ")

# Run in parallel with multithreading
t = @elapsed begin
    @threads for i in eachindex(files)
        process_file(files[i], p)
    end
end



