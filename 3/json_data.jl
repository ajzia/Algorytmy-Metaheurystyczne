include("./bee_colony.jl")
using .artificial_bee_colony
using JSON
using Dates
using TimesDates
using Statistics

const tsp_files = [
  "burma14", "gr17", "ulysses22", "fri26", "bays29", 
  "swiss42", "eil51", "st70", "eil76", "gr96", 
  "kroA100", "pr107", "bier127", "ch130", "gr137",
  "pr144", "kroA150", "u159", "si175", "kroB200"
  ]

const MOVES = Dict(
  "insert" => insert,
  "swap" => swap, 
  "invert" => invert,
) # moves
  
const SELECTION_FUNCS = Dict(
    "roulette" => roulette,
    "tournament" => tournament
  )
  
const STOP_COND = Dict(
  "it" => iteration_condition, 
  "time" => time_condition
  )  

function prd(data::Float64, optimal::Int)
  return ((data - optimal) / optimal) * 100
end

function generate_data(
  stat::String,
  type::String, 
  bees::Int,
  limit::Int,
  move::Function, 
  stop_type::Function, stop_max::Int, 
  select_func::Function, select_param::Float64
  )

  results = Dict()
  results["time"] = Dict()

  if type == "tsp"
    collection = tsp_files
  elseif type in ("symm", "asymm")
    collection = collect(10:10:200)
  end
  
  swarm = moving_swarm(bees, move)

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
    if stat == "threads" results["time"][nodes] = [] end
    temp = []; time_temp = []
    
    low = 1
    if stat == "threads" low = 5 end
    for i in 1:low
      test_start = time_ns()
      # println("Try: $(i)")
      _, distance = honex(swarm, limit, (stop_type, stop_max), nodes, tsp_dict[:weights], (select_func, select_param))
      push!(temp, distance)
      test_end = time_ns()
      time = (test_end - test_start) * 1e-6
      push!(time_temp, time) 
    end
    
    if stat == "threads" 
      # push!(results[nodes][])
      push!(results["time"][i], mean(time)) 
    end

    if stat == "oprd"
      push!(results[nodes], temp[1])
    end

    if stat == "prd" && type == "tsp"
      if type == "tsp"
        opt::Int = (n == "ulysses22") ? 7013 : tsp_dict[:optimal]
        best_prd = prd(mean(temp), opt)
        println("Mean: $(mean(temp)), Opt: $(opt), Prd: $(best_prd)")
        push!(results[nodes], best_prd)
      else
        opt = minimum(temp)
        best_prd = prd(mean(temp), opt)
        println("Mean: $(mean(temp)), Opt: $(opt), Prd: $(best_prd)")
        push!(results[nodes], best_prd)
      end
    end



    # test_start = time_ns()
    # test_end = time_ns()
    # time = (test_end - test_start) * 1e-6
    # push!(results["time"][i], time)

  end # end for

  now = Dates.now()
  isdir("./jsons") || mkdir("./jsons")

  dir = "./jsons/abc-s$(stat)-t$type-b$(bees)-l$(limit)-m$move-s$stop_type-sm$stop_max-sf$(select_func)-sp$(select_param)-$now.json" 
  open(dir, "w") do io
    JSON.print(io, results)
  end    
end

function main(args)
  stat = args[1]
  type = args[2]
  bees = parse(Int, args[3]); limit = parse(Int, args[4])
  move = MOVES[args[5]]
  stop_type = STOP_COND[args[6]]
  stop_max = parse(Int, args[7])
  select_func = SELECTION_FUNCS[args[8]]

  if (args[8] == "tournament") param = parse(Float64, args[9])
  else param = 0.0 end

  # starting node / repetitions for k_random
  generate_data(stat, type, bees, limit, move, stop_type, stop_max, select_func, param)
end

if abspath(PROGRAM_FILE) == @__FILE__
  if length(ARGS) < 8
    println("""
    Usage: julia data.jl 
    [type of statistic (prd, threads)]
    [type (tsp, symm, asymm)] 
    [n (no. bees)] 
    [stagnation limit] 
    [move (invert, insert, swap)] 
    [stop_type (it, time)] 
    [stop_max] 
    [selection type (roulette, tournament)] 
    [selection parameter (only for tournament)]""")
    return # tsp 50 5000 invert time 10 roulette # ew. 0.0
  end

  main(ARGS)
end
