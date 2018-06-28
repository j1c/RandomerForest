
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

grabResults <- function(path) {
  fnames <- list.files(path = path, pattern = "*.RData")
  fnames.length <- length(fnames)
  
  load(paste0(path, fnames[1]))
  classifier.names <- names(testError[[1]])
  
  error.rates <- vector("list", length(classifier.names))
  names(error.rates) <- classifier.names
    
  for (classifier in classifier.names) {
    error.rates[[classifier]] <- matrix(data = rep(NA, fnames.length), ncol = 5, nrow = fnames.length)
  }
  
  for (idx in seq.int(fnames.length)) {
    data.path <- paste0(path, fnames[idx])
    load(data.path)
    dataset.name <- names(testError)
    
    for (classifier in classifier.names) {
      temp <- testError[[dataset.name]][[classifier]]
      error.rates[[classifier]][idx, ] <- apply(temp, 2, min)
    }
  }
  
  return(error.rates)
}

getDatasetCategory <- function(data.path, results.path) {
  fnames <- list.files(path = results.path, pattern = "*.RData")
  fnames.length <- length(fnames)
  dataset.category <- as.vector(read.csv(paste0(data.path, "dataset_category.txt"), header=F)[[1]])
  dataset.names <- as.vector(read.csv(paste0(data.path, "names.txt"), header=F)[[1]])
  
  for (idx in seq.int(length(dataset.names))) {
    
  }
}

computeResults <- function(path) {
  error.rates <- grabResults(path)

  classifier.names <- names(error.rates)
  classifier.length <- length(classifier.names)
  mean.error <- setNames(vector("list", classifier.length), classifier.names)
  difference.error <- setNames(vector("list", classifier.length), classifier.names)

  if (classifier.length == 2) {
    for (classifier in classifier.names) {
      error.rates[[classifier]] <- rowMeans(error.rates[[classifier]])
    }
    mean.error <- sqrt((error.rates[[1]] + error.rates[[2]]) / 2)
    difference.error <- sqrt(abs(error.rates[[1]] - error.rates[[2]])) * sign(error.rates[[1]] - error.rates[[2]])
  } else {
    print('More than two classifier is not yet supported')
    # TODO: implement pairwise comparisons for more than 2 classifiers
  }
  
  return(list(mean.error = mean.error, difference.error = difference.error))
  # plotResults(mean.error, difference.error)
}

plotResults <- function(mean.error, difference.error, data.path, categories = NULL) {
  library("ggplot2")
  
  ##
  dataset.category <- as.vector(read.csv(paste0(data.path, 'dataset_category.txt'), header=F)[[1]])
  dataset.category <- dataset.category[-24]
  dataset.category <- dataset.category[-4]
   
  df <- data.frame(mean.error, difference.error, dataset.category)
  names(df) <- c('mean', 'diff', 'category')
  df$category <- factor(df$category)
  
  fig <- ggplot(df, aes(x = mean, y = diff, color = category)) + geom_point() +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black")) +
    labs(x = expression(sqrt("Mean Error")), 
         y = expression(sqrt("Difference in Error"))) + 
    geom_hline(yintercept=0) + 
    xlim(0, 1) + 
    ylim(-.25, .25) +
    annotate("text", label = 'bold("Subsampling Better")', x = .8, y = .2, parse = T) + 
    annotate("text", label = 'bold("Subsampling Worse")', x = .8, y = -.2, parse = T) + 
    scale_color_discrete("Dataset Type") +
    ggtitle("Random Forest Package Bootstrap vs Subsampling")
  
  print(fig)
  return(fig)
}
