const MOVES = [insert, invert, swap]

"""
    random_swarm(size::Int) -> Vector{Bee}
  Creates a population of bees of `size` with random move assigned to each bee.

## Parameters:
- `size::Int`: size of the population.

## Returns:
- `Vector{Bee}`: population of bees with `move`.

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
