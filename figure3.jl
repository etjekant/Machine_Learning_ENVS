using PyCall, CSV, DataFrames, Plots, PyPlot, OrderedCollections
@pyimport matplotlib.pyplot as pyplt

function data_prep(val_par)
    val_par_split = split.(val_par, ",")
    val_par_flat = [i for arr in val_par_split for i in arr]
    val_par_unique = unique(val_par_flat)
    println(sort(val_par_unique))
    count_per_val = zeros(Int64, length(val_par_unique))
    for i in eachindex(val_par_unique)
        val = val_par_unique[i]
        for falt in val_par_flat
            if val == falt
                count_per_val[i] += 1
            end
        end
    end
    sortalg = sortperm(count_per_val)
    count_per_val = count_per_val[sortalg]
    val_par_unique = val_par_unique[sortalg]
    return count_per_val, val_par_unique
end
data = CSV.read("Lit_study.csv", DataFrame)
val_par = data[:, "Validation parameters"]
count_per_val, val_par_unique = data_prep(val_par)
top10_count_all = count_per_val[end-9:end] 
top10_val_all = val_par_unique[end-9:end]

#for regression
val_par = data[:, "Validation parameters"]
mode = data[:, "Mode"]
val_par = val_par[mode .== "R"]
count_per_val_reg, val_par_unique_reg = data_prep(val_par)
top10_count_reg = count_per_val_reg[end-9:end] 
top10_val_reg = val_par_unique_reg[end-9:end]

#For classification
val_par = data[:, "Validation parameters"]
mode = data[:, "Mode"]
val_par = val_par[mode .== "C"]
count_per_val_clas, val_par_unique_clas = data_prep(val_par)
top10_count_clas = count_per_val_clas[end-9:end] 
top10_val_clas = val_par_unique_clas[end-9:end]



fig = pyplt.figure(constrained_layout=true)
axs = fig.subplot_mosaic([["Left", "TopRight"],["Left", "BottomRight"]],
                          gridspec_kw=Dict("width_ratios"=>[2, 1]))
# Left is the total plot (first graph)
axs["Left"].set_title("Total models (A)", fontsize=11)
axs["Left"].bar(top10_val_all, top10_count_all ./ 75)
axs["Left"].set_xticklabels(top10_val_all, rotation=80)
axs["Left"].set_ylabel("% used in literature")
# Topright is the reg models (second graph)
axs["TopRight"].set_title("Regression models (B)", fontsize=11)
axs["TopRight"].bar(top10_val_reg, top10_count_reg , color=reg_color)
axs["TopRight"].set_xticklabels(top10_val_reg, rotation=80)

axs["BottomRight"].set_title("Classification models (C)", fontsize=11)
axs["BottomRight"].bar(top10_val_clas, top10_count_clas, color=Class_color)
axs["BottomRight"].set_xticklabels(top10_val_clas, rotation=80)

pyplt.savefig("foo3.png")