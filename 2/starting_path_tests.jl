include("./main.jl")
include("./data_generator.jl")

using TSPLIB
using JSON
using Plots
using PlotlyJS

"""
    tabu_after_x()
"""
function tabu_after_x()
  length_dict = Dict(
    :name => "Tabu search depending on starting path",
    :n => [],
    :y => Dict(
      :rnn => [], 
      :kr => [], 
      :twoopt => [] # rnn, krandom(10000), 2-opt
    ),
    :legend => Dict(
      :rnn => "repetitive nearest neighbour", 
      :kr => "k - random", 
      :twoopt => "2 - opt (nn)" # rnn, krandom(10000), 2-opt
    ),
    :save => "length-starting-path",
    :ylabel => "path's length"
  )

  max_distance = 100
  k = 1000
  sampleSize = 4


  for n in 10:10:150
    println(n)
    
    rnn_s = 0; kr_s = 0; twoopt_s = 0

    append!(length_dict[:n], n)
    
    for _ in 1:sampleSize
    tsp_dict = generate_dict(n, max_distance, true)
    #rnnp = repetitive_nearest_neighbour(tsp_dict)[1]
    #rnnp2 = copy(rnnp)
    rnn_s += tabu_search(repetitive_nearest_neighbour(tsp_dict)[1], invert, ("it", 1000), ("stat", 7), 10, 0.1, tsp_dict[:weights])[2]
    kr_s += tabu_search(k_random(tsp_dict, k)[1] , invert, ("it", 1000), ("stat", 7), 10, 0.1, tsp_dict[:weights])[2]
    twoopt_s += tabu_search(two_opt(tsp_dict, nearest_neighbour(2, tsp_dict[:weights])[1])[1], invert, ("it", 1000), ("stat", 7), 10, 0.1, tsp_dict[:weights])[2]
    

    end

    append!(length_dict[:y][:rnn], rnn_s/sampleSize)
    append!(length_dict[:y][:kr], kr_s/sampleSize)
    append!(length_dict[:y][:twoopt], twoopt_s/sampleSize)
    
  end

  isdir("./output/starting_path") || mkdir("./output/starting_path")
  isfile("./output/starting_path/length_from_x.json") || 
  open("./output/starting_path/length_from_x.json", "w") do io
    JSON.print(io, length_dict)
  end
  
end

function improvement_made()
  max_distance = 100
  k = 10000

  functions = [k_random, repetitive_nearest_neighbour, two_opt]
  name = Dict(k_random => "k - random", repetitive_nearest_neighbour => "repetitive nn", two_opt => "2 - opt")
  short = Dict(k_random => "kr", repetitive_nearest_neighbour => "rnn", two_opt => "twoopt")

  for func in functions
    data = Dict(
      :name => "Starting path improvement - " * name[func],
      :n => [],
      :y => Dict(
        :starting => [], 
        :tabu => []
      ),
      :legend => Dict(
        :starting => name[func], 
        :tabu => "after tabu"
      ),
      :save => short[func] * "_improv",
      :ylabel => "path's length"
    )
    sampleSize = 4
    
    for n in 10:10:150
      println(short[func], n)
      starts = 0
      tabus = 0
      for _ in 1:sampleSize
      tsp_dict = generate_dict(n, max_distance, true)
      
      startPath, startLength = callFunction(func, tsp_dict, k)
      starts += startLength

      tabuLength = tabu_search(startPath, invert, ("it", 1000), ("stat", 7), 10, 0.1, tsp_dict[:weights])[2]     
      tabus += tabuLength
      end
      append!(data[:n], n)
      append!(data[:y][:starting], starts/sampleSize)
      append!(data[:y][:tabu], tabus/sampleSize)
    end
    draw_plot(data)

    data[:name] = data[:name] * " [%]"
    data[:save] = data[:save] * "%"
    data[:ylabel] = " % of starting path"
    for i in 1:length(data[:n])
      data[:y][:tabu][i] = data[:y][:tabu][i] / data[:y][:starting][i] * 100
      data[:y][:starting][i] = 100
    end

    draw_plot(data)
    
  end
  
end

function callFunction(func::Function, tsp_dict::Dict, k::Int)
  if func == k_random return k_random(tsp_dict, k) end
  if func == repetitive_nearest_neighbour return repetitive_nearest_neighbour(tsp_dict) end
  if func == two_opt return two_opt(tsp_dict, repetitive_nearest_neighbour(tsp_dict)[1]) end
end

"""
    draw_plot(data_dict)
  Draws plot showing differences in path length for different starting paths.
  
# Parameters:
- `data_dict::Dict`: dictionary with data from tests. 
"""
function draw_plot(data_dict::Dict)
  x = data_dict["n"]
  plotTitle = data_dict["name"]
  series = collect(values(data_dict["y"]))
  legend = collect(values(data_dict["legend"]))
  saveName = data_dict["save"]
  yLabel = data_dict["ylabel"]

  # x = data_dict[:n]
  # plotTitle = data_dict[:name]
  # series = collect(values(data_dict[:y]))
  # legend = collect(values(data_dict[:legend]))
  # saveName = data_dict[:save]
  # yLabel = data_dict[:ylabel]

  plotlyjs()
  isdir("./plots") || mkdir("./plots")

  plt = Plots.plot()
  for i in 1:length(series) 
    plt = Plots.plot!(x, series[i], xticks=:all, marker=(:circle,5), yformatter = :plain, title=plotTitle, label = legend[i], legend=:bottomright, xlabel = "number of nodes", ylabel = yLabel)
  end
  
  Plots.savefig(plt, "./plots/" * saveName * ".png")
end

"""
  Main program function.
"""
function main()
  
  tabu_after_x()
  data_dict = JSON.parsefile("./output/starting_path/length_from_x.json")
  draw_plot(data_dict)
  #improvement_made()

end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
