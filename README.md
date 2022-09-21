



---
title: |
  ![](Figures/logos.png)
  Cluster Muse
author: "Benjamin Heuclin, Ingénieur statisticien, UR AIDA, Cirad"
date: "19/08/2022"

output:
  html_document:
    number_sections: yes
    toc: yes
---

___

Pour les agents Cirad, il faut demander l'accès à Bertrand Pitollat  ([bertrand.pitollat@cirad.fr](mailto:bertrand.pitollat@cirad.fr)).

Vous obtenez  ainsi un nom utilisateur (généralement celui de votre compte Cirad) et un mot de passe (généralement le même que celui de votre compte Cirad).

Pour utiliser le cluster, il faut un terminal unix pour ce connect, soumettre et gérer vos jobs et un logiciel de transfert de fichier pour envoyer vos codes, ... de votre PC vers le cluster et vice-versa.


Documentation Muse : https://meso-lr.umontpellier.fr/documentation-utilisateurs/



# Connexion au Cluster


C'est très simple ! La connexion au cluster de calcul haute performance se fait via le protocole SSH. Le nom d’hôte de la machine de connexion est `muse-login.meso.umontpellier.fr`.

Suivant votre système d’exploitation, vous pouvez vous y connecter comme suit :

**Sous linux ou Mac :**

Ouvrir une connexion ssh dans un terminal en tapant la commande suivante : 

```
ssh «nom_utilisateur»@muse-login.meso.umontpellier.fr
```
Entrer ensuite votre MDP.

Sous Mac, vous pouvez également utiliser le logiciel Xquartz.

Vous voilà maintenant connecter au cluster Muse. Le cluster Muse utilise le gestionnaire de job SLURM.  C'est d'ici que vous pourait executer et gérer vos jobs avec les commandes spécifiques SLURM (Voir plus bas pour les principales commandes). 



**Sous windows :**

