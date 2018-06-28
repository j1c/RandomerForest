getCatDatasets <- function(path) {
  dataset.names <- as.vector(read.csv(file = paste0(path, 'names.txt'), header = F)[[1]])
  cat.datasets <- list.files(paste0(path, 'categorical_map/'))
  
  dataset.category <- vector(mode="character", length = length(dataset.names))
  
  for (idx in seq.int(length(dataset.names))) {
    if (any(grepl(paste0(dataset.names[idx],'_'), cat.datasets))) {
      print(paste0(dataset.names[idx]))
      dataset.category[idx] <- 'categorical'
      
      if (dataset.names[idx] == 'spect') {
        dataset.category[idx] <- 'numeric'
      }
    } else {
      dataset.category[idx] <- 'numeric'
    }
  }
  
  return(dataset.category)
}

path <- './Data/uci/processed/'

cats <- getCatDatasets(path)
