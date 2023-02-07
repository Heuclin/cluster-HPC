
**Jupyter notebook on the HPC cluster:**
https://researchcomputing.princeton.edu/support/knowledge-base/jupyter




<a name="ex_python"></a>
  
  ## 6.1. Exemple python
  
  https://researchcomputing.princeton.edu/support/knowledge-base/python
https://github.com/PrincetonUniversity/hpc_beginning_workshop/tree/main/python/cpu


Installation des packages dans un environnement :
  
  Each package and its dependencies will be installed locally in ~/.conda. Consider replacing `ml-env` with an environment name that is specific to your work. On the command line, use `conda deactivate` to leave the active environment and return to the base environment.


```
module load python/Anaconda/3-5.1.0
conda create --name ml-env scikit-learn pandas matplotlib --channel conda-forge
```

pour ajouter des packages ultérieurement :
  ```
$ conda activate ml-env
(ml-env)$ conda install pandas
```

pour l'activer :
```
source activate ml-env
```

pour le désactiver :
```
conda deactivate ml-env
```

Pour voir la liste de tous les environnements :
```
conda env list
```

Supprimer un environnement :
```
conda remove --name ml-env --all
```
