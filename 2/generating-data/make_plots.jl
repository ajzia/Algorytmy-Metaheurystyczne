using Plots
using LaTeXStrings
import JSON

ENV["GKSwstype"] = "100"

macro Name(arg)
  string(arg)
end

function str_to_int_vector(a::Array{String})
  return map(x -> parse(Int, x), a)
end

function lexicographic_cmp(x::String)
  number_idx = findfirst(isdigit, x)
  str, num = SubString(x, 1, number_idx-1), SubString(x, number_idx, length(x))
  return str, parse(Int, num)
end

function sort_keys(dict::Dict)
  return sort(collect(keys(dict)), by=lexicographic_cmp)
end

function find_files(name, type, move, stop_type, stop_max, list_type, list_size, long_size, asp)
  if !isdir("./jsons") return end
  dict = Dict()
  i = 1

  foreach(readdir("./jsons")) do f
    println(f)
    name_split = split(strip(f), "-")
    println(name_split)
    if (("$name" in name_split == true) && 
      ("t$type" in name_split) && 
      ("m$move" in name_split) && 
      ("s$stop_type" in name_split) && 
      ("sm$stop_max" in name_split) && 
      ("lt$list_type" in name_split) && 
      ("ls$list_size" in name_split) && 
      ("long$long_size") && 
      ("a$asp" in name_split)
    )
      data[i] = JSON.parsefile("./jsons/$f"; dicttype=Dict, inttype=Int, use_mmap=true)
      i += 1
    end
  end

  return dict
end

function plot_move(data::Dict, plot_title::String)
  x::Array{Int} = []; insert::Array{Int} = []; invert::Array{Int} = []; swap::Array{Int} = []

  for k in sort_keys(data)
    push!(x, parse(Int, k))
    push!(insert, data[k][1])
    push!(invert, data[k][2])
    push!(swap, data[k][3])
  end

  plt = Plots.plot!(x, insert, xticks=:all, marker=(:circle,5), yformatter = :plain, title=plot_title, label = @Name(insert), legend=:outertopright,
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "calculated distance", size = (1000, 600))
  plt = Plots.plot!(x, invert, xticks=:all, marker=(:circle,5), yformatter = :plain, title=plot_title, label = @Name(invert), legend=:outertopright,
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "calculated distance", size = (1000, 600))
  plt = Plots.plot!(x, swap, xticks=:all, marker=(:circle,5), yformatter = :plain, title=plot_title, label = @Name(swap), legend=:outertopright,
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "calculated distance", size = (1000, 600))
  

  isdir("./plots") || mkdir("./plots")
  Plots.savefig(plt, "./plots/$(plot_title).png")
end

function plot_tabu_size(data::Dict, plot_title::String)
  x::Array{Int} = []; stat_one::Array{Int} = []; stat_seven::Array{Int} = []; rel_2::Array{Int} = []

  for k in sort_keys(data)
    push!(x, parse(Int, k))
    push!(stat_one, data[k][1])
    push!(stat_seven, data[k][2])
    push!(rel_2, data[k][3])
  end

  plt = Plots.plot!(x, stat_one, xticks=:all, marker=(:circle,5), yformatter = :plain, title=plot_title, label = "tabu_size = 1", legend=:outertopright,
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "calculated distance", size = (1000, 600))
  plt = Plots.plot!(x, stat_seven, xticks=:all, marker=(:circle,5), yformatter = :plain, title=plot_title, label = "tabu_size = 7", legend=:outertopright,
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "calculated distance", size = (1000, 600))
  plt = Plots.plot!(x, rel_2, xticks=:all, marker=(:circle,5), yformatter = :plain, title=plot_title, label = "tabu_size = nodes / 2", legend=:outertopright,
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "calculated distance", size = (1000, 600))
  

  isdir("./plots") || mkdir("./plots")
  Plots.savefig(plt, "./plots/$(plot_title).png")
end

function plot_thread(one::Dict, two::Dict, four::Dict, eight::Dict, plot_title::String)
  x::Array{Int} = []; stat_one::Array{Float64} = []; stat_two::Array{Float64} = []; stat_four::Array{Float64} = []; stat_eight::Array{Float64} = []

  for k in sort_keys(one)
    push!(x, parse(Int, k))
    push!(stat_one, one[k][1])
    push!(stat_two, two[k][1])
    push!(stat_four, four[k][1])
    push!(stat_eight, eight[k][1])
  end

  plt = Plots.plot!(x, stat_one, xticks=:all, marker=(:circle,5), yformatter = :plain, title=plot_title, label = "thread = 1", legend=:outertopright,
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "time", size = (1000, 600))
  plt = Plots.plot!(x, stat_two, xticks=:all, marker=(:circle,5), yformatter = :plain, title=plot_title, label = "threads = 2", legend=:outertopright,
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "time", size = (1000, 600))
  plt = Plots.plot!(x, stat_four, xticks=:all, marker=(:circle,5), yformatter = :plain, title=plot_title, label = "threads = 4", legend=:outertopright,
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "time", size = (1000, 600))
    plt = Plots.plot!(x, stat_eight, xticks=:all, marker=(:circle,5), yformatter = :plain, title=plot_title, label = "threads = 8", legend=:outertopright,
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "time", size = (1000, 600))
  

  isdir("./plots") || mkdir("./plots")
  Plots.savefig(plt, "./plots/$(plot_title).png")
end

function main(args::Array{String})
  data = JSON.parsefile("./jsons/$(args[1])"; dicttype=Dict, inttype=Int, use_mmap=true)
  if length(args) == 5
    one_thread = JSON.parsefile("./jsons/$(args[1])"; dicttype=Dict, inttype=Int, use_mmap=true)
    two_threads = JSON.parsefile("./jsons/$(args[2])"; dicttype=Dict, inttype=Int, use_mmap=true)
    four_threads = JSON.parsefile("./jsons/$(args[3])"; dicttype=Dict, inttype=Int, use_mmap=true)
    eight_threads = JSON.parsefile("./jsons/$(args[4])"; dicttype=Dict, inttype=Int, use_mmap=true)
    type = args[5]
    
    if type == "1" title = "tabu-threads-step100-tsymm-minvert-sit-sm500-ltstat-ls7-long10-a0.05"
    else title = "tabu-threads-step50-tsymm-minvert-sit-sm500-ltstat-ls7-long10-a0.05" end
      plot_thread(one_thread, two_threads, four_threads, eight_threads, title)
    return
  end
  
  if length(args) >= 10 data = JSON.parsefile("./jsons/$(args[10])"; dicttype=Dict, inttype=Int, use_mmap=true) end
  if length(args) > 3 && args[3] == "all" 
    plot_move(data, "tabu-$(args[1])-t$(args[2])-m$(args[3])-s$(args[4])-sm$(args[5])-lt$(args[6])-ls$(args[7])-long$(args[8])-a$(args[9])")
  end
  if length(args) > 6 && args[6] == "mix"
    plot_tabu_size(data, "tabu-$(args[1])-t$(args[2])-m$(args[3])-s$(args[4])-sm$(args[5])-lt$(args[6])-ls$(args[7])-long$(args[8])-a$(args[9])")
  end
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end