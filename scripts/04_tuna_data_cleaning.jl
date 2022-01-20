########## 
##########
# Niche model specification  
##########
##########
# AUTHOR: Cole B. Brookson
# DATE OF CREATION: 2022-01-07
##########
##########

# set up =======================================================================

include("./00_setup.jl")

using DrWatson
@quickactivate "tuna-diet-prediction"
using DataFrames, CSV, Plots, DelimitedFiles

# read in data 
avail_data = DataFrame(CSV.File(
    datadir("./tuna-data/raw/DIET_FED_SAIP_PRE_proportion_combined.csv")))
consump_data = DataFrame(CSV.File(
    datadir("./tuna-data/raw/meanN%_FO%_summary_combo.csv")))
trait_data = DataFrame(CSV.File(
    datadir("./tuna-data/raw/trait_data_cole_111821.csv")))

# data cleaning ================================================================

allowmissing!(avail_data)
for i in 1:size(avail_data, 1)
    for j in 1:size(avail_data, 2)
        if avail_data[i,j] == "NA"
            avail_data[i,j] = missing 
        end 
    end 
end
CSV.write(datadir("./tuna-data/clean/avail_data.csv"), avail_data)

allowmissing!(consump_data)
for i in 1:size(consump_data, 1)
    for j in 1:size(consump_data, 2)
        if consump_data[i,j] == "NA"
            consump_data[i,j] = missing 
        end 
    end 
end
CSV.write(datadir("./tuna-data/clean/consump_data.csv"), consump_data)

allowmissing!(trait_data)
for i in 1:size(trait_data, 1)
    for j in 1:size(trait_data, 2)
        if trait_data[i,j] == "NA"
            trait_data[i,j] = missing 
        end 
    end 
end
CSV.write(datadir("./tuna-data/clean/trait_data.csv"), trait_data)

