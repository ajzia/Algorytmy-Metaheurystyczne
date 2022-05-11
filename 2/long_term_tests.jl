include("./main.jl")
include("./data_generator.jl")

using TSPLIB
using JSON
using Plots
using PlotlyJS

"""
    tabu_after_x()
"""
function long_on_off()
  length_dict = Dict(
    :name => "Long term memory size",
    :n => [],
    :y => Dict(
      :zero => [], 
      :one => [],
      :six => [], 
      :rel => []
    ),
    :legend => Dict(
      :zero => "size = 0", 
      :one => "size = 1",
      :six => "size = 6", 
      :rel => "size = n/2"
    ),
    :save => "long-size",
    :ylabel => "path's length"
  )

  max_distance = 100
  sampleSize = 4


  for n in 10:10:150
    println(n)
    zero = 0; one = 0; six = 0; rel = 0

    append!(length_dict[:n], n)

    for _ in 1:sampleSize
    tsp_dict = generate_dict(n, max_distance, true)
    rnnp = repetitive_nearest_neighbour(tsp_dict)[1]

    zero += tabu_search(copy(rnnp), invert, ("it", 1000), ("stat", 7), 0, 0.1, tsp_dict[:weights])[2]
    one += tabu_search(copy(rnnp), invert, ("it", 1000), ("stat", 7), 1, 0.1, tsp_dict[:weights])[2]
    six += tabu_search(copy(rnnp), invert, ("it", 1000), ("stat", 7), 6, 0.1, tsp_dict[:weights])[2] # 5 gorzej niz rel, 6+ = rel
    rel += tabu_search(copy(rnnp), invert, ("it", 1000), ("stat", 7), -1, 0.1, tsp_dict[:weights])[2]
    
    end

    append!(length_dict[:y][:zero], zero/sampleSize)
    append!(length_dict[:y][:one], one/sampleSize)
    append!(length_dict[:y][:six], six/sampleSize)
    append!(length_dict[:y][:rel], rel/sampleSize)
    
  end
  println("zero ", length_dict[:y][:zero][end])
  println("stat1 ", length_dict[:y][:one][end])
  println("stat2 ", length_dict[:y][:six][end])
  println("rel ", length_dict[:y][:rel][end])
  draw_plot(length_dict)
  # isdir("./output/starting_path") || mkdir("./output/starting_path")
  # isfile("./output/starting_path/length_from_x.json") || 
  # open("./output/starting_path/length_from_x.json", "w") do io
  #   JSON.print(io, length_dict)
  #end
  
end


"""
    draw_plot(data_dict)
  Draws plot showing differences in path length for different starting paths.
  
# Parameters:
- `data_dict::Dict`: dictionary with data from tests. 
"""
function draw_plot(data_dict::Dict)
  # x = data_dict["n"]
  # plotTitle = data_dict["name"]
  # series = collect(values(data_dict["y"]))
  # legend = collect(values(data_dict["legend"]))
  # saveName = data_dict["save"]
  # yLabel = data_dict["ylabel"]

  x = data_dict[:n]
  plotTitle = data_dict[:name]
  series = collect(values(data_dict[:y]))
  legend = collect(values(data_dict[:legend]))
  saveName = data_dict[:save]
  yLabel = data_dict[:ylabel]

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
  
  long_on_off()
  # data_dict = JSON.parsefile("./output/starting_path/length_from_x.json")
  # draw_plot(data_dict)
  #improvement_made()

end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
