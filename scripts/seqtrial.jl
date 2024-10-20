#### seqtrial: set up treatment arms of sequential target trial

#### necessary packages
# Arrow, DataFrames,

## todo: make it a ! function
## todo: integrate censoring function before making final df
## todo: assigned treatment variable

function seqtrial(df::DataFrame)
    # Emulate Target Trials
    trials_dict = Dict{Int64, DataFrame}() # Create dict to save DFs
    
    for i in unique(df[!,:period])
        filt_tmp(eligible, period) = eligible == 1 && period == i # creates template for filtering
        elig_tmp = filter([:eligible, :period] => filt_tmp, df).id
        filt_tmp2(id, period) = in(id, elig_tmp) && period >= i # filters all ids that are eligible at timepoint i and all following timepoints of them
        trial_tmp = filter([:id, :period] => filt_tmp2, df)

        if isempty(trial_tmp)
            continue  # Skip this iteration if no eligible data is found
        end

        trial_tmp[!, :trialnr] .= i # add Trial Nr

        start_time = minimum(trial_tmp[!, :period]) # get start time
        trial_tmp[!, :fup] .= trial_tmp.period .- start_time # add follow-up-time
        #transform!(groupby(trial_tmp, :id), eachindex => :fup) # add follow-up-time

        sort!(trial_tmp, [:id, :period]) # sort for treatment assignment

        # add indicator for baseline treatment assignment by id
        trial_tmp[!, :baseline_treatment] .= 0
        grouped_df = groupby(trial_tmp, :id)
        for group in grouped_df
            if group.treatment[1] == 1
                group.baseline_treatment .= 1
            end
        end  

        trials_dict[i] = trial_tmp
    end
    return trials_dict
end

