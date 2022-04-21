function swap(pathway::Vector{Int}, move::Tuple{Int, Int}, distance::Float64, weights::AbstractMatrix{Float64})#, flag::Bool)
  i, j = move; nodes = size(weights, 1); path = copy(pathway)
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

function invert(pathway::Vector{Int}, move::Tuple{Int, Int}, distance::Float64, weights::AbstractMatrix{Float64})#, flag::Bool)
  i, j = move; nodes = size(weights, 1); path = copy(pathway)
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

function insert(pathway::Vector{Int}, move::Tuple{Int, Int}, distance::Float64, weights::AbstractMatrix{Float64})#, flag::Bool)
  i, j = move; nodes = size(weights, 1); path = copy(pathway)

  temp = path[i]
  deleteat!(path, i)
  insert!(path, j, temp)

  if (i == 1 && j == nodes) return path, distance end

  # for asymetric if flag return end

  prev_i = i == 1 ? nodes : i - 1
  prev_j = j == 1 ? nodes : j - 1
  next_j = j == nodes ? 1 : j + 1

  path_length = distance
  path_length -= weights[path[prev_i], path[j]]
  path_length -= weights[path[i], path[j]]
  path_length -= weights[path[prev_j], path[next_j]]
  
  path_length += weights[path[prev_i], path[i]]
  path_length += weights[path[prev_j], path[j]]
  path_length += weights[path[j], path[next_j]]

  return path, path_length
end
