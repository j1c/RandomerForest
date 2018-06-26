#' Rerf evaluate
#'
#' #' Evaluate Rerf models for several values of mat.options[[2]] and mat.options[[4]]
#'
#' @param Xtrain an n sample by d feature matrix (preferable) or data frame that will be used to train a forest.
#' @param Ytrain an n length vector of class labels
#' @param Xtest an n sample by d feature matrix (preferable) or data frame that will be used to test a forest.
#' @param Ytest an n length vector of class labels
#' @param params a list of parameters used in the various rerf functions
#' @param store.predictions ????? (store.predictions=FALSE)
#' @param timeout specify max amount of time to run OOBPredict before timing out. This is needed because OOBPredict sometimes hangs and can't be killed. (timeout = Inf)
#'
#' @return something ?????
#'
#' @author Jaewon Chung, j1c@jhu.edu, James, jbrowne6@jhu.edu and Tyler
#'
#' @importFrom AUC auc roc
#' @importFrom compiler setCompilerOptions cmpfun
#'

RerFEval <- function(Xtrain, Ytrain, Xtest, Ytest, ...) {
  # Handle arguments
  args <- list(...)
  params <- argParser(args)
  set.seed(params$seed)
  
  # params <- list(
  #   trees = 500L, random.matrix = "binary", d = round(sqrt(ncol(Xtrain))),
  #   sparsity = 1 / ncol(Xtrain), prob = 0.5, rotate = F, rank.transform = F,
  #   min.parent = 2L, max.depth = ceiling(log2(nrow(X))), bagging = 1 / exp(1), store.oob = T,
  #   store.impurity = F, replacement = T, stratify = T, num.cores = 1L,
  #   seed = 1L, cat.map = NULL, iw = NULL, ih = NULL, patch.min = NULL, patch.max = NULL
  # )
  
  labels.train <- unique(Ytrain)
  labels.test <- unique(Ytest)
  labels.all <- unique(c(labels.train, labels.test))

  nClasses <- length(labels.all)
}

train <- 


argParser <- function(args) {
  
  if (!("rotate" %in% params.names)) {
    params$rotate <- F
  }
  
  if (!("cat.map" %in% params.names)) {
    params$cat.map <- NULL
  }
  
  if (is.null(params$cat.map)) {
    p <- ncol(Xtrain)
  } else {
    if (!params$rotate) {
      p <- params$cat.map[[1L]][1L] - 1L + length(params$cat.map)
    } else {
      p <- ncol(Xtrain)
      params$cat.map <- NULL
    }
  }
  
  if (!("trees" %in% params.names)) {
    params$trees <- 500L
  }
  
  if (!("random.matrix" %in% params.names)) {
    params$random.matrix <- "binary"
  }
  
  if (!("d" %in% params.names)) {
    params$d <- round(sqrt(p))
  }
  
  if (!("sparsity" %in% params.names)) {
    if (params$random.matrix == "binary" || params$random.matrix == "continuous") {
      params$sparsity <- 1 / p
    } else if (params$random.matrix == "frc" || params$random.matrix == "frcn") {
      params$sparsity <- 2
    } else if (params$random.matrix == "poisson") {
      params$sparsity <- 1
    } else if (params$random.matrix == "rf") {
      params$sparsity <- 1
    }
  }
  
  if (!("rank.transform" %in% params.names)) {
    params$rank.transform <- F
  }
  
  if (!("min.parent" %in% params.names)) {
    params$min.parent <- 2L
  }
  
  if (!("max.depth" %in% params.names)) {
    params$max.depth <- "inf"
  }
  
  if (!("bagging" %in% params.names)) {
    params$bagging <- 1 / exp(1)
  }
  
  if (!("store.oob" %in% params.names)) {
    params$store.oob <- T
  }
  
  if (!("store.impurity" %in% params.names)) {
    params$store.impurity <- F
  }
  
  if (!("replacement" %in% params.names)) {
    params$replacement <- T
  }
  
  if (!("stratify" %in% params.names)) {
    params$stratify <- T
  }
  
  if (!("num.cores" %in% params.names)) {
    params$num.cores <- 1L
  }
  
  if (!("seed" %in% params.names)) {
    params$seed <- 1L
  }
  set.seed(params$seed)
  
  # if (!("iw" %in% params.names)) {
  #   params$iw <- NULL
  # }
  # 
  # if (!("ih" %in% params.names)) {
  #   params$ih <- NULL
  # }
  
  if (!("patch.min" %in% params.names)) {
    params$patch.min <- NULL
  }
  
  if (!("patch.max" %in% params.names)) {
    params$patch.max <- NULL
  }
  
  if (!("prob" %in% params.names)) {
    params$prob <- 0.5
  }
}