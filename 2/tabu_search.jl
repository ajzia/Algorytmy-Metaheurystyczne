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
      tabu_search(duzo argumentow) -> (costam)
    Returns the best found path.

  ## Parameters:
  - `path::Vector{T<:Integer}`: the path to improve.
    
  ## Returns:
  - `Array{Int64}`: the best path found.
  - `Float64`: path's weight.

  """
  function tabu_search(starting_path::Vector{Int}, move::Function, stop_cond::String, max::Int, tabu_size::String, nodes::Int, weights::AbstractMatrix{Float64}, asp::Float64)
    @assert asp > 0 && asp < 1
    
    stops = ["it", "time", "dest", "best"]; @assert stop_cond in stops
    stats = Dict(); for s in stops stats[s] = 0 end


    if tabu_size == "rel" # relative to the problem size
      tabu_size = cld(nodes, 5)
    else # static 
      tabu_size = parse(Int, tabu_list)
    end

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
    for _ in 1:tabu_size enqueue!(tabu_list, [-1, -1]) end
    tabu_matrix::Vector{BitVector} = [BitVector([0 for _ in 1:nodes]) for _ in 1:nodes]
    
    ij = [-1, -1]

    while true
      from_asp = false
      for i in 1:nodes-1, j in i+1:nodes
        #if tabu_matrix[i][j] continue end
        current_path = move(selected_path, i, j)
        current_length = calculate_path(current_path, weights); stats["dest"] += 1

        if (!tabu_matrix[i][j] && current_length < local_best_length) || (tabu_matrix[i][j] && current_length < asp * global_best_length)
          local_best_path = copy(current_path)
          local_best_length = current_length
          ij = [i, j]

          if(tabu_matrix[i][j])
            from_asp = true
            tabu_matrix[i][j] = false;
            tabu_matrix[j][i] = false;
            tabu_list.delete(ij)
            deleteat!(tabu_list, findfirst(x -> x=="s", tabu_list))
          end
        end
      end

      if local_best_length < global_best_length
        global_best_path = copy(local_best_path)
        global_best_length = local_best_length
        stats["best"] = 0
      else stats["best"] += 1 end
        
      selected_path = local_best_path
      selected_path_length = local_best_length

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
end
