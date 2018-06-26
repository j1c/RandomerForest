#' RandomForest evaluation code
#'
#' @param Xtrain 
#' @param Ytrain
#' @param Xtest
#' @param Ytest
#' @param params
#'
#' @importFrom AUC auc roc
#' @importFrom compiler setCompilerOptions cmpfun
#' @importFrom R.utils withTimeout
#'

rfEval <- function(Xtrain, Ytrain, Xtest, Ytest, args) {
  
  # 
  labels.train <- unique(Ytrain)
  labels.test <- unique(Ytest)
  labels.all <- unique(c(labels.train, labels.test))
  
  nClasses <- length(labels.all)
}

train <- function() {
  
}