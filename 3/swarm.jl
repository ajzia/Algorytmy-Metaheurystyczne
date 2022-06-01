import Base.@kwdef

const MOVES = [insert, invert, swap]

@kwdef mutable struct Bee
  path::Vector{Int} = []
  distance::Float64 = 0.0
  move::Function
  count::Int = 0
end

"""
    random_swarm(size::Int) -> Vector{Bee}
  Creates a population of bees of `size` with random move assigned to each bee.

## Parameters:
- `size::Int`: size of the population.

## Returns:
- `Vector{Bee}`: population of bees random moves.

"""
function random_swarm(size::Int)::Vector{Bee}
  swarm::Vector{Bee} = []
  for _ in 1:size 
    move = MOVES[rand(1:length(MOVES))]
    new_bee = Bee(move=move)
    push!(swarm, new_bee)
  end
  return swarm
end

"""
    moving_swarm(size::Int, move::Function) -> Vector{Bee}
  Creates a population of bees of `size` with `move` assigned to each bee.

## Parameters:
- `size::Int`: size of the population.
- `move::Function`: type of movement.

## Returns:
- `Vector{Bee}`: population of bees with `move`.

"""
function moving_swarm(size::Int, move::Function)::Vector{Bee}
  swarm::Vector{Bee} = []
  for _ in 1:size 
    new_bee = Bee(move=move)
    push!(swarm, new_bee)
  end
  return swarm
end


"""
    organized_swarm(size::Int, ratio::Tuple{Float64, Float64, Float64}) -> Vector{Bee}
  Creates a population of bees of `size` with given `ratio` of moves.

## Parameters:
- `size::Int`: size of the population.
- `ratio::Tuple{Float64, Float64, Float64}`: ratio of different moves, in order: invert, insert, swap

## Returns:
- `Vector{Bee}`: population of bees with `move`.

"""
function organized_swarm(size::Int, ratio::Tuple{Float64, Float64, Float64})::Vector{Bee}
  swarm::Vector{Bee} = []

  @assert ((ratio[1] + ratio[2] + ratio[3]) == 1)

  slots_left::Int = size

  invert_bees::Int = floor(ratio[1] * size)
  slots_left -= invert_bees
  insert_bees::Int = floor(min(ratio[2] * size, slots_left))
  slots_left -= insert_bees
  #swap_bees = min(ratio[3] * size, slots_left)
  swap_bees::Int = slots_left
  
  append!(swarm, moving_swarm(invert_bees, invert))
  append!(swarm, moving_swarm(insert_bees, insert))
  append!(swarm, moving_swarm(swap_bees, swap))

  return swarm
end

