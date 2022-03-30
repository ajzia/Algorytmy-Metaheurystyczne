include("./main.jl")

using TSPLIB
using JSON
using Plots
using PlotlyJS
using Statistics

"""
    save_data()
  Saves data from algorithms for given files in a .json file.

"""
function save_data()
  prd = Dict()

  tsp_files = [
  "burma14", "gr17", "ulysses22", "fri26", "bays29", 
  "swiss42", "eil51", "st70", "eil76", "gr96", 
  "kroA100", "pr107", "bier127", "ch130", "gr137",
  "pr144", "kroA150", "u159", "si175", "kroB200",
  ]

  temp1 = []; i = 1
  for x in tsp_files
    tsp = readTSP("./all/" * x * ".tsp")
    tsp_dict = struct_to_dict(tsp)

    n = tsp_dict[:dimension]
    opt = tsp_dict[:optimal]

    prd[n] = []

    for i in 1:100
      push!(temp1, k_random(tsp_dict, 100)[2])
    end

    x = mean(temp1)
    path, y = (repetitive_nearest_neighbour(tsp_dict))
    z = two_opt(tsp_dict, path)[2]

    push!(prd[n], x); push!(prd[n], y); push!(prd[n], z); push!(prd[n], opt);

    println(i)
    i += 1
  end

  isdir("./data") || mkdir("./data")
  isfile("./data/prd.json") 
  open("./data/prd.json", "w") do io
    JSON.print(io, prd)
  end
end

# draw path for a specific problem for a specific algorithm
function draw_path(name::String, nodes::AbstractMatrix{Float64}, path::Vector{T}) where T <: Integer 
  x = []; y = [] 
  n = length(path)

  for i in 1:size(path, 1)
    append!(x, nodes[path[i], :][1]); append!(y, nodes[path[i], :][2])
  end

  append!(x, nodes[path[1], :][1]); append!(y, nodes[path[1], :][2])

	plotlyjs()
  plt = Plots.plot!(x, y, marker=(:circle,5), palette = palette([:indianred1], 7), title="$name")
  Plots.savefig(plt, "./plots/$name-n$n.png")
end

"""
    prd(data, optimal) -> Float64
  Calculates prd for the given weight.

# Parameters:
- `data::Float64`: computed weight of the path.
- `optimal::Int64`: weight of the optimal path for the given problem.

# Returns:
- `Float64`: prd for the given weight.

"""
function prd(data::Float64, optimal::Int64)
  return ((data - optimal) / optimal) * 100
end

"""
    draw_plot(data_dict)
  Draws plots showing prd for specific algorithms.

# Parameters:
- `data_dict::Dict`: dictionary with data from algorithms for several .tsp files.

"""
function draw_plot(data_dict::Dict)
  x = []; y1 = []; y2 = []; y3 = []

  for i in ("14", "17", "22", "26", "29", "42", "51", "70", "76", "96", "100", "107", "127", "130", "137", "144", "150", "159", "175", "200")
    opt::Int64 = floor(data_dict[i][4])
    a = prd(data_dict[i][1], opt)
    b = prd(data_dict[i][2], opt)
    c = prd(data_dict[i][3], opt)

    push!(x, i); push!(y1, a); push!(y2, b); push!(y3, c); 
  end

  plotlyjs()
  isdir("./plots") || mkdir("./plots")
  
  plt = Plots.plot(x, y1, xticks=:all, marker=(:circle,5), yformatter = :plain, title="prd for k_random algorithm", label = "k_random", legend=:outertopright)
  Plots.savefig(plt, "./plots/prd.png")

  plt = Plots.plot(x, y2, xticks=:all, marker=(:circle,5), yformatter = :plain, title="prd", label = "rnn", legend=:outertopright)
  plt = Plots.plot!(x, y3, xticks=:all, marker=(:circle,5), yformatter = :plain, title="prd", label = "2opt", legend=:outertopright)
  Plots.savefig(plt, "./plots/prd-rnn-2opt.png")
end

function main()
  # saving data - muted, so it;s not going every time
  # save_data()

  for (root, dirs, files) in walkdir("./data")
    for file in files
      data_dict = JSON.parsefile(joinpath(root, file))
      draw_plot(data_dict)
    end
  end

end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
