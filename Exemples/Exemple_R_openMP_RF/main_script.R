####################################################################
# Benjamin Heuclin, UR AIDA, PERSYST, CIRAD              
# février 2023
# 
# R script example for job in openMP
# (apply a random forest on Iris dataset)
###################################################################

library(doParallel)
library(caret)
library(randomForest)

# Parallel settings -------------------------------------------------------
nb_CPUs <- as.integer(Sys.getenv("SLURM_JOB_CPUS_PER_NODE")) 
doParallel::registerDoParallel(cores=nb_CPUs)

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










