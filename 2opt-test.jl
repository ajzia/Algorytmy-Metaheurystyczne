include("./main.jl")

using TSPLIB
using JSON
using Plots
using PlotlyJS

"""
    testing()
  Tests different starting paths for 2-OPT and saves data to a .json file.
"""
function testing()
  length_dict = Dict(
    :name => "2opt-start",
    :n => [], 
    :one_random => [],
    :krandom => [], 
    :nn => [],
    :rnn => []
  )


  tsp_files = [
  "burma14", "gr17", "ulysses22", "fri26", "bays29", 
  "swiss42", "eil51", "st70", "eil76", "gr96", 
  "kroA100", "pr107", "bier127", "ch130", "gr137",
  "pr144", "kroA150", "u159", "brg180", "kroB200",
  ]
  whereami = 1
  sample_size = 1
  for x in tsp_files
    println(whereami)
    whereami += 1
    tsp = readTSP("./all/" * x * ".tsp")
    tsp_dict = struct_to_dict(tsp)
    n = tsp_dict[:dimension]
    append!(length_dict[:n], n)
    nn_s = two_opt(tsp_dict, nearest_neighbour(1, tsp_dict[:dimension], tsp_dict[:weights])[1])[2]
    rnn_s = two_opt(tsp_dict, repetitive_nearest_neighbour(tsp_dict)[1])[2]
    append!(length_dict[:nn], nn_s)
    append!(length_dict[:rnn], rnn_s)
    r_s = 0
    kr_s = 0
    #for a in 1:sample_size
      k = 10000
      r_s += two_opt(tsp_dict, shuffle(collect(1:tsp_dict[:dimension])))[2]
      kr_s += two_opt(tsp_dict, k_random(tsp_dict, k)[1])[2]

    #end
    append!(length_dict[:one_random], r_s/sample_size) 
    append!(length_dict[:krandom], kr_s/sample_size) 
  end

  isdir("./json_data/2opt") || mkdir("./json_data/2opt")
  isfile("./json_data/2opt/starting-path.json") || 
  open("./json_data/2opt/starting-path.json", "w") do io
    JSON.print(io, length_dict)
  end
  
end

"""
    draw_plot(data_dict)
  Draws plot showing differences in path length for different starting paths.
  
# Parameters:
- `data_dict::Dict`: dictionary with data from tests. 
"""
function draw_plot(data_dict::Dict)
  x = data_dict["n"]
  y1 = data_dict["one_random"]
  y2 = data_dict["krandom"]
  y3 = data_dict["nn"]
  y4 = data_dict["rnn"]

  plotlyjs()
  isdir("./plots") || mkdir("./plots")
  
  plt = Plots.plot(x, y1, xticks=:all, marker=(:circle,5), yformatter = :plain, title="Starting path for 2-OPT", label = "start = one random", legend=:outertopright, xlabel = "number of nodes", ylabel = "shortest found path's length")
  plt = Plots.plot!(x, y2, xticks=:all, marker=(:circle,5), yformatter = :plain, title="Starting path for 2-OPT", label = "start = k_random [k = 10000]", legend=:outertopright, xlabel = "number of nodes", ylabel = "shortest found path's length")
  plt = Plots.plot!(x, y3, xticks=:all, marker=(:circle,5), yformatter = :plain, title="Starting path for 2-OPT", label = "start = nn", legend=:outertopright, xlabel = "number of nodes", ylabel = "shortest found path's length")
  plt = Plots.plot!(x, y4, xticks=:all, marker=(:circle,5), yformatter = :plain, title="Starting path for 2-OPT", label = "start = rnn", legend=:outertopright, xlabel = "number of nodes", ylabel = "shortest found path's length")

  Plots.savefig(plt, "./plots/2opt-starting-path.png")
end

"""
  Main program function.
"""
function main()
  
  testing()
  data_dict = JSON.parsefile("./json_data/2opt/starting-path.json")
  draw_plot(data_dict)

end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end

