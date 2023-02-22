---
output:
  word_document: default
  html_document: default
---




![](Figures/logos.png)

# Introduction au cluster de calcul MESO@LR 


***Axe transversal TIM, UR AIDA***

*Benjamin Heuclin, Ingénieur statisticien, UR AIDA, Cirad*

*Septembre 2022*

Licence : <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/"><img alt="Licence Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/88x31.png" /></a><br />Ce(tte) œuvre est mise à disposition selon les termes de la <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/">Licence Creative Commons Attribution - Pas d’Utilisation Commerciale 4.0 International</a>.




___

1. [C'est quoi un supercalculateur ? et la parallélisation ?](#cluster_parallelisation)
    1. [La paralélisation](#parallelisation)
    2. [Cluster de calcul MUSE (MESO@LR)](#cluster)
2. [Connexion au Cluster](#connexion)
3. [Transfer de fichier](#transfer) 
4. [Les espaces de stockage](#stockage)
5. [Procedure de soumission de jobs R](#proc_soumission)
6. [Les commandes SLURM utiles](#commandes)
7. [Rstudio sur le cluster](#rstudio) 
8. [Ressources](#ressources)
*  [Annexes](#annexes)

    A.[ Les exemples](#annexes_exemples)
      1. [Exemple R OpenMP sur calibration d'une RF](#ex_R_openMP)
      2. [Exemple R openMP for loop](#ex_R_forloop)
      3. [Exemple R array](#ex_R_array)
      
    B. [Script batch corrompu à cause des retours à la ligne WINDOWS](#annexes_unix_LF)
    
    C. [rsync](#annexes_rsunc)
    
    
    
___










> 🚨 Ce document se limite à l'utilisation de R sur CPU, avec une parallélisation en mémoire partagée (openMP). C'est une initiation pour prendre rapidement en main le processus de soumission de jobs.

Pour les agents Cirad, il faut demander l'accès à Bertrand Pitollat ([bertrand.pitollat@cirad.fr](mailto:bertrand.pitollat@cirad.fr)) en lui envoyant un email en précisant l'unité, votre numéro de poste téléphonique CIRAD accompagné de la charte signée.  


Vous obtenez  ainsi un nom d'utilisateur (généralement celui de votre compte Cirad) et un mot de passe (généralement le même que celui de votre compte Cirad).

Pour utiliser le cluster, il faut un terminal unix pour ce connect, soumettre et gérer vos jobs et un logiciel de transfert de fichier pour envoyer vos codes, ... de votre PC vers le cluster et vice-versa.


Documentation Muse : https://meso-lr.umontpellier.fr/documentation-utilisateurs/



[######################################################################################]: # 

<br><br>

# 1. C'est quoi un supercalculateur ? et la parallélisation ? {#cluster_parallelisation}

---


[Définition wikipédia](https://fr.wikipedia.org/wiki/Superordinateur) : <br>
Un superordinateur ou supercalculateur est un ordinateur conçu pour atteindre les plus hautes performances possibles avec les techniques connues lors de sa conception, en particulier en ce qui concerne la vitesse de calcul. Pour des raisons de performance, c'est presque toujours un ordinateur central, dont les tâches sont fournies en traitement par lots. <br>
La science des superordinateurs est appelée « calcul haute performance » (en anglais : high-performance computing ou HPC). 

Un supercalculateur est généralement un regroupement plusieurs ordinateurs indépendants appelés nœuds (node en anglais) d'où l'appélation également sous le terme de cluster de calcul.



## 1.1 La parallélisation {#parallelisation}

Ce lien explique très bien les différents types de parallélisation :

https://cwant.github.io/hpc-beyond/21-introduction-to-parallelism/index.html

> Une tâche (ou processus, ou thread) est une unité de traitement logique


* **Stratégie de mémoire partagée :** il s'agit de la situation où votre programme exécute des tâches sur pluisieurs CPUs (1 par tâche) sur le même nœud, et chaque CPU peut accéder à toute la mémoire utilisée par le programme. Une bibliothèque très largement utilisée pour réaliser ce type de parallélisme est OpenMP (Open Multi-Processing).<br>
Ce type de parallélisation peut se produire pendant l'exécution d'une boucle "for" spécifique en répartissant la boucle entre les différents CPUs. <br>
**Ce type de paralélisation est réalisable sur ton PC.**

* **Stratégie de mémoire distribuée :** chaque tâche est exécuté sur un CPU (sur un noeud) qui possède sa propre mémoire qui lui est privée, et aucune autre CPU ne peut voir cette mémoire (indépendance). Afin de communiquer ce qui se trouve dans l'espace mémoire d'un CPU à un autre, les CPUs se "passent des messages". Grâce à cette conception, le code est modularisé de telle sorte que certaines parties du programme peuvent être exécutées sur plusieurs machines différentes (nœuds), chaque machine devant travailler avec son propre espace mémoire.
Une bibliothèque populaire pour implémenter ce type de parallélisme est appelée MPI (Message Passing Interface). <br>


* **Stratégie hybride :** la mémoire est distribuée entre les nœuds, mais sur chaque nœud le code peut utiliser une stratégie de mémoire partagée. Cela pourrait être un cas où vous voulez utiliser MPI pour faire passer des messages entre chaque nœud, mais sur chaque nœud vous utilisez une stratégie de mémoire partagée utilisant OpenMP. <br>



![](Figures/parallelisation.png)

**En résumé :**

|          | 1 node       | n nodes |
| :------- | :----------- | :------ |
| 1 CPU    | Job en série | MPI     |
| n CPUs   | OpenMP       | hybride : OpenMPI |




<br>

## 1.2 Le cluster de calcul MUSE (MESO@LR) {#cluster}

**Les chiffres :**

* 308 nœuds (nodes) de calcul Dell PowerEdge C6320
    - bi processeurs Intel Xeon E5-2680 v4 2,4 Ghz (broadwell)
    - **28 CPUs par nœuds**, total : 8624 CPUs 
    - 128 Go RAM par nœuds
    - 330 Tflops 
* 2 noeuds large mémoire 112 coeurs, 3To RAM
* 2 noeuds GPU de visualisation, 52 coeurs CPU (bi-processeurs 26 coeurs), dédiés et configurées pour le post-traitement (Poweredge R740 embarquant du RTX6000)
* 1,3 Po de stockage dédié au calcul
    * 1 Po de stockage rapide sous Lustre
    * 350 To de stockage pérenne
* Réseau d’interconnexion Intel OmniPath 100 Gb/s
* Pas d’accélérateur
* Gestionnaire de soumission de job : [SLURM (Simple Linux Utility for Resource Management)](https://slurm.schedmd.com/documentation.html)
    * Ordonnancement de tâches dans les files d’attentes (arbitrage)


<br>
**Fonctionnement :**

  * Les utilisateurs appartenant à des groupes exécutent des jobs sur des partitions
  * Une partition est un ensemble de nœuds


<br>
**Partitions pour les Ciradiens :**

Il faut choisir la partition sur laquelle lancer vos jobs. Il existe plusieurs partions pour les ciradiens :


| Partition   | Description            | Limite de <br> temps | nb nodes  | nb CPUs <br> par noeud |Mémoire par défaut * | Mémoire max |
| :---------  | :------------          | :---------:     |:--------: |:------: | :------: | :------: |
| agap_short  | Pour des jobs rapides  | 1 h             | 71        | 28      | 4 Go     | 128 Go   |
| agap_normal | Partition par défaut   | 2 j             | 67        | 28      | 4 Go     | 128 Go   |
| agap_long   | Pour jobs chronophages | Pas de limite   | 67        | 28      | 4 Go     | 128 Go   |
| agap_bigmem | calculs grosse mémoire | Pas de limite   | 1         | 112     | 28 Go    | 3 To     |




$*$ La mémoire vive par noeud est limitée par défaut (voir colonne 6) mais elle peut être augmentée en ajoutant la ligne :

* `--mem=XG` (pour la mémoire alouée pour le job en entié)
* ou `--mem-per-cpu=XG`  (pour la mémoire alouée pour chaque CPU)

dans votre script batch (voir section [Soumission de job](#proc_soumission)) avec "X" la quantité de mémoire. Voir colonne 7 pour la quantité de mémoire max par noeud. 
Ces 2 paramètres sont exclusifs l'un l'autre. 





















[######################################################################################]: # 
<br><br>

# 2. Connexion au Cluster {#connexion}

---

C'est très simple ! La connexion au cluster de calcul haute performance se fait via le protocole SSH. Le nom d’hôte de la machine de connexion est `muse-login.meso.umontpellier.fr`.

Suivant votre système d’exploitation, vous pouvez vous y connecter comme suit :

**Sous linux ou Mac :**

Ouvrir une connexion ssh dans un terminal en tapant la commande suivante : 

```
ssh «nom_utilisateur»@muse-login.meso.umontpellier.fr
```
Entrer ensuite votre MDP.

Sous Mac, vous pouvez également utiliser le logiciel Xquartz.

Vous voilà maintenant connecté au cluster Muse. Le cluster Muse utilise le gestionnaire de job SLURM. C'est d'ici que vous pourez exécuter et gérer vos jobs avec les commandes spécifiques SLURM (voir plus bas pour les principales commandes). 



**Sous windows :**

Installer le logiciel MobXterm (https://mobaxterm.mobatek.net/download-home-edition.html). Lors de la première connexion, il faut la configurer !

Configuration :

1. Cliquer sur le bouton Session (en haut à gauche)
2. Une fenêtre "*Session settings*" s'ouvre alors
3. Cliquer sur SSH (en haut à gauche)
4. Remplir les champs suivant : 
    a. *Remote host* : `muse-login.meso.umontpellier.fr`
    b. Sélectionner *Specify username*
    c. Entrer votre nom d'utilisateur
    d. *Port* : 22
5. Cliquer sur OK


![](Figures/MobaXterm1-2.png)


6. Un terminal unix s'ouvre. 
7. Il faut ensuite entrer votre mot de passe (rien ne s'affiche lorsque vous tapez le mdp, c'est un réglage de sécurité) puis valider en appuyant sur "entrée".
8. MobaXterm vous demande si vous voulez enregistrer le mdp pour ne plus vous le demander. C'est vous qui voyez !

![](Figures/MobaXterm2-2.png)


> 🤩 Pour les prochaines fois, vous n'aurez qu'à ouvrir MobaXterm et à cliquer sur votre session que vous trouverez dans l'onglet "*User sessions*" sur la gauche.  
Vous pouvez également créer un raccourci sur votre bureau en faisant un clique droit dessus. Cela permet d'ouvrir votre session en même temps que le logiciel se lance. C'est trop bien 🤩



Vous voilà maintenant connecté au cluster Muse. Le cluster Muse utilise le gestionnaire de job SLURM.  C'est d'ici que vous pourrez exécuter et gérer vos jobs avec les commandes spécifiques SLURM (voir section [Soumission de jobs](#soumission)). 








**Quelsques commandes Linux utiles :**

* `ls` pour afficher le contenu du répertoir courant
* `ls -a` pour afficher tous les fichiers (même caché) du répertoir courant
* `cd "path"` pour changer de répertoir
* `cd ..` pour aller au répertoir parent
* `pwd` pour afficher le chemin absolut du répertoir courant (depuis la racine)
* ⬆️⬇️ **Flèche haut/bas** pour naviger dans historique des commandes utilisées

Pour plus d'info sur les commandes Linux de bases :
https://doc.ubuntu-fr.org/tutoriel/console_commandes_de_base





[######################################################################################]: # 
<br><br>

# 3. Transfer de fichiers {#transfer}

---

Pour soumettre vos jobs, il va falloir envoyer vos scripts sur le cluster. Il vous faudra ensuite récupérer les fichiers générés par vos jobs. Pour ce faire, on va utiliser le logiciel FileZilla. Il est disponible sous Windows, OSX et Linux. Pour le téléchargement de fichiers volumineux du cluster vers votre machine (long avec FileZilla) il est possible d'utiliser "rsunc" (voir [annexe A](#annexes_rsunc))




**Installer FileZilla :** https://filezilla-project.org/download.php?show_all=1


> **Remarque pour Linux** : Filezilla est disponible par l’intermédiaire de votre Gestionnaire de paquets `apt-get install filezilla`

**Présentation de FileZilla : **

![](Figures/Filezilla2.png)

Pour ce connecter, remplir dans la zone de connection :

* **Hôte** : `sftp://muse-login.meso.umontpellier.fr`
* **Nom d'utilisateur** : votre nom d'utilisateur 
* **Mot de passe** : votre mot de passe
* **Port** : 22


> 🤩 Après la première connexion, ces informations seront enregistrées et vous pourrez vous connecter facilement en cliquant sur la petite flèche à côté de "Connexion rapide"

Vous pouvez transférer un fichier dans un sens ou dans l'autre en cliquant droit dessus puis cliquer sur "Téléversé" ou "Télécharger".










[######################################################################################]: # 
<br><br>

# 4. Les espaces de stockage  {#stockage}

---

Il y a plusieurs espaces de stockage. Les fichiers déposés sur le répertoire "scratch" sont temporaires pour effectuer vos calculs, et sont automatiquement supprimés à 60 jours. Les documents destinés à être conservés doivent être déposés sur votre répertoire "home".

Email de Bertrand Pitollat du 19/10/2021 :


Vous disposez de plusieurs espaces de stockage sur le cluster Muse :

- **home directory** : C'est votre point d'entrée sur le cluster Muse.
  * Il est hébergé sur la baie NFS du cluster Muse.
  * Il n'est ni sauvegardé ni répliqué.
  * Il est limité à un quota de 50 Go (hors autres espaces de stockage).
  * Il est accessible en lecture et en écriture depuis les noeuds de login et en lecture seule depuis les noeuds de calcul.

- **répertoire personnel sur la baie répliquée : lien replicated**
  * Il est hébergé sur la baie NetApp du cluster Muse.
  * Ce répertoire est personnel.
  * Il est destiné au stockage long terme des données personnelles.
  * Il est accessible via le lien replicated de votre home directory (par exemple, /home/pitollatb/replicated => /storage/replicated/cirad_users/pitollatb).
  * Il est sauvegardé et répliqué sur une baie de secours.
  * Il est limité à un quota de 500Go.
  * Il est accessible en lecture et en écriture depuis les noeuds de login et de calcul.

- **espace projets / unités / équipes sur la baie répliquée : lien projects**
  * Cet espace est hébergé sur la baie NetApp du cluster Muse.
  * Il est destiné au stockage long terme des données projets / unités / équipes.
  * L'espace est accessible via le lien projects de votre home directory (par exemple, /home/pitollatb/projects => /storage/replicated/cirad/projects).
  * Il est sauvegardé et répliqué sur une baie de secours.
  * Il est partitionné par répertoire projet, unité ou équipe avec un quota initial de 5To pour chaque répertoire.
  * Chaque répertoire projet peut être associé à un groupe d'utilisateurs à définir par le collectif.
  * L'espace est accessible en lecture et en écriture depuis les noeuds de login et de calcul.

- **espace work : lien work_agap**
  * Il est hébergé sur la baie NFS du cluster Muse.
  * Cet espace de stockage précédemment dédié au stockage des données projets ne doit plus être utilisé.
  * Les données s'y trouvant doivent être transférées dans le nouvel espace projets / unités / équipes.
  * Il n'est ni sauvegardé ni répliqué.
  * Il est accessible via le lien work_agap de votre home directory (par exemple, /home/pitollatb/work_agap => /nfs/work/agap).
  * Il est accessible en lecture et en écriture depuis les noeuds de login et en lecture seule depuis les noeuds de calcul.

- **espace personnel scratch : lien scratch**
  * Il est hébergé sur la baie Lustre du cluster Muse.
Ce espace est personnel.
  * Il est rapide et performant et doit être utilisé pour héberger les données temporaires de calcul.
  * A la fin du calcul, les données doivent être supprimées ou déplacées.
  * Il est accessible via le lien scratch de votre home directory (par exemple, /home/pitollatb/scratch => /lustre/pitollatb).
  * Il n'est ni sauvegardé ni répliqué.
  * Il est limité dans le temps : les données vieilles de plus de 2 mois seront bientôt automatiquement supprimées.
  * Il est accessible en lecture et en écriture depuis les noeuds de login et de calcul.

- **banques de données scratch : /lustre/agap**
  * Cet espace communautaire stocke les banques de données.
  * Il est hébergé sur la baie Lustre du cluster Muse pour optimiser les calculs.
  * Il n'est ni sauvegardé ni répliqué.
  * Il ne doit pas être utilisé pour stocker de données personnelles.
  * Il est accessible à l'emplacement /lustre/agap.
  * Les banques maintenues par biomaj sont accessibles à l'emplacement /lustre/agap/BANK/biomaj.

- **espace web :** Par ailleurs, il existe un espace dédié pour héberger les données affichées/diffusées par nos différents services web (genome hubs, ...).
Nous contacter si nécessaire.

**Important :**
Je vous rappelle que pour des raisons de performance du cluster Muse, toutes les écritures issues des jobs doivent être redirigées vers votre répertoire scratch et qu'il faut bannir toute lecture intensive depuis les espaces NFS et NetApp.






[######################################################################################]: # 
<br><br>

# 5. Procedure de soumission de jobs R  {#proc_soumission}

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



💥🔥 **Alerte Windows** 🚨🧯 **Attention aux retours à la ligne !!!**  
Par défault dans Windows les retours chariot sont de type DOS et ils ne sont pas compatible avec Linux ou Max de type UNIX (Posix LF) et ça plantle !  
Il faut soit :

* utiliser **Notepad++** en faisant :  
*Edition > Convertir les sauts de ligne > Convertir en format UNIX (LF)*  
⚠️ a faire pour chaque nouveau fichier
* utiliser **Rstudio** en réglant l'option des retours à la ligne de type Unix :  
*Tools > Global options > Code > Saving > Serialization > Line ending conversion > Posix (LF)*  
A faire qu'une seule fois ❤️💪 Il sait tout faire ce Rstudio ! 💪❤️ 





**Prenons le fichier *batch* de l'Exemple_R_openMP_RF** pour voir sa construction


```
#!/bin/bash
#SBATCH --partition=agap_short  # la partition
#SBATCH --job-name openMP_RF    # nom du job
#SBATCH --nodes=1               # NB noeuds (MPI processes, openMP -> 1)
#SBATCH --ntasks=1              # NB tâches (MPI processes, openMP -> 1)
#SBATCH --ntasks-per-node=1     # NB tâches par noeud (MPI processes, openMP -> 1)
#SBATCH --cpus-per-task=10      # NB CPUs par task
#SBATCH --mem-per-cpu=100M      # Mémoire par CPU
#SBATCH --time=0-00:10:00       # Temps limite (10 min)

module purge
module load cv-standard
module load R/3.6.1

# OpenMP runtime settings
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

cd $SLURM_SUBMIT_DIR   # Pour se mettre dans le répertoir où est exécuter le .sh

mkdir ./Rout           # Crer le dossier Rout pour les sorties console de R
mkdir ./results        # créer le dossier "results" pour la sauvegarde de mes résultats
R CMD BATCH ./script_RF.R    ./Rout/script_RF.Rout
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

# 6. Les commandes SLURM utiles {#commandes}

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

# 7. Rstudio sur le cluster {#rstudio}

---

http://193.52.26.138/rstudio/auth-sign-in

Rstudio est isolé sur un noeud dédié (96 CPUs et 3To de mémoire) et est partagé avec tous les utilisateurs Rstudio.


**Il est destiné à la mise au point des scripts mais il faut éviter de lancer des calculs lourds directement dessus.
Une fois mis au point il vaut mieux les soumettre via script batch.**









[######################################################################################]: # 
<br><br>

# 8. Ressources {#ressources}

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

# Annexes {#annexes}

---

## A. Les exemples {#annexes_exemples}

[-----------------------------------------------------------]: # 

### A.1. Exemple R OpenMP sur calibration d'une RF {#ex_R_openMP}

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

### A.2. Exemple R openMP for loop {#ex_R_forloop}




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
<br>

### A.3. Exemple R array {#ex_R_array}

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







## B. Script batch corrompu à cause des retours à la ligne WINDOWS {#annexes_unix_LF}

**Si tu as un fichier corrompu à cause des retours à la ligne au format WINDOWS**
```
-bash-4.2$ sbatch job_submission.sh
sbatch: error: Batch script contains DOS line breaks (\r\n)
sbatch: error: instead of expected UNIX line breaks (\n).
```
Tu peux soit :

* dans **Notepad++** faire :  *Edition > Convertir les sauts de ligne > Convertir en format UNIX (LF)* et sauvegarder
* dans **Rstudio** (avec l'option qui va bien pour les fin de lignes "unix LF" comme décrit au dessus) : modifier légèrement ton .sh (avec un saut de ligne par exemple) et le sauvegarder. Rstudio va automatiquement convertir les sauts de ligne










## C. rsync EN CONSTRUCTION {#annexes_rsunc}

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

















