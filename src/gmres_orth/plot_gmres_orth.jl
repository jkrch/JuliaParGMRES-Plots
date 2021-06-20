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

	# Benchmark folders
	folders = ["1e6_100-samples", "1e6_1000-samples", "1e7_100-samples"]

	# Benchmark subfolders
	subfolders = ["par-ser", "ser-par", "par-par"]

	# Iterate over matrix size number of samples folders
	for (ifolder, folder) in enumerate(folders)

		# Get folders with csv files
		csvfolder_parser = joinpath(folder, subfolders[1])
		csvfolder_parser = joinpath(csvfolder_parser, readdir(csvfolder_parser)[1])
		csvfolder_serpar = joinpath(folder, subfolders[2])  
		csvfolder_serpar = joinpath(csvfolder_serpar, readdir(csvfolder_serpar)[1])	
		csvfolder_parpar = joinpath(folder, subfolders[3])
		csvfolder_parpar = joinpath(csvfolder_parpar, readdir(csvfolder_parpar)[1])
		csvfolders = [csvfolder_parser, csvfolder_serpar, csvfolder_parpar]

	   	# Get result for serial sparse serial dense (orth=mgs)
	   	file = joinpath(csvfolder_serpar, "csv", "runtimes_ser_csr_mgs_none.csv")
	   	df = DataFrame!(CSV.File(file, header=true))
	   	y = convert(Vector, df[!, 5])
	   	y_ser_ser = similar(y)
	   	y_ser_ser .= y[1]

	   	# Iterate over csv folders
	   	for (icsvfolder, csvfolder) in enumerate(csvfolders)

	   		# Create plots
	   		plt1 = plot(ylabel="Runtime in seconds", xlabel="Number of threads", 
	   					legend=:topright, framestyle=:box)
	   		plt2 = plot(ylabel="Parallel speedup", xlabel="Number of threads", 
	   					legend=:none, framestyle=:box)

			# Get all csv files with runtimes in sorted order
			files = glob(string("runtimes*"), joinpath(csvfolder, "csv"))
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
			width = 530
			height = width / 2
			plot(plt1, plt2, layout=(1,2), size=(width,height))
			filename = string("gmres_orth_", folder, "_", subfolders[icsvfolder])
			savefig(string(filename, ".png"))
			savefig(string(filename, ".tex"))

		end # for
		    
	end # for

end # function
