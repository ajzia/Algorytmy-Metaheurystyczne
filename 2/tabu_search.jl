# dzisiejsza lista tabu: wszystkie brzydkie słowa
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
      tabu_search(starting_path, move, stop, tabu_size, asp, weights) -> (Vector{Int}, Float64)
    The algorithm returns the best permutation of the `path` it can find, having `starting_path` as a starting point.

  ## Parameters:
  - `starting_path::Vector{Int}`: the path to improve.
  - `move::Function`: type of movement.
  - `stop::Tuple{String, Int}`: type of stop criterion and its limit.
  - `list_size::Tuple{String, Int}`: type of tabu list length and it's parameter.
  - `asp::Float64`: value of the aspiration criterion.
  - `weights::AbstractMatrix{Float64}`: matrix of weights between nodes.
    
  ## Returns:
  - `Vector{Int}`: the best path found.
  - `Float64`: the path's weight.

  """
  function tabu_search(starting_path::Vector{Int}, move::Function, stop::Tuple{String, Int}, list_size::Tuple{String, Int}, asp::Float64, weights::AbstractMatrix{Float64})
    println("Parameters: \nMove: $move \nStop criterion: \"$(stop[1])\", and max: $(stop[2]) \nType \"$(list_size[1])\", and size of tabu list: $(list_size[2]) \nAspiration: $asp\n")
    @assert asp > 0 && asp < 1
    
    stop_cond, max = stop; nodes = size(weights, 1)

    stops = ["it", "time", "dest", "best"]; @assert stop_cond in stops
    stats = Dict(); for s in stops stats[s] = 0 end

    sizes = ["rel", "stat"]; @assert list_size[1] in sizes
    tabu_size = list_size[1] == "rel" ? cld(nodes, list_size[2]) : list_size[2]

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
    tabu_list::Array{Vector{Int}} = [[-1, -1] for i in 1:tabu_size]
    tabu_matrix::Vector{BitVector} = [BitVector([0 for _ in 1:nodes]) for _ in 1:nodes]
    
    ij = [-1, -1]

    while true
      from_asp = false
      for i in 1:nodes-1, j in i+1:nodes
        current_path, current_length = move(selected_path, (i, j), global_best_length, weights)
        stats["dest"] += 1

        if (!tabu_matrix[i][j] && current_length < local_best_length) || (tabu_matrix[i][j] && current_length < asp * global_best_length)
          local_best_path = copy(current_path)
          local_best_length = current_length
          ij = [i, j]

            if(tabu_matrix[i][j])
            from_asp = true
            tabu_matrix[i][j] = tabu_matrix[j][i] = false;
            deleteat!(tabu_list, findfirst(x -> x == ij, tabu_list))
          end
        end
      end

      if local_best_length < global_best_length
        global_best_path = copy(local_best_path)
        global_best_length = local_best_length
        stats["best"] = 0
      else stats["best"] += 1 end
        
      selected_path, selected_path_length = local_best_path, local_best_length

      if !from_asp x = popfirst!(tabu_list) end
      push!(tabu_list, ij) # tabu list (nie chcemy usuwac 1 jesli best jest z aspiracji - do zmiany)
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
end # module
