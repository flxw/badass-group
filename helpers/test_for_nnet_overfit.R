### nnet overfitting test

if(!require("nnet")) install.packages("nnet"); library("nnet")
if(!require("NeuralNetTools")) install.packages("NeuralNetTools"); library("NeuralNetTools")
if(!require("mlr")) install.packages("mlr"); library("mlr")
if(!require("caret")) install.packages("caret"); library("caret")
if(!require("dplyr")) install.packages("dplyr"); library("dplyr")
if(!require("parallelMap")) install.packages("parallelMap"); library("parallelMap")
if(!require("data.table")) install.packages("data.table"); library("data.table")
if(!require("lubridate")) install.packages("lubridate"); library("lubridate")

# load helper to preprocess data and select fetures
source('helpers/amend_features.R')
# load data
source('load_data.R')

dn = amend_features(df_known)
dn[is.na(dn)] = 0
n = nrow(dn)

test.results <- data.frame(matrix(ncol = 3, nrow = 0))
rn <- c("tr_size", "ts_acc", "tr_acc")
colnames(test.results) = rn

return <- "return"
vars <- c("user_id", 
          "order_item_id", 
          "item_id", 
          "item_size", 
          "item_color", 
          "brand_id", 
          "user_dob", 
          "delivery_duration", 
          "user_maturity", 
          "price_and_age", 
          "avg_return", 
          "nr_obs", 
          "order_month", 
          "order_day", 
          "del_year", 
          "del_month", 
          "del_day")

fmla <- as.formula(paste(return, "~", paste(vars, collapse = " + ")))

parallelStartSocket(parallel::detectCores())

## Take tuned parameters
for (part in seq(0.05, 0.8, 0.05)) {
  set.seed(1)
  idx.train <- createDataPartition(y = dn$return, p = part, list = FALSE) 
  tr <- dn[idx.train, ]  # training set
  ts <- dn[-idx.train, ] # test set 
  
  train_task = makeClassifTask(data = tr, target = "return", positive = 1)
  test_task = makeClassifTask(data = ts, target = "return", positive = 1)
  
  resample_desc = makeResampleDesc("CV", iters = 5)
  nnet_learner = makeLearner("classif.nnet", 
                             predict.type = "prob",
                             par.vals = list(size = 15, 
                                             MaxNWts = 10000,
                                             maxit = 200,
                                             decay = 0.00921592
                            ))
  
  cv.nnet = crossval(learner = nnet_learner,
                       task = train_task,
                       iters = 5,
                       stratify = TRUE,
                       measures = mlr::acc,
                       show.info = T)
  nnet_model = mlr::train(nnet_learner, train_task)
  
  ts$pred <- predict(nnet_model, test_task)$data$response
  tr$pred <- predict(nnet_model, train_task)$data$response
  results =  data.frame(part, mean(ts$pred == ts$return), mean(tr$pred == tr$return))
  colnames(results) = rn
  test.results = rbind(test.results, results)
}

parallelStop()

# Plot overfitting graph and infer test result
nnet_overfit_plot <- ggplot(test.results, aes(tr_size)) + # basic graphical object
  geom_line(aes(y=tr_acc), colour="red") +  # first layer
  geom_line(aes(y=ts_acc), colour="green")  # second layer
nnet_overfit_plot
# Save graph
save(nnet_overfit_plot, file = "data/nnet_overfit_plot")
