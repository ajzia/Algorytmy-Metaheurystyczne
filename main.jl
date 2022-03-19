using TSPLIB
using Random

"""
    struct_to_dict(s) -> Dict
  Converts struct to dict.

Ref: https://stackoverflow.com/a/70317636.

## Parameters:
- `s::Struct`: struct to convert to dict.

## Returns:
- `Dict`: struct converted to dict.
"""
function struct_to_dict(s)
  return Dict(key => getfield(s, key) for key in propertynames(s))
end

"""
    calculate_path(path, weights) -> Float64
  Returns path's weight.

## Parameters:
- `path::Vector{T<:Integer}`: path with given order of visited nodes
- `weights::AbstractMatrix{Float64}`: matrix of weights between nodes

## Returns:
- Sum of weights between nodes in the path

"""
function calculate_path(path::Vector{T}, weights::AbstractMatrix{Float64}) where T<:Integer
  @assert isperm(path) "Invalid path"
  distance = weights[path[end], path[1]]
  for i in 1:length(path)-1
    distance += weights[path[i], path[i + 1]]
  end 
  return distance
end

"""
    k_random(tsp_dict, k) -> (Array{Float64}, Float64)
  Returns the best permutation out of k-random permutations.

## Parameters:
- `tsp_dict::Dict`: `TSP` dataset.
- `k::{Int}`: the number of repetitions.

## Returns:
- The best path and its length found from `k` repetitions

"""
function k_random(tsp_dict::Dict, k::Int)
  @assert k >= 1  "Invalid number of tries"
  best_path = Vector{Int64}
  min_length = Float64

  for i in 1:k
    path = shuffle(collect(1:tsp_dict[:dimension]))
    length = calculate_path(path, tsp_dict[:weights])
    
    best_path, min_length = (i == 1 || min_length > length) ?  (path, length) : (best_path, min_length)
  end
  return (best_path, min_length)
end

"""
  Main program function
"""
function main()
  # reading .tsp file and converting it to dictionary
  tsp = readTSP("./all/gr17.tsp")
  tsp_dict = struct_to_dict(tsp)

  # k_random test
  path, weight = k_random(tsp_dict, 100000)
  println("\nDistance: ", weight, "  Path: ", path)
end

main()
