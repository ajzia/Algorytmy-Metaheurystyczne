include("./bee_colony.jl")
using .artificial_bee_colony

const STOP_CONDITIONS = Dict("iterations" => iteration_condition, "time" => time_condition)

"""
  Main program function.
"""
function main(args)
  if length(args) != 3 || !isfile("./all/$(args[1]).tsp") || !(args[2] in keys(STOP_CONDITIONS))
    println("Usage: julia main.jl [name of tsp file (name.tsp)] [stop criterion (time, iterations)] [max]")
    return
  end

  tsp_dict = load_tsp("./all/$(args[1]).tsp")
  max = parse(Int, args[3])
  
  size = 1000; limit = 3000
  stop_cond = args[2]
  #path, distance = @time honex(random_swarm(size), limit, (STOP_CONDITIONS[stop_cond], max), tsp_dict[:dimension], tsp_dict[:weights])
  path, distance = @time honex(moving_swarm(size, invert), limit, (STOP_CONDITIONS[stop_cond], max), tsp_dict[:dimension], tsp_dict[:weights], (roulette, 0.0))

  path2, distance2 = @time honex(moving_swarm(size, invert), limit, (STOP_CONDITIONS[stop_cond], max), tsp_dict[:dimension], tsp_dict[:weights], (tournament, 0.08))


  println("\n >==================================== AFTER ABC ====================================<\n")
  println("Roulette:")
  println("Path: $path\nDistance: $distance")
  println("Tournament:")
  println("Path: $path2\nDistance: $distance2")
  println("Optimal: $(tsp_dict[:optimal])")
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end
