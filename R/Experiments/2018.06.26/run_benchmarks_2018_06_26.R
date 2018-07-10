# evaluate classifiers on benchmark datasets

rm(list = ls())
options(scipen = 999)

library(randomForest)

# Parameters

# For local
#rerfPath <- "./"
#dataPath <- "./Data/processed/"
#source(paste0(rerfPath, "R/Code/Utils/GetFolds.R"))
#source(paste0(rerfPath, "R/Code/Utils/Utils.R"))

# For MARCC
rerfPath <- "~/work/jaewon/RandomerForest"
dataPath <- "~/work/jaewon/RandomerForest/Data/uci/processed/"
source(paste0(rerfPath, "RandomerForest/R/Utils/GetFolds.R"))
source(paste0(rerfPath, "RandomerForest/R/Utils/Utils.R"))

classifiers <- c("rf-bag", "rf-subsample")
nCl <- length(classifiers)

seed <- 20180626L

set.seed(seed = seed)

testError <- list()
OOBError <- list()
trainTime <- list()
testTime <- list()
bestIdx <- list()
params <- list()


dataSet <- "abalone"
#dataSets <- read.table(paste0(dataPath, "names.txt"))[[1]]

# Set variables
testError[[dataSet]] <- vector(mode = "list", length = nCl)
names(testError[[dataSet]]) <- classifiers
OOBError[[dataSet]] <- vector(mode = "list", length = nCl)
names(OOBError[[dataSet]]) <- classifiers
trainTime[[dataSet]] <- vector(mode = "list", length = nCl)
names(trainTime[[dataSet]]) <- classifiers
testTime[[dataSet]] <- vector(mode = "list", length = nCl)
names(testTime[[dataSet]]) <- classifiers
bestIdx[[dataSet]] <- vector(mode = "list", length = nCl)
names(bestIdx[[dataSet]]) <- classifiers
params[[dataSet]] <- vector(mode = "list", length = nCl)
names(params[[dataSet]]) <- classifiers

# Data wrangling
X <- as.matrix(read.table(paste0(dataPath, "data/", dataSet, ".csv"), header = F, sep = ",", quote = "", row.names = NULL))

p <- ncol(X) - 1L
n <- nrow(X)

Y <- as.integer(X[, p + 1L]) + 1L
X <- X[, -(p + 1L)]

# remove columns with zero variance
X <- X[, apply(X, 2, function(x) any(as.logical(diff(x))))]
# mean-center and scale by sd
X <- scale(X)

# Get folds
fold <- GetFolds(paste0(dataPath, "cv_partitions/", dataSet, "_partitions.txt"))
nFolds <- length(fold)

print(paste0("Evaluting Dataset: ", dataSet))
cat("\n")

for (m in classifiers) {
  # Parameter tuning
  if (m == "rf-bag") {
    replace <- T
  } else if (m == "rf-subsample") {
    replace <- F
  }
  
  # Control for different number of feature selection
  if (p < 5) {
    mtrys <- 1:p
  } else {
    mtrys <- ceiling(p^c(1 / 4, 1 / 2, 3 / 4, 1))
    print(paste0("Mtrys: ", mtrys))
  }
  
  if (n >= 1000) {
    nodesize <- ceiling(n * 0.002)
  } else {
    nodesize <- 1
  }
  
  params[[dataSet]][[m]] <- list(replace = replace, mtrys = mtrys, nodesize = nodesize)
  
  size <- length(mtrys)
  OOBErrors <- matrix(as.double(rep(NA, size)), ncol = nFolds, nrow = size)
  testErrors <- matrix(as.double(rep(NA, size)), ncol = nFolds, nrow = size)
  
  print(paste0("evaluating model: ", m))
  for (fold.idx in seq.int(nFolds)) {
    print(paste0("fitting fold: ", fold.idx))
    
    data <- splitData(X, Y, fold, fold.idx)
    
    for (mtrys.idx in seq.int(length(mtrys))) {
      model <- randomForest(data$X.train, data$y.train, 
                            mtry = mtrys[mtrys.idx], 
                            replace = replace, 
                            nodesize = nodesize)
      
      OOBErrors[mtrys.idx, fold.idx] <- model$err.rate[, 1][length(model$err.rate[, 1])]
      testErrors[mtrys.idx, fold.idx] <- computePredictions(model, data$X.test, data$y.test)
    }
  }
  
  OOBError[[dataSet]][[m]] <- OOBErrors
  testError[[dataSet]][[m]] <- testErrors
}

save(OOBError, testError, file = paste0(rerfPath, "RandomerForest/R/Result/2018.06.26/", dataSet, "_2018_06_26.RData"))
