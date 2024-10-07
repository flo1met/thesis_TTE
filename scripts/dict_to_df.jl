#### dict_to_df

function dict_to_df(dict::Dict)
    return vcat(values(dict)...) # combine all DFs in dict
end