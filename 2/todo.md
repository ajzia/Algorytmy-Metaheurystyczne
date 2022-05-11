## środa 20.04.2022

#### Algorytm:

- [x] tabu search

#### Ruch:

- [x] swap
- [x] invert
- [x] insert

#### Kryterium stopu:

- [x] maksymalna liczba iteracji
- [x] limit wywolań funkcji celu
- [x] liczba iteracji bez nowego najlepszego rozwiązania

```
  time: dołożyć start czasu oraz jego zmianę
```

#### Utils:

- [x] plik .tsp jako argument
- [x] module

## czwartek 21.04.2022

#### Elementy algorytmu:

- [x] kryterium aspiracji
<!-- - [ ] pamięc długoterminowa -->

#### Dobieranie długości tabu list:

- [x] stały dla wszystkich instancji (np. 10)
- [x] zależny od wielkości instancji

#### Akceleracja liczenia:

- [x] invert
- [x] swap
- [x] insert

```
  symetryczne -> asymetryczne (parametr żeby zmieniać, implementacja na później)
```

#### Utils:

- [x] zmiana kolejki na listę

## piątek 22.04.2022

#### Tabu search:

- [x] komentarz do funkcji
- [x] refractor przyjmowania parametrów

#### Move:

- [x] komentarze do funkcji
<!-- - [ ] look into: generowanie funkcji w funkcji  -->

## środa 27.04.2022

#### Tabu search:

- [x] przejrzeć kryterium aspiracji - sprawdzić poprawność działania
- [x] pamięć długoterminowa
- [x] wielowątkowość

```
  -> wykorzystanie wątków do przeglądania sąsiedztwa
```

<!-- ### Skip - niepolecane przez prof. Bożejko
#### Implementacja deterministyczna vs probabilistyczna:

- [ ] kilkukrotne osiągnięcie kryt. stopu - liczenie średniej z liczby podejść
- [ ] ścieżka, od której zaczynamy nowe podejście
  1. [ ] cofnięta o kilka ruchów, z wymuszeniem wybrania innej ścieżki
  2. [ ] shuffle na global_path -->

## czwartek i dalej 28.04.2022

#### Tabu search:

- [x] wielowątkowość

```
  -> wykorzystanie wątków do przeglądania sąsiedztwa -> poprawić
```

#### Move:

- [x] komentarz do funkcji `uno_reverse(...)`

#### Zaległe:

- [x] kryterium stopu time

```
  -> przypisywanie czasu do zmiennej
```

#### Badania: (28.04-04.05)

- [x] wybranie najciekawszych statystyk
- [x] generowanie i zapisywanie danych
- [x] generowanie danych tsp
  1. [x] symetrycznych (euklidesowych)
  2. [x] asymetrycznych
