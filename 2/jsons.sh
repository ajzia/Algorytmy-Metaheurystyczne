# tsp
julia --threads 4 data.jl tsp all it 1000 stat 7 10 0.05 repetitive_nearest_neighbour
julia --threads 4 data.jl tsp all it 1000 stat 7 10 0.05 two_opt

# symm
julia --threads 4 data.jl symm all it 1000 stat 7 10 0.05 repetitive_nearest_neighbour
julia --threads 4 data.jl symm all it 1000 stat 7 10 0.05 two_opt

# mix tabu list size
julia --threads 4 data.jl tsp invert it 1000 mix 0 10 0.05 two_opt
julia --threads 4 data.jl symm invert it 1000 mix 0 10 0.05 two_opt

# thread test
julia --threads 1 data.jl symm invert it 500 stat 7 10 0.05 two_opt 100 50 500 1
julia --threads 2 data.jl symm invert it 500 stat 7 10 0.05 two_opt 100 50 500 2
julia --threads 4 data.jl symm invert it 500 stat 7 10 0.05 two_opt 100 50 500 4
julia --threads 8 data.jl symm invert it 500 stat 7 10 0.05 two_opt 100 50 500 8


