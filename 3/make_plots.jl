using Plots
using LaTeXStrings
import JSON

ENV["GKSwstype"] = "100"

const BEES = [10, 100, 1000, 10000, 200, 2000, 25, 50, 500, 5000, 75]

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

function plot_prd(data::Dict, bees::Int, plot_title::String)
  prd = []
  for k in sort_keys(data)
    push!(x, parse(Int, k))
    push!(prd, data[k][1])
  end 

  plt = Plots.plot(x, prd, xticks=:all, marker=(:circle,5), yformatter = :plain, title=plot_title, label = "abc for $(bees) bees", legend=:outertopright,
    margin=5Plots.mm, xlabel = "number of nodes", ylabel = "prd % to optimal", size = (1000, 600))

  isdir("./plots") || mkdir("./plots")
  Plots.savefig(plt, "./plots/$(plot_title)-bees$(bee).png")

  return plt
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
  # data = JSON.parsefile("./jsons/$(args[1])"; dicttype=Dict, inttype=Int, use_mmap=true)
  # if length(args) == 5
  #   one_thread = JSON.parsefile("./jsons/$(args[1])"; dicttype=Dict, inttype=Int, use_mmap=true)
  #   two_threads = JSON.parsefile("./jsons/$(args[2])"; dicttype=Dict, inttype=Int, use_mmap=true)
  #   four_threads = JSON.parsefile("./jsons/$(args[3])"; dicttype=Dict, inttype=Int, use_mmap=true)
  #   eight_threads = JSON.parsefile("./jsons/$(args[4])"; dicttype=Dict, inttype=Int, use_mmap=true)
  #   type = args[5]
    
  #   if type == "1" title = "tabu-threads-step100-tsymm-minvert-sit-sm500-ltstat-ls7-long10-a0.05"
  #   else title = "tabu-threads-step50-tsymm-minvert-sit-sm500-ltstat-ls7-long10-a0.05" end
  #     plot_thread(one_thread, two_threads, four_threads, eight_threads, title)
  #   return
  # end
  
  prd_plots = []
  for (root, dirs, files) in walkdir("./bees_prd/")
    for (file, bee) in (files, BEES)
      data_dict = JSON.parsefile(joinpath(root, file))
      # draw_plot(data_dict["name"], data_dict)

      p = plot_prd(data_dict, bee, "prd for given number of bees")
      push!(prd_plots, p)

      # if data_dict["name"] == "prd"
      #   wilcoxon_test(data_dict)
      # end
    end
  end

  for pl in prd_plots
    Plots.plot!(pl)
  end

  isdir("./plots") || mkdir("./plots")
  Plots.savefig(plt, "./plots/prd_for_different bee_size.png")
end

if abspath(PROGRAM_FILE) == @__FILE__
  main(ARGS)
end