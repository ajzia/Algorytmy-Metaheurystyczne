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
- [x] wątki
- [ ] komentarz do funkcji `honex`

#### tworzenie populacji

- [x] tworzenie populacji
  - [x] z określonym stosunkiem funkcji ruchu (np. 0.5, 0.3, 0.2 dla invert, insert, swap)

#### Elementy algorytmu:

- [x] turniej

#### Utils:

- [ ] komentarze
  - [ ] ruletka
  - [ ] turniej
  - [x] swarm.jl
  - [x] stop_conditions.jl
- [x] plik `selection_types.jl`

#### Badania:

- [x] najlepsza lambda dla turnieju (soon bo ważne)
- [x] prd
- [x] porównanie czas/iteracje `tabu` a `abc`
- [x] wielkość populacji
- [x] iteracje bez poprawy rozwiązania
- [x] swarm (random a insert a invert a swap)
- [x] organized swarm - różne ratio
- [x] lambda dla turnieju
- [x] ruletka a turniej
- [x] czas działania na określonej liczbie wątków
