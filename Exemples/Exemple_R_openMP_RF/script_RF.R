
rm(list=ls())

# load library 
library(doParallel)     # for parallelisation
library(caret)          # for training RF
library(randomForest)   # fit RF




# Parallel settings -------------------------------------------------------

nb_CPUs <- as.integer(Sys.getenv("SLURM_JOB_CPUS_PER_NODE")) 
print(paste0("detected CPU : ", nb_CPUs))

# Calibrate on 10 CPUs
cl <- parallel::makePSOCKcluster(nb_CPUs)
doParallel::registerDoParallel(cl)
foreach::getDoParWorkers()



# the DATA ----------------------------------------------------------------

iris2 <- rbind(iris, iris, iris, iris)
nrow(iris2)

summary(iris2)



# Split data in train/test set --------------------------------------------

Trainingindex <- createDataPartition(iris2$Species, p=0.8, list=FALSE)
data_train <- iris2[Trainingindex, ]
data_test <- iris2[-Trainingindex, ]







# RF calibration ----------------------------------------------------------

# time without parallel
start<-Sys.time()
RF_model_train <- train(
  Species~.,
  data = data_train,
  method = "rf",
  trControl = trainControl(method = "LOOCV", allowParallel = FALSE),
) 
end<-Sys.time()
print(end-start) 


# time with parallel
start<-Sys.time()
RF_model_train <- train(
  Species~.,
  data = data_train,
  method = "rf",
  trControl = trainControl(method = "LOOCV", allowParallel = TRUE),
) 
end<-Sys.time()
print(end-start) 







# RF fit ------------------------------------------------------------------

fitControl <- trainControl(method = "none")

## Now specify the exact models to evaluate:
RFFGrid <- expand.grid(mtry=RF_model_train$bestTune$mtry) 
RFFGrid

fit_RF <- train(Species~.,
                data = data_train,
                method = "rf",
                trControl = fitControl,
                tuneGrid = RFFGrid
)

save(fit_RF, file="results/fit_RF_iris.Rdata")



# RF Predictive performances -----------------------------------------------

results_RF_test <- data.frame(
    Species=data_test$Species,
    y_pred=predict(fit_RF, new=data_test))

table(results_RF_test$Species, results_RF_test$y_pred)


stopCluster(cl)



