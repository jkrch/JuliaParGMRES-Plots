using CSV
using DataFrames
using DelimitedFiles
using Glob
using StatsPlots; pgfplotsx()


# Reurn arrays with matrices
function get_matrices()
	csvfolder = joinpath("ser", readdir("ser")[1], "csv")
	csvfile = glob("runtimes-solver*", csvfolder)[1]
	df = DataFrame!(CSV.File(csvfile, header=true))
	x = convert(Vector, df[!, 1])
	return x
end

# Return arrays with runtimes
function get_runtimes(nthreads::String, benchstep::String)
	csvfolder = joinpath(nthreads, readdir(nthreads)[1], "csv")
	csvfiles = glob(string("*", benchstep,  "*"), csvfolder)
	y = []
	for csvfile in csvfiles
		df = DataFrame!(CSV.File(csvfile, header=true))
	 	push!(y, convert(Vector, df[!, 5]))
	end
	return y
end

# Create plots
function plot_gmres_orth_matrix()

	# Runtimes

	# Get results
	x = get_matrices()
	y_ser = get_runtimes("ser", "solver")[1]
	y_par = get_runtimes("par", "solver")
	# y_par = [y_par[2] y_par[1] y_par[4] y_par[3]]
	y = [y_ser y_par[3] y_par[4] y_par[1] y_par[2]]
	
	# Treat underscore and make all italic
	for i in 1:length(x)
		x[i] = replace(x[i], "_" => "\\_")
		x[i] = replace(x[i], x[i] => string("\\textit{", x[i], "}"))
	end

	# # Treat !
	# x[1] = replace(x[1], "!" => "\\textit{!}")
	# x[2] = replace(x[2], "!" => "\\textit{!}")

	# # Plot
	# groupedbar(x, y, 
	# 	xrotation=60, ylabel="Runtime in seconds", 
	# 	label=["1 thread" "4 threads" "8 threads" "16 threads" "32 threads"],
	# 	linestyle=[:solid :dash :dot :dashdot :dashdotdot], 
	# 	color=[:blue :red :green :orange :grey],
	# 	legend=:topright, size=(530, 530/2)
	# ) 
		
	# # Save plot
	# savefig("gmres_orth_matrix_solver_runtimes.png")
	# savefig("gmres_orth_matrix_solver_runtimes.tex")


	# Speedups
	
	# Compute speedups
	y_speedups = deepcopy(y_par)
	for i in 1:length(y_speedups)
		y_speedups[i] = y_ser ./ y_par[i]
	end
	y = [y_speedups[2] y_speedups[1] y_speedups[4] y_speedups[3]]

	# Plot
	groupedbar(x, y, 
		xrotation=90, ylabel="Parellel speedup", 
		label=["32 threads" "16 threads" "8 threads" "4 threads"],
		linestyle=[:solid :dash :dot :dashdot], 
		color=[:blue :red :green :orange],
		legend=:outertopright, size=(450, 450/2),
	) 
		

	# Save plot
	savefig("gmres_orth_matrix_solver_speedups.png")
	savefig("gmres_orth_matrix_solver_speedups.tex")

end
