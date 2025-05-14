using DataFrames
using CSV
using Profile
using FloatingTableView
using Arrow
using FilePathsBase

cd("C:/Users/Florian/Documents/GitHub\thesis_TTE/data")
df = CSV.read("trial_example.csv", DataFrame)


function seqtrial(df::DataFrame)
    sort!(df, :period)
    Arrow.write("df.arrow", df) # write apache arrow
    df = nothing # delete df

    df = DataFrame(Arrow.Table("df.arrow"))
    
    for i in unique(df[!,:period])
        println(i)
    end

end


# old function
function seqtrial(df::DataFrame)
    sort!(df, :period) # bring period in right order for loop

    tempdir = mktempdir() # create temp dir for .arrow
    arrow_file = joinpath(tempdir, "df.arrow")
    Arrow.write(arrow_file, df) # write arrow file
    empty!(df) # delete orig DF
    
    df = DataFrame(Arrow.Table(arrow_file)) # reread DF as arrow
        
    # Emulate Target Trials
    trials_dict = Dict{Int64, DataFrame}() # Create dict to save DFs
    for i in unique(df[!,:period])
        filt_tmp(eligible::Int64, period::Int64) = eligible == 1 && period >= i # creates template for filtering
        trial_tmp = filter([:eligible, :period] => filt_tmp, df)
        trial_tmp[!, :trialnr] .= i
        trials_dict[i] = trial_tmp
    end
    return vcat(values(trials_dict)...) # combine all DFs in dict
end




############# correct filt_temp ###################
## todo: make it a ! function

function seqtrial(df::DataFrame)
    sort!(df, :period) # bring period in right order for loop

    tempdir = mktempdir() # create temp dir for .arrow
    arrow_file = joinpath(tempdir, "df.arrow")
    Arrow.write(arrow_file, df) # write arrow file
    empty!(df) # delete orig DF
    
    df = DataFrame(Arrow.Table(arrow_file)) # reread DF as arrow
        
    # Emulate Target Trials
    trials_dict = Dict{Int64, DataFrame}() # Create dict to save DFs
    for i in unique(df[!,:period])
        filt_tmp(eligible::Int64, period::Int64) = eligible == 1 && period == i # creates template for filtering
        elig_tmp = filter([:eligible, :period] => filt_tmp, df).id
        filt_tmp2(id::Int64, period::Int64) = in(id, elig_tmp) && period >= i # filters all ids that are eligible at timepoint i and all following timepoints of them
        trial_tmp = filter([:id, :period] => filt_tmp2, df)

        trial_tmp[!, :trialnr] .= i # add Trial Nr 
        transform!(groupby(trial_tmp, :id), eachindex => :fup) # add follow-up-time

        trials_dict[i] = trial_tmp
    end
    return vcat(values(trials_dict)...) # combine all DFs in dict
end


# test function
df = CSV.read("trial_example.csv", DataFrame)
out = seqtrial(df)
@profview_allocs seqtrial(df)
browse(out)
browse(df)
#############################################################################

## censoring function (censor individuals who deviate from the treatment)
## todo make it a ! function
function censor(df::DataFrame)
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
                break
            end
        end
    end
    
    return df
end

out_censor = censor(out)
out_censor
browse(out_censor)


#############################################################################

####### IPW function ######
using GLM
using StatsModels

function IPW(df::DataFrames, formula::String)   
    # create model
    model = glm(@formula(formula), df, Binomial(), LogitLink())
    
    # calculate weights
    df[!, :weights] .= predict(model, df, terms(model))
    
    # apply inverse propensity score weights (if censored = 1/weight, if not censore 1/(1-weight))
    df[!, :weights] .= ifelse.(df.censor .== 1, 1 ./ df.weights, 1 ./ (1 .- df.weights))
       
    return df
    
end





#############################################################################


####### tests ######
sort!(out, [:outcome])

sort!(stdict[150], [:id, :period, :outcome])

filt_temp(treatment::Int64, period::Int64) = treatment == 1 && period >= 333
test = filter([:treatment, :period] => filt_temp, df)
@allocated unique(df[!,:period])

groups = [:id]
df_group = groupby(df, groups)

for i in eachrow(df)
    if df.treatment == 1 && df.period >= 1 + i
        println(1 + i)
    end
end

for (i, row) in eachrow(df)
    if df.treatment == 1 && df.period >= 1+i
        println(1+i)
    end
end

for i in eachrow(df)
    println(i)
end

eachrow(df)




test = filter([:treatment, :period] => filt_temp, df)
browse(test)
@allocated filter(:treatment => filt_temp, df)

Base.summarysize(df)
Base.summarysize(test)




Arrow.write("test2.arrow", df)
df = DataFrame(Arrow.Table("test.arrow"))
df_filt = filter([:treatment, :period] => filt_temp, df)

Base.summarysize(df)
Base.summarysize(df_filt)







# no arrow
function seqtrial2(df::DataFrame)
    sort!(df, :period)        
    # Emulate Target Trials
    trials_dict = Dict{Int64, DataFrame}() # Create Dict to save DFs
    for i in unique(df[!,:period])
        filt_tmp(eligible::Int64, period::Int64) = eligible == 1 && period >= i # creates template for filtering
        trial_tmp = filter([:eligible, :period] => filt_tmp, df)
        trial_tmp[!, :trialnr] .= i
        trials_dict[i] = trial_tmp
    end
    return vcat(values(trials_dict)...) 
end
df = CSV.read("trial_example.csv", DataFrame)
out = seqtrial2(df)
@profview seqtrial2(df)

@time seqtrial(df) #0.869559 seconds (57.92 k allocations: 1.071 GiB, 24.77% gc time)
@time seqtrial2(df) #1.038080 seconds (54.94 k allocations: 1.071 GiB, 34.61% gc time)


#### Benchmark
using BenchmarkTools

df = CSV.read("trial_example.csv", DataFrame)
@benchmark seqtrial(df)
df = CSV.read("trial_example.csv", DataFrame)
@benchmark seqtrial2(df)