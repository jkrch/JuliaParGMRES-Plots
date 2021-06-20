using CSV
using DataFrames
using DelimitedFiles
using Glob
using Plots; pgfplotsx()


# Create plots
function plot_spmv_nthreads()

	# Dictionary to convert command line arguments to label parts
	# for all solvergroups
	labels = Dict(
		# kernels
		"ser" => "SparseArrays", "par" => "MtSpMV.jl", "mkl" => "MKLSparse.jl",
		# formats
		"csr" => ", CSR", "csc" => ", CSC",	
	)

	# Linestyles and markershapes
	styles = [:solid, :dash, :dot, :xcross, :cross]

	# Iterate over systems
	for sys in ["sys1", "sys2"]

		# Iterate over matrix sizes
		for matsize in ["1e6", "1e7"]

			# Create all plots
			plt1 = plot(ylabel="Runtime in seconds", xlabel="Number of threads", 
						legend=:topright, dpi=300, framestyle=:box)
			plt2 = plot(ylabel="Parallel speedup", xlabel="Number of threads", 
						legend=:none, dpi=300, framestyle=:box)
			plts = [plt1, plt2]

			# Plot for all benchmark types
			for (j, metric) in enumerate(["runtimes", "speedups"])

				# Get folder with benchmarks
				folder = joinpath(sys, matsize)
				folder = joinpath(folder, readdir(folder)[1])

				# Get all csv files for metric in sorted order
				files_ser = glob(string(metric, "*ser*"), joinpath(folder, "csv"))
				files_par = glob(string(metric, "*par*"), joinpath(folder, "csv"))
				files_mkl = glob(string(metric, "*mkl*"), joinpath(folder, "csv"))
				files = vcat(reverse(files_par), reverse(files_mkl), reverse(files_ser))

				# Add results from all files to plots
				for (i, file) in enumerate(files)

					# Get benchmark results
				    df = DataFrame!(CSV.File(file, header=true))
				    x = convert(Vector, df[!, 1])
				    y = convert(Vector, df[!, 5])

				    # # Convert from seconds to milliseconds
				    # if metric == "runtimes"
				    # 	y = y .* 1000
				    # end

				    # Create label from filename
				    infos = file[findlast('/', file) + 1 : findlast('.', file) - 1]
				    infos = infos[findfirst('_', infos) + 1 : length(infos)]
				    infos = split(infos, "_")
				    label = ""
				    for (j, info) in enumerate(infos)
						label = string(label, labels[info])
					end

					# Add to plot
					if length(x) == 1
						scatter!(plts[j], x, y, label=label, markershape=styles[i])
					else
						plot!(plts[j], x, y, label=label, linestyle=styles[i])
					end

				end # for

				# Plot side by side and save
				width = 530
				plot(plts[1], plts[2], layout=(1,2), size=(width, width/2))
				filename = string("bench_spmv_nthreads_", sys, "_", matsize)
				savefig(string(filename, ".png"))
				savefig(string(filename, ".tex"))

			end # for 

		end # for

	end # for

end # function
