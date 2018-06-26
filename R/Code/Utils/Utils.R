
splitData <- function(X, Y, fold, idx) {
  train.idx <- unlist(fold[-idx])
  test.idx <- fold[[idx]]
  
  X.train <- X[train.idx, ]
  X.test <- X[test.idx, ]
  y.train <- factor(Y[train.idx])
  y.test <- Y[test.idx]
  
  return(list(X.train = X.train, y.train = y.train, X.test = X.test, y.test = y.test))
}


computePredictions <- function(model, X.test, y.test) {
  predicted <- predict(model, X.test)
  
  train.levels <- length(levels(model$predicted))
  test.levels <- length(levels(factor(y.test)))
  
  predicted <- as.numeric(as.vector(predicted))
  out <- mean(predicted != y.test)
  return(out)
}
