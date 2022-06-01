## środa 25.05.2022

#### Algorytm:

- [x] artificial bee colony

## wtorek 31.05.2022

#### Populacja:

- [x] struktura pszczoły

```julia
@kwdef mutable struct Bee
  path::Vector{Int} = []
  distance::Float64 = 0.0
  move::Function
  count::Int = 0
end
```

- [x] tworzenie populacji
  - [x] z losowymi funkcjami ruchu
  - [x] z wybraną funkcją ruchu

#### Elementy algorytmu:

- [x] szybsza ruletka
- [x] zamiana `solutions` i `no_improvements` na listę struktur
- [x] parametry funkcji

#### Utils:

- [x] moduł `artificial_bee_colony`
- [x] plik `main.jl`

## środa 01.06.2022 i dalej...

#### ABC:

- [x] dodanie kryteriów stopu (czas, liczba iteracji)
- [ ] wątki
- [ ] komentarz do funkcji `honex` 

#### Elementy algorytmu:

- [ ] turniej
- [ ] krzyżowanie / mutacje

#### Utils:

- [ ] komentarze
  - [ ] ruletka
  - [x] swarm.jl
  - [x] stop_conditions.jl

#### Badania:

- [ ] prd
- [ ] porównanie czas/iteracje `tabu` a `abc`
- [ ] wielkość populacji
- [ ] iteracje bez poprawy rozwiązania
- [ ] swarm (random a insert a invert a swap)
- [ ] ruletka a turniej
- [ ] czas działania na określonej liczbie wątków
