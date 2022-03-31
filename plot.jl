include("./main.jl")

using TSPLIB
using JSON
using Plots
using PlotlyJS
using Statistics

"""
    save_data()
  Saves data from algorithms for the given files to a .json file.

"""
function save_data()
  prd = Dict(); krand = Dict()

  tsp_files = [
  "burma14", "gr17", "ulysses22", "fri26", "bays29", 
  "swiss42", "eil51", "st70", "eil76", "gr96", 
  "kroA100", "pr107", "bier127", "ch130", "gr137",
  "pr144", "kroA150", "u159", "si175", "kroB200",
  ]

  temp1 = []
  for x in tsp_files
    tsp = readTSP("./all/" * x * ".tsp")
    tsp_dict = struct_to_dict(tsp)

    n, opt = (tsp_dict[:dimension], tsp_dict[:optimal])
    prd[n], krand[n] = ([], [])
    prd["name"] = "prd"; krand["name"] = "k-random"
    krand["k"] = [1000, 10000, 1000000, 1000000]

    for i in 1:100
      push!(temp1, k_random(tsp_dict, 100)[2])
    end

    for i in (1000, 10000, 100000, 1000000)
      push!(krand[n], k_random(tsp_dict, i)[2])
    end

    path, y = (repetitive_nearest_neighbour(tsp_dict))
    z = two_opt(tsp_dict, path)[2]

    push!(prd[n], mean(temp1)); push!(prd[n], y); push!(prd[n], z); push!(prd[n], opt);
  end

  isdir("./data") || mkdir("./data")
  isfile("./data/prd.json") 
  open("./data/prdcopy.json", "w") do io
    JSON.print(io, prd)
  end

  isfile("./data/krand.json") 
  open("./data/krand.json", "w") do io
    JSON.print(io, krand)
  end
end


"""
    draw_path(name, nodes, path)
  Draws the given path on a plot.
  
# Parameters:
- `name::String`: name of the .tsp file.
- `nodes::AbstractMatrix{Float64}`: coordinates of nodes.
- `path::Vector{T<:Integer}`: computed path.
 
"""
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
    draw_plot(name, data_dict)
  Draws plots showing prd for specific algorithms.

# Parameters:
- `name::String`: name of the statistic.
- `data_dict::Dict`: dictionary with data from algorithms for several .tsp files.

"""
function draw_plot(name::String, data_dict::Dict)
  x, y1, y2, y3, y4 = ([], [], [], [], [])

  for i in ("14", "17", "22", "26", "29", "42", "51", "70", "76", "96", "100", "107", "127", "130", "137", "144", "150", "159", "175", "200")
    opt::Int64 = floor(data_dict[i][4])
    if name == "prd"
      a = prd(data_dict[i][1], opt)
      b = prd(data_dict[i][2], opt)
      c = prd(data_dict[i][3], opt)

    elseif name == "k-random"
      a = data_dict[i][1]
      b = data_dict[i][2]
      c = data_dict[i][3]
      d = data_dict[i][4]

      push!(y4, d)
    end
    push!(x, i); push!(y1, a); push!(y2, b); push!(y3, c); 
  end

  plotlyjs()
  isdir("./plots") || mkdir("./plots")
  
  if name == "prd"
    plt = Plots.plot(x, y1, xticks=:all, marker=(:circle,5), yformatter = :plain, title="$name for k_random algorithm", label = "k_random", legend=:outertopright,
      margin=5Plots.mm, xlabel = "number of nodes", ylabel = "prd in %")
    Plots.savefig(plt, "./plots/$name-krand.png")
    Plots.plot()
    l2, l3 = "rnn", "2opt"
  elseif name == "k-random"
    plt = Plots.plot(x, y1, xticks=:all, marker=(:circle,5), yformatter = :plain, title=name, label = "k = 1000", legend=:outertopright)
    l2, l3 = "k = 10000", "k = 100000"
  end 

  plt = Plots.plot!(x, y2, xticks=:all, marker=(:circle,5), yformatter = :plain, title=name, label = l2, legend=:outertopright,
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "prd in %")
  plt = Plots.plot!(x, y3, xticks=:all, marker=(:circle,5), yformatter = :plain, title=name, label = l3, legend=:outertopright,
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "prd in %")
  
  if name == "k-random" 
    plt = Plots.plot!(x, y4, xticks=:all, marker=(:circle,5), yformatter = :plain, title=name, label = "k = 1000000", legend=:outertopright, 
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "path's weight for the best path found for specific k")
  end

  Plots.savefig(plt, "./plots/$name.png")
end

"""
  Main program function.
"""
function main()
  # saving data - muted, so it;s not going every time
  # save_data()

  for (root, dirs, files) in walkdir("./data")
    for file in files
      data_dict = JSON.parsefile(joinpath(root, file))
      draw_plot(data_dict["name"], data_dict)
    end
  end

end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
