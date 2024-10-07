#### seqtrial: set up treatment arms of sequential target trial

#### necessary packages
# Arrow, DataFrames,

## todo: make it a ! function
## todo: integrate censoring function before making final df

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

        start_time = minimum(trial_tmp[!, :period]) # get start time
        trial_tmp[!, :fup] .= trial_tmp.period .- start_time # add follow-up-time
        #transform!(groupby(trial_tmp, :id), eachindex => :fup) # add follow-up-time

        sort!(trial_tmp, [:id, :period]) # sort for treatment assignment

        trials_dict[i] = trial_tmp
    end
    return trials_dict
end