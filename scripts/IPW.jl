#### IPW: stabilised inverse probability weighting to adjust for confounder bias

# necessary packages:
# GLM, StatsModels, DataFrames, Distributions

## todo: make it a ! function
## generalize formula createn

function IPW(df::DataFrame)
    # initialise IPW column
    df[!, :IPW] .= 0.0

    df_eligible = filter(row -> row.eligible == 1, df)

    # create model
    model_num = glm(@formula(treatment ~ period + (period^2)), df_eligible, Binomial(), LogitLink())
    model_denom = glm(@formula(treatment ~ catvarA + catvarB + catvarC + nvarA + nvarB + nvarC + period + (period^2)), df_eligible, Binomial(), LogitLink())
    
    prd_num = predict(model_num, df)
    prd_denom = predict(model_denom, df)

    # calculate weights with ifelse
    df[!, :IPW] .= ifelse.(df.treatment .== 1, (prd_num ./ prd_denom), ((1 .- prd_num) ./ (1 .- prd_denom)))

    # truncate weights at 99th percentile
    #df[!, :IPW] = ifelse.(df.IPW .> quantile(df.IPW, 0.99), quantile(df.IPW, 0.99), df.IPW)

    # delete models and weights
    prd_num = nothing
    prd_denom = nothing
    model_num = nothing
    model_denom = nothing
    
    return df
    #return model
end