#### convert_to_arrow
## convertes a DataFrame to an Arrow Table
### sorts DF before, for loop to work correctly

function convert_to_arrow(df::DataFrame)
    sort!(df, :period) # bring period in right order for loop

    tempdir = mktempdir() # create temp dir for .arrow
    arrow_file = joinpath(tempdir, "df.arrow")
    Arrow.write(arrow_file, df) # write arrow file
    empty!(df) # delete orig DF
    
    df = DataFrame(Arrow.Table(arrow_file)) # reread DF as arrow

    return df
end