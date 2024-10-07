#### art_censor: artificially censor, censoring function (censor individuals who deviate from the treatment)

# necessary packages:
# DataFrames

## todo: make it a ! function
## todo: optimize, profile

function art_censor(dict::Dict{Int64, DataFrame})
    for key in keys(dict)
        df = dict[key]
        
        # Initialize censor column
        df[!, :censor] .= 0
    
        # Group by :id and :trialnr
        grouped_df = groupby(df, [:id, :trialnr])
    
        # Create an empty DataFrame to hold the results after censoring
        censored_df = DataFrame()
    
        # Loop through the groups
        for group in grouped_df
            censored_group = group # Create a copy of the group to work with
            
            for i in 2:nrow(censored_group) # Start at 2 to compare with the previous row
                if censored_group.treatment[i-1] == 1 && censored_group.treatment[i] == 0
                    # Mark censoring for all following rows in the group
                    censored_group.censor[i:end] .= 1
                    
                    # Find first censored row
                    first_censor = findfirst(censored_group.censor .== 1)
                    
                    # If a censor is found, keep rows up to the first censored row
                    if first_censor != nothing
                        censored_group = censored_group[1:first_censor, :]
                    end
                    break # Stop further checks in this group since we censored it
                end
            end
            
            # Append the censored group to the final censored DataFrame
            append!(censored_df, censored_group)
        end
    
        # Update the original DataFrame in the dictionary with the censored DataFrame
        dict[key] = censored_df
    end
    
    return dict
end




#### old version
#function art_censor(dict::Dict{Int64, DataFrame})
#    for df in values(dict)
        # initialise censor column
#        df[!, :censor] .= 0
    
        # group by :id and :trialnr
#        grouped_df = groupby(df, [:id, :trialnr])
    
        # censor if treatment changes from 1 to 0
        ## TO OPTMIZE: use findfirst instead of loop
#        for group in grouped_df
#            for i in 2:nrow(group) # start at 2 to compare with previous row 
#                if group.treatment[i-1] == 1 && group.treatment[i] == 0
#                    group.censor[i:end] .= 1 # censor all following rows in the group
#                    # remove all rows after treatment change from 1 to 0 (except of first)
#                    first_censor = findfirst(group.censor .== 1)
#                    if first_censor != nothing
#                        group = group[1:first_censor, :]
#                    end
#
#                    break
#                end
#            end
#        end
#    end 
#    return dict
#end
