## testing cw 

using DataFrames
using CSV
using Profile
#using FloatingTableView
using FilePathsBase
using GLM
using StatsModels
using CategoricalArrays
using CodecBzip2
using RData
using Pkg
Pkg.develop(path = "C:/Users/fmetwaly/OneDrive - UMC Utrecht/Documenten/GitHub/TargetTrialEmulation.jl")
using TargetTrialEmulation

df = RData.load("thesis_TTE/data/data_censored.rda")["data_censored"]

df[!, :x1] = CategoricalVector(df.x1)
df[!, :x3] = CategoricalVector(df.x3)

df_out, model, model_num, model_denom = TTE(df, 
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    censored = :censored,
    covariates = [:x1, :x2, :x3, :x4, :age], 
    save_w_model = true
    )


model
model_num
model_denom

glm(@formula(outcome ~ baseline_treatment + trialnr + (trialnr^2) + fup + (fup^2) + x1 + x2 + x3 + x4 + age), df_out, Binomial(), LogitLink())

## R 
### numerator
# read csv
wm_num_d_R = CSV.read("thesis_TTE/data/wm_num_d.csv", DataFrame)
glm(@formula(censored == 0 ~ period + period^2), wm_num_d_R, Binomial(), LogitLink())

### denominator
wm_denom_d_R = CSV.read("thesis_TTE/data/wm_denom_d.csv", DataFrame)
glm(@formula(censored == 0 ~ period + period^2), wm_denom_d_R, Binomial(), LogitLink())


wdf_out = TTE(df, 
    outcome = :outcome, 
    treatment = :treatment, 
    period = :period, 
    eligible = :eligible, 
    censored = :censored,
    covariates = [:x1, :x2, :x3, :x4, :age], 
    save_w_model = false
    )








# export to csv
CSV.write("IPCW.csv", out[1])

out[2]
out[3]

test2 = predict(out[2], df)
test = predict(out[2], df)

sq = seqtrial(df, [:x1, :x2, :x3, :x4, :age])

df_seq = dict_to_df(sq)

#export to csv
CSV.write("thesis_TTE/data/seqtrial.csv", df_seq)
#cumprod of IPCW

# outcome model
glm(@formula(outcome ~ baseline_treatment + trialnr + (trialnr^2) + fup + (fup^2)), df_seq, Binomial(), LogitLink())

df_seq.IPCW

# output type of every column in df_seq
for col in names(df_seq)
    println("Column: $col")
    println("Type: $(eltype(df_seq[!, col]))")
end

for col in names(df)
    println("Column: $col")
    println("Type: $(eltype(df[!, col]))")
end








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


###########################################################################
df = RData.load("data_censored.rda")["data_censored"]

df = convert_to_arrow(df)
out = seqtrial(df)
out_df = dict_to_df(out)

IPTW(out_df, [:x2, :x4, :age])
IPCW(out_df, [:x2, :x4, :age])

out_df.IPTW = cumprod(out_df.IPTW)
out_df.IPCW = cumprod(out_df.IPCW)

out_df.weights = out_df.IPTW .* out_df.IPCW

model = glm(@formula(outcome ~ baseline_treatment + period + (period^2) + x1 + x2 + x3 + x4 + age), out_df, Binomial(), LogitLink(), wts = out_df.weights)

coefs = coef(model)

coefs_exp = exp.(coefs)

# export out_df to csv
CSV.write("out_df.csv", out_df)











tests = [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]

tests4 = cumprod(tests)
test2 = 1 ./ tests4

tests3 = 1 ./ tests
tests5 = cumprod(tests3)


testsA = [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
testsB = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]

testsAc = cumprod(testsA)
testsBc = cumprod(testsB)

testsA2 = 1 ./ testsAc
testsB2 = 1 ./ testsBc

testsF = testsA2 ./ testsB2


testsA22 = 1 ./ testsAc
testsB22 = 1 ./ testsBc

testsAc2 = cumprod(testsA22)
testsBc2 = cumprod(testsB22)

testsF2 = testsAc2 .* testsBc2

testsF
testsF2