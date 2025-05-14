using DataFrames
using CSV
using Profile
using FloatingTableView

cd("C:/Users/Florian/Documents/Utrecht University/05_thesis/BIOSTAT-07 - Confidence Intervals in Emulated Target Trials/Julia")
df = CSV.read("trial_example.csv", DataFrame)

function seqtrial!(df::DataFrame)
    groups = [:id, :treatment]
    transform!(groupby(df, groups), eachindex => :fup)

    df.durA = df.treatment # initialize durA column
    # cloning
    df_group = groupby(:id)
    for g in df_group
        for row in eachrow(g) 
            if row.treatment == 0
                continue # skip treatment == 0
            end
            
    
        end 
        
    end
end

seqtrial!(df)

@profview seqtrial!(df)

browse(df) 