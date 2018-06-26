# evaluate classifiers on benchmark datasets

rm(list = ls())
options(scipen = 999)

# Parameters
rerfPath <- "~/work/jaewon"
dataPath <- "~/work/jaewon/data/uci/processed/"
library(randomForest)
library(dummies)
source(paste0(rerfPath, "R/Code/Utils/RerFEval.R"))
# source(paste0(rerfPath, "R/Code/Utils/GetCatMap.R"))
source(paste0(rerfPath, "R/Code/Utils/GetFolds.R"))

classifiers <- c("rf-bag", "rf-subsample")
nCl <- length(classifiers)

nTrees <- 500L
supervised <- 0
num.cores <- 24L
seed <- 20180621L

set.seed(seed = seed)

testError <- list()
OOBError <- list()
trainTime <- list()
testTime <- list()
bestIdx <- list()
params <- list()

dataSets <- read.table(paste0(dataPath, "names.txt"))[[1]]
# dataSet <- dataset

dataSet <- "abalone"

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

cat("\n")
trainIdx <- unlist(fold[-1])
testIdx <- fold[[1]]

X_train <- X[trainIdx, ]
X_test <- X[testIdx, ]

# Y <- factor(Y)
Y_train <- factor(Y[trainIdx])
Y_test <- factor(Y[testIdx])

labels.train <- unique(Y_train)
labels.test <- unique(Y_test)

levs <- c(labels.train, labels.test[!(labels.test %in% labels.train)])

Y_train <- factor(Y_train)
Y_test <- factor(Y[testIdx], levels = levs)

print(paste0("Training dataset ", dataSet))

for (m in classifiers) {
  # Parameter tuning
  if (m == "rf-bag") {
    replace <- T
  }
  else if (m == "rf-subsample") {
    replace <- F
  }

  # Control for different number of feature selection
  if (p < 5) {
    mtry <- 1:p
  }
  else {
    mtry <- ceiling(p^c(1 / 4, 1 / 2, 3 / 4, 1))
  }

  if (n >= 1000) {
    nodesize <- ceiling(n * 0.002)
  }
  else {
    nodesize <- 1
  }

  params[[dataSet]][[m]] <- list(replace = replace, mtry = mtry)

  size <- length(mtry)
  OOBErrors <- vector("numeric", size)
  # testError <- vector("numeric", size)

  idx <- 1

  print(paste0("evaluating model ", m))
  for (p in params[[dataSet]][[m]]$mtry) {
    res <- randomForest(X, factor(Y), replace = replace, nodesize = nodesize)
    OOBErrors[idx] <- mean(res$err.rate[, 1])
    idx <- idx + 1
  }
  print(paste0(m, " minimum OOB error: ", min(OOBErrors)))

  OOBError[[dataSet]][[m]] <- append(OOBError[[dataSet]][[m]], OOBErrors)
  save(OOBError, file = paste0(rerfPath, "RandomerForest/R/Results/2018.06.26/", dataSet, "_2018_06_26.RData"))
}
