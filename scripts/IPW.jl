#### IPW: inverse probability weighting

# necessary packages:
# GLM, StatsModels, DataFrames

## todo: make it a ! function

function IPW(df::DataFrame, formula::FormulaTerm)
    # create model
    model = glm(formula, df, Binomial(), LogitLink())
    
    # calculate weights
    df[!, :weights] .= predict(model, df, terms(model))
    
    # apply inverse propensity score weights (if censored = 1/weight, if not censore 1/(1-weight))
    df[!, :weights] .= ifelse.(df.censor .== 1, 1 ./ df.weights, 1 ./ (1 .- df.weights))
       
    return df
    
end