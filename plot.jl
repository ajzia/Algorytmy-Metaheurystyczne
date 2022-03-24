include("./main.jl")

using TSPLIB
using Plots
using PlotlyJS

function draw_plot(name::String, nodes::AbstractMatrix{Float64}, path) 
  x = []; y = [] 
  for i in 1:size(path, 1)
    append!(x, nodes[path[i], :][1]); append!(y, nodes[path[i], :][2])
  end

  append!(x, nodes[path[1], :][1]); append!(y, nodes[path[1], :][2])

	plotlyjs()
  plt = Plots.plot(x, y, marker=(:circle,5), palette = palette([:indianred1], 7), title="$name")
  Plots.savefig(plt, "./plots/$name.png")
end

function main()
	tsp = readTSP("./all/eil51.tsp")
  tsp_dict = struct_to_dict(tsp)

	path =  k_random(tsp_dict, 1000)[1]
	draw_plot("k_random", tsp_dict[:nodes], path)
end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
