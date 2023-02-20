####################################################################
# Benjamin Heuclin, UR AIDA, PERSYST, CIRAD              
# février 2023
# 
# R script example for array job 
# (run one code several times on different parameters)
###################################################################



# get task index (id) ($SLURM_ARRAY_TASK_ID in job_submission.sh)
id = as.numeric(commandArgs(trailingOnly=TRUE)[1])
print(paste0('Hello! I am the task: ', id))


# my function definition
my_fct <- function(n, p, k) return(n*p*k)

# Define a grid of parameters
pars <-  expand.grid(n = 1:2, p = 1:3, k = 1:2)


# print parameters for this task
print(paste0('Les parametres pour cette tache: n=', pars$n[i], ', p=', pars$p[i], ', k=', pars$k[i]))

# my calculus
result <- my_fct(n=pars$n[id], p=pars$p[id], k=pars$k[id])
print(paste0("The result is : ", result))

# Save the results in ".Rdata" object
save(result, file = paste0("results/my_result_n=", pars$n[id], "p=", pars$p[id], "k=", pars$k[id], ".Rdata") )

# a break 
Sys.sleep(30)






