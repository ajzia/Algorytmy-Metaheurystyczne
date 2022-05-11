using Random

function generate_dict(N::Int, max_distance::Int, symmetrical::Bool)
  tsp = Dict(
    :dimension => N, 
    :weights => []
  )

  rng = MersenneTwister()
  tsp[:weights] = rand(rng, 1:max_distance, N, N) * 1.0
  

  for i in 1:N, j in i:N
    if (i == j) tsp[:weights][i, j] = 0 end
    if symmetrical tsp[:weights][j, i] = tsp[:weights][i, j] end
  end

  return tsp
end
