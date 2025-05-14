# short benchmark if inerjoin is faster on sorted dataframes

using DataFrames
using BenchmarkTools
using Pkg
Pkg.develop(path = "../TargetTrialEmulation.jl")
using TargetTrialEmulation

# create two dataframes
df1 = DataFrame(a = 1:10^6, b = rand(1:10, 10^6))
df2 = DataFrame(a = 1:10^6, c = rand(1:10, 10^6))

# benchmark innerjoin on unsorted dataframes
@btime innerjoin($df1, $df2, on = :a) #   12.864 ms (200 allocations: 38.16 MiB)

# sort dataframes
sort!(df1, :a)
sort!(df2, :a)

# benchmark innerjoin on sorted dataframes
@btime innerjoin($df1, $df2, on = :a) # 12.611 ms (200 allocations: 38.16 MiB)



################

using CSV
using Random
using StatsBase

data = CSV.read("data/trial_example.csv", DataFrame)
data_shuf = shuffle(data)

@benchmark bootstrap_sample(data, :id)
#BenchmarkTools.Trial: 2816 samples with 1 evaluation per sample.
# Range (min … max):  1.246 ms …  16.436 ms  ┊ GC (min … max):  0.00% … 87.10%
# Time  (median):     1.465 ms               ┊ GC (median):     0.00%
# Time  (mean ± σ):   1.772 ms ± 693.987 μs  ┊ GC (mean ± σ):  12.62% ± 16.59%
#
#   ▆██▇▆▆▅▄▃▃▂▂▂▁▂ ▁ ▁ ▁        ▂▃▃▄▃▃▂▁▁                     ▁
#  ██████████████████████▇▇▇▇██▇█████████████▇▇█▇▇▇▆▇▇▄▅▇▇▄▄▅▄ █
#  1.25 ms      Histogram: log(frequency) by time      3.43 ms <
#
# Memory estimate: 5.41 MiB, allocs estimate: 454.

@benchmark bootstrap_sample(data_shuf, :id)
#BenchmarkTools.Trial: 1999 samples with 1 evaluation per sample.
# Range (min … max):  1.768 ms …  15.955 ms  ┊ GC (min … max):  0.00% …  0.00%
# Time  (median):     2.178 ms               ┊ GC (median):     0.00%
# Time  (mean ± σ):   2.502 ms ± 864.425 μs  ┊ GC (mean ± σ):  10.17% ± 14.32%
#
#    ▆█▆▂▁▁▁
#  ▂▇███████▇▆▄▃▃▃▃▃▃▂▃▂▂▂▂▂▄▄▅▄▃▄▄▃▃▃▂▂▂▂▂▂▂▂▂▂▂▁▂▁▁▁▁▁▁▁▁▁▁▁ ▃
#  1.77 ms         Histogram: frequency by time        4.52 ms <
#
# Memory estimate: 5.61 MiB, allocs estimate: 454.


function bootstrap_sample_2(df::DataFrame, id_var::Symbol)
    n = length(unique(df[!, id_var]))  # Number of unique IDs
    df_bs = DataFrame(
        bs_id = sample(unique(df[!, id_var]), n, replace=true),  # Sample IDs with replacement
        ID_new = 1:n  # Assign new sequential IDs
    )

    sort!(df_bs, :bs_id)  # Sort the bootstrap IDs

    # Merge bootstrap IDs with the original dataset
    df_bootstrapped = innerjoin(df_bs, df, on=:bs_id => id_var)

    return df_bootstrapped
end

@benchmark bootstrap_sample_2(data, :id)
#BenchmarkTools.Trial: 2746 samples with 1 evaluation per sample.
# Range (min … max):  1.188 ms …  16.661 ms  ┊ GC (min … max):  0.00% … 84.29%
# Time  (median):     1.472 ms               ┊ GC (median):     0.00%
# Time  (mean ± σ):   1.818 ms ± 771.892 μs  ┊ GC (mean ± σ):  12.14% ± 16.36%
#
#    ▄▇█▇▆▅▄▃▂▂▁▁  ▁  ▁  ▁   ▁▂▃▃▃▃▃▂▁ ▁                       ▁
#  ▄▄████████████████████████████████████▇▇▇▇▇▇▇▅▆▅▆▆▆▆▃▅▄▄▆▃▅ █
#  1.19 ms      Histogram: log(frequency) by time      3.72 ms <
#
# Memory estimate: 5.63 MiB, allocs estimate: 472.