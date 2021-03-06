timestamp <- Sys.time()
library(caret)
library(plyr)
library(recipes)
library(dplyr)

model <- "mlpKerasDropout"

## In case the package or one of its dependencies uses random numbers
## on startup so we'll pre-load the required libraries: 

for(i in getModelInfo(model)[[1]]$library)
  do.call("require", list(package = i))

testmod <- try(keras_model_sequential(),
               silent = TRUE)
if(inherits(testmod, "try-error"))
  stop("Could not start a sequential model. ",
       "`tensorflow` might not be installed. ",
       "See `?install_tensorflow`.", 
       call. = FALSE)

#########################################################################

set.seed(2)
training <- twoClassSim(50, linearVars = 2)
testing <- twoClassSim(500, linearVars = 2)
trainX <- training[, -ncol(training)]
trainY <- training$Class

rec_cls <- recipe(Class ~ ., data = training) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors())

cctrl1 <- trainControl(method = "cv", number = 3, returnResamp = "all")
cctrl2 <- trainControl(method = "LOOCV")
cctrl3 <- trainControl(method = "none",
                       classProbs = TRUE, summaryFunction = twoClassSummary)
cctrlR <- trainControl(method = "cv", number = 3, returnResamp = "all", search = "random")

set.seed(849)
test_class_cv_model <- train(trainX, trainY, 
                             method = "mlpKerasDropout", 
                             trControl = cctrl1,
                             preProc = c("center", "scale"),
                             tuneLength = 2,
                             verbose = 0,
                             epochs = 10)

set.seed(849)
test_class_cv_form <- train(Class ~ ., data = training, 
                            method = "mlpKerasDropout", 
                            trControl = cctrl1,
                            preProc = c("center", "scale"),
                            tuneLength = 2,
                            verbose = 0,
                            epochs = 10)

test_class_pred <- predict(test_class_cv_model, testing[, -ncol(testing)])
test_class_pred_form <- predict(test_class_cv_form, testing[, -ncol(testing)])

set.seed(849)
test_class_rand <- train(trainX, trainY, 
                         method = "mlpKerasDropout", 
                         trControl = cctrlR,
                         tuneLength = 4,
                         preProc = c("center", "scale"),
                         verbose = 0,
                         epochs = 10)

set.seed(849)
test_class_loo_model <- train(trainX, trainY, 
                              method = "mlpKerasDropout", 
                              trControl = cctrl2,
                              tuneLength = 2,
                              preProc = c("center", "scale"),
                              verbose = 0,
                              epochs = 5)

set.seed(849)
test_class_none_model <- train(trainX, trainY, 
                               method = "mlpKerasDropout", 
                               trControl = cctrl3,
                               tuneLength = 1,
                               metric = "ROC", 
                               preProc = c("center", "scale"),
                               verbose = 0,
                               epochs = 10)

test_class_none_pred <- predict(test_class_none_model, testing[, -ncol(testing)])
test_class_none_prob <- predict(test_class_none_model, testing[, -ncol(testing)], type = "prob")

set.seed(849)
test_class_rec <- train(x = rec_cls,
                        data = training,
                        method = "mlpKerasDropout", 
                        trControl = cctrl1,
                        tuneLength = 2,
                        verbose = 0,
                        epochs = 10)

test_class_pred_rec <- predict(test_class_rec, testing[, -ncol(testing)])

test_levels <- levels(test_class_cv_model)
if(!all(levels(trainY) %in% test_levels))
  cat("wrong levels")

#########################################################################

library(caret)
library(plyr)
library(recipes)
library(dplyr)
set.seed(1)
training <- SLC14_1(30)
testing <- SLC14_1(100)
trainX <- training[, -ncol(training)]
trainY <- training$y

rec_reg <- recipe(y ~ ., data = training) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) 
testX <- trainX[, -ncol(training)]
testY <- trainX$y 

training_mat <- as.matrix(training)
testing_mat <- as.matrix(testing)

rctrl1 <- trainControl(method = "cv", number = 3, returnResamp = "all")
rctrl2 <- trainControl(method = "LOOCV")
rctrl3 <- trainControl(method = "none")
rctrlR <- trainControl(method = "cv", number = 3, returnResamp = "all", search = "random")

set.seed(849)
test_reg_cv_model <- train(trainX, trainY, 
                           method = "mlpKerasDropout", 
                           trControl = rctrl1,
                           preProc = c("center", "scale"),
                           tuneLength = 2,
                           verbose = 0,
                           epochs = 10)
test_reg_pred <- predict(test_reg_cv_model, testX)

set.seed(849)
test_reg_cv_form <- train(y ~ ., data = training, 
                          method = "mlpKerasDropout", 
                          trControl = rctrl1,
                          preProc = c("center", "scale"),
                          tuneLength = 2,
                          verbose = 0,
                          epochs = 10)
test_reg_pred_form <- predict(test_reg_cv_form, testX)

set.seed(849)
test_reg_rand <- train(trainX, trainY, 
                       method = "mlpKerasDropout", 
                       trControl = rctrlR,
                       tuneLength = 4,
                       preProc = c("center", "scale"),
                       verbose = 0,
                       epochs = 10)

set.seed(849)
test_reg_loo_model <- train(trainX, trainY, 
                            method = "mlpKerasDropout",
                            trControl = rctrl2,
                            tuneLength = 2,
                            preProc = c("center", "scale"),
                            verbose = 0,
                            epochs = 5)

set.seed(849)
test_reg_none_model <- train(trainX, trainY, 
                             method = "mlpKerasDropout", 
                             trControl = rctrl3,
                             tuneLength = 1,
                             preProc = c("center", "scale"),
                             verbose = 0,
                             epochs = 10)
test_reg_none_pred <- predict(test_reg_none_model, testX)

set.seed(849)
test_reg_cv_matrix <- train(y ~ ., 
                            data = training_mat, 
                            method = "mlpKerasDropout", 
                            trControl = rctrl1,
                            tuneLength = 2,
                            verbose = 0,
                            epochs = 10)
test_reg_pred_matrix <- predict(test_reg_cv_matrix, testing_mat)

set.seed(849)
test_reg_rec <- train(x = rec_reg,
                      data = training,
                      method = "mlpKerasDropout",
                      tuneLength = 2, 
                      trControl = rctrl1,
                      verbose = 0,
                      epochs = 10)

test_reg_pred_rec <- predict(test_reg_rec, testing[, -ncol(testing)])

#########################################################################

test_class_predictors1 <- predictors(test_class_cv_model)
test_reg_predictors1 <- predictors(test_reg_cv_model)

#########################################################################

tests <- grep("test_", ls(), fixed = TRUE, value = TRUE)

sInfo <- sessionInfo()
timestamp_end <- Sys.time()

save(list = c(tests, "sInfo", "timestamp", "timestamp_end"),
     file = file.path(getwd(), paste(model, ".RData", sep = "")))

q("no")


