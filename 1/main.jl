using TSPLIB
using Random

# counter = 0

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
- `path::Vector{T<:Integer}`: path with a given order of visited nodes.
- `weights::AbstractMatrix{Float64}`: matrix of weights between nodes.

## Returns:
- Sum of weights between nodes in the path.

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
- The best path and its length found from `k` repetitions.

"""
function k_random(tsp_dict::Dict, k::Int)
  @assert k >= 1  "Invalid number of tries"
  best_path = Vector{Int64}
  min_length = Float64

  for i in 1:k
    path = shuffle(collect(1:tsp_dict[:dimension]))
    length = calculate_path(path, tsp_dict[:weights])    
    # global counter += tsp_dict[:dimension] - 1
    best_path, min_length = (i == 1 || min_length > length) ? (path, length) : (best_path, min_length)
  end
  return (best_path, min_length)
end

"""
    nearest_neighbour(node, dimension, weights) -> (Array{Float64}, Float64)
  Calculates the best path using nearest neighbour algorithm with a given starting node.

## Parameters:
- `node::Int`: starting node.
- `dimension::Int`: number of nodes in a path.
- `weights::AbstractMatrix{Float64}`: matrix of weights between nodes.

## Returns:
- `Array{Int64}`: the best path found.
- `Float64`: path's weight.

"""
function nearest_neighbour(node::Int, dimension::Int, weights::AbstractMatrix{Float64})
  @assert node <= dimension && node > 0
  
  non_visited = collect(1:dimension)
  deleteat!(non_visited, node)
  
  path = [node]
  path_length = 0
  
  for i in 1:dimension-1
    min_length = maximum!(float([1]), weights[path[end], :])[1] + 1
    nearest_node = Int64

    for i in 1:size(non_visited, 1)
      len = weights[path[end], non_visited[i]]
      # global counter += 1
      (nearest_node, min_length) = min_length > len ? (non_visited[i], len) : (nearest_node, min_length)
    end
    
    push!(path, nearest_node)
    path_length += min_length
    deleteat!(non_visited, findall(x -> x == nearest_node, non_visited))
  end

  path_length += weights[path[end], node]
  return (path, path_length)
end

"""
    repetitive_nearest_neighbour(tsp_dict) -> (Array{Float64}, Float64)
  Returns the best path using nearest neighbour algorithm, having `i = 1,2,...,n` as a starting node.

## Parameters:
- `dimension::Int`: number of nodes in a path.
- `weights::AbstractMatrix{Float64}`: matrix of weights between nodes.

## Returns:
- `Array{Int64}`: the best path found.
- `Float64`: path's weight.

"""
function repetitive_nearest_neighbour(tsp_dict::Dict)
  best_path = Vector{Int64}
  min_length = Float64

  for i in 1:tsp_dict[:dimension]
    path, length = nearest_neighbour(i, tsp_dict[:dimension], tsp_dict[:weights])
    best_path, min_length = (i == 1 || min_length > length) ? (path, length) : (best_path, min_length)
  end
  return (best_path, min_length)
end

"""
    two_opt(tsp_dict, path) -> (Array{Float64}, Float64)
  Returns an improved path.

## Parameters:
- `tsp_dict::Dict`: `TSP` dataset.
- `path::Vector{T<:Integer}`: the path to improve.
  
## Returns:
- `Array{Int64}`: the best path found.
- `Float64`: path's weight.

"""
function two_opt(tsp_dict::Dict, path::Vector{T}) where T<:Integer
  best_path = copy(path)
  min_length = calculate_path(path, tsp_dict[:weights])
  better = true
  
  while better
    better = false
    for i in 1:length(path), j in i+1:length(path)
      # global counter+= 1
      new_path = reverse(path, i, j)
      new_length = calculate_path(new_path, tsp_dict[:weights])
      if new_length < min_length
        best_path = new_path
        min_length = new_length
        better = true
      end
    end
    path = best_path
  end
  return(best_path, min_length)
end

"""
    tsp_test(name, f, tsp_dict)
  Runs test for a given algorithm with `tsp_dict`.
  Requires function `func` to determine the best path for the algorithm.

## Parameters:
- `name::{String}`: name of the algorithm.
- `func::{Function}`: function used to calculate a path.
- `tsp_dict::Dict`: `TSP` dataset.

"""
function tsp_test(name::String, func::Function, tsp_dict::Dict, args...)
  (path, weight) = func(tsp_dict, args...)
  println("Algorithm: $name")
  if tsp_dict[:dimension] <= 51 println("Path: $path \nDistance: $weight\n")
  else println("Distance: $weight\n") end
end

function load_tsp(path::String)
  return struct_to_dict(readTSP(path))
end

"""
  Main program function.
"""
function main()
  # reading .tsp file and converting it to dictionary
  tsp_dict = load_tsp("./all/eil51.tsp")

  # k_random test
  tsp_test("k-random", k_random, tsp_dict, 100000)

  # repetitive_nearest_neighbour test
  tsp_test("repetitive nearest neighbour", repetitive_nearest_neighbour, tsp_dict)

  # 2-OPT test
  tsp_test("two-opt", two_opt, tsp_dict, repetitive_nearest_neighbour(tsp_dict)[1])
  
end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end

function counting_test(func::Function, tsp_dict::Dict, args...)
  # global counter = 0
  func(tsp_dict, args...)
  # return counter
end