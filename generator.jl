function generate(n::Int, min::Int, max::Int) # -> AbstractMatrix{Float64}
  array = rand(min:max, n, n)
  return array
end