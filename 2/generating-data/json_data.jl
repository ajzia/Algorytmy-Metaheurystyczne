include("../tabu_search.jl")
using .TabuSearch
using JSON
using Dates
using TimesDates

const tsp_files = [
  "burma14", "gr17", "ulysses22", "fri26", "bays29", 
  "swiss42", "eil51", "st70", "eil76", "gr96", 
  "kroA100", "pr107", "bier127", "ch130", "gr137",
  "pr144", "kroA150", "u159", "si175", "kroB200"
  ]

function prd(data::Float64, optimal::Int)
  return ((data - optimal) / optimal) * 100
end

function generate_data(
  algorithm::Function, 
  alg_name::String, 
  type::String,       # from tsp, symm, asymm
  move, 
  stop_type::String, stop_max::Int, 
  list_type::String, list_size::Int, 
  long_size::Int,
  asp::Float64,
  args...)

  results = Dict()

  if type == "tsp"
    collection = [
      "burma14", "gr17", "ulysses22", "fri26", "bays29", 
      "swiss42", "eil51", "st70", "eil76", "gr96", 
      "kroA100", "pr107", "bier127", "ch130", "gr137",
      "pr144", "kroA150", "u159", "si175", "kroB200"
      ]
  elseif type in ("symm", "asymm")
    collection = collect(10:10:200)
  end

  if length(args) > 0
    collection = collect(args[1]:args[2]:args[3])    
  end

  for n in collection
    if type == "tsp"
      println("Current file: $n tsp")
      tsp_dict = load_tsp("./all/$(n).tsp")
    elseif type == "symm" 
      println("Current size: $n symmetric")
      tsp_dict = generate_dict(n, 500, true)
    elseif type == "asymm"
      println("Current size: $n asymmetric")
      tsp_dict = generate_dict(n, 500, false)
    end

    nodes = tsp_dict[:dimension]
    results[nodes] = []
    path::Vector{Int} = []

    if alg_name == "k_random" path = algorithm(tsp_dict, 10000)[1]
    elseif alg_name == "repetitive_nearest_neighbour" path = algorithm(tsp_dict)[1]
    elseif alg_name == "two_opt" 
      p::Vector{Int} = repetitive_nearest_neighbour(tsp_dict)[1]
      path = two_opt(tsp_dict, p)[1]
    end

    # println(path)

    if move == "all"
      # insert, invert, swap
      println("Start insert.")
      dist = tabu_search(path, insert, (stop_type, stop_max), (list_type, list_size), long_size, asp, tsp_dict[:weights])[2]
      println("End insert.")
      push!(results[nodes], dist)
      println(dist)
      println("Start invert.")
      dist = tabu_search(path, invert, (stop_type, stop_max), (list_type, list_size), long_size, asp, tsp_dict[:weights])[2]
      println("End invert.")
      push!(results[nodes], dist)
      println("Start swap.")
      dist = tabu_search(path, swap, (stop_type, stop_max), (list_type, list_size), long_size, asp, tsp_dict[:weights])[2]
      println("End swap.")
      println(dist)
      push!(results[nodes], dist)

      # if type == "tsp"
      #   opt::Int = (n == "ulysses22") ? 7013 : tsp_dict[:optimal]
      #   best_prd = prd(minimum(results[nodes]), opt)
      #   push!(results[nodes], best_prd)
      # end

    elseif list_type == "mix"
      # 1, 7, n/2
      dist = tabu_search(path, move, (stop_type, stop_max), ("stat", 1), long_size, asp, tsp_dict[:weights])[2]
      push!(results[nodes], dist)
      dist = tabu_search(path, move, (stop_type, stop_max), ("stat", 7), long_size, asp, tsp_dict[:weights])[2]
      push!(results[nodes], dist)
      dist = tabu_search(path, move, (stop_type, stop_max), ("rel", 2), long_size, asp, tsp_dict[:weights])[2]
      push!(results[nodes], dist)
    elseif long_size == -1
      dist = tabu_search(path, move, (stop_type, stop_max), (list_type, list_size), 0, asp, tsp_dict[:weights])[2]
      push!(results[nodes], dist)
      dist = tabu_search(path, move, (stop_type, stop_max), (list_type, list_size), 1, asp, tsp_dict[:weights])[2]
      push!(results[nodes], dist)
      dist = tabu_search(path, move, (stop_type, stop_max), (list_type, list_size), 7, asp, tsp_dict[:weights])[2]
      push!(results[nodes], dist)
      dist = tabu_search(path, move, (stop_type, stop_max), (list_type, list_size), fld(nodes, 2), asp, tsp_dict[:weights])[2]
      push!(results[nodes], dist)
    elseif asp == 100.0
      dist = tabu_search(path, move, (stop_type, stop_max), (list_type, list_size), long_size, 0.01, tsp_dict[:weights])[2]
      push!(results[nodes], dist)
      dist = tabu_search(path, move, (stop_type, stop_max), (list_type, list_size), long_size, 0.04, tsp_dict[:weights])[2]
      push!(results[nodes], dist)
      dist = tabu_search(path, move, (stop_type, stop_max), (list_type, list_size), long_size, 0.07, tsp_dict[:weights])[2]
      push!(results[nodes], dist)

    elseif length(args) > 0
      test_start = time_ns()
      tabu_search(path, move, (stop_type, stop_max), (list_type, list_size), long_size, asp, tsp_dict[:weights])
      test_end = time_ns()
      timee = (test_end - test_start) * 1e-6
      push!(results[nodes], timee)
    else
      dist = tabu_search(path, move, (stop_type, stop_max), (list_type, list_size), long_size, asp, tsp_dict[:weights])[2]
      # println(dist)
      push!(results[nodes], dist)
    end

    if type == "tsp"
      opt::Int = (n == "ulysses22") ? 7013 : tsp_dict[:optimal]
      best_prd = prd(minimum(results[nodes]), opt)
      push!(results[nodes], best_prd)
    end

    # test_start = time_ns()
    # test_end = time_ns()
    # time = (test_end - test_start) * 1e-6
    # push!(results["time"][i], time)
  end

  now = Dates.now()
  isdir("./jsons") || mkdir("./jsons")

  if length(args) < 1 dir = "./jsons/tabu-$(alg_name)-t$type-m$move-s$stop_type-sm$stop_max-lt$list_type-ls$list_size-long$long_size-a$asp-$now.json" 
  else dir = "./jsons/tabu-$(alg_name)-t$type-th$(args[4])-m$move-s$stop_type-sm$stop_max-lt$list_type-ls$list_size-long$long_size-a$asp-$now.json" end
  open(dir, "w") do io
    JSON.print(io, results)
  end    
