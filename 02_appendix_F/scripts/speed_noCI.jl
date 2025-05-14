using Pkg
#Pkg.add(PackageSpec(url="https://github.com/flo1met/TargetTrialEmulation.jl", rev="dev"))
using TargetTrialEmulation
using CSV
using DataFrames


files = readdir("02_apendix_F/datasets/")
results = DataFrame(file=String[], time_seconds=Float64[], alloc_kb=Float64[])

for fname in files
    println("Processing $fname")
    df = CSV.read("02_apendix_F/datasets/$fname", DataFrame)

    timing = @timed begin
        df_out, model = TTE(df, 
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
            estimate_surv = false
        )
    end

    push!(results, (
        file = fname,
        time_seconds = timing.time,
        alloc_kb = timing.bytes / 1024
    ))
end

CSV.write("02_apendix_F/out/performance_summary_noCI_julia.csv", results)

results