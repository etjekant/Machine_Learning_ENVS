using PyCall, CSV, DataFrames, Plots, PyPlot, OrderedCollections
@pyimport matplotlib.pyplot as pyplt
pyplt.pie([8, 17, 18, 3, 29], labels=["Tr", "Tr+V", "K", "Tr + V + Te", "K+Te"], colors=["orangered","cornflowerblue","yellowgreen","mediumpurple","orchid"])
pyplt.title("Data Splitting")
colors = ["cornflowerblue",];
pyplt.savefig("pie.png")
pyplt.clf()
