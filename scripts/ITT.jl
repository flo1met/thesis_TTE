#### ITT: estimate intetion-to-treat effect

# necessary packages
#

## todo

function ITT(df::DataFrame)
    df = convert_to_arrow(df)
    df = IPW(df)
    out = seqtrial(df)
    df_seq = dict_to_df(out)

    model = glm(@formula(outcome ~ baseline_treatment + trialnr + (trialnr^2) + fup + (fup^2) + catvarA + catvarB + catvarC + nvarA + nvarB + nvarC), df_seq, Binomial(), LogitLink(), wts = df_seq.IPW)

    return model
end