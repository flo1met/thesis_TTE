#### IPCW: stabilised inverse probability of censor weighting to adjust for ____ bias introduced by censoring

# necessary packages:
# GLM, StatsModels, DataFrames, Distributions

## todo: make it a ! function
## generalize formula creation

function IPCW(df::DataFrame, covariates::Array{Symbol,1})
    # initialise IPW column
    df[!, :IPCW] .= 1.0

    df_eligible = filter(row -> row.eligible == 1, df)

    # create formula string
    formula_string_d = "censored ~ $(join(covariates, " + ")) + baseline_treatment + period + (period^2)"

    # create model
    model_num = glm(@formula(censored ~ baseline_treatment + period + (period^2)), df_eligible, Binomial(), LogitLink())
    model_denom = glm(eval(Meta.parse("@formula $formula_string_d")), df_eligible, Binomial(), LogitLink())
    
    prd_num = predict(model_num, df)
    prd_denom = predict(model_denom, df)

    # calculate inverse propensity weights with ifelse
    df[!, :IPCW] .= ifelse.(df.treatment .== 1, (prd_num ./ prd_denom), ((1 .- prd_num) ./ (1 .- prd_denom)))

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