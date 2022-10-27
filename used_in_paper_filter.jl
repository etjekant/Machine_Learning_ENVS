using PyCall, CSV, DataFrames, Plots, PyPlot, OrderedCollections
@pyimport matplotlib.pyplot as pyplt
function value_finder(Other_method1, Best_method1)
    total_methods = Vector{Any}(undef, length(Other_method1))
    for i in eachindex(Other_method1)
        splitted = split(Other_method1[i], ",")
        push!(splitted, Best_method1[i])
        total_methods[i] = copy(splitted)
    end
    for i in eachindex(total_methods)
        total_methods[i] = sort(unique(total_methods[i]))
    end
    total_methods

    flattend_total_method = [i for arr in total_methods for i in arr]
    unique_total_methods = sort(unique(flattend_total_method))

    method_count = OrderedDict(zip(unique_total_methods, zeros(Int64, length(unique_total_methods))))
    for subset_t in total_methods
        for j in unique_total_methods
            if j in subset_t
                method_count[j] += 1
            end
        end
    end
    method_count
    method_count_values = collect(values(method_count))
    method_count_labels = keys(method_count)
    labels = [i for i in method_count_labels]
    # Removing the none
    method_count_values = method_count_values[labels .!= "None"] 
    labels = labels[labels .!= "None"]
    method_count_chance = method_count_values ./ length(Other_method1)
    return labels, method_count_chance
end


data = CSV.read("./Lit_study.csv", DataFrame)[1:75, :]
Best_method1 = data[:, "Best method"]
Other_method1 = data[:, "Other Class"]
Best_method1[Best_method1 .== "Other"] .= "DT"
mode = data[:, "Mode"]

mode = mode[Other_method1 .!= "None"]
Best_method1 = Best_method1[Other_method1 .!= "None"]
Other_method1 = Other_method1[Other_method1 .!= "None"]
# data first graph
best_labels, best_chance = value_finder(Other_method1, Best_method1)
best_color = color_finder(best_labels, color_dict)
# data second graph
reg_method = Best_method1[mode .== "R"]
Other_reg = Other_method1[mode .== "R"]

reg_labels, reg_chance = value_finder(Other_reg, reg_method) 
reg_color = color_finder(reg_labels, color_dict)
# Data third graph
Class_method = Best_method1[mode .== "C"]
Other_class = Other_method1[mode .== "C"] 
Class_labels, Class_chance = value_finder(Other_class, Class_method) 
Class_color = color_finder(Class_labels, color_dict)

fig = pyplt.figure(constrained_layout=true)
axs = fig.subplot_mosaic([["Left", "TopRight"],["Left", "BottomRight"]],
                          gridspec_kw=Dict("width_ratios"=>[2, 1]))
# Left is the total plot (first graph)
axs["Left"].set_title("Total models (A)", fontsize=11)
axs["Left"].bar(best_labels, best_chance, color=best_color)
axs["Left"].set_ylabel("% used in literature")
# Topright is the reg models (second graph)
axs["TopRight"].set_title("Regression models (B)", fontsize=11)
axs["TopRight"].bar(reg_labels, reg_chance, color=reg_color)
axs["BottomRight"].set_title("Classification models (C)", fontsize=11)
axs["BottomRight"].bar(Class_labels, Class_chance, color=Class_color)
axs["Left"].set_ylim(0, 1)
axs["TopRight"].set_ylim(0, 1)
axs["BottomRight"].set_ylim(0, 1)
pyplt.savefig("used_in_paper_filter.png")
