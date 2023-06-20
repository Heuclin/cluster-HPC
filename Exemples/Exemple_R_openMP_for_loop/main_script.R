####################################################################
# Benjamin Heuclin, UR AIDA, PERSYST, CIRAD              
# February 2023
# 
# R script example for job in openMP with for loop
# (run one code several times on different parameters)
###################################################################



# Parallel settings -------------------------------------------------------

# load library for parallelisation
library(doParallel)

# get the number of CPU define in the batch script
nb_CPUs <- as.integer(Sys.getenv("SLURM_JOB_CPUS_PER_NODE"))
print(paste0("detected CPU : ", nb_CPUs))

# Set the number of cores
doParallel::registerDoParallel(cores = nb_CPUs)





# My code -----------------------------------------------------------------

# my function definition
my_fct <- function(n, p, k) return(n*p*k)

# Define a grid of parameters
pars <-  expand.grid(n = 1:4, p = 1:3, k = 1:10)


dir.create("results") # To create directory to save the results


# Parallel for loop (See ?foreach::foreach for more help)
RESULTS = foreach::foreach(i = 1:nrow(pars), .verbose = FALSE, .combine="c")%dopar%{
  result <- my_fct(n=pars$n[i], p=pars$p[i], k=pars$k[i]) # my calculus
  print(paste0("The result is : ", result))
  
  # Save the outputs in ".Rdata" object
  save(result, file = paste0("results/my_result_n=", pars$n[i], "p=", pars$p[i], "k=", pars$k[i], ".Rdata") )
  
  # a break of 10s 
  Sys.sleep(10)
  
  return(result)
}

RESULTS




