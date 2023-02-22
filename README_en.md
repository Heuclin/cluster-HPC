
![](Figures/logos.png)

# Introduction to HPC cluster MESO-LR


***Axe transversal TIM, UR AIDA***

*Benjamin Heuclin, Statistician engineer, UR AIDA, Cirad*

*Septembre 2022*

Licence : <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/"><img alt="Licence Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></a><br />Ce(tte) œuvre est mise à disposition selon les termes de la <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/">Licence Creative Commons Attribution - Pas d’Utilisation Commerciale 4.0 International</a>.




___

1. [What is a supercomputer? And parallelization?](#cluster_parallelisation)
    1. [Parallelization](#parallelization)
    2. [The MESO@LR cluster at the University of Montpellier](#cluster)
2. [Cluster connection](#connection)
3. [File transfer](#transfer) 
4. [The storage spaces](#storage)
5. [Job submission process under SLURM](#proc_soumission)
6. [Useful SLURM commands](#commands)
7. [Rstudio on the cluster](#rstudio) 
8. [Ressources](#ressources)
*  [Annexes](#annexes)

    A.[Examples](#annexes_examples)
      1. [R OpenMP example parallel for loop](#ex_R_forloop)
      2. [R OpenMP example for random forest calibration](#ex_R_openMP)
      3. [R array example](#ex_R_array)
      
    B. [Script batch corrompu à cause des retours à la ligne WINDOWS](#annexes_unix_LF)
    
    C. [rsync](#annexes_rsync)
    
    
    
___


> This document is limited to the use of R on CPU, with shared memory parallelization (openMP). It is an initiation to quickly take control of the job submission process.

To use the cluster, you need a unix terminal to connect, submit and manage your jobs and a file transfer software to send your codes, ... from your PC to the cluster and vice versa.

Cluster documentations : https://meso-lr.umontpellier.fr/documentation-utilisateurs/


[######################################################################################]: # 

<br><br>

<a name="cluster_parallelisation"></a>

# 1. What is a supercomputer? And parallelization? 

---

[Wikipédia definition](https://fr.wikipedia.org/wiki/Superordinateur) : <br>
A supercomputer is a computer designed to achieve the highest possible performance with the techniques known at the time of its design, particularly in terms of computing speed. For performance reasons, it is almost always a mainframe computer, whose tasks are performed in batch mode. <br>
The science of supercomputing is called "high performance computing" (HPC). 

A supercomputer is generally a grouping of several independent computers called nodes, hence the term "cluster".



<a name="parallelization"></a>

## 1.1 Parallelization 

This link explains very well the different types of parallelization:

https://cwant.github.io/hpc-beyond/21-introduction-to-parallelism/index.html

> A task (or processus, or thread) is a logical processing unit


* **Shared memory strategy:** this is the situation where your program runs tasks on several CPUs (1 per task) on the same node, and each CPU can access all the memory used by the program. A widely used library for achieving this type of parallelism is OpenMP (Open Multi-Processing). <br>
This type of parallelization can occur during the execution of a specific "for" loop by distributing the loop among the different CPUs. <br>
**This type of parallelization is possible on your PC.**

* **Distributed memory strategy:** each task is executed on a CPU (on a node) that has its own private memory, and no other CPU can see this memory (independence). In order to communicate what is in the memory space from one CPU to another, the CPUs "pass messages" to each other. With this design, the code is modularized so that parts of the program can be run on several different machines (nodes), each machine having to work with its own memory space.
A popular library for implementing this type of parallelism is called MPI (Message Passing Interface). 



* **Hybrid strategy:** memory is distributed between nodes, but on each node the code can use a shared memory policy. This could be a case where you want to use MPI to pass messages between each node, but on each node you use a shared memory strategy using OpenMP. 



![](Figures/parallelisation.png)

**En résumé :**

|          | 1 node       | n nodes |
| :------- | :----------- | :------ |
| 1 CPU    | serial job   | MPI     |
| n CPUs   | OpenMP       | hybrid : OpenMPI |




<br>

<a name="cluster"></a>

## 1.2 The MESO@LR cluster at the University of Montpellier

**Numbers :**

* 308 nodes Dell PowerEdge C6320
    - bi processeurs Intel Xeon E5-2680 v4 2,4 Ghz (broadwell)
    - **28 CPUs per node**, total: 8624 CPUs 
    - 128 Go RAM per node
    - 330 Tflops 
* 2 large memory nodes 112 CPUs, 3To RAM
* 2 GPU node for visualization, 52 CPU (bi-processeurs 26 CPU)
* 1,3 Po of storage dedicated to computing
    * 1 Po for quick storage under Lustre
    * 350 To of perennial storage
* Interconnection network Intel OmniPath 100 Gb/s
* No accelerator
* Job submission manager: [SLURM (Simple Linux Utility for Resource Management)](https://slurm.schedmd.com/documentation.html)
    * Scheduling of tasks in queues (arbitration)


<br>
**Fonctionnement :**

  * Users belonging to groups run jobs on partitions
  * A partition is a set of nodes


<br>
**Partitions for CIRAD staff :**

You have to choose the partition on which to launch your jobs. There are several partions for the CIRAD:

| Partition   | Description            | Tme Limite | nb nodes  | nb CPUs <br> per node |default memory * | max memory |
| :---------  | :------------          | :---------:     |:--------: |:------: | :------: | :------: |
| agap_short  | For fast jobs          | 1 h             | 71        | 28      | 4 Go     | 128 Go   |
| agap_normal | Default partition      | 2 j             | 67        | 28      | 4 Go     | 128 Go   |
| agap_long   | For long jobs          | Pas de limite   | 67        | 28      | 4 Go     | 128 Go   |
| agap_bigmem | Large memory calculations | Pas de limite   | 1         | 112     | 28 Go    | 3 To     |




$*$ The RAM per node is limited by default (see column 6) but it can be increased by adding the line :

* `--mem=XG` (for the memory allocated for the whole job)
* ou `--mem-per-cpu=XG`  (for the memory allocated for each CPU)


In your batch script (see section [Job submission](#proc_soumission)) with "X" the amount of memory. See column 7 for the max memory quantity per node. 
These 2 parameters are exclusive of each other. 


















[######################################################################################]: # 
<br><br>

<a name="connection"></a>

# 2. Cluster connection 

---

It is very simple! The connection to the HPC cluster is done via the SSH protocol. The hostname of the connection machine is `muse-login.meso.umontpellier.fr`.

Depending on your operating system, you can connect as follows:


**Under linux or Mac :**

Open an ssh connection in a terminal with the following command: 

```
ssh «username»@muse-login.meso.umontpellier.fr
```
Then enter your password

On Mac, you can also use the Xquartz software.

You are now connected to the cluster. The MESO@LR cluster uses the SLURM job manager. From here you can run and manage your jobs with the SLURM specific commands (see section [Job submission process under SLURM](#submission)). 




**Under windows :**

Install the MobXterm software (https://mobaxterm.mobatek.net/download-home-edition.html). The first time you connect, you have to configure it!

Configuration :

1. Click on the Session button (top left)
2. A "*Session settings*" window will open
3. Click on SSH (top left)
4. Fill in the following fields
    a. *Remote host* : `muse-login.meso.umontpellier.fr`
    b. Select *Specify username*
    c. Enter your username
    d. *Port* : 22
5. Click on OK


![](Figures/MobaXterm1-2.png)


6. A unix terminal opens
7. Then you have to enter your password (nothing is displayed when you type, it is a security setting) then validate by pressing "enter".
8. MobaXterm asks you if you want to save the password so that it doesn't ask you again. It's up to you!

![](Figures/MobaXterm2-2.png)


> For the next times, you will just have to open MobaXterm and click on your session that you will find in the tab "*User sessions*" on the left.  
You can also create a shortcut on your desktop by right-clicking on it. This will open your session at the same time as the software launches. It's too good 🤩



You are now connected to the cluster. The MESO@LR cluster uses the SLURM job manager. From here you can run and manage your jobs with the SLURM specific commands (see section [Job submission process under SLURM](#submission)). 






**Some useful Linux commands:**

* `ls` to display the contents of the current directory
* `ls -a` to show all files (even hidden) in the current directory
* `cd "path"` to change the directory
* `cd ..` to go to the parent directory
* `pwd` to show the absolute path of the current directory (from the root)
* ⬆️⬇️ **Up/down arrow** to navigate through the history of used commands

For more info on basic Linux commands :
https://doc.ubuntu-fr.org/tutoriel/console_commandes_de_base







[######################################################################################]: # 
<br><br>

<a name="transfer"></a>

# 3. File transfer

---


To submit your jobs, you will have to send your scripts on the cluster. You will then have to download the files generated by your jobs. To do this, we will use the FileZilla software. It is available for Windows, OSX and Linux. To download large files from the cluster to your machine (long with FileZilla) it is possible to use "rsync" (see [appendix C](#annexes_rsync))


**Install FileZilla :** https://filezilla-project.org/download.php?show_all=1


> Note for Linux: Filezilla is available through your package manager `apt-get install filezilla`

**Introduction to FileZilla: **

![](Figures/Filezilla2.png)

To connect for the first time, fill in the connection field:

* **Host**:  `sftp://muse-login.meso.umontpellier.fr`
* **User name** : your user name 
* **Password** : your password
* **Port** : 22


> 🤩 After the first login, this information will be saved and you will be able to login easily by clicking on the little arrow next to "Quick Login"

You can upload and download a file either way by right clicking on it and then clicking on "Upload" or "Download".













[######################################################################################]: # 
<br><br>

<a name="storage"></a>

# 4. The storage spaces

---

here are several storage spaces. Files placed on the "scratch" directory are temporary for your calculations, and are automatically deleted after 60 days. The documents intended to be kept must be deposited on your "home" or "replicated" directory.

Email from Bertrand Pitollat on november 19, 2021 :


You have several storage spaces on the MESO@LR cluster:

* **home directory**:
  * Storage limit: 50Go
  * Time limit: no
  * Writable from calculation nodes: **NO**
  * Visiibility: personnal 
  * Hosted array: NFS
  * Replicated: NO
  * Comment: This is your entry point to the cluster
  
* **replicated directory**:
  * Storage limit: 500Go
  * Time limit: no
  * Writable from calculation nodes: **YES**
  * Visiibility: personnal 
  * Hosted array: NetApp
  * Replicated: Yes
  * Comment: Long-term storage of personal data with replication, there is a shortcut from your home directory

* **scratch directory**:
  * Storage limit: no
  * Time limit: **2 months**
  * Writable from calculation nodes: **YES**
  * Visiibility: personnal 
  * Hosted array: Lustre
  * Replicated: NO
  * Comment: Fast and powerful and should be used to host temporary calculation data, there is a shortcut from your home directory
  
* **projects directory**:
  * Storage limit: 5To
  * Time limit: no
  * Writable from calculation nodes: **YES**
  * Visiibility: specific user group for each subdirectory
  * Hosted array: NetApp
  * Replicated: Yes
  * Comment: Long-term storage of shared data, Partitioned by project, unit or team directory with replication, there is a shortcut from your home directory
  


> **Important:** For cluster performance reasons, all writes from jobs must be redirected to your scratch directory and that you must ban all intensive reads from NFS and NetApp spaces.






[######################################################################################]: # 
<br><br>

<a name="proc_soumission"></a>

# 5. Job submission process under SLURM 

---

Dans cette section j'explique comment soumettre des jobs en parallèle sous R. 


Pour illustrer la soumission d'un job en parallèle, nous utiliserons l'Exemple_R. Dans cet exemple bidon, je répète l'opération 2*k pour k=1 à 50. Je veux paralléliser ces opérations sur 10 coeurs pour aller 10 fois plus vite. Je sauvegarde chaque résultat dans un ".Rdata" dans un fichier "results".


Pour soumettre un job, vous devez choisir entre :

  * Un mode d’exécution en temps réel avec la commande srun directement dans le terminal (non détaillé dans ce tuto)
  * Un mode d’exécution différé en définissant son job dans un script ***batch*** (.sh) et en le lancer à l’aide de la commande `sbatch` dans le terminal


⚠️ **J'explique ici uniquement la procédure différée avec la commande `sbatch`** 

Cette procédure consiste à définir les paramètres d'exécution dans un fichier *batch* (.sh)

Ce fichier peut être éditer avec [**Notepad++**](https://notepad-plus-plus.org/downloads/) ou **Rstudio**.
Pour le créer : 

* avec **Notepad++** : *File > New* puis sauvegarder avec l'extension *.sh*
* avec **Rstudio** : *File > New File > Shell Script*

👉 Mais le plus simple est de reprendre un script ***batch*** (.sh) qu'on a sous la main d'un autre projet.



💥🔥 **Alerte Windows**: **Attention aux retours à la ligne !!!**  
Par défault dans Windows les retours chariot sont de type DOS et ils ne sont pas compatible avec Linux ou Max de type UNIX (Posix LF) et ça plantle !  
Il faut soit :

* utiliser **Notepad++** en faisant :  
*Edition > Convertir les sauts de ligne > Convertir en format UNIX (LF)*  
⚠️ a faire pour chaque nouveau fichier
* utiliser **Rstudio** en réglant l'option des retours à la ligne de type Unix :  
*Tools > Global options > Code > Saving > Serialization > Line ending conversion > Posix (LF)*  
A faire qu'une seule fois! Il sait tout faire ce Rstudio ! 💪





**Prenons le fichier *batch* de l'Exemple_R_openMP_RF** pour voir sa construction


```
#!/bin/bash
#SBATCH --partition=agap_short  # The partition
#SBATCH --job-name ex1          # Job name
#SBATCH --nodes=1               # NB nodes (MPI processe, openMP -> 1)
#SBATCH --ntasks=1              # NB tasks (MPI processe, openMP -> 1)
#SBATCH --ntasks-per-node=1     # NB tasks per node (MPI processe, openMP -> 1)
#SBATCH --cpus-per-task=10      # NB CPUs per task
#SBATCH --mem-per-cpu=100M      # Memory per CPU
#SBATCH --time=00:10:00         # Time limite

module purge 
module load cv-standard
module load R/3.6.1

# OpenMP runtime settings
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

cd $SLURM_SUBMIT_DIR    # To go to the directory where the .sh is executed

mkdir ./Rout            # Create the "Rout"" folder for the R console outputs
mkdir ./results         # Create the "results" folder to save my results
R CMD BATCH ./main_script.R    ./Rout/main_script.Rout # submit the R job

# To get job information after running (used memory, time, ...) in the .out file
seff $SLURM_JOB_ID
```

Ce fichier se décompose en 3 parties :

* 1re partie : chaque ligne commençant par `#SBATCH` décrit un paramètre **SLURM** <br>
Pleins d'options existent, se référer à la documentation du cluster pour plus d'info (https://meso-lr.umontpellier.fr/documentation-utilisateurs/).

* 2ème partie : Il faut ensuite charger les **modules** (logiciels, compilateurs) avec la commande `module load`. 
[Les modules reposent sur un système de dépendances et de conflits fixés par la personne ayant installé ou compilé le logiciel ou la librairie visée.]: # 
On commance par décharcher tous les modules qui peuvent être chargés.
Pour utiliser le logiciel R, en fonction de la version, il faut charger le module `cv-standard` et ensuite `R/version` ou `R` (charge la dernière version 4.2.2). Si votre code utilise un autre langage (c++, python, ...), il faudra alors charger les modules en conséquence. Pour voir la liste des modules disponibles : `module avail`. Plus d'info sur les modules dans la documentation du cluster (https://meso-lr.umontpellier.fr/documentation-utilisateurs/) section "Environnement logiciel du Cluster Muse" et le TP : https://meso-lr.umontpellier.fr/wp-content/uploads/2020/03/1-TP-Environment_module3.pdf. Je vous conseille de précicer la version de R avec laquelle vous voulez travailler pour ne pas avoir de surprise si une nouvelle version est installée. Les versions de R disponibles sont :
    * en local (installé par muse@lr) :
        * `R/3.6.1`
        * `R/3.6.1-tcltk `
        * `R/3.6.3 `
        * `R/4.0.2`
        * `R/4.2.2`
    * dans cv-standard (la majorité des compilateurs et bibliothèques standards) :
        * `R/3.3.1`
        * `R/3.4.3`
    
**Vous pouvez aussi installer vos propres logiciels.**

* 3ème partie : Enfin la ligne pour exécuter le script R : `R CMD BATCH ` suivie du chemin d'accès vers le script, suivi du chemin d'accès vers le **Rout** pour écrire les sorties (ce qui s'affiche dans la console de Rstudio en temps normal). **Pensez à créer le fichier Rout dans votre projet**.




Pour lancer votre code, il faut exécuter dans le terminal (après s'être placé dans le bon répertoire) le fichier batch associé avec la commande :
```
sbatch job_submission.sh
```




**Attention** : si votre code nécessite le chargement de packages, il faut impérativement les installer avant. Pour ce faire, dans le terminal, charger les modules puis lancer R :
```
module load cv-standard R/3.6.1
R
```
Installer ensuite les packages (il vous faudra choisir un miroir) :
```
install.packages("doParallel")
```
Enfin quitter R avec la commande `q()`.



















[######################################################################################]: # 
<br><br>

<a name="commands"></a>

# 6. Useful SLURM commands

---

Pour voir l'état de tous les jobs (de tous les utilisateurs)
```
squeue
```


Pour voir l'état de vos jobs 
```
squeue -u $USER -o '%.18i %.9P %.20j %u %.8T %.10M %.9l %.6D %R'
```


Pour tuer un job
```
scancel <JOB_ID>
```


Pour voir le nombre de CPUs disponibles par noeud (très utile pour choisir le nombre de coeurs pour passer devant toute la fille d'attente)
```
sinfo -o "%P %n %C"
```

* La 1er colonne (%P) donne la partition
* La 2ème colonne (%n) donne l'identifiant du noeud
* La 3ème colonne (%C) donne le nombre de CPUs par état dans le format "alloué/libre/autre/total"

![](Figures/sinfo.png)



Consulter la quantité de mémoire consommée par le job après son exécution : 
```
sacct -o JobID,Node,AveRSS,MaxRSS,MaxRSSTask,MaxRSSNode,TRESUsageInTot%250 -j <JOB_ID> 
```



Plus d'info sur les commandes ici : https://slurm.schedmd.com/man_index.html
















[######################################################################################]: # 
<br><br>

<a name="rstudio"></a>

# 7. Rstudio on the cluster

---

http://193.52.26.138/rstudio/auth-sign-in

Rstudio est isolé sur un noeud dédié (96 CPUs et 3To de mémoire) et est partagé avec tous les utilisateurs Rstudio.


**Il est destiné à la mise au point des scripts mais il faut éviter de lancer des calculs lourds directement dessus.
Une fois mis au point il vaut mieux les soumettre via script batch.**









[######################################################################################]: # 
<br><br>

<a name="ressources"></a>

# 8. Ressources 

---

**Mailing list d'entraides :**
meso-help@umontpellier.fr


**Site web sur cluster MUSE MESO@LR :**
https://meso-lr.umontpellier.fr/documentation-utilisateurs/


**Présentation du cluster MUSE MESO@LR :**
https://meso-lr.umontpellier.fr/wp-content/uploads/2019/11/1-Presentation_cluster_Muse.pdf

**TP-Environment Module :**
https://meso-lr.umontpellier.fr/wp-content/uploads/2020/03/1-TP-Environment_module3.pdf

**TP-SLURM :**
https://meso-lr.umontpellier.fr/wp-content/uploads/2020/04/1-TP-SLURM3.pdf


**Commandes Linux de bases :**
https://doc.ubuntu-fr.org/tutoriel/console_commandes_de_base

**Quick Intro to Parallel Computing in R (et les ref dedans) : **
https://nceas.github.io/oss-lessons/parallel-computing-in-r/parallel-computing-in-r.html










[######################################################################################]: # 

<br><br>

<a name="annexes"></a>

# Annexes

---



<a name="annexes_examples"></a>

## A. Examples



[-----------------------------------------------------------]: # 


<br>

<a name="ex_R_forloop"></a>

### A.1. R OpenMP example parallel for loop

Imaginon que j'ai besoin d'exécuter une fonction ou un code sur différents paramètres d'entrée ou données (ou les deux). Je peux alors faire ça avec une boucle "for".

Par exemple, je veux appliquer la fonction `my_fct = n * p * k` sur différents paramètres d'entrée :

* `n` = 1 ou 2
* `p` = 1, 2 ou 3
* `k` = 1 ou 2

Celà fait `2*3*2 = 12` combinaisons et donc 12 exécutions de ma fonction. 
Je peux très bien faire cela avec le code R :

```
# Définition de ma fonction
my_fct <- function(n, p, k) return(n*p*k)

# Définition d'une grille de paramètres que je veux faire varier
pars <-  expand.grid(n = 1:2, p = 1:3, k = 1:10)

# exécution de ma fonction sur les différentes combinaisons de paramètres
for(i in 1:nrow(pars)){
  result <- my_fct(n=pars$n[i], p=pars$p[i], k=pars$k[i])
  save(result, file = paste0("results/my_result_n=", pars$n[i], "p=", pars$p[i], "k=", pars$k[i], ".Rdata") )
}
```

Celà peut-être très long en fonction de l'application, or **une boucle "for" se parallélise très bien en openMP**.

> Chaque tâche (itération de la boucle) a besoin d'accéder à ce qui a été chargé dans l'environnement avant la boucle, on a besoin d'être en mémoire partagée $\rightarrow$ **openMP**).

Cela se fait facilement avec la fonction `foreach` du package du même nom. Il faut toutefois déclarer un certain nombre de CPU disponible avec la fonction `registerDoParallel` du package `doParallel`. 

**Le script R devient :**

```
library(doParallel)

# Set the number of cores
doParallel::registerDoParallel(cores = 10)

# Définition de ma fonction
my_fct <- function(n, p, k) return(n*p*k)

# Définition d'une grille de paramètres que je veux faire varier
pars <-  expand.grid(n = 1:2, p = 1:3, k = 1:10)

# Parallel for loop
foreach::foreach(i = 1:nrow(pars), .verbose = FALSE) %dopar% {
  result <- my_fct(n=pars$n[i], p=pars$p[i], k=pars$k[i])
  save(result, file = paste0("results/my_result_n=", pars$n[i], "p=", pars$p[i], "k=", pars$k[i], ".Rdata") )

  return() # I return nothing because I save each result in ".Rdata" object in folder "results"
}
```

> Ce script R peut très bien s'éxécuter sur votre PC (attention à adapter le nombre de CPU). Pour détecter le nombre de CPU sur votre PC, vous pouvez utiliser la fonction `parallel::detectCores()`. Ne pas prendre plus que le max-1 sur vos PC !



**Le fichier batch pour la soummision du job :**
```
#!/bin/bash
#SBATCH --partition=agap_short  # la partition
#SBATCH --job-name ex1          # nom du job
#SBATCH --nodes=1               # NB noeuds (MPI processes, openMP -> 1)
#SBATCH --ntasks=1              # NB tâches (MPI processes, openMP -> 1)
#SBATCH --ntasks-per-node=1     # NB tâches par noeud (MPI processes, openMP -> 1)
#SBATCH --cpus-per-task=10      # NB CPUs par task
#SBATCH --mem-per-cpu=100M      # Mémoire par CPU
#SBATCH --time=00:10:00         # Temps limite
#
#SBATCH --mail-type=begin       # send email when job begins
#SBATCH --mail-type=end         # send email when job ends
#SBATCH --mail-user=benjamin.heuclin@cirad.fr

module purge
module load cv-standard
module load R/3.6.1

# OpenMP runtime settings
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

cd $SLURM_SUBMIT_DIR

mkdir ./Rout 
mkdir ./results
R CMD BATCH ./main_script.R    ./Rout/main_script.Rout

# Rscript ./main_script.R 
```




[-----------------------------------------------------------]: # 





<a name="ex_R_openMP"></a>

### A.2. R OpenMP example for random forest calibration

> ⚠️ ATTENTION Pour cet exemple, il faut installer les packages "doParallel", "caret" et "randomForest" dans votre R/3.6.1.


Dans cette exemple, je souhaite calibrer un modèle de forêts aléatoires (random forest) sur les données "iris" (de base dans R).

**Description des données (`?iris`)** : This famous (Fisher's or Anderson's) iris data set gives the measurements in centimeters of the variables sepal length and width and petal length and width, respectively, for 50 flowers from each of 3 species of iris. The species are Iris setosa, versicolor, and virginica.

> J'ai cumulé 3 fois le jeu de données pour arriver à 450 observations sinon c'est trop rapide.


L'objectif ici est de retrouver la variété en fonction des measures faites sur les sépales et pétales. On est donc dans une classification et on va réaliser ça avec un Random Forest.

Pour ce faire il faut calibrer le paramètre "mtry" (Number of variables randomly sampled as candidates at each split). On réalise alors une CV à l'aide du package `caret` et sa fonction `train`. Ce processus implique de lancer plusieurs forêts aléatoires avec des paramètres différents. Cela se parallélise très bien (10 RF en parallèle sur 10 coeurs dans l'exemple (1 par coeur)). Le package `caret` gère la paralélisation à votre place avec l'option `allowParallel = TRUE` dans la fonction `trainControl` (mode OpenMP). Il faut juste déclarer un nombre de CPUs disponible pour la parallélisation en début du script R. Cela peut se faire à l'aide du package `doParallel` :

```
doParallel::registerDoParallel(cores=10)
```

le script R ressemble à :
```
library(doParallel, caret, randomForest)

# Parallel settings -------------------------------------------------------
doParallel::registerDoParallel(cores=10)

# the DATA ----------------------------------------------------------------
iris2 <- rbind(iris, iris, iris)

# Split data in train/test set --------------------------------------------
trainingIndex <- createDataPartition(iris2$Species, p=0.8, list=FALSE)
data_train <- iris2[trainingIndex, ]
data_test <- iris2[-trainingIndex, ]

# RF calibration ----------------------------------------------------------
RF_model_train <- train(Species~., data = data_train,
  method = "rf",
  trControl = trainControl(method = "LOOCV", allowParallel = TRUE),
) 

# RF fit ------------------------------------------------------------------
RFFGrid <- expand.grid(mtry=RF_model_train$bestTune$mtry) 
fit_RF <- train(Species~.,data = data_train,
                method = "rf",
                trControl = trainControl(method = "none"),
                tuneGrid = RFFGrid
)

save(fit_RF, file="results/fit_RF_iris.Rdata")


# RF Predictive performances -----------------------------------------------
table(data_test$Species, predict(fit_RF, new=data_test))

```

> Ce script R peut très bien s'éxécuter sur votre PC (attention à adapter le nombre de CPU). Pour détecter le nombre de CPU sur votre PC, vous pouvez utiliser la fonction `parallel::detectCores()`. Ne pas prendre plus que le max-1 sur vos PC !



<br>
**Astuce :**
On peut récupérer dans R le nombre de CPUs qu'on a déclaré dans le batch (.sh) (variable d'environnement `SLURM_JOB_CPUS_PER_NODE`) avec la commande R :
```
nb_CPUs <- as.integer(Sys.getenv("SLURM_JOB_CPUS_PER_NODE")) 
doParallel::registerDoParallel(cores=nb_CPUs)
```
Cela évite les erreurs ;)













[-----------------------------------------------------------]: # 
<br>

<a name="ex_R_array"></a>

### A.3. R array example

Le type de soummision "array" est adapté pour exécuter un code (une fonction) plusieurs fois avec des paramètres différents en entrée ou sur des données différentes (ou les deux).

Reprenons l'[exemple R de la boucle for](#ex_R_forloop) juste au dessus. 
Dans cet exemple, je souhaite exécuter la fonction `my_fct=n*p*k` sur différents paramètres d'entrée :

* `n` = 1 ou 2
* `p` = 1, 2 ou 3
* `k` = 1 ou 2

**Les 12 exécutions sont indépendantes** et donc on peut optimiser le lancement de ce job à l'aide d'un **array**. Le principe est qu'on demande au cluster un certain nombre de CPUs et le cluster va les choisir potentiellement dans des noeuds (node) differents.   
On est donc sur une forme de paralélisation hybride OpenMPI ! 

> Lorsqu'il y a beaucoup de jobs en attente sur le cluster, cela permet à votre job de passe plus vite car c'est plus facile de prendre *n* CPUs par-ci par-là plutôt que *n* CPUs sur le même noeud. La réservation de ressources est optimisée !

Pour ce faire, on spécifie l'option `--array` dans le batch (.sh) :


```
#!/bin/bash
#SBATCH --partition=agap_short  # la partition
#SBATCH --job-name array        # nom du job
#SBATCH --array=1-12            # OPTION ARRAY 
#SBATCH -o array-%a.out
#SBATCH --mem-per-cpu=100M      # Mémoire par CPU
#SBATCH --time=00:30:00         # Temps limite

module purge
module load cv-standard
module load R/3.6.1

cd $SLURM_SUBMIT_DIR

mkdir ./results
Rscript ./main_script.R $SLURM_ARRAY_TASK_ID
```

⚠️ **Attention** : On ne précise pas le nombre de noeud ni de coeur ni de tasks que l'on souhaite. C'est SLURM qui va répartir en fonction des ressources disponibles.

Sur la dernière ligne d'exécution du script R, on rajoute la variable d'environnement `$SLURM_ARRAY_TASK_ID`, cela permet au script R de récupérer le numéro de la tâche.  
Et enfin dans le script R il faut utiliser la commande `as.numeric(commandArgs(trailingOnly=TRUE)[1])` pour récupérer l'indice (*i*). Je peux ainsi lancer la fonction sur la ligne *i* ème ligne de ma grille de paramètres.

```
# on récupère l'indice de la tâche ($SLURM_ARRAY_TASK_ID)
i = as.numeric(commandArgs(trailingOnly=TRUE)[1])

# Définition d'une grille de paramètres que je veux faire varier
pars <-  expand.grid(n = 1:2, p = 1:3, k = 1:2)

# Définition de ma fonction
my_fct <- function(n, p, k) return(n*p*k)

# Execution de la fonction sur la ligne i de la grille de paramètres
result <- my_fct(n=pars$n[i], p=pars$p[i], k=pars$k[i])
print(paste0("Le resultat de ma fonction est : ", result))
```

> La scructuration du code R est totalement repensé, pas besoin de déclarer un nombre de CPUs comme dans l'exemple précédent. Ici le script est pensé pour une éxécution et il doit être indépendant des autres exécutions (on charge tout ce dont la tâche à besoin : la grille de paramètres, la fonction). Ce script ne peut pas s'éxécuter sur votre PC tel quel  contrairement au script R précédent !


<br>
Pour supprimer des tâches dans un job array :

```
# Cancel array ID 1 to 3 from job array 20
$ scancel 20_[1-3]

# Cancel array ID 4 and 5 from job array 20
$ scancel 20_4 20_5

# Cancel all elements from job array 20
$ scancel 20
```
Plus d'info ici : https://slurm.schedmd.com/job_array.html






<a name="annexes_unix_LF"></a>

## B. Script batch corrompu à cause des retours à la ligne WINDOWS 

**Si tu as un fichier corrompu à cause des retours à la ligne au format WINDOWS**
```
-bash-4.2$ sbatch job_submission.sh
sbatch: error: Batch script contains DOS line breaks (\r\n)
sbatch: error: instead of expected UNIX line breaks (\n).
```
Tu peux soit :

* dans **Notepad++** faire :  *Edition > Convertir les sauts de ligne > Convertir en format UNIX (LF)* et sauvegarder
* dans **Rstudio** (avec l'option qui va bien pour les fin de lignes "unix LF" comme décrit au dessus) : modifier légèrement ton .sh (avec un saut de ligne par exemple) et le sauvegarder. Rstudio va automatiquement convertir les sauts de ligne









[-----------------------------------------------------------]: # 



<a name="annexes_rsync"></a>

## C. rsync (IN PROGRESS)

source : https://meso-lr.umontpellier.fr/documentation-utilisateurs/

```
#! /usr/bin/env bash
###################################################################
# rsync.sh : Ecrit par Jérémy Verrier				  #
# Script permettant la copie sécurisée de fichiers ou de dossiers #
###################################################################

# Entrez votre nom d'utilisateur
USER=
# Entrez le chemin complet du répertoire ou du fichier à copier (/home/verrier/work/results.txt)
DOSSIER_CLUSTER=
# Entrez le chemin complet du répertoire ou du fichier de destination
DOSSIER_PERSO=

while [ 1 ]
do
    rsync -avz --progress --partial "${USER}"@muse-login.meso.umontpellier.fr:"${DOSSIER_CLUSTER}" "${DOSSIER_PERSO}"
    if [ "$?" = "0" ] ; then
        echo "Rsync OK"
        exit
    else
        echo "Rsync erreur, nouvelle tentative dans 1 minute..."
        sleep 60
    fi
done
```


A enregister au au format .sh ou à télécharger avec le lien ci-dessous.

[Ce script](https://hpc-lr.umontpellier.fr/wp-content/uploads/2017/05/rsync.txt) vous permet de copier des données depuis le cluster Muse vers votre machine.
Il vous faut modifier les champs USER, DOSSIER_CLUSTER et DOSSIER_PERSO et ensuite le lancer avec la commande « bash rsync ».
Il est vivement conseillé d’utiliser ce script lors de téléchargement de fichiers volumineux.

















































