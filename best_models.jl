using PyCall, CSV, DataFrames, Plots, PyPlot, OrderedCollections
@pyimport matplotlib.pyplot as pyplt
# function needed 
function color_finder(models, color_dict)
    color_array = Vector{String}(undef, length(models))
    for i in eachindex(models)
        color_array[i] = color_dict[models[i]]
    end
    return color_array
end

#setup color per model
model = ["DT", "SVM", "CL","DE", "NN", "LS", "BA"]
colors = ["orangered","cornflowerblue","yellowgreen","orange","mediumpurple","gold","orchid"]
color_dict = Dict(zip(model, colors))


# making first part 
data = CSV.read("./Lit_study.csv", DataFrame)[1:75, :]
Best_method1 = data[:, "Best method"]
Best_method1[Best_method1 .== "Other"] .= "DT"
unique_best_methods = sort(unique(Best_method1))


# Changing type of best_method in total
Best_method = Vector{String}(undef, 0)
for i in Best_method1
    push!(Best_method, i)
end
Best_method
# Makeing best methods into counts in total

best_method_count = zeros(Int64, length(unique_best_methods))
for i in eachindex(unique_best_methods)
    best_method_count[i] = count(Best_method .== unique_best_methods[i])
end
best_method_count
best_method_labels = unique_best_methods
best_method_sizes = best_method_count ./ sum(best_method_count)
best_method_color = color_finder(best_method_labels, color_dict)
#end first graph
#second graph
Reg_Best_method1 = data[:, "Best method"]
mode1 = data[:, "Mode"] 
# Changing type of best_method in class
Reg_Best_method = Vector{String}(undef, 0)
for i in Reg_Best_method1
    push!(Reg_Best_method, i)
end
# Type Changing for the mode variable
mode = Vector{String}(undef, 0)
for i in mode1
    push!(mode, i)
end
Reg_Best_method

# Changing the "other" to DT, since the model is 80% DT
Reg_Best_method[Reg_Best_method .== "Other"] .= "DT"
# Only taking the samples were the mode is classification
Reg_Best_method = Reg_Best_method[mode .== "R"]
Reg_unique_methods = sort(unique(Reg_Best_method))

Reg_method_count = zeros(Int64, length(Reg_unique_methods))
for i in eachindex(Reg_unique_methods)
    Reg_method_count[i] = count(Reg_Best_method .== Reg_unique_methods[i])
end
Reg_method_count
Reg_method_size = Reg_method_count ./ sum(Reg_method_count)
Reg_method_label = Reg_unique_methods
Reg_method_color = color_finder(Reg_method_label, color_dict)

#Third graph
Class_Best_method1 = data[:, "Best method"]
mode1 = data[:, "Mode"] 
# Changing type of best_method in class
Class_Best_method = Vector{String}(undef, 0)
for i in Class_Best_method1
    push!(Class_Best_method, i)
end
# Type Changing for the mode variable
mode = Vector{String}(undef, 0)
for i in mode1
    push!(mode, i)
end
Class_Best_method

# Changing the "other" to DT, since the model is 80% DT
Class_Best_method[Class_Best_method .== "Other"] .= "DT"
# Only taking the samples were the mode is classification
Class_Best_method = Class_Best_method[mode .== "C"]
print(Class_Best_method)
class_unique_methods = sort(unique(Class_Best_method))

class_method_count = zeros(Int64, length(class_unique_methods))
for i in eachindex(class_unique_methods)
    class_method_count[i] = count(Class_Best_method .== class_unique_methods[i])
end
class_method_count
class_method_size = class_method_count ./ sum(class_method_count)
class_method_label = class_unique_methods
class_method_color = color_finder(class_method_label, color_dict)

# Making the plot
fig = pyplt.figure(constrained_layout=true)
axs = fig.subplot_mosaic([["Left", "TopRight"],["Left", "BottomRight"]],
                          gridspec_kw=Dict("width_ratios"=>[2, 1]))
# Left is the total plot (first graph)
axs["Left"].set_title("Best total models (A)")
axs["Left"].pie(best_method_sizes, labels=best_method_labels, colors=best_method_color)
# Topright is the reg models (second graph)
axs["TopRight"].set_title("Regression models (B)")
axs["TopRight"].pie(Reg_method_size, labels=Reg_method_label, colors=Reg_method_color)
axs["BottomRight"].set_title("Classification models (C)")
axs["BottomRight"].pie(class_method_size, labels=class_method_label, colors=class_method_color)
pyplt.savefig("best_models.png")
