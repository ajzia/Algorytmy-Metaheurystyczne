module artificial_bee_colony

  include("../2/data_generator.jl")
  include("../1/main.jl")
  include("../2/move.jl")
  include("./stop_conditions.jl")
  include("./swarm.jl")

  # exports from ../1/main.jl
  export load_tsp, struct_to_dict, calculate_path
  export k_random, nearest_neighbour, repetitive_nearest_neighbour, two_opt
  # exports from ../2/move.jl
  export swap, invert, insert
  # export from ../2/data_generator.jl
  export generate_dict
  # exports from ./swarm.jl
  export random_swarm, moving_swarm
  # exports from ./stop_conditions.jl
  export iteration_condition, time_condition
  # export from ./bee_colony.jl
  export honex

  using Random

  # function roulette(solutions::Array{Tuple{Vector{Int}, Float64}}, nrOfBees::Int)

  #   k = nrOfBees

  #   4502394

  #   sum = 0
  #   for i in 1:k sum += solutions[i][2] end

  #   prob::Array{Float64} = [solutions[i][2]/sum for i in 1:k]
  #   #prob = [1-prob[i] for i in 1:k]

  #   #sum = 0
  #   #for i in 1:k sum += prob[i] end

  #   sum2 = 0
  #   #prob = [prob[i]/sum for i in 1:k]

  #   for i in 1:k
  #     prob[i] = (prob[i]/sum) + sum2
  #     sum2+=prob[i]
  #   end


  #   return prob
  # end

  # function roulette_shoot(prob::Array{Float64}, p::Float64)
  #   #sum=0
  #   idx = 1
  #   #println("prob: ", prob)
  #   while prob[idx] <= p
  #     #sum+=prob[idx]
  #     idx+=1

  #   end

  #   return idx
  # end

  function roulette(distances::Vector{Float64})
    min = minimum(distances)
    while true
      random_bee = rand(1:length(distances))
      if rand() < min / distances[random_bee]
        return random_bee
      end
    end
  end

  function honex(swarm::Vector{Bee}, limit::Int, stop::Tuple{Function, Int}, nodes::Int, weights::AbstractMatrix{Float64})
    # move = invert

    # max_distance = 100
    # population = 5000
    # limit = 500 # po ilu iteracjach bez ulepszeń wywalamy rozwiązanie

    # no_improvement::Array{Int} = zeros(Int, population)
    # solutions::Array{Tuple{Vector{Int}, Float64}} = [] 
    
    
    #tsp_dict = generate_dict(nodes, max_distance, true)
    # weights = tsp_dict[:weights]
    

    # best_path::Vector{Int} = [];  best_distance::Float64 = 0

    # (best_path, best_distance) = k_random(tsp_dict, 1)
    best_path::Vector{Int} = shuffle(collect(1:nodes))
    best_distance::Float64 = calculate_path(best_path, weights)
    # push!(solutions, (best_path, best_distance))
    # push!(no_improvement, 0)

    # stop condition
    (stop_function, max) = stop
    (start, max, increment, check) = stop_function(max)

    # initial path and it's weights
    for bee in swarm 
      bee.path = shuffle(collect(1:nodes))
      bee.distance = calculate_path(bee.path, weights)
      # push!(solutions, (path, dist))
      # push!(no_improvement, 0)

      if bee.distance < best_distance
        best_path = copy(bee.path)
        best_distance = bee.distance
      end
    end

    while check(start, max)
      #if it%1000 == 0 println("10%") end
      if typeof(max) == Int println("Iteration: $start") end
      
      # 1st loop -> worker bees
      for employbee in swarm
        # for k in 1:population
        (i, j) = rand(1:nodes, 2)
        (curr_path, curr_distance) = employbee.path, employbee.distance
        (new_path, new_distance) = employbee.move(curr_path, (i, j), curr_distance, weights)

        if new_distance < curr_distance
          employbee.count = 0
          # no_improvement[k] = 0
          (employbee.path, employbee.distance) = copy(new_path), new_distance
          if new_distance < best_distance
            best_path = copy(new_path)
            best_distance = new_distance  
            println("NEW BEST!: $(best_distance)")
          end
        else
          employbee.count += 1
        end

      end
      
      # 2nd loop -> bee observers
      path_weights = [bee.distance for bee in swarm]
      for observer in swarm
        # for k in 1:population
        random_flower = roulette(path_weights)
        lucky_bee = swarm[random_flower]
        # p = rand()
        # random_flower = roulette_shoot(prob, p) # tu bedzie ruletka ale jeszcze nie ma :)

        (i, j) = rand(1:nodes, 2)
        (curr_path, curr_distance) = (lucky_bee.path, lucky_bee.distance)
        (new_path, new_distance) = observer.move(curr_path, (i, j), curr_distance, weights)

        if new_distance < curr_distance
          observer.count = 0
          # no_improvement[k] = 0
          (observer.path, observer.distance) = copy(new_path), new_distance
          if new_distance < best_distance
            best_path = copy(new_path)
            best_distance = new_distance
            println("NEW BEST!: $(best_distance)")
          end
        else
          observer.count += 1
        end
      end

      # 3rd loop -> bee scouts
      for scout in swarm
        # for k in 1:population
        if scout.count > limit
          new_path = shuffle(collect(1:nodes))
          new_distance = calculate_path(new_path, weights)

          (scout.path, scout.distance) = copy(new_path), new_distance
          scout.count = 0
          # no_improvement[k] = 0
          if new_distance < best_distance
            best_path = copy(new_path)
            best_distance = new_distance
            println("NEW BEST!: $(best_distance)")
          end
        end
      end

      start = increment(start)
    end # while

    return (best_path, best_distance)
  end # bee

end # module








