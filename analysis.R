library(tidyverse)
library(data.table)
# list all files

list.files("../BankRunData/") -> allFi

resultsList <- list()

for (el in allFi[grepl("Results",allFi)]){
  read.csv(el) -> resultsList[[length(resultsList)+1]]
}
rbindlist()
