module artificial_bee_colony

  include("../2/data_generator.jl")
  include("../1/main.jl")
  include("../2/move.jl")
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
  # export from ./bee_colony.jl
  export bee

  import Base.@kwdef
  using Random

  @kwdef mutable struct Bee
    path::Vector{Int} = []
    distance::Float64 = 0.0
    move::Function
    count::Int = 0
  end

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

  function roulette(distances::Vector{Int})
    min = minimum(distances)
    while true
      random_bee = rand(1:length(distances))
      if rand() < min / distances[random_bee]
        return random_bee
      end
    end
  end

  function bee(population::Int, limit::Int, nodes::Int, weights::AbstractMatrix{Float64})# i inne jakeis -> move::Function, ...
    move = invert

    max_distance = 100
    # population = 5000
    # limit = 500 # po ilu iteracjach bez ulepszeń wywalamy rozwiązanie

    no_improvement::Array{Int} = zeros(Int, population)
    solutions::Array{Tuple{Vector{Int}, Float64}} = [] 
    
    
    #tsp_dict = generate_dict(nodes, max_distance, true)
    # weights = tsp_dict[:weights]
    

    # best_path::Vector{Int} = [];  best_distance::Float64 = 0

    # (best_path, best_distance) = k_random(tsp_dict, 1)
    best_path::Vector{Int} = shuffle(collect(1:nodes))
    best_distance::Float64 = calculate_path(best_path, weights)
    push!(solutions, (best_path, best_distance))
    # push!(no_improvement, 0)

    println("Start best: $best_distance")


    for _ in 2:population # inicjalizacja rozwiązań
      path = shuffle(collect(1:nodes))
      dist = calculate_path(path, weights)
      push!(solutions, (path, dist))
      # push!(no_improvement, 0)

      if dist < best_distance
        best_path = copy(path)
        best_distance = dist
      end
    end

    it = 1

    while it <= 5000 # tu bedzie jakis stop fajniejszy
      #if it%1000 == 0 println("10%") end
      println("Iteration: $it")
      
      # petla nr 1 (pierwsze pszczolki)
      for k in 1:population
        (i, j) = rand(1:nodes, 2)
        (curr_solution, curr_distance) = solutions[k]
        (new_solution, new_distance) = move(curr_solution, (i, j), curr_distance, weights)

        if new_distance < curr_distance
          no_improvement[k] = 0
          solutions[k] = copy(new_solution), new_distance
          if new_distance < best_distance
            println("NEW BEST!: $(best_distance)")
            best_path = copy(new_solution)
            best_distance = new_distance  
          best_distance = new_distance
            best_distance = new_distance  
          best_distance = new_distance
            best_distance = new_distance  
          best_distance = new_distance
            best_distance = new_distance  
          end
        else
          no_improvement[k] += 1
        end

      end
      
      # pętla nr 2 (obserwatorzy)
      for k in 1:population
        random_flower = roulette(solutions[1][1])
        # p = rand()
        # random_flower = roulette_shoot(prob, p) # tu bedzie ruletka ale jeszcze nie ma :)

        (i, j) = rand(1:nodes, 2)
        curr_solution, curr_distance = solutions[random_flower]
        new_solution, new_distance = move(curr_solution, (i, j), curr_distance, weights)

        if new_distance < curr_distance
          no_improvement[k] = 0
          solutions[k] = copy(new_solution), new_distance
          if new_distance < best_distance
            println("NEW BEST!: $(best_distance)")
            best_path = copy(new_solution)
            best_distance = new_distance
          end
        else
          no_improvement[k] += 1
        end
      end

      # pętla nr 3 (zwiadowcy)
      for k in 1:population
        if no_improvement[k] > limit
          new_solution = shuffle(collect(1:nodes))
          new_distance = calculate_path(new_solution, weights)

          solutions[k] = copy(new_solution), new_distance
          no_improvement[k] = 0
          if new_distance < best_distance
            println("NEW BEST!: $(best_distance)")
            best_path = copy(new_solution)
            best_distance = new_distance
          end
        end
      end

      it+=1
    end # while

    return (best_path, best_distance)
  end # bee

end # module








