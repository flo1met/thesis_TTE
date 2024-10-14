#### testing code and performance

using DataFrames
using CSV
using Profile
using FloatingTableView
using Arrow
using FilePathsBase
using GLM
using StatsModels
using Distributions
using CategoricalArrays

cd("C:/Users/Florian/Documents/GitHub/thesis_TTE/data")
df = CSV.read("trial_example.csv", DataFrame)
df[!, :catvarA] = CategoricalVector(df.catvarA)
df[!, :catvarB] = CategoricalVector(df.catvarB)
df[!, :catvarC] = CategoricalVector(df.catvarC)

out_model = ITT(df)


df = convert_to_arrow(df)
df = IPW(df)
out = seqtrial(df)
df_seq = dict_to_df(out)

df_seq[!, :catvarA] = CategoricalVector(df_seq.catvarA)
df_seq[!, :catvarB] = CategoricalVector(df_seq.catvarB)
df_seq[!, :catvarC] = CategoricalVector(df_seq.catvarC)
model = glm(@formula(outcome ~ baseline_treatment + trialnr + (trialnr^2) + fup + (fup^2) + catvarA + catvarB + catvarC + nvarA + nvarB + nvarC), 
            df_seq, Binomial(), LogitLink(), wts = df_seq.IPW)

model_nowght = glm(@formula(outcome ~ baseline_treatment + trialnr + (trialnr^2) + fup + (fup^2) + catvarA + catvarB + catvarC + nvarA + nvarB + nvarC), 
df_seq, Binomial(), LogitLink())

weights = CSV.read("weights.csv", DataFrame)[:, 1] |> vec
data = CSV.read("data.csv", DataFrame)

data[!, :catvarA] = CategoricalVector(data.catvarA)
data[!, :catvarB] = CategoricalVector(data.catvarB)
data[!, :catvarC] = CategoricalVector(data.catvarC)
model = glm(@formula(outcome ~ assigned_treatment + trial_period + (trial_period^2) + followup_time + (followup_time^2) + catvarA + catvarB + catvarC + nvarA + nvarB + nvarC), 
            data, Binomial(), LogitLink(), wts = data.weight)

model_nowght = glm(@formula(outcome ~ assigned_treatment + trial_period + (trial_period^2) + followup_time + (followup_time^2) + catvarA + catvarB + catvarC + nvarA + nvarB + nvarC), 
            data, Binomial(), LogitLink())


model_2 = glm(@formula(outcome ~ assigned_treatment), data, Binomial(), LogitLink())
df_wght = IPW(df)




out = seqtrial(df_wght)
out_censor = art_censor(out)

df_fin = dict_to_df(out_censor)

formula_obj = @formula(censor ~ treatment + fup)
test_glm = glm(formula_obj, df_fin, Binomial(), LogitLink())

pred = predict(test_glm, df_fin)
# get range of pred
println("Min: ", minimum(pred))
println("Max: ", maximum(pred))


browse(out[1])
browse(out_censor[1])
browse(df_fin)

# check dimensions
println("Original: ", size(out[1]))
println("Censored: ", size(out_censor[1]))

lowdel = findfirst(out_censor[1].censor .== 1)
out_del = delete!(out_censor[1], lowdel+1:nrow(out_censor[1]))
browse(out_del)


#### vcat(values(trials_dict)...) # combine all DFs in dict



#####

## R model: 
    #glm(formula = outcome ~ assigned_treatment + trial_period + I(trial_period^2) + 
    #followup_time + I(followup_time^2) + catvarA + catvarB + 
    #nvarA + nvarB + nvarC, family = binomial(link = "logit"), 
    #data = data, weights = w)


df_seq = dict_to_df(out)

## Julia model:
model = glm(@formula(outcome ~ treatment + period + (period^2) + fup + (fup^2) + catvarA + catvarB + catvarC + nvarA + nvarB + nvarC), df_seq, Binomial(), LogitLink())



####


# full ITT test
using CategoricalArrays
df = CSV.read("trial_example.csv", DataFrame)
df[!, :catvarA] = CategoricalVector(df.catvarA)
df[!, :catvarB] = CategoricalVector(df.catvarB)
df[!, :catvarC] = CategoricalVector(df.catvarC)




