# first, check if there are any jld2 files in the data directory
# there may be several and need a list of them

jld2_files = []
for file in readdir(dataDir)
    if endswith(file, ".jld2")
        push!(jld2_files, joinpath(dataDir, file))
    end
end

# now read these files which contain dataframes and stack them
# call the stack jointFrame
if !isempty(jld2_files)
    jointFrame = DataFrame()
    for file in jld2_files
        df = load_object(file)
        jointFrame = vcat(jointFrame, df)
    end     
end

# now, load all completed models at paths which contain the string "bankRunResults"
completed_files = readdir(dataDir, join=true)
completed_files = filter(file -> occursin("bankRunResults", file), completed_files)
completed_models = DataFrame()
for file in completed_files
    df = CSV.read(file, DataFrame; header=false)
    completed_models = vcat(completed_models, df)
end 

# now name the first column :key and drop the second column
rename!(completed_models, :Column1 => :key)
select!(completed_models, Not(:Column2))

# now, we have three sets of files to filter
# files that contain the string "bankRunEndogenous"
# get all files of this form and load them into a list
endogenous_files = readdir(dataDir, join=true)
endogenous_files = filter(file -> occursin("bankRunEndogenous", file), endogenous_files)
# for each file, read it into a data frame, 
# then drop all rows not in completed_models
# and then overwrite the file with the filtered data
for file in endogenous_files
    df = CSV.read(file, DataFrame; header=false)
    # now filter the rows in df to only those in completed_models
    df = innerjoin(df, completed_models, on=:key)
    # now write the filtered data frame back to the file
    CSV.write(file, df, writeheader=false)
end

# now we do the same for bankRunExogenous
exogenous_files = readdir(dataDir, join=true)
exogenous_files = filter(file -> occursin("bankRunExogenous", file), exogenous_files)
# for each file, read it into a data frame,
# then drop all rows not in completed_models
# and then overwrite the file with the filtered data
for file in exogenous_files
    df = CSV.read(file, DataFrame; header=false)
    # now filter the rows in df to only those in completed_models
    df = innerjoin(df, completed_models, on=:key)
    # now write the filtered data frame back to the file
    CSV.write(file, df, writeheader=false)
end

# now, assemble the control file 
# read in babankRunParametersFin.csv
control_file = CSV.read(dataDir * "/bankRunParametersFin.csv", DataFrame; header=false)
# and bankRunlogNormal.csv
log_normal_file = CSV.read(dataDir * "/bankRunlogNormal.csv", DataFrame; header=false)
# and finally bankRunGeometric.csv
geometric_file = CSV.read(dataDir * "/bankRunGeometric.csv", DataFrame; header=false)




