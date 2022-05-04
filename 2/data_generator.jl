using Random

function generate_dict(N::Int, max_distance::Int, symmetrical::Bool)
  tsp = Dict(
    :dimension => N, 
    :weights => []
  )

  rng = MersenneTwister()
  tsp[:weights] = rand(rng, 1:max_distance, N, N) * 1.0

  
  if symmetrical
    for i in 1:N, j in i:N
     tsp[:weights][j, i] = tsp[:weights][i, j] 
    end
  end

  

  return tsp
end