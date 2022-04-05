include("./main.jl")

using TSPLIB
using JSON
using Plots
using PlotlyJS

"""
    testing()
  Runs complexity tests and saves complexity data from algorithms for the given files to a .json file.
"""
function testing()
  count_dict = Dict(
    :name => "Counting",
    :n => [], 
    :krandom => [], 
    :rnn => [], 
    :twoopt => []
  )

  const_dict = Dict(
    :name => "Constants",
    :n => [], 
    :krandom => [], 
    :rnn => [], 
    :twoopt => []
  )

  tsp_files = [
  "burma14", "gr17", "ulysses22", "fri26", "bays29", 
  "swiss42", "eil51", "st70", "eil76", "gr96", 
  "kroA100", "pr107", "bier127", "ch130", "gr137",
  "pr144", "kroA150", "u159", "brg180", "kroB200",
  ]
  whereami = 1
  for x in tsp_files
    println(whereami)
    whereami += 1
    tsp = readTSP("./all/" * x * ".tsp")
    tsp_dict = struct_to_dict(tsp)
    n = tsp_dict[:dimension]
    k = 10000

    kr_c = counting_test(k_random, tsp_dict, 10000)
    rnn_c = counting_test(repetitive_nearest_neighbour, tsp_dict)
    twoopt_c = counting_test(two_opt, tsp_dict, shuffle(collect(1:tsp_dict[:dimension])))

    append!(count_dict[:n], tsp_dict[:dimension])
    append!(count_dict[:krandom], kr_c) 
    append!(count_dict[:rnn], rnn_c)
    append!(count_dict[:twoopt], twoopt_c)
    
    append!(const_dict[:n], tsp_dict[:dimension])
    append!(const_dict[:krandom], kr_c/(k*n)) 
    append!(const_dict[:rnn], rnn_c/(n*n*n))
    append!(const_dict[:twoopt], twoopt_c/(n*n*n))
  end

  isdir("./data") || mkdir("./data")
  isfile("./data/counting-test.json") || 
  open("./data/counting-test.json", "w") do io
    JSON.print(io, count_dict)
  end

  isdir("./data") || mkdir("./data")
  isfile("./data/counting-constants.json") || 
  open("./data/counting-constants.json", "w") do io
    JSON.print(io, const_dict)
  end
  
end

"""
    draw_plot(dataC_dict, dataT_dict)
  Draws plots showing complexity and constants for specific algorithms.
# Parameters:
- `data_dictC::Dict`: dictionary with data from algorithms for several .tsp files.
- `data_dictT::Dict`: dictionary with data from algorithms for several .tsp files.
"""
function draw_plot(dataC_dict::Dict, dataT_dict::Dict)
  x = dataC_dict["n"]; y1 = dataC_dict["krandom"]; y2 = dataC_dict["rnn"]; y3 = dataC_dict["twoopt"]
  xx = dataT_dict["n"]; yy1 = dataT_dict["krandom"]; yy2 = dataT_dict["rnn"]; yy3 = dataT_dict["twoopt"]

  plotlyjs()
  isdir("./plots") || mkdir("./plots")
  
  plt = Plots.plot(x, y1, xticks=:all, marker=(:circle,5), yformatter = :plain, title="Complexity", label = "k_random [k = 10000]", legend=:outertopright, xlabel = "number of nodes", ylabel = "number of operations")
  plt = Plots.plot!(x, y2, xticks=:all, marker=(:circle,5), yformatter = :plain, title="Complexity", label = "rnn", legend=:outertopright, xlabel = "number of nodes", ylabel = "number of operations")
  plt = Plots.plot!(x, y3, xticks=:all, marker=(:circle,5), yformatter = :plain, title="Complexity", label = "2opt", legend=:outertopright, xlabel = "number of nodes", ylabel = "number of operations")
  Plots.savefig(plt, "./plots/complexityCounting.png")

  plt = Plots.plot(xx, yy1, xticks=:all, marker=(:circle,5), yformatter = :plain, title="Constants", label = "k_random / (k*n) [k=10000]", legend=:outertopright, xlabel = "number of nodes", ylabel = "number of operations/complexity")
  plt = Plots.plot!(xx, yy2, xticks=:all, marker=(:circle,5), yformatter = :plain, title="Constants", label = "rnn / (n*n*n)", legend=:outertopright, xlabel = "number of nodes", ylabel = "number of operations/complexity")
  plt = Plots.plot!(xx, yy3, xticks=:all, marker=(:circle,5), yformatter = :plain, title="Constants", label = "2opt / (n*n*n)", legend=:outertopright, xlabel = "number of nodes", ylabel = "number of operations/complexity")
  Plots.savefig(plt, "./plots/complexityConstants.png")
end

"""
  Main program function.
"""
function main()
  
  testing()
  dataC_dict = JSON.parsefile("./data/counting-test.json")
  dataT_dict = JSON.parsefile("./data/counting-constants.json")
  draw_plot(dataC_dict, dataT_dict)

end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
