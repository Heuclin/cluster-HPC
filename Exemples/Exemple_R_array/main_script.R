
# on récupère l'indice (i) de la tâche ($SLURM_ARRAY_TASK_ID dans job_submission.sh)
i = as.numeric(commandArgs(trailingOnly=TRUE)[1])
print(paste0('Hello! Je suis la tache : ', i))

# Définition d'une grille de paramètres que je veux faire varier
pars <-  expand.grid(n = 1:2, p = 1:3, k = 1:2)

# Définition de ma fonction
my_fct <- function(n, p, k) return(n*p*k)

# on affiche les paramètres pour ce job
print(paste0('Les parametres pour cette tache: n=', pars$n[i], ', p=', pars$p[i], ', k=', pars$k[i]))

# Execution de la fonction sur la ligne i de la grille de paramètres
result <- my_fct(n=pars$n[i], p=pars$p[i], k=pars$k[i])
print(paste0("Le resultat de ma fonction est : ", result))

# une petite pause de 30s et c'est fini
Sys.sleep(30)






