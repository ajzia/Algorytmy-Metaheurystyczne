function swap(path::Vector{Int}, i::Int, j::Int)
  way = copy(path)
  way[i], way[j] = way[j], way[i]
  return way
end

function invert(path::Vector{Int}, i::Int, j::Int)
  way = copy(path)
  reverse!(way, i, j)
  return way
end

function insert(path::Vector{Int}, i::Int, j::Int)
  way = copy(path)
  temp = way[i]
  deleteat!(way, i)
  insert!(way, j, temp)
  return way
end
