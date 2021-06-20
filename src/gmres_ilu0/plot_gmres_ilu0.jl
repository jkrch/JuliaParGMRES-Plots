using CSV
using DataFrames
using DelimitedFiles
using Glob
using Plots; pgfplotsx()


# Create plots
function plot_gmres_ilu0()

	# Plot labels
	labels = ["Parallel ILU0", "Serial ILU0", "No precond."]

   	# Plot linestyles
   	linestyles = [:solid, :dashdot, :dash, :dot]

	# Benchmark folders
	folders = ["1e6_1000-samples", "1e7_100-samples", "atmosdd_100-samples"]


	# Solver

	# Iterate over matrix size number of samples folders
	for (ifolder, folder) in enumerate(folders)

		# Plot 1 
		# Left: Solver runtimes none, ilu0, parilu0, 
		# Right: Speedup parilu0 over ilu0

		# Get folders with csv files
		csvfolder_ser = joinpath(folder, "ser", 
			readdir(joinpath(folder, "ser"))[1], "csv")
		csvfolder_par = joinpath(folder, "par", 
			readdir(joinpath(folder, "par"))[1], "csv")

		# Create plots
		plt1 = plot(ylabel="Runtime in seconds", xlabel="Number of threads", 
					legend=:topright, framestyle=:box)
		plt2 = plot(ylabel="Parallel speedup", xlabel="Number of threads", 
					legend=:none, framestyle=:box)

		# Runtimes solver csv files
		csvfile_ser = joinpath(csvfolder_ser, 
			"runtimes-solver_par_csr_dgks_ilu0.csv")
		csvfile_par = joinpath(csvfolder_par,
			"runtimes-solver_par_csr_dgks_parilu0.csv")
		csvfiles = [csvfile_par, csvfile_ser]
		if folder == "atmosdd_100-samples"
			csvfile_none = joinpath(csvfolder_ser, 
				"runtimes-solver_par_csr_dgks_none.csv")
			csvfiles = [csvfile_par, csvfile_ser, csvfile_none]
		end
			
		# Add runtimes from all files to the first plot
		for (ifile, file) in enumerate(csvfiles)
		    df = DataFrame!(CSV.File(file, header=true))
		    x = convert(Vector, df[!, 1])
		    y = convert(Vector, df[!, 5])
			plot!(plt1, x, y, linestyles=linestyles[ifile], label=labels[ifile])
		end

		# Compute speedups and add to second plot
		df_par = DataFrame!(CSV.File(csvfile_par, header=true))
		df_ser = DataFrame!(CSV.File(csvfile_ser, header=true))
		y_par = convert(Vector, df_par[!, 5])
		y_ser = convert(Vector, df_ser[!, 5])
		x = convert(Vector, df_par[!, 1])
		y = y_ser ./ y_par
		plot!(plt2, x, y, linestyles=linestyles[1], label=labels[1])

		# Plot runtimes and speedups side by side
		plot(plt1, plt2, layout=(1,2), size=(530,530/2))
		savefig(string("gmres_ilu0_", folder, "_solver.png"))
		savefig(string("gmres_ilu0_", folder, "_solver.tex"))

	end # for


	# Precon

	# Iterate over matrix size number of samples folders
	for (ifolder, folder) in enumerate(folders)

		# Plot 1 
		# Left: Solver runtimes none, ilu0, parilu0, 
		# Right: Speedup parilu0 over ilu0

		# Get folders with csv files
		csvfolder_ser = joinpath(folder, "ser", 
			readdir(joinpath(folder, "ser"))[1], "csv")
		csvfolder_par = joinpath(folder, "par", 
			readdir(joinpath(folder, "par"))[1], "csv")

		# Create plots
		plt1 = plot(ylabel="Runtime in seconds", xlabel="Number of threads", 
					legend=:topright, framestyle=:box)
		plt2 = plot(ylabel="Parallel speedup", xlabel="Number of threads", 
					legend=:none, framestyle=:box)

		# Runtimes solver csv files
		csvfile_ser = joinpath(csvfolder_ser, 
			"runtimes-precon_par_csr_dgks_ilu0.csv")
		csvfile_par = joinpath(csvfolder_par,
			"runtimes-precon_par_csr_dgks_parilu0.csv")
		csvfiles = [csvfile_par, csvfile_ser]
			
		# Add runtimes from all files to the first plot
		for (ifile, file) in enumerate(csvfiles)
		    df = DataFrame!(CSV.File(file, header=true))
		    x = convert(Vector, df[!, 1])
		    y = convert(Vector, df[!, 5])
			plot!(plt1, x, y, linestyles=linestyles[ifile], label=labels[ifile])
		end

		# Compute speedups and add to second plot
		# Compute speedups and add to second plot
		df_par = DataFrame!(CSV.File(csvfile_par, header=true))
		df_ser = DataFrame!(CSV.File(csvfile_ser, header=true))
		y_par = convert(Vector, df_par[!, 5])
		y_ser = convert(Vector, df_ser[!, 5])
		x = convert(Vector, df_par[!, 1])
		y = y_ser ./ y_par
		plot!(plt2, x, y, linestyles=linestyles[1], label=labels[1])

		# Plot runtimes and speedups side by side
		plot(plt1, plt2, layout=(1,2), size=(530,530/2))
		savefig(string("gmres_ilu0_", folder, "_precon.png"))
		savefig(string("gmres_ilu0_", folder, "_precon.tex"))

	end # for

end # function
