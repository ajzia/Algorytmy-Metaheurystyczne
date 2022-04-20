include("./tabu_search.jl")
using .TabuSearch

"""
  Main program function.
"""
function main(args)
  if length(args) == 0 || !isfile("./all/$(args[1]).tsp")
    println("Usage: julia tabu_search.jl [name of tsp file (name.tsp)]")
    return
  end

  tsp_dict = load_tsp("./all/$(args[1]).tsp")
  
  path, distance = tabu_search(repetitive_nearest_neighbour(tsp_dict)[1], insert, "it", 1000.0, 10, tsp_dict[:dimension], tsp_dict[:weights])
  println("Path: $path\nDistance: $distance")
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end
