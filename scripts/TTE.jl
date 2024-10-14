#### TTE: Target Trial Emulation wrapper function

function TTE(df::DataFrame;
    outcome::Symbol,
    treatment::Symbol,
    period::Symbol,
    eligible::Symbol,
    censored::Symbol,
    covariates::Array{Symbol,1},
    model::String,
    method::String)

    # rename columns to standard names
    rename!(df, outcome => :outcome, 
                treatment => :treatment, 
                period => :period, 
                eligible => :eligible,
                censored => :censored)




    # rerename columns for final output
    #rename!(df, :outcome => outcome, 
    #            :treatment => treatment, 
    #            :period => period, 
    #            :eligible => eligible)

    return df
end

