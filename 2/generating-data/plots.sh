# legit
julia make_plots.jl repetitive_nearest_neighbour symm all it 1000 stat 7 10 0.05 tabu-repetitive_nearest_neighbour-tsymm-mall-sit-sm1000-ltstat-ls7-long10-a0.05-2022-05-05T11:21:48.328.json
julia make_plots.jl repetitive_nearest_neighbour tsp all it 1000 stat 7 10 0.05 tabu-repetitive_nearest_neighbour-ttsp-mall-sit-sm1000-ltstat-ls7-long10-a0.05-2022-05-05T11:08:40.070.json
julia make_plots.jl two_opt tsp all it 1000 stat 7 10 0.05 tabu-two_opt-ttsp-mall-sit-sm1000-ltstat-ls7-long10-a0.05-2022-05-05T11:13:25.745.json
julia make_plots.jl two_opt symm all it 1000 stat 7 10 0.05 tabu-two_opt-tsymm-mall-sit-sm1000-ltstat-ls7-long10-a0.05-2022-05-05T12:21:46.959.json

# tabu list size
julia make_plots.jl two_opt tsp invert it 1000 mix 0 10 0.05 tabu-two_opt-ttsp-minvert-sit-sm1000-ltmix-ls0-long10-a0.05-2022-05-05T11:47:13.229.json
julia make_plots.jl two_opt symm invert it 1000 mix 0 10 0.05 tabu-two_opt-tsymm-minvert-sit-sm1000-ltmix-ls0-long10-a0.05-2022-05-05T11:54:00.490.json

# threads 
julia make_plots.jl tabu-two_opt-tsymm-th1-step100-minvert-sit-sm500-ltstat-ls7-long10-a0.05-2022-05-05T15:57:59.512.json tabu-two_opt-tsymm-th2-step100-minvert-sit-sm500-ltstat-ls7-long10-a0.05-2022-05-05T16:05:43.023.json tabu-two_opt-tsymm-th4-step100-minvert-sit-sm500-ltstat-ls7-long10-a0.05-2022-05-05T16:09:56.796.json tabu-two_opt-tsymm-th8-step100-minvert-sit-sm500-ltstat-ls7-long10-a0.05-2022-05-05T16:12:48.330.json 1

# threads
julia make_plots.jl tabu-two_opt-tsymm-th1-minvert-sit-sm500-ltstat-ls7-long10-a0.05-2022-05-05T16:46:39.399.json tabu-two_opt-tsymm-th2-minvert-sit-sm500-ltstat-ls7-long10-a0.05-2022-05-05T16:50:09.030.json tabu-two_opt-tsymm-th4-minvert-sit-sm500-ltstat-ls7-long10-a0.05-2022-05-05T16:33:15.171.json tabu-two_opt-tsymm-th8-minvert-sit-sm500-ltstat-ls7-long10-a0.05-2022-05-05T16:39:23.850.json 2
