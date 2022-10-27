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
    return labels, method_count_chance, method_count_values
end
function color_finder(models, color_dict)
    color_array = Vector{String}(undef, length(models))
    for i in eachindex(models)
        color_array[i] = color_dict[models[i]]
    end
    return color_array
end
function count_maker(Best_method1)
    Best_method1 = sort(Best_method1)
    unique_best = unique(Best_method1)
    return_dict = OrderedDict(zip(unique_best, zeros(Int64, length(unique_best))))
    for i in Best_method1
        return_dict[i] += 1
    end
    return_count = [i for i in values(return_dict)]
    return_values = [i for i in keys(return_dict)]
    return return_count, return_values
end
function corrector(total_best_labels, total_best_count, best_names, best_count)
    return_array = zeros(max(length(total_best_count), length(best_count)))
    for i in eachindex(total_best_labels)
        for j in eachindex(best_names)
            if total_best_labels[i] == best_names[j]
                return_array[i] = best_count[j] / total_best_count[i]
            end
        end
    end
    return return_array, total_best_labels
end
model = ["DT", "SVM", "CL","DE", "NN", "LS", "BA"];
colors = ["orangered","cornflowerblue","yellowgreen","orange","mediumpurple","gold","orchid"];
color_dict = Dict(zip(model, colors));



data = CSV.read("./Lit_study.csv", DataFrame)[1:75, :];
Best_method1 = data[:, "Best method"];
Other_method1 = data[:, "Other Class"];
mode = data[:, "Mode"];


Best_method1[Best_method1 .== "Other"] .= "DT"

# data first graph
total_best_labels, total_best_chance, total_best_count = value_finder(Other_method1, Best_method1)
best_count, best_names = count_maker(Best_method1)
best_corrected_per, best_corrected_name = corrector(total_best_labels, total_best_count, best_names, best_count)
# data second graph
total_reg_method = Best_method1[mode .== "R"];
total_Other_reg = Other_method1[mode .== "R"];
reg_count, reg_names = count_maker(total_reg_method);

total_reg_labels, total_reg_chance, total_reg_count = value_finder(total_Other_reg, total_reg_method) ;
reg_corrected_per, reg_corrected_name = corrector(total_reg_labels, total_reg_count, reg_names, reg_count)
# Data third graph
total_Class_method = Best_method1[mode .== "C"];
total_Other_class = Other_method1[mode .== "C"] ;
class_count, class_names = count_maker(total_Class_method);

total_Class_labels, total_Class_chance, total_Class_count = value_finder(total_Other_class, total_Class_method) ;
class_corrected_per, class_corrected_name = corrector(total_Class_labels, total_Class_count, class_names, class_count)

fig = pyplt.figure(constrained_layout=true)
axs = fig.subplot_mosaic([["Left", "TopRight"],["Left", "BottomRight"]],
                          gridspec_kw=Dict("width_ratios"=>[2, 1]))
plt.ylim(0, 1)
# Left is the total plot (first graph)
axs["Left"].set_title("Corrected models total (A)", fontsize=11)
axs["Left"].bar(best_corrected_name, best_corrected_per, color=best_color)
axs["Left"].set_ylabel("% used in literature")
# Topright is the reg models (second graph)
axs["TopRight"].set_title("Regression models (B)", fontsize=11)
axs["TopRight"].bar(reg_corrected_name, reg_corrected_per, color=reg_color)
axs["BottomRight"].set_title("Classification models (C)", fontsize=11)
axs["BottomRight"].bar(class_corrected_name, class_corrected_per, color=Class_color)
axs["Left"].set_ylim(0, 1)
axs["TopRight"].set_ylim(0, 1)
axs["BottomRight"].set_ylim(0, 1)
pyplt.savefig("corr_best_model.png")
