module artificial_bee_colony

  include("../2/data_generator.jl")
  include("../1/main.jl")
  include("../2/move.jl")
  include("./stop_conditions.jl")
  include("./selection_types.jl")
  include("./swarm.jl")

  # exports from ../1/main.jl
  export load_tsp, struct_to_dict, calculate_path
  export k_random, nearest_neighbour, repetitive_nearest_neighbour, two_opt
  # exports from ../2/move.jl
  export swap, invert, insert
  # export from ../2/data_generator.jl
  export generate_dict
  # exports from ./swarm.jl
  export random_swarm, moving_swarm, organized_swarm
  # exports from ./stop_conditions.jl
  export iteration_condition, time_condition
  # export from ./bee_colony.jl
  export honex
  # exports from ./selection_types.jl
  export roulette, tournament

  using Random

  
  function honex(swarm::Vector{Bee}, limit::Int, stop::Tuple{Function, Int}, nodes::Int, weights::AbstractMatrix{Float64}, selection::Tuple{Function, Float64})
    
    best_path::Vector{Int} = []
    best_distance::Float64 = Inf

    # stop condition
    (stop_function, max) = stop
    (start, max, increment, check) = stop_function(max)

    # initial path and it's weights
    for bee in swarm 
      bee.path = shuffle(collect(1:nodes))
      bee.distance = calculate_path(bee.path, weights)

      if bee.distance < best_distance
        best_path = copy(bee.path)
        best_distance = bee.distance
      end
    end

    while check(start, max)
    
      if typeof(max) == Int println("Iteration: $start") end
      
      # 1st loop -> worker bees
      for employbee in swarm
        # for k in 1:population
        (i, j) = rand(1:nodes, 2)
        (curr_path, curr_distance) = employbee.path, employbee.distance
        (new_path, new_distance) = employbee.move(curr_path, (i, j), curr_distance, weights)

        if new_distance < curr_distance
          employbee.count = 0
          (employbee.path, employbee.distance) = copy(new_path), new_distance
          if new_distance < best_distance
            best_path = copy(new_path)
            best_distance = new_distance  
            println("(e) NEW BEST!: $(best_distance)")
            println("\tprev path: $(curr_path)")
            println("\tnew path: $(best_path)")
            println("\ti, j: $((i, j))")
            
          end
        else
          employbee.count += 1
        end

      end
      
      # 2nd loop -> bee observers
      path_weights = [bee.distance for bee in swarm]
      for observer in swarm
        
        if selection[1] == roulette random_flower = roulette(path_weights)
        else random_flower = tournament(path_weights, selection[2]) end

        lucky_bee = swarm[random_flower]

        (i, j) = rand(1:nodes, 2)
        (curr_path, curr_distance) = (lucky_bee.path, lucky_bee.distance)
        (new_path, new_distance) = observer.move(curr_path, (i, j), curr_distance, weights)

        if new_distance < curr_distance
          observer.count = 0
          (observer.path, observer.distance) = copy(new_path), new_distance
          if new_distance < best_distance
            best_path = copy(new_path)
            best_distance = new_distance
            println("(o) NEW BEST!: $(best_distance)")
            println("\tprev path: $(curr_path)")
            println("\tnew path: $(best_path)")
            println("\ti, j: $((i, j))")
          end
        else
          observer.count += 1
        end
      end

      # 3rd loop -> bee scouts
      for scout in swarm
        
        if scout.count > limit
          new_path = shuffle(collect(1:nodes))
          new_distance = calculate_path(new_path, weights)

          (scout.path, scout.distance) = copy(new_path), new_distance
          scout.count = 0
          
          if new_distance < best_distance
            best_path = copy(new_path)
            best_distance = new_distance
            println("(s) NEW BEST!: $(best_distance)")
            println("\tprev path: $(curr_path)")
            println("\tnew path: $(best_path)")
          end
        end
      end

      start = increment(start)
    end # while

    return (best_path, best_distance)
  end # bee

end # module