end

function main(args)
  algs = Dict(  
    "k_random" => k_random,
    # "nearest_neighbour" => nearest_neighbour,
    "repetitive_nearest_neighbour" => repetitive_nearest_neighbour, 
    "two_opt" => two_opt
    ) # algorithms

  moves = Dict(
    "insert" => insert,
    "swap" => swap, 
    "invert" => invert,
    "all" => "all"
  ) # moves

  type = args[1] # type of data
  move = args[2] # type of move
  stop_type = args[3] # stop type 
  stop_max = parse(Int, args[4])
  list_type = args[5]; list_size = parse(Int, args[6]) 
  long_size = parse(Int, args[7])
  asp = parse(Float64, args[8])
  name = args[9]

  if length(args) == 13
    st = parse(Int, args[10])
    step = parse(Int, args[11])
    eend = parse(Int, args[12])
    threads = args[13]
  end

  # starting node / repetitions for k_random
  for i in keys(algs)
    if i == name
      generate_data(algs[i], name, type, moves[move], stop_type, stop_max, list_type, list_size, long_size, asp, st, step, eend, threads)
    end
  end
end

if abspath(PROGRAM_FILE) == @__FILE__
  if length(ARGS) < 9
    println("Usage: julia data.jl [type] [move] [stop_type] [stop_max] [list_type] [list_size] [long_size] [asp] [starting_path_algoritm]")
    return 
  end

  main(ARGS)
end
