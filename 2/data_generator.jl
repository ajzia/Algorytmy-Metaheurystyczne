using Random

function generate_dict(N::Int, max_distance::Float64, symmetrical::Bool)
  tsp = Dict(
    :dimension => N, 
    :weights => []
  )

  rng = MersenneTwister()
  tsp[:weights] = rand(rng, Float64, N, N) * max_distance

  if symmetrical
    for i in 1:N, j in i+1:N
      tsp[:weights][i, j] = tsp[:weights][j, i]
    end
  end

  return tsp
end