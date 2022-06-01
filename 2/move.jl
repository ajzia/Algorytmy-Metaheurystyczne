"""
    swap(pathway, move, distance, weights) -> (Vector{Int}, Float64)
  Swaps two elements in the `pathway` and calculates its length.

## Parameters:
- `pathway::Vector{Int}`: path with a given order of visited nodes.
- `move::Tuple{Int, Int}`: move to make, array of path's indexes `i` and `j`.
- `distance::Float64`: original path's distance.
- `weights::AbstractMatrix{Float64}`: matrix of weights between nodes.
  
## Returns:
- `Vector{Int}`: changed path.
- `Float64`: lenght of the changed path.

"""
function swap(pathway::Vector{Int}, move::Tuple{Int, Int}, distance::Float64, weights::AbstractMatrix{Float64})
  i::Int, j::Int = move; nodes::Int = size(weights, 1); path::Vector{Int} = copy(pathway)
  path[i], path[j] = path[j], path[i] 

  prev_i::Int = i == 1 ? nodes : i - 1
  prev_j::Int = j == 1 ? nodes : j - 1
  next_i::Int = i == nodes ? 1 : i + 1
  next_j::Int = j == nodes ? 1 : j + 1

  path_length::Float64 = path_len::Float64 = distance
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

  return (path, path_length + path_len - distance)
end

"""
    invert(pathway, move, distance, weights) -> (Vector{Int}, Float64)
  Inverts elements between two indexes in the path and calculates its length.

## Parameters:
- `pathway::Vector{Int}`: path with a given order of visited nodes.
- `move::Tuple{Int, Int}`: move to make, array of path's indexes `i` and `j`.
- `distance::Float64`: original path's distance.
- `weights::AbstractMatrix{Float64}`: matrix of weights between nodes.
  
## Returns:
- `Vector{Int}`: changed path.
- `Float64`: lenght of the changed path.

"""
function invert(pathway::Vector{Int}, move::Tuple{Int, Int}, distance::Float64, weights::AbstractMatrix{Float64})
  i::Int, j::Int = move; nodes::Int = size(weights, 1); path::Vector{Int} = copy(pathway)
  if i > j i, j = j, i end

  reverse!(path, i, j)

  if (i == 1 && j == nodes) return (path, distance) end

  prev_i::Int = i == 1 ? nodes : i - 1
  next_j::Int = j == nodes ? 1 : j + 1

  path_length::Float64 = distance
  path_length -= weights[path[prev_i], path[j]]
  path_length -= weights[path[i], path[next_j]]

  path_length += weights[path[prev_i], path[i]]
  path_length += weights[path[j], path[next_j]]
  
  return (path, path_length)
end

"""
    insert(pathway, move, distance, weights) -> (Vector{Int}, Float64)
  Inserts element from `i`-th position to the `j`-th position in the path and calculates its length.

## Parameters:
- `pathway::Vector{Int}`: path with a given order of visited nodes.
- `move::Tuple{Int, Int}`: move to make, array of path's indexes `i` and `j`.
- `distance::Float64`: original path's distance.
- `weights::AbstractMatrix{Float64}`: matrix of weights between nodes.
  
## Returns:
- `Vector{Int}`: changed path.
- `Float64`: lenght of the changed path.

"""
function insert(pathway::Vector{Int}, move::Tuple{Int, Int}, distance::Float64, weights::AbstractMatrix{Float64})
  i::Int, j::Int = move; nodes::Int = size(weights, 1); path::Vector{Int} = copy(pathway)

  temp::Int = path[i]
  deleteat!(path, i)
  insert!(path, j, temp)

  if (i == 1 && j == nodes) return (path, distance) end

  prev_i::Int = i == 1 ? nodes : i - 1
  prev_j::Int = j == 1 ? nodes : j - 1
  next_j::Int = j == nodes ? 1 : j + 1

  path_length::Float64 = distance
  path_length -= weights[path[prev_i], path[j]]
  path_length -= weights[path[i], path[j]]
  path_length -= weights[path[prev_j], path[next_j]]

  path_length += weights[path[prev_i], path[i]]
  path_length += weights[path[prev_j], path[j]]
  path_length += weights[path[j], path[next_j]]

  return (path, calculate_path(path, weights))
end

function range_split(nodes)::Vector{Tuple{Int, Int}}
  threads::Int = Threads.nthreads()
  splits::Int = cld(nodes, threads)
  if (splits == 0) return Vector{Tuple{Int, Int}}([(1,nodes)]) end
  return Vector{Tuple{Int, Int}}(
    [
      if (i+splits < nodes) 
        Tuple{Int,Int}((i+1,i+splits)) 
      else 
        Tuple{Int,Int}((i+1, nodes)) 
      end 
      for i in 0:splits:nodes-1
    ]
  )
end
