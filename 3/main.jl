include("./bee_colony.jl")
using .artificial_bee_colony

"""
  Main program function.
"""
function main(args)
  if length(args) == 0 || !isfile("./all/$(args[1]).tsp")
    println("Usage: julia main.jl [name of tsp file (name.tsp)]")
    return
  end

  tsp_dict = load_tsp("./all/$(args[1]).tsp")
  
  size = 1000; limit = 500
  path, distance = honex(random_swarm(size), limit, tsp_dict[:dimension], tsp_dict[:weights])

  println("\n >==================================== AFTER ABC ====================================<\n")
  println("Path: $path\nDistance: $distance")
  println("Optimal: $(tsp_dict[:optimal])")
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end
