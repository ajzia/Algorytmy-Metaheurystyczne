"""
    wilcoxon_test(data_dict)
  Performes a Wilcoxon test for rnn and 2opt algorithm.

# Parameters:
- `data_dict::Dict`: dictionary with data from algorithms for several .tsp files.

"""
function wilcoxon_test(data_dict::Dict)
  x1 = []; x2 = []

  for i in ("14", "17", "22", "26", "29", "42", "51", "70", "76", "96", "100", "107", "127", "130", "137", "144", "150", "159", "175", "200")
    push!(x1, data_dict[i][2]); push!(x2, data_dict[i][3])
  end

  println("Wilcoxon test. Statr for n = 20, alpha = 0.05 for rnn and 2opt witha path from rnn algorithm.\n")
  for i in 1:length(x1)
    println("[$(x1[i])], [$(x2[i])]")
  end

  difference = []
  for i in 1:length(x1)
    push!(difference, [x1[i] - x2[i], 0])
  end

  for i in 1:length(difference)
    min = Inf; index = 1 
    for k in 1:length(difference)
      if abs(difference[k][1]) < min && difference[k][2] == 0
        min = abs(difference[k][1])
        index = k
      end
    end
    difference[index][2] = difference[index][1] < 0 ? (-1) * i : i
  end

  println("\nDifferences and ranks:")
  for i in 1:length(difference)
    println("[$(difference[i][1])], [$(difference[i][2])]")
  end

  w_min = 0; w_plus = 0; w_crit = 52
  for i in 1:length(difference)
    if difference[i][2] < 0
      w_min += abs(difference[i][2])
    else 
      w_plus += difference[i][2]
    end
  end

  w_stat = min(w_min, w_plus)
  println("\nW minus = $w_min\nW plus = $w_plus\nW stat = $w_stat")
  
  if w_stat < w_crit
    println("\nW stat is smaller than the critical value. The test has shown a visible difference in the algorithms.")
  else 
    println("\nW stat is bigger than the critical value. The test hasn't shown a visible difference in the algorithms.")
  end
end
