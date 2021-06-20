using CSV
using DataFrames
using DelimitedFiles
using Glob
using Plots; pgfplotsx()


# Create plots
function plot_gmres_orth()

	# Plot labels
	labels = Dict(
		# kernels
		"ser" => "SparseArrays", "par" =>  "MtSpMV.jl", "mkl" => "",
		# formats
		"csr" => "", "csc" => "",	
		# orth
		"mgs" => ", MGS", "cgs" => ", CGS", "dgks" => ", DGKS",
		# precon
		"none" => "", "jacobi" => "", "ilu0" => "",
		"parjacobi" => "", "parilu0" => "",
	)

   	# Plot linestyles
   	linestyles = [:solid, :dash, :dot]

   	# Benchmarks
   	benchs = ["bench_gmres_orth_par_ser", "bench_gmres_orth_ser_par", "gmres_orth_par_par"]

   	# Folders
   	folders = [
   		joinpath("par_ser", readdir("par_ser")[1]),
   		joinpath("ser_par", readdir("ser_par")[1]),
		joinpath("par_par", readdir("par_par")[1])
	]

   	# Get result for serial spmv and serial dense (orth=mgs)
   	file = joinpath(folders[2], "csv", "runtimes_ser_csr_mgs_none.csv")
   	df = DataFrame!(CSV.File(file, header=true))
   	y = convert(Vector, df[!, 5])
   	y_ser_ser = similar(y)
   	y_ser_ser .= y[1]

   	# Iterate through folders
   	for (ifolder, folder) in enumerate(folders)

   		# Create plots
   		plt1 = plot(ylabel="Runtime in seconds", xlabel="Number of threads", 
   					legend=:topright, framestyle=:box)
   		plt2 = plot(ylabel="Parallel speedup", xlabel="Number of threads", 
   					legend=:none, framestyle=:box)

		# Get all csv files with runtimes in sorted order
		files = glob(string("runtimes*"), joinpath(folder, "csv"))
		if length(files) == 3
			files = [files[3], files[1], files[2]]
		end

		# Add results from all files to plots
		for (ifile, file) in enumerate(files)

			# Get benchmark results
		    df = DataFrame!(CSV.File(file, header=true))
		    x = convert(Vector, df[!, 1])
		    y = convert(Vector, df[!, 5])

		    # Create label from filename
		    infos = file[findlast('/', file) + 1 : findlast('.', file) - 1]
		    infos = infos[findfirst('_', infos) + 1 : length(infos)]
		    infos = split(infos, "_")
		    label = ""
		    for info in infos
				label = string(label, labels[info])
			end
			
			# Add runtimes to first plot
			plot!(plt1, x, y, label=label, linestyles=linestyles[ifile])

			# Add speedups to second plot
			y_speedups = y_ser_ser ./ y
			plot!(plt2, x, y_speedups, linestyles=linestyles[ifile])

		end # for

		# Plot side by side and save
		width = 510
		plot(plt1, plt2, layout=(1,2), size=(width, width/2))
		savefig(string(benchs[ifolder], ".png"))
		savefig(string(benchs[ifolder], ".tex"))

	end # for

end # function
