## testing cw 

using DataFrames
using CSV
using Profile
#using FloatingTableView
using Arrow
using FilePathsBase
using GLM
using StatsModels
using Distributions
using CategoricalArrays
using CodecBzip2
using RData

cd("C:/Users/fmetwaly/OneDrive - UMC Utrecht/Documenten/GitHub/thesis_TTE/data")
df = RData.load("data_censored.rda")["data_censored"]
df

# sort df

## rename columns
rename!(df, :treatment => :treat)

TTE(df; 
    outcome = :outcome, 
    treatment = :treat, 
    period = :period, 
    eligible = :eligible, 
    censored = :censored,
    covariates = [:x1, :x2, :x3, :x4, :age], 
    model = "glm", 
    method = "ITT"
    )

df

IPW(df, [:x1, :x2, :x3, :x4, :age])


f_str = "outcome ~ treat + period + (period^2) + x1 + x2 + x3 + x4 + age"

function gen_formula(formula_str::String)
    return eval(Meta.parse("@formula $formula_str"))
end


covariates::Array{Symbol,1} = [:x1, :x2, :x3, :x4, :age]
f_str = "outcome ~ treat + $(join(covariates, " + ")) + period + (period^2)"

eval(Meta.parse("@formula $f_str"))

f = gen_formula(f_str)