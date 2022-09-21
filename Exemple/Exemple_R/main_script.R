
# rm(list=ls())

# load library for parallelisation
library(doParallel)




# Set the number of cores
doParallel::registerDoParallel(cores = 10)



# number of repetition of an opparation
nb_rep <- 50



# Parallel for loop
foreach::foreach(k = 1:nb_rep, .verbose = FALSE) %dopar% {
  
  # my opperation
  my_result <- 2*k
  
  # Save the outputs in ".Rdata" object
  save(my_result, file = paste0("results/my_result_rep_", k, ".Rdata") )
  
  # I return nothing because I save each result in ".Rdata" object in folder "results"
  return()
}







