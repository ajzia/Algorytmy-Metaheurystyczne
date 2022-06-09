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

  using Random, FLoops
  
  function best_bee(bees::Vector{Bee})::Bee
    return reduce((x, y) -> x.distance < y.distance ? x : y, bees)
  end

  function employbees(employed_bees::Vector{Bee}, nodes::Int, weights::AbstractMatrix{Float64})::Tuple{Vector{Int}, Float64}
    e_dist::Float64 = typemax(Float64)
    e_path::Vector{Int} = employed_bees[1].path
  
    for ebee in employed_bees
      (i, j) = rand(1:nodes, 2)
      (curr_path, curr_distance) = copy(ebee.path), ebee.distance
      (new_path, new_curr_distance) = ebee.move(curr_path, (i, j), curr_distance, weights)
  
      if new_curr_distance < curr_distance
        ebee.count = 0
        (curr_path, curr_distance) = (new_path, new_curr_distance)
        
        if new_curr_distance < e_dist
          e_dist = new_curr_distance
          e_path = new_path
        end
      else
        ebee.count += 1
      end
    end
    return (e_path, e_dist)
  end

  function select_flowers(swarm::Vector{Bee}, selection::Function, selection_parameter::Float64)::Dict{Bee, Vector{Bee}}
    chosen_bees::Dict{Bee, Vector{Bee}} = Dict()

    distances::Vector{Float64} = [bee.distance for bee in swarm]
    for _ in swarm
      i = selection(distances, selection_parameter)
      the_chosen_one = swarm[i]
      if (!haskey(chosen_bees, the_chosen_one))
        chosen_bees[the_chosen_one] = [the_chosen_one]
      else
        push!(chosen_bees[the_chosen_one], the_chosen_one)
      end
    end

    return chosen_bees
  end

  function observers(lucky_bee::Bee, observer_bees::Vector{Bee}, nodes::Int, weights::AbstractMatrix{Float64})::Tuple{Vector{Int}, Float64}
    o_dist::Float64 = lucky_bee.distance
    o_path::Vector{Int} = lucky_bee.path
  
    for observer in observer_bees
      (i, j) = rand(1:nodes, 2)
      (curr_path, curr_distance) = (copy(lucky_bee.path), lucky_bee.distance)
      (new_path, new_distance) = observer.move(curr_path, (i, j), curr_distance, weights)
  
      if new_distance < curr_distance
        observer.count = 0
        (observer.path, observer.distance) = copy(new_path), new_distance
        if new_distance < o_dist
          o_path = copy(new_path)
          o_dist = new_distance
        end
      else
        observer.count += 1
      end
    end
    return (o_path, o_dist)
  end

  function scouts(scout_bees::Vector{Bee}, limit::Int, nodes::Int, weights::AbstractMatrix{Float64})::Tuple{Vector{Int}, Float64}
    s_dist::Float64 = typemax(Float64)
    s_path::Vector{Int} = scout_bees[1].path
    
    for scout in scout_bees
      if (scout.count < limit) continue end

      new_path = shuffle(collect(1:nodes))
      new_distance = calculate_path(new_path, weights)

      (scout.path, scout.distance) = copy(new_path), new_distance
      scout.count = 0

      if new_distance < s_dist
        s_path = copy(new_path)
        s_dist = new_distance
      end
    end
    return (s_path, s_dist)
  end

  function honex(swarm::Vector{Bee}, limit::Int, stop::Tuple{Function, Int}, nodes::Int, weights::AbstractMatrix{Float64}, selection::Tuple{Function, Float64})::Tuple{Vector{Int}, Float64}
    best_path::Vector{Int} = shuffle(collect(1:nodes))
    best_distance::Float64 = calculate_path(best_path, weights)

    # stop condition
    (stop_function, max) = stop
    (start, max, increment, check) = stop_function(max)

    # selection
    (selection_func, lambda) = selection

    ranges::Vector{Tuple{Int, Int}} = range_split(length(swarm))

    Threads.@threads for bee in swarm 
      bee.path = shuffle(collect(1:nodes))
      bee.distance = calculate_path(bee.path, weights)
    end

    the_best_bee = best_bee(swarm)

    if (the_best_bee.distance < best_distance)
      best_path = copy(the_best_bee.path)
      best_distance = the_best_bee.distance
    end

    while check(start, max)
      if typeof(max) == Int println("Iteration: $start") end

      # 1st loop -> bee employees
      @floop for (i, j) in ranges
        (loop_e_path, loop_e_dist) = employbees(swarm[i:j], nodes, weights)
        @reduce() do (p_e = Vector{Int}(undef, 0); loop_e_path), (d_e = typemax(Float64); loop_e_dist)
          if (loop_e_dist < d_e)
            p_e = loop_e_path
            d_e = loop_e_dist
          end
        end
      end

      if d_e < best_distance
        best_path = copy(p_e)
        best_distance = d_e
        println("(e) NEW BEST!: $(best_distance)")
      end
      
      # 2nd loop -> bee observers
      selected_bees::Dict{Bee, Vector{Bee}} = select_flowers(swarm, selection_func, lambda)
      @floop for bee in keys(selected_bees)
        (loop_o_path, loop_o_dist) = observers(bee, selected_bees[bee], nodes, weights)
        @reduce() do (p_o = Vector{Int}(undef, 0); loop_o_path), (d_o = typemax(Float64); loop_o_dist)
          if (loop_o_dist < d_o)
            p_o = loop_o_path
            d_o = loop_o_dist
          end
        end
      end

      # best_bee = find_best_bee(hive)
      if (d_o < best_distance)
        best_path = copy(p_o)
        best_distance = d_o
        println("(o) NEW BEST!: $(best_distance)")
      end

      # 3rd loop -> bee scouts
      @floop for (i, j) in ranges
        (loop_s_path, loop_s_dist) = scouts(swarm[i:j], limit, nodes, weights)
        @reduce() do (p_s = Vector{Int}(undef, 0); loop_s_path), (d_s = typemax(Float64); loop_s_dist)
          if (loop_s_dist < d_s)
            p_s = loop_s_path
            d_s = loop_s_dist
          end
        end
      end

      if d_s < best_distance
        best_path = copy(p_s)
        best_distance = d_s
        println("(s) NEW BEST!: $(best_distance)")
      end

      start = increment(start)
    end # while

    return (best_path, best_distance)
  end # bee

end # module
