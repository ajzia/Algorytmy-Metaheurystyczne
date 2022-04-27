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
  
  path = nearest_neighbour(2, tsp_dict[:weights])[1] 

  path, distance = tabu_search(path, invert, ("it", 1000), ("stat", 7), 0.9, tsp_dict[:weights])
  println("Path: $path\nDistance: $distance")
  println(calculate_path(path, tsp_dict[:weights]))
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end
