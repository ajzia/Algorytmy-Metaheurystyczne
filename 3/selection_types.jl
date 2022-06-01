function roulette(distances::Vector{Float64})
  min = minimum(distances)
  while true
    random_bee = rand(1:length(distances))
    if rand() < min / distances[random_bee]
      return random_bee
    end
  end
end


function tournament(distances::Vector{Float64}, lambda::Float64)
  n::Int = round(lambda*length(distances))
  solutions = rand(distances, n)

  return argmin(solutions)
end

# "Tournament Selection Based Artificial Bee Colony Algorithm with Elitist Strategy"
#     -> Meng-Dan Zhang, Zhi-Hui Zhan, Jing-Jing Li & Jun Zhang 
