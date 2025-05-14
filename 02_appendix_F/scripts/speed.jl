using Pkg
#Pkg.add(PackageSpec(url="https://github.com/flo1met/TargetTrialEmulation.jl", rev="dev")) # install package from GitHub
using TargetTrialEmulation
using CSV
using DataFrames


files = readdir("02_appendix_F/datasets/")
results = DataFrame(file=String[], time_seconds=Float64[], alloc_kb=Float64[])

for fname in files
    print("Processing $fname")
    df = CSV.read("02_appendix_F/datasets/$fname", DataFrame)

    timing = @timed begin
        df_out, model, MRD_out, BS_sample_200 = TTE(df, 
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
    end

    push!(results, (
        file = fname,
        time_seconds = timing.time,
        alloc_kb = timing.bytes / 1024,
    ))
end

CSV.write("02_appendix_F/out/performance_summary_julia.csv", results)

results