# PROJECT2.JL

# code that is actually evaluated using the "main" function
# written in helpers.jl. the optimize function is shared with run.jl
# which has a seperate implementation of main that enables graphing

#TODO include just the optimize funtion or just copy and paste it over
include("run.jl")

main("simple1", 1, optimize)