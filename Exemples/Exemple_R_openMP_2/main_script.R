
# load library for parallelisation
library(doParallel)

nb_CPUs <- as.integer(Sys.getenv("SLURM_JOB_CPUS_PER_NODE")) 
print(paste0("detected CPU : ", nb_CPUs))

# Set the number of cores
doParallel::registerDoParallel(cores = nb_CPUs)




# Définition de ma fonction
my_fct <- function(n, p, k){
  return(n*p*k)
}




# Définition d'une grille de paramètres que je veux faire varier
pars <-  expand.grid(n = 1:2, p = 1:3, k = 1:10)


# Parallel for loop
foreach::foreach(iter = 1:nrow(pars), .verbose = FALSE) %dopar% {
  
  # mes calculs
  result <- my_fct(n=pars$n[iter], p=pars$p[iter], k=pars$k[iter])
  print(paste0("Le resultat de ma fonction est : ", result))
  
  # Save the outputs in ".Rdata" object
  save(result, file = paste0("results/my_result_rep_", iter, ".Rdata") )
  
  # une petite pause de 30s et c'est fini
  Sys.sleep(30)
  
  # I return nothing because I save each result in ".Rdata" object in folder "results"
  return()
}







