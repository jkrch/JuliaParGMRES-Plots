using CSV
using DataFrames
using DelimitedFiles
using Glob
using Plots; pgfplotsx()


# Create plots
function plot_gmres_jacobi()

	# Plot labels
	labels = ["Parallel Jacobi", "Serial Jacobi"]

	# Benchmark folders
	folders = ["1e6_1000-samples", "1e7_100-samples"]


	# Plot 1 
	# Left: Solver runtimes ilu0 and parilu0
	# Right: Speedup parilu0 over ilu0

	# Iterate over matrix size number of samples folders
	for (ifolder, folder) in enumerate(folders)

		# Get folders with csv files
		csvfolder = joinpath(folder, readdir(folder)[1], "csv")

		# Create plots
		plt1 = plot(ylabel="Runtime in seconds", xlabel="Number of threads", 
					legend=:topright, framestyle=:box)
		plt2 = plot(ylabel="Parallel speedup", xlabel="Number of threads", 
					legend=:none, framestyle=:box)

		# Runtimes csv files 
		csvfile_ser = joinpath(csvfolder, 
			"runtimes-solver_par_csr_dgks_jacobi.csv")
		csvfile_par = joinpath(csvfolder, 
			"runtimes-solver_par_csr_dgks_parjacobi.csv")
			
		# Add runtimes from all files to the first plot
		df_par = DataFrame!(CSV.File(csvfile_par, header=true))
		df_ser = DataFrame!(CSV.File(csvfile_ser, header=true))
		y_par = convert(Vector, df_par[!, 5])
		y_ser = convert(Vector, df_ser[!, 5])
		x = convert(Vector, df_ser[!, 1])
		plot!(plt1, x, y_par, label=labels[1])
		plot!(plt1, x, y_ser, label=labels[2])

		# Compute speedups for solver and add to second plot
		y = y_ser ./ y_par
		plot!(plt2, x, y, label=labels[1])

		# Plot runtimes and speedups side by side
		plot(plt1, plt2, layout=(1,2), size=(530,530/2))
		savefig(string("gmres_jacobi_", folder, "_solver.png"))
		savefig(string("gmres_jacobi_", folder, "_solver.tex"))

	end # for


	# Plot 2
	# Left: Precon runtimes ilu0 and parilu0
	# Right: Speedup parilu0 over ilu0

	# Iterate over matrix size number of samples folders
	for (ifolder, folder) in enumerate(folders)

		# Get folders with csv files
		csvfolder = joinpath(folder, readdir(folder)[1], "csv")

		# Create plots
		plt1 = plot(ylabel="Runtime in seconds", xlabel="Number of threads", 
					legend=:none, framestyle=:box)
		plt2 = plot(ylabel="Parallel speedup", xlabel="Number of threads", 
					legend=:bottomright, framestyle=:box)

		# Runtimes csv files 
		csvfile_ser = joinpath(csvfolder, 
			"runtimes-precon_par_csr_dgks_jacobi.csv")
		csvfile_par = joinpath(csvfolder, 
			"runtimes-precon_par_csr_dgks_parjacobi.csv")
			
		# Add runtimes from all files to the first plot
		df_par = DataFrame!(CSV.File(csvfile_par, header=true))
		df_ser = DataFrame!(CSV.File(csvfile_ser, header=true))
		y_par = convert(Vector, df_par[!, 5])
		y_ser = convert(Vector, df_ser[!, 5])
		x = convert(Vector, df_ser[!, 1])
		plot!(plt1, x, y_par, label=labels[1])
		plot!(plt1, x, y_ser, label=labels[2])

		# Compute speedups for solver and add to second plot
		y = y_ser ./ y_par
		plot!(plt2, x, y, label=labels[1])
		plot!(plt2, [1], [0], label=labels[2])

		# Plot runtimes and speedups side by side
		plot(plt1, plt2, layout=(1,2), size=(530,530/2))
		savefig(string("gmres_jacobi_", folder, "_precon.png"))
		savefig(string("gmres_jacobi_", folder, "_precon.tex"))

	end # for

end # function
