library(tidyverse)
library(data.table)

# list all files

setwd("~/ResearchCode/BankRunData")

# first read in control file
read.csv("bankRunParametersInit.csv") -> control

list.files()[grepl("Endogenous",list.files())] -> endoList
list.files()[grepl("Exogenous",list.files())] -> exoList
list.files()[grepl("Results",list.files())] -> resultList

endoDatList <- list()
exoDatList <- list()
resultDatList <- list()

for (el in endoList){
  read.csv(el,header=FALSE) -> endoDatList[[length(endoDatList)+1]]
}

for (el in exoList){
  read.csv(el,header=FALSE) -> exoDatList[[length(exoDatList)+1]]
}

for (el in resultList){
  read.csv(el,header=FALSE) -> resultDatList[[length(resultDatList)+1]]
}

rbindlist(endoDatList) -> endogenousDat
rbindlist(exoDatList) -> exogenousDat
rbindlist(resultDatList) -> resultDat

# now add names
c("key","agent","exogenous","deposit","tick","vault") -> names(exogenousDat)

c("key","agent","exogenous","deposit","tick","valt","wdProb","stayProb") -> names(endogenousDat)

c("key","result") -> names(resultDat)

table(resultDat$result) / nrow(resultDat)

# plot exogenous vs endogenous withdrawals

exogenousDat %>% group_by(key) %>% summarise(exoCnt=n()) -> exoWD
endogenousDat %>% group_by(key) %>% summarise(endoCnt=n()) -> endoWD

merge(exoWD,endoWD,by="key",all.x=TRUE) -> jointDat
jointDat$endoCnt <- coalesce(jointDat$endoCnt,0)

merge(jointDat,resultDat,by="key") -> finDat

ggplot(data=finDat) + geom_point(aes(x=exoCnt,y=endoCnt,color=result))
