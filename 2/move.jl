"""
    swap(pathway, move, distance, weights) -> (Vector{Int}, Float64)
  Swaps two elements in the `pathway` and calculates its length.

## Parameters:
- `pathway::Vector{Int}`: path with a given order of visited nodes.
- `move::Array{Int}`: move to make, tuple of path's indexes `i` and `j`.
- `distance::Float64`: orignal path's distance.
- `weights::AbstractMatrix{Float64}`: matrix of weights between nodes.
  
## Returns:
- `Vector{Int}`: changed path.
- `Float64`: lenght of the changed path.

"""
function swap(pathway::Vector{Int}, move::Array{Int}, distance::Float64, weights::AbstractMatrix{Float64})#, flag::Bool)
  i, j = move[1], move[2]; nodes = size(weights, 1); path = copy(pathway)
  if i > j i, j = j, i end
  path[i], path[j] = path[j], path[i] 

  prev_i = i == 1 ? nodes : i - 1
  prev_j = j == 1 ? nodes : j - 1
  next_i = i == nodes ? 1 : i + 1
  next_j = j == nodes ? 1 : j + 1

  # for asymetric if flag return end

  path_length = path_len = distance
  path_length -= weights[path[j], path[next_i]]
  path_length -= weights[path[prev_j], path[i]]
  path_length += weights[path[i], path[next_i]]
  path_length += weights[path[prev_j], path[j]]
  
  if (i == 1 && j == nodes) return path, path_length end
  path_len -= weights[path[prev_i], path[j]]
  path_len -= weights[path[i], path[next_j]]
  path_len += weights[path[prev_i], path[i]]
  path_len += weights[path[j], path[next_j]]

  if j-i == 1 return path, path_len end

  return path, path_length + path_len - distance
end

"""
    invert(pathway, move, distance, weights) -> (Vector{Int}, Float64)
  Inverts elements between two indexes in the path and calculates its length.

## Parameters:
- `pathway::Vector{Int}`: path with a given order of visited nodes.
- `move::Array{Int}`: move to make, tuple of pathway's indexes `i` and `j`.
- `distance::Float64`: orignal path's distance.
- `weights::AbstractMatrix{Float64}`: matrix of weights between nodes.
  
## Returns:
- `Vector{Int}`: changed path.
- `Float64`: lenght of the changed path.

"""
function invert(pathway::Vector{Int}, move::Array{Int}, distance::Float64, weights::AbstractMatrix{Float64})#, flag::Bool)
  i, j = move[1], move[2]; nodes = size(weights, 1); path = copy(pathway)
  if i > j i, j = j, i end
  reverse!(path, i, j)

  if (i == 1 && j == nodes) return path, distance end

  prev_i = i == 1 ? nodes : i - 1
  next_j = j == nodes ? 1 : j + 1

  # for asymetric if flag return end

  path_length = distance
  path_length -= weights[path[prev_i], path[j]]
  path_length -= weights[path[i], path[next_j]]

  path_length += weights[path[prev_i], path[i]]
  path_length += weights[path[j], path[next_j]]
  
  return path, path_length
end

"""
    insert(pathway, move, distance, weights) -> (Vector{Int}, Float64)
  Inserts element from `i`-th position to the `j`-th position in the path and calculates its lenght.

## Parameters:
- `pathway::Vector{Int}`: path with a given order of visited nodes.
- `move::Array{Int}`: move to make, tuple of pathway's indexes `i` and `j`.
- `distance::Float64`: orignal path's distance.
- `weights::AbstractMatrix{Float64}`: matrix of weights between nodes.
  
## Returns:
- `Vector{Int}`: changed path.
- `Float64`: lenght of the changed path.

"""
function insert(pathway::Vector{Int}, move::Array{Int}, distance::Float64, weights::AbstractMatrix{Float64})#, flag::Bool)
  i, j = move[1], move[2]; nodes = size(weights, 1); path = copy(pathway)

  if i > j println("i = $i, j = $j\nBefore insert: ", path) end

  temp = path[i]
  deleteat!(path, i)
  insert!(path, j, temp)

  if i > j println("After insert: ", path) end

  if (i == 1 && j == nodes) return path, distance end

  # for asymetric if flag return end

  prev_i = i == 1 ? nodes : i - 1
  prev_j = j == 1 ? nodes : j - 1
  next_j = j == nodes ? 1 : j + 1
  next_i = i == nodes ? 1 : i + 1

  path_length = distance
  if i < j
    path_length -= weights[path[prev_i], path[j]]
    path_length -= weights[path[i], path[j]]
  else
    path_length -= weights[path[i], path[j]]
    path_length -= weights[path[next_i], path[j]]
  end
  path_length -= weights[path[prev_j], path[next_j]]
  
  if i < j path_length += weights[path[prev_i], path[i]]
  else path_length += weights[path[i], path[next_i]] end
  path_length += weights[path[prev_j], path[j]]
  path_length += weights[path[j], path[next_j]]

  @assert path_length == calculate_path(path, weights)
  return path, path_length
end

function uno_reverse(best::Tuple{Vector{Int}, Float64}, move::Function, matrix::Vector{BitVector}, tabu::Array{Vector{Int}}, memory_list, weights::AbstractMatrix{Float64})
  path, distance = best
  for _ in 1:length(tabu)
    x = popfirst!(tabu)
    if x != [-1, -1] matrix[x[1]][x[2]] = matrix[x[2]][x[1]] = false end
  end

  ij, tabu = memory_list[end]
  # println("ij   $ij")
  # println(memory_list[end])
  deleteat!(memory_list, length(memory_list))
  
  # print("MEMORY LIST:    ")

  for i in 1:length(tabu)
    x = tabu[i]
    if x != [-1, -1] matrix[x[1]][x[2]] = matrix[x[2]][x[1]] = true end
  end

  popfirst!(tabu)
  push!(tabu, ij)
  if ij != [-1, -1] matrix[ij[1]][ij[2]] = matrix[ij[2]][ij[1]] = true end
  # println(matrix[5][6])

  println("--- ij: ", ij, ", path ", path, ", distance: ", distance)
  path, distance = move(path, [ij[2], ij[1]], distance, weights)
  @assert distance == calculate_path(path, weights)
  return path, distance, tabu
end
