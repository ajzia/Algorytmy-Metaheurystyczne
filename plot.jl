include("./main.jl")

using TSPLIB
using JSON
using Plots
using PlotlyJS

function save_data(k::Int, name::String, tsp_dict::Dict)
  test_dict = Dict(
    :name => name,
    :k => k, 
    :n => tsp_dict[:dimension], 
    :krandom => [], 
    :rnn => [], 
    :twoopt => [],
    :optimal => tsp_dict[:optimal]
    )

  for i in 1:k
    println("CURRENT: $i")

    append!(test_dict[:krandom], k_random(tsp_dict, k)[2])

    if i == 1 
      (path, len) = repetitive_nearest_neighbour(tsp_dict)
      append!(test_dict[:rnn], len)
      append!(test_dict[:twoopt], two_opt(tsp_dict,path)[2])
    end
    
    println("END $i")
  end

  isdir("./json_data/k$k") || mkdir("./json_data/k$k")
  isfile("./json_data/k$k/$name-k$k.json") || 
  open("./json_data/k$k/$name-k$k.json", "w") do io
    JSON.print(io, test_dict)
  end
end

function draw_plot(name::String, nodes::AbstractMatrix{Float64}, path) 
  x = []; y = [] 
  n = length(path)

  for i in 1:size(path, 1)
    append!(x, nodes[path[i], :][1]); append!(y, nodes[path[i], :][2])
  end

  append!(x, nodes[path[1], :][1]); append!(y, nodes[path[1], :][2])

	plotlyjs()
  plt = Plots.plot(x, y, marker=(:circle,5), palette = palette([:indianred1], 7), title="$name")
  Plots.savefig(plt, "./plots/$name-n$n.png")
end

function main()

  tsp_files = [
  "burma14", "gr17", "ulysses22", "fri26", "bays29", 
  "swiss42", "eil51", "st70", "eil76", "gr96", 
  "kroA100", "pr107", "bier127", "ch130", "gr137",
  "pr144", "kroA150", "u159", "brg180", "kroB200",
  ]

  file_dict = Dict("name" => []); j = 1

  # saving data from all algorithms for each file to .json
  for x in tsp_files
    tsp = readTSP("./all/" * x * ".tsp")
    tsp_dict = struct_to_dict(tsp)

    for k in 200:200:1000
      save_data(k, x, tsp_dict)
    end
  end

end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
