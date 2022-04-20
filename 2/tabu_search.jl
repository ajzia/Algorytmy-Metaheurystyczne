include("../1/main.jl")
# dzisiejsza lista tabu: przepraszam, sorry, sory, sorki 


"""
  Main program function.
"""
function main()
  tsp_dict = load_tsp("./all/eil51.tsp")
end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