Installer le logiciel MobXterm (https://mobaxterm.mobatek.net/download-home-edition.html). Lors de la première connection, il faut la configurer !

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
7. Il faut ensuite entrer votre mot de passe (rien ne s'affiche lorsque vous tapez le mdp, c'est un réglage de sécuriter) puis valider en appuyan sur "entrée".
8. MobaXterm vous demande si vous voulez enregistrer le mdp pour ne plus vous le demander. C'est vous qui voyez !

![](Figures/MobaXterm2-2.png)


Pour les prochaines fois, vous n'aurez qu'à ouvrir MobaXterm et cliquer sur votre session que vous trouverez dans l'onglet "User sessions" sur la gauche. Vous pouvez egalement créer un racourci sur votre bureau en faisant un clique droit dessus. Cela permet d'ouvrir votre session en même temps que le logiciel se lance.



Vous voilà maintenant connecter au cluster Muse. Le cluster Muse utilise le gestionnaire de job SLURM.  C'est d'ici que vous pourait executer et gérer vos jobs avec les commandes spécifiques SLURM (Voir plus bas pour les principales commandes). 






# Transfer de fichier
Pour soumettre vos job, il va falloir envoyer vos scripts sur le cluster. Il vous faudra ensuite récupérer les fichiers générés par vos job. Pour ce faire, on va utiliser le logiciel FileZilla. Il est disponible sous Windows, OSX et Linux.

Installer FileZilla : https://filezilla-project.org/download.php?show_all=1

Remarque : sous Linux, Filezilla est disponible par l’intermédiaire de votre
Gestionnaire de paquets 
```
apt-get install filezilla
```

Présentation de FileZilla : 

![](Figures/Filezilla2.png)

Pour ce connecter, remplir dans la zone de connection :

* Hôte : `sftp://muse-login.meso.umontpellier.fr`
* Nom d'utilisateur : votre nom d'utilisateur 
* Mot de passe : votre mot de passe
* Port : 22


**Après la première connexion, ces informations seront enregistrées et vous pourrez vous connecter facilement en cliquant sur la petite flèche à coté de "Connexion rapide".**

Vous pouvez transférer un fichier dans un sens ou dans l'autre en cliquant droit dessus puis cliquer sur "Téléversé" ou "Télécharger".






# Les espaces de stockage

Il y a plusieurs espaces de stockage. Les fichiers déposés sur le répertoire "scratch" sont temporaires pour effectuer vos calcul, et sont automatiquement supprimés à 60 jours. Les documents destinés à être conservés doivent être déposés sur votre répertoire "home".

Email de Bertrand Pitollat du 19/10/2021 :

___
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

___











# Procedure de soumission de jobs R

Dans cette section j'explique comment soumettre des jobs en parallele sous R. Avant de rentrer dans le vif du sujet, il faut choisir une partition sur laquelle lancer les jobs.

**Les partitions :** 

Il faut choisir le type de partition sur laquelle lancer vos jobs. Il existe plusieurs partions avec des paramètres différents sur lesquelles vous pouvez soumettre vos job :

![](Figures/partition.PNG)

Sur chaque partition il y a un certain nombre de noeuds (nodes) (!j'ai pas compté combien). Chaque noeud contiend 28 coeurs (cores).
Pour les novices, un noeud peut être apparenté à un ordinateur et les coeurs au processeurs.

En tant qu'utilisateur Cirad lambda, nous avons accès aux partitions :

* *agap_short* pour des jobs rapides (limite de 1h)
* *agap_normal* pour des jobs de 2 jours max
* *agap_long* pour des jobs chronophages (pas de limite de temps)
* *agap_bigmem* pour des jobs nécessitant beaucoup de mémoire vive (pas de limite de temps)

La mémoire vive par coeur est limitée par défaut (voir 3ème colone) mais elle peut être augmenter en ajoutant le paramètre `--mem-per-cpu=XG`, avec X la quantité de mémoire alloué au job (en théorie, max de 128G pour la queue *agap_short*, *agap_normal*, et *agap_long*, et max de 3000G pour la queue *agap_bigmem*).





**Soumision de jobs**

Pour illustrer la soumission d'un job en parallèle, nous utiliserons l'Exemple_1. Dans cette exemple bidon je répète l'oppération 2*k pour k=1 à 50. Je veux paralleliser ces oppérations sur 10 coeurs pour aller 10 fois plus vite. Je sauvegarde chaque résult dans un ".Rdata" dans un fichier "results".


Pour soumettre un job vous devez choisir entre :

  * Un mode d’exécution en temps réel avec la commande srun (non détailler dans ce tuto)
  * Un mode d’exécution différé en définissant son job dans un script *batch* et en le lancer à l’aide de la commande `sbatch` 


**J'explique ici uniquemement la procedure différée avec la commande `sbatch`** :

Cette procédure consiste à définir les paramètres d'exécution dans un fichier *batch*. 

Prenons le fichier *batch* de l'Exemple_1 :

```
#!/bin/bash
#SBATCH --partition=agap_short
#SBATCH --job-name ex1
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem-per-cpu=1G
#SBATCH --time=01:00:00

module load cv-standard
module load R

R CMD BATCH /storage/replicated/cirad/projects/AIDA/Atelier_cluster/Exemple_1/main_script.R    /storage/replicated/cirad/projects/AIDA/Atelier_cluster/Exemple_1/Rout/main_script.Rout
```
ce fichier ce décompose en 3 parties :

* 1ère partie : chaque ligne commençant par `#SBATCH` décrit un paramètre **SLURM** :
    * `--partition=` pour sélectionner la partition
    * `--job-name ` pour donner un nom à la soumission
    * `--nodes=` nombre de noeuds (toujours 1 dans ce tuto)
    * `--ntasks=` nombre de tâches pour la parallelisation, correspond au nb de coeurs puisque 1 noeud 
    * `--mem-per-cpu=` quantité de mémoire vive par coeur
    * `--time=` temps maximum
    
D'autres options existes, ce référer à la documentation du cluster pour plus d'info (https://meso-lr.umontpellier.fr/documentation-utilisateurs/).

* 2ère partie : Il faut ensuite charger les **modules** avec la commande `module load`. Les modules reposent sur un système de dépendances et de conflits fixés par la personne ayant installé ou compilé le logiciel ou la librairie visée.
Pour utiliser le logiciel R, il faut charger le module cv-standard et ensuite R. Si votre code utilise un autre language (c++, python, ...), il faudra alors charcher les modules en conséquence. Pour voir la liste des modules disponibles : `module avail`. Plus d'info sur les module dans la documentation du cluster (https://meso-lr.umontpellier.fr/documentation-utilisateurs/) section "Environnement logiciel du Cluster Muse" et le TP : https://meso-lr.umontpellier.fr/wp-content/uploads/2020/03/1-TP-Environment_module3.pdf


* 3ère partie : Enfin la ligne pour executer le script R : `R CMD BATCH ` suivie du chemin d'accès vers le script, suivi du chemin d'accès vers le **Rout** pour ecrire les sorties (ce qui s'affiche dans la console de Rstudio en temps normale).





Pour lancer votre code, il faut exécuter le fichier batch associé avec la commande :
```
sbatch job_submission.sh
```




**Attention** : si votre code nécessite le chargement de packages ("doParallel" pour l'Exemple_1), il faut impérativement les installer avant. Pour ce faire, dans le terminale, charger les modules puis lancer R :
```
module load cv-standard R
R
```
Installer ensuite les packages (il vous faudra choisir un miroir) :
```
install.packages("doParallel")
```
Enfin quiter R avec la commande `q()`.




# Les commandes utiles


Pour voir l'etat de tous les jobs (de tous les utilisateurs)
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


Pour voir le nombre de coeurs disponibles par noeud (très util pour choisir le nombre de coeurs pour passer devant toute la fille d'attente)
```
sinfo -o "%P %n %C"
```

* La 1er colone donne la partition
* La 2ème colone donne l'identifiant du noeud
* La 3ème colone donne le nombre de CPUs par état dans le format "alloué/libre/autre/total"

![](Figures/sinfo.png)



Consulter la quantité de mémoire consommée par le job après son exécution : 
```
sacct -o JobID,Node,AveRSS,MaxRSS,MaxRSSTask,MaxRSSNode,TRESUsageInTot%250 -j <JOB_ID> 
```



Plus d'info sur les commandes ici : https://slurm.schedmd.com/man_index.html






# Exemples

## Exemple python

https://researchcomputing.princeton.edu/support/knowledge-base/python
https://github.com/PrincetonUniversity/hpc_beginning_workshop/tree/main/python/cpu


Installation des package dans un environnement :

Each package and its dependencies will be installed locally in ~/.conda. Consider replacing `ml-env` with an environment name that is specific to your work. On the command line, use conda deactivate to leave the active environment and return to the base environment.


```
module load python/Anaconda/3-5.1.0
conda create --name ml-env scikit-learn pandas matplotlib --channel conda-forge
```

