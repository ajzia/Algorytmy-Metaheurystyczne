using Dates

"""
    iteration_condition(max) -> Tuple{Int, Int, Function, Function}
  Starts iteration statistic, creates iteration and check functions.

## Parameters:
- `max::Int`: stop condition limit.

## Returns:
- `Int`: stop condition's starting statistic.
- `Int`: stop condition's limit.
- `Function`: function incrementing the statistic.
- `Function`: function checking for a stop.

"""
function iteration_condition(max::Int)::Tuple{Int, Int, Function, Function}
  start::Int = 1
  (function increment(it::Int)::Int return it += 1 end)
  (function check(it::Int, max::Int)::Bool return it <= max end)

  return (start, max, increment, check)
end

"""
    time_condition(max) -> Tuple{DateTime, Dates.Millisecond, Function, Function}
  Starts time statistic, converts `max` from seconds to miliseconds, creates iteration and check functions.

## Parameters:
- `max::Int`: stop condition limit in seconds.

## Returns:
- `DateTime`: stop condition's starting statistic.
- `Dates.Millisecond`: stop condition's limit converted to milliseconds.
- `Function`: function incrementing the statistic.
- `Function`: function checking for a stop.

"""
function time_condition(max::Int)::Tuple{DateTime, Dates.Millisecond, Function, Function}
  start = Dates.now()
  max = convert(Dates.Millisecond, Dates.Second(max))
  (function increment(start::DateTime)::DateTime return start end)
  (function check(start::DateTime, max::Dates.Millisecond)::Bool return (Dates.now() - start) <= max end)

  return (start, max, increment, check)
end
