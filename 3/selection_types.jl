# (http://www.sciencedirect.com/science/article/pii/S0378437111009010)
function roulette(distances::Vector{Float64}, args...)::Int
  min = minimum(distances)
  while true
    random_bee = rand(1:length(distances))
    if rand() < min / distances[random_bee]
      return random_bee
    end
  end
end

# "Tournament Selection Based Artificial Bee Colony Algorithm with Elitist Strategy"
#     -> Meng-Dan Zhang, Zhi-Hui Zhan, Jing-Jing Li & Jun Zhang 
function tournament(distances::Vector{Float64}, lambda::Float64)::Int
  n::Int = round(lambda*length(distances))
  solutions = rand(distances, n)

  return argmin(solutions)
end
