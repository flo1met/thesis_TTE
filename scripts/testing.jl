#### testing code and performance

using DataFrames
using CSV
using Profile
using FloatingTableView
using Arrow
using FilePathsBase
using GLM
using StatsModels

cd("C:/Users/Florian/Documents/GitHub/thesis_TTE/data")
df = CSV.read("trial_example.csv", DataFrame)

out = seqtrial(df)
out_censor = art_censor(out)

df_fin = dict_to_df(out_censor)

out_IPW = IPW(df_fin, @formula(censor ~ treatment + fup))

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