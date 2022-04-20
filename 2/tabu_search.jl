# dzisiejsza lista tabu: przepraszam, sorry, sory, sorki 
module TabuSearch
  using DataStructures 

  # exports from ../1/main.jl
  export load_tsp, struct_to_dict, calculate_path
  export k_random, nearest_neighbour, repetitive_nearest_neighbour, two_opt
  # exports from this file
  export tabu_search
  # exports from ./stop_move.jl
  export swap, invert, insert

  """
      tabu_search(duzo argumentow) -> (costam)
    Returns the best found path.

  ## Parameters:
  - `path::Vector{T<:Integer}`: the path to improve.
    
  ## Returns:
  - `Array{Int64}`: the best path found.
  - `Float64`: path's weight.

  """
  function tabu_search(starting_path::Vector{T}, move::Function, stop_cond::String, max::Float64, tabu_size::Int, nodes::Int, weights::AbstractMatrix{Float64}) where T<:Integer
    stops = ["it", "time", "dest", "best"]; @assert stop_cond in stops
    stats = Dict(); for s in stops stats[s] = 0 end

    starting_length = calculate_path(starting_path, weights)

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

    while true
      stats["it"] += 1
      if stats[stop_cond] > max return global_best_path, global_best_length end

      for i in 1:nodes-1, j in i+1:nodes
        if tabu_matrix[i][j] continue end
        current_path = move(selected_path, i, j)
        current_length = calculate_path(current_path, weights); stats["dest"] += 1

        if current_length < local_best_length
          local_best_path = copy(current_path)
          local_best_length = current_length
          ij = [i, j]
        end
      end

      if local_best_length < global_best_length
        global_best_path = copy(local_best_path)
        global_best_length = local_best_length
        stats["best"] = 0
      else stats["best"] += 1 end
        
      selected_path = local_best_path
      selected_path_length = local_best_length

      x = dequeue!(tabu_list); enqueue!(tabu_list, ij) # tabu list
      tabu_matrix[ij[1]][ij[2]] = tabu_matrix[ij[2]][ij[1]] = true

      if x != [-1, -1]
        tabu_matrix[x[1]][x[2]] = tabu_matrix[x[2]][x[1]] = false
      end

      stats["it"] += 1
      if stats[stop_cond] > max return global_best_path, global_best_length end
    end  # while

  end # tabu search

  include("../1/main.jl")
  include("./move.jl")
end
