include("../1/main.jl")
using DataStructures;
# dzisiejsza lista tabu: przepraszam, sorry, sory, sorki 

"""
    tabu_search(duzo argumentow) -> (costam)
  Returns the best found path.

## Parameters:
- `tsp_dict::Dict`: `TSP` dataset.
- `path::Vector{T<:Integer}`: the path to improve.
  
## Returns:
- `Array{Int64}`: the best path found.
- `Float64`: path's weight.

"""
function tabu_search(tsp_dict::Dict, starting_path::Vector{T}, stop_cond::String, max::Float64, tabu_size::Int, nodes::Int) where T<:Integer

  print("in tabu")

  starting_length = calculate_path(starting_path, tsp_dict[:weights])

  # variables
  global_best_path::Vector{Int} = [];  global_best_length::Float64 = 0
  local_best_path::Vector{Int} = [];   local_best_length::Float64 = 0
  current_path::Vector{Int} = [];      current_length::Float64 = 0
  selected_path::Vector{Int} = [];     selected_length::Float64 = 0


  # init
  global_best_path = copy(starting_path)
  local_best_path = copy(starting_path)
  current_path = copy(starting_path)
  selected_path = copy(starting_path)

  global_best_length = local_best_length = current_length = selected_path_length = starting_length

  # tabu list & matrix
  tabu_list = Queue{Vector{Int}}()
  for _ in 1:tabu_size enqueue!(tabu_list, [-1, -1]) end
  tabu_matrix::Vector{BitVector} = [BitVector([0 for _ in 1:nodes]) for _ in 1:nodes]
  
  ij = [-1, -1]

  it = 0
  while true

    for i in 1:nodes-1, j in i+1:nodes
      if tabu_matrix[i][j] continue end
      #current_path = move(selected_path, i, j)
      current_path = reverse(selected_path, i, j) # tylko do testu
      current_length = calculate_path(current_path, tsp_dict[:weights])

      if current_length < local_best_length
        local_best_path = copy(current_path)
        local_best_length = current_length
        ij = [i, j]
      end
    end

    if local_best_length < global_best_length
      global_best_path = copy(local_best_path)
      global_best_length = local_best_length
    end

    selected_path = local_best_path
    selected_path_length = local_best_length

    x = dequeue!(tabu_list); enqueue!(tabu_list, ij) # tabu list
    tabu_matrix[ij[1]][ij[2]] = tabu_matrix[ij[2]][ij[1]] = true

    if x != [-1, -1]
      tabu_matrix[x[1]][x[2]] = tabu_matrix[x[2]][x[1]] = false
    end

    it+=1
    if it == 2000 return (global_best_path, global_best_length) end
  end  
end

"""
  Main program function.
"""
function main()
  tsp_dict = load_tsp("./all/eil51.tsp")
  # tabu
  print(tabu_search(tsp_dict, k_random(tsp_dict, 100)[1], "0", 0.0, 10, tsp_dict[:dimension]))
end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