df_wght = IPW(df)

out = seqtrial(df)
df_seq = dict_to_df(out)

typeof(df_seq.catvarA)
df_seq[!, :catvarA] = CategoricalVector(df_seq.catvarA)
df_seq[!, :catvarB] = CategoricalVector(df_seq.catvarB)
df_seq[!, :catvarC] = CategoricalVector(df_seq.catvarC)

#df_f = IPW(df, df_seq)


browse(df_seq)
sort!(df_seq, [:id, :trialnr])

CSV.write("trial_example_seq.csv", df_seq)

df_a1 = filter(row -> row.assigned_treatment == 1, df_seq)
df_a0 = filter(row -> row.assigned_treatment == 0, df_seq)

model = glm(@formula(outcome ~ assigned_treatment + trialnr + (trialnr^2) + fup + (fup^2) + catvarA + catvarB + catvarC + nvarA + nvarB + nvarC), df_f, Binomial(), LogitLink(), wts = df_seq.IPW)
model_a1 = glm(@formula(outcome ~ assigned_treatment + trialnr + (trialnr^2) + fup + (fup^2) + catvarA + catvarB + catvarC + nvarA + nvarB + nvarC), df_a1, Binomial(), LogitLink(), wts = df_a1.IPW)
model_a0 = glm(@formula(outcome ~ assigned_treatment + trialnr + (trialnr^2) + fup + (fup^2) + catvarA + catvarB + catvarC + nvarA + nvarB + nvarC), df_a0, Binomial(), LogitLink(), wts = df_a0.IPW)


df_seq.IPW
browse(df_seq)


typeof(df_seq.catvarA)

groupby(df, :id) do group
    if group.treatment[1] == 1
        group[!, :baseline_treatment] .= 1
    else
        group[!, :baseline_treatment] .= 0                
    end
end   

df_baseline = combine(groupby(df, :id), :treatment => (x -> x[1] == 1 ? 1 : 0) => :baseline_treatment)

# Join the baseline_treatment back to the original DataFrame
df = leftjoin(df, df_baseline, on=:id)
# check if this is correct, if yes implement in seqtrial.jl











# temp
function art_censor(df::DataFrame)
    # initialise censor column
    df[!, :censor] .= 0
    
    # group by :id and :trialnr
    grouped_df = groupby(df, [:id, :trialnr])
    
    # censor if treatment changes from 1 to 0
    ## TO OPTMIZE: use findfirst instead of loop
    for group in grouped_df
        for i in 2:nrow(group) # start at 2 to compare with previous row 
            if group.treatment[i-1] == 1 && group.treatment[i] == 0
                group.censor[i:end] .= 1 # censor all following rows in the group
                # remove all rows after treatment change from 1 to 0 (except of first)

                break
            end
        end
    end
    
    return df
end

function art_censor(dict::Dict{Int64, DataFrame})
    for df in values(dict)
        art_censor(df)
    end
    return dict
    
end



#################




function art_censor(df::DataFrame)
    # initialise censor column
    df[!, :censor] .= 0
    
    # group by :id and :trialnr
    grouped_df = groupby(df, [:id, :trialnr])
    
    # censor if treatment changes from 1 to 0
    ## TO OPTMIZE: use findfirst instead of loop
    first0 = findfirst(group.treatment .== 0)
    if first0 != nothing
        # censor all following rows in the group and remove all rows after treatment change from 1 to 0 (except of first)
        group.censor[first0:end] .= 1
        # remove rows
        group.censor[(first0 + 1):end] .= nothing

    end

    
    return df
end

function art_censor(df::DataFrame)
    # initialise censor column
    df[!, :censor] .= 0
    
    # group by :id and :trialnr
    grouped_df = groupby(df, [:id, :trialnr])
    

    
    # censor if treatment changes from 1 to 0
    ## TO OPTMIZE: use findfirst instead of loop
    first0 = findfirst(group.treatment .== 0)
    if first0 != nothing
        # censor all following rows in the group and remove all rows after treatment change from 1 to 0 (except of first)
        group.censor[first0:end] .= 1
        # remove rows
        group.censor[(first0 + 1):end] .= nothing

    end

    
    return df
end