include("../2/main.jl")
include("../2/data_generator.jl")

function roulette(solutions::Array{Tuple{Vector{Int}, Float64}}, nrOfBees::Int)

  k = nrOfBees

  4502394

  sum = 0
  for i in 1:k sum += solutions[i][2] end

  prob::Array{Float64} = [solutions[i][2]/sum for i in 1:k]
  #prob = [1-prob[i] for i in 1:k]

  #sum = 0
  #for i in 1:k sum += prob[i] end

  sum2 = 0
  #prob = [prob[i]/sum for i in 1:k]

  for i in 1:k
    prob[i] = (prob[i]/sum) + sum2
    sum2+=prob[i]
  end


  return prob
end

function roulette_shoot(prob::Array{Float64}, p::Float64)
  #sum=0
  idx = 1
  #println("prob: ", prob)
  while prob[idx] <= p
    #sum+=prob[idx]
    idx+=1

  end

  return idx
end

function bee() # i inne jakeis -> move::Function, ...

  move = invert

  n = 51
  max_distance = 100
  nr_of_bees = 5000
  L = 500 # po ilu iteracjach bez ulepszeń wywalamy rozwiązanie

  no_improvement::Array{Int} = []
  solutions::Array{Tuple{Vector{Int}, Float64}} = []


  #tsp_dict = generate_dict(n, max_distance, true)
  tsp_dict = load_tsp("../2/all/eil51.tsp")
  weights = tsp_dict[:weights]


  best_solution::Vector{Int} = [];  best_distance::Float64 = 0

  best_solution, best_distance = k_random(tsp_dict, 1)
  push!(solutions, (best_solution, best_distance))
  push!(no_improvement, 0)

  println("start best: $best_distance")


  for _ in 2:nr_of_bees # inicjalizacja rozwiązań
    solution, distance = k_random(tsp_dict, 1)
    push!(solutions, (solution, distance))
    push!(no_improvement, 0)

    if distance < best_distance
      best_solution = copy(solution)
      best_distance = distance
    end
  end

  it = 0

  while it < 10000 # tu bedzie jakis stop fajniejszy
    #if it%1000 == 0 println("10%") end
    println("it: $it")

    # pętla nr 1 (pierwsze pszczółki)
    for k in 1:nr_of_bees
      i = rand((1, n)); j = rand((1, n))
      curr_solution, curr_distance = solutions[k]
      new_solution, new_distance = move(curr_solution, (i, j), curr_distance, weights)

      if new_distance < curr_distance
        no_improvement[k] = 0
        solutions[k] = copy(new_solution), new_distance
        if new_distance < best_distance
          best_solution = copy(new_solution)
          best_distance = new_distance
        end
      else
        no_improvement[k] += 1
      end

    end
    
    # pętla nr 2 (obserwatorzy)
    for k in 1:nr_of_bees
      prob = roulette(solutions, nr_of_bees)
      p = rand()
      random_flower = roulette_shoot(prob, p) # tu bedzie ruletka ale jeszcze nie ma :)

      i = rand((1, n)); j = rand((1, n))
      curr_solution, curr_distance = solutions[random_flower]
      new_solution, new_distance = move(curr_solution, (i, j), curr_distance, weights)

      if new_distance < curr_distance
        no_improvement[k] = 0
        solutions[k] = copy(new_solution), new_distance
        if new_distance < best_distance
          best_solution = copy(new_solution)
          best_distance = new_distance
        end
      else
        no_improvement[k] += 1
      end
    end

    # pętla nr 3 (zwiadowcy)
    for k in 1:nr_of_bees
      if no_improvement[k] > L
        new_solution, new_distance = k_random(tsp_dict, 1)
        solutions[k] = copy(new_solution), new_distance
        no_improvement[k] = 0
        if new_distance < best_distance
          best_solution = copy(new_solution)
          best_distance = new_distance
        end
      end
    end


    it+=1
  end

  return (best_solution, best_distance)

end


"""
  Main program function.
"""
function main()
  
  path, distance = bee()

  println("path: $path \ndistance: $distance, optimal: $(load_tsp("../2/all/eil51.tsp")[:optimal]) ")
  
end


if abspath(PROGRAM_FILE) == @__FILE__
  main()
end



