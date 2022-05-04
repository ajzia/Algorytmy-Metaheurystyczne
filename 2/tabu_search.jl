# dzisiejsza lista tabu: wkurzanie sie na innych
module TabuSearch
  using TimesDates  
  using FLoops

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
  function tabu_search(starting_path::Vector{Int}, move::Function, stop::Tuple{String, Int}, list_size::Tuple{String, Int}, long_size::Int, asp::Float64, weights::AbstractMatrix{Float64})
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
    selected_path::Vector{Int} = [];     selected_path_length::Float64 = 0

    # init
    global_best_path = copy(starting_path)
    local_best_path = copy(starting_path)
    current_path = copy(starting_path)
    selected_path = copy(starting_path)

    global_best_length = local_best_length = current_length = selected_path_length = starting_length

    # tabu list & matrix
    tabu_list::Array{Tuple{Int, Int}} = [(-1, -1) for _ in 1:tabu_size]
    tabu_matrix::Vector{BitVector} = [BitVector([0 for _ in 1:nodes]) for _ in 1:nodes]
    ij::Tuple{Int, Int} = (-1,-1)
    
    # long term memory
    memory_list::Array = []

    # neighbours 
    ranges::Vector{Tuple{Int, Int}} = range_split(nodes)

    println("Parameters: \nMove: $move \nStop criterion: \"$(stop[1])\", and max: $(stop[2]) \nType \"$(list_size[1])\", and size of tabu list: $(tabu_size) \nAspiration: $asp\n")

    function neighbourhood(range::Tuple{Int, Int})
      low::Int, high::Int = range
      dist::Float64 = typemax(Float64)
      mv::Tuple{Int, Int} = (-1, 1)
      path::Vector{Int} = copy(local_best_path) 

      for i in low:high
        low2 = (move == insert) ? 1 : i+1
        for j in low2:nodes
          if (i == j) continue end

          p::Vector{Int}, distance::Float64 = move(selected_path, (i, j), selected_path_length, weights)

          if (tabu_matrix[i][j] && distance > global_best_length * (1 - asp))
            continue
          end

          if (distance < dist)
            mv = (i, j)
            dist = distance
            path = copy(p)
          end
        end
      end
      return (path, dist, mv)
    end

    while true
      # println("$(stats["it"])")

      @floop for r in ranges
        (loop_path, loop_dist, loop_move) = neighbourhood(r)
        @reduce() do (p = Vector{Int}(undef, 0); loop_path), (dist = typemax(Float64); loop_dist), (mv = (-1,-1); loop_move)
          if (loop_dist < dist)
            p = loop_path
            dist = loop_dist
            mv = loop_move
          end
        end
      end
      
      (ij, local_best_path, local_best_length) = (mv, p, dist)

      if local_best_length < global_best_length
        global_best_path, global_best_length = copy(local_best_path), local_best_length
        t = copy(tabu_list)
        popfirst!(t)
        push!(t, ij)
        push!(memory_list, (copy(global_best_path), global_best_length, t, tabu_matrix))

        if length(memory_list) > long_size
          popfirst!(memory_list)
        end
        stats["best"] = 0
      else 
        stats["best"] += 1 
        if stats["best"] % 1000 == 0 && memory_list != []
          x = pop!(memory_list)
          local_best_path = x[1]
          local_best_length = x[2]
          tabu_list = x[3]
          tabu_matrix = x[4]
          ij = (-1, -1)
        end 
      end
        
      selected_path, selected_path_length = local_best_path, local_best_length

      if ij != (-1, -1) 
        y = findfirst(x -> x == ij, tabu_list)
        if y === nothing x = popfirst!(tabu_list) 
        else deleteat!(tabu_list, y); x = (-1,-1) end

        push!(tabu_list, ij)
        if ij != (-1, -1) tabu_matrix[ij[1]][ij[2]] = tabu_matrix[ij[2]][ij[1]] = true end
        if x != (-1, -1) tabu_matrix[x[1]][x[2]] = tabu_matrix[x[2]][x[1]] = false end
      end

      stats["it"] += 1
      if stats[stop_cond] > max return global_best_path, global_best_length end
    end  # while

  end # tabu search

  include("../1/main.jl")
  include("./move.jl")
end # module
