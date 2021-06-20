using CSV
using DataFrames
using DelimitedFiles
using Glob
using Plots; pgfplotsx()


function create_subplot(nthreads, kernels, systems)

	# Create plot
	plt = plot(ylabel="GFlops", xaxis=:log10, xlabel="Matrix size", 
			   legend=:topleft, framestyle=:box)

	# Linestyles
	linestyles = Dict("sys1, par, 32" => :solid, "sys1, mkl, 32" => :dash, 
					  "sys2, par, 32" => :dash,   "sys1, par, 16" => :dash,
					  "sys1, par, 8" => :dashdot,   "sys1, par, 4" => :dashdotdot,
					  "sys1, par, 1" => :dot)

	# Colors
	colors = Dict("sys1, par, 32" => :blue, "sys1, mkl, 32" => :green, 
				  "sys2, par, 32" => :darkorange3,  "sys1, par, 16" => :purple,
				  "sys1, par, 8" => :red,  "sys1, par, 4" => :fuchsia,
				  "sys1, par, 1" => :grey)

	# Labels
	syslabel = Dict("sys1" => "sys. I", "sys2" => "sys. II")
	kernellabel = Dict("par" => "MtSpMV.jl", "mkl" => "MKLSparse.jl")

	# Count
	counter = 0

	# Iterate over number of threads
	for (it, t) in enumerate(nthreads)

		# Iterate over kernel
		for (ikernel, kernel) in enumerate(kernels)

			# Iterate over systems
			for (isys, sys) in enumerate(systems)

				# Count up
				counter += 1

				# Add number of threads to label
				if t == "1"
				    label = "SparseArrays, 1 thread, "
				    label = string(label, syslabel[sys])
				else
				    label = ""
				    label = string(label, kernellabel[kernel])
				    label = string(label, ", ")
				    label = string(label, t, " threads")
				    label = string(label, ", ")
				    label = string(label, syslabel[sys])
			    end

				# Get folder with benchmarks
				folder = joinpath(sys, kernel, t)
				folder = joinpath(folder, readdir(folder)[1], "csv")

				# Get all csv files for metric in sorted order
				file = glob("gflops*", folder)[1]

				# Get benchmark results starting from 10^2
			    df = DataFrame!(CSV.File(file, header=true))#[9:65,:]
			    x = convert(Vector, df[!, 2])
			    y = convert(Vector, df[!, 5])

				# Add to plot
				key = string(sys, ", ", kernel, ", ", t)
				plot!(plt, x, y, label=label, linestyle=linestyles[key], 
					  color=colors[key])

			end #for

		end # for 

	end # for

	return plt

end # function


# Create plots
function plot_spmv_size()

	# Plot 1
	plt1 = create_subplot(["32"], ["par", "mkl"], ["sys1"]) 

	# Plot 2
	plt2 = create_subplot(["32"], ["par"], ["sys1", "sys2"])

	# Plot 3
	plt3 = create_subplot(["32", "16", "8", "4", "1"], ["par"], ["sys1"])
	# plt3 = plot(plt3, xlabel="Matrix size")


	# Plot side by side and save
	width = 520
	height = 700
	plt = plot(plt1, plt2, plt3, layout=(3,1), size=(width, height))
	filename = string("bench_spmv_size")
	savefig(string(filename, ".png"))
	savefig(string(filename, ".tex"))

end # function
