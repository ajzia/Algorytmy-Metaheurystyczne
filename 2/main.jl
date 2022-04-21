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
  
  path, dist = repetitive_nearest_neighbour(tsp_dict)
  x::Vector{Int}, y = swap(path, (3,5), dist, tsp_dict[:weights])
  
  println("Korekta sciezki: $y")
  println("Liczenie calej: $(calculate_path(x, tsp_dict[:weights]))")
  # path, distance = tabu_search(repetitive_nearest_neighbour(tsp_dict)[1], swap, "it", 1000, 10, tsp_dict[:dimension], tsp_dict[:weights])
  # println("Path: $path\nDistance: $distance")
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end
