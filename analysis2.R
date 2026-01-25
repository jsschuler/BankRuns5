library(tidyverse)
library(data.table)

# list all files

setwd("~/ResearchCode/BankRunDataPartial")

# first read in control file
read.csv("bankRunParametersInit.csv") -> control
names(control) <- c("seed1","iteration","graphParams1","graphParams2","reserveRatio","depositInsuranceQuantile","seed2","key")
#read.csv("supplemental.csv") -> auxil

#merge(control,auxil,by="key") -> control
list.files()[grepl("Endogenous",list.files())] -> endoList
list.files()[grepl("Exogenous",list.files())] -> exoList
list.files()[grepl("Results",list.files())] -> resultList
list.files()[grepl("agents",list.files())] -> agentsList

endoDatList <- list()
exoDatList <- list()
resultDatList <- list()
agentsDatList <- list()
for (el in endoList){
  read.csv(el,header=FALSE) -> endoDatList[[length(endoDatList)+1]]
}

for (el in exoList){
  read.csv(el,header=FALSE) -> exoDatList[[length(exoDatList)+1]]
}

for (el in resultList){
  read.csv(el,header=FALSE) -> resultDatList[[length(resultDatList)+1]]
}

for (el in agentsList){
  read.csv(el,header=FALSE) -> agentsDatList[[length(agentsDatList)+1]]
}


rbindlist(endoDatList) -> endogenousDat
rbindlist(exoDatList) -> exogenousDat
rbindlist(resultDatList) -> resultDat
rbindlist(agentsDatList) -> agentsDat
nrow(resultDat)
# now add names
c("key","agent","exogenous","deposit","tick","vault") -> names(exogenousDat)

c("key","agent","withdraw","deposit","tick","valt","wdProb","stayProb") -> names(endogenousDat)

c("key","result") -> names(resultDat)

c("key","idx","deposit") -> names(agentsDat) 
nrow(resultDat)

# Let's understand the agent deposit distribution

agentsDat %>% group_by(key) %>% summarise(totDeposit=sum(deposit)) -> totDeposit
totDeposit$origVault <- .25*totDeposit$totDeposit
merge(agentsDat,totDeposit,by="key") -> agentsDeposits

agentsDeposits$vaultPortion <- agentsDeposits$deposit / agentsDeposits$origVault
agentsDeposits$depPortion <- agentsDeposits$deposit / agentsDeposits$totDeposit
round(quantile(agentsDeposits$vaultPortion,c(0,0.01,.05,.25,.5,.75,.95,.99,1)),10)
# plot exogenous vs endogenous withdrawals

exogenousDat %>% group_by(key) %>% summarise(exoCnt=n()) -> exoWD
endogenousDat %>%  transform(withdraw=(withdraw=="true")) %>% group_by(key) %>% summarise(endoCnt=sum(withdraw)) -> endoWD

merge(exoWD,endoWD,by="key",all=TRUE) -> jointDat
jointDat$endoCnt <- coalesce(jointDat$endoCnt,0)

merge(jointDat,resultDat,by="key") -> finDat

merge(control,finDat,by="key") -> finDat

# check 
endogenousDat %>% group_by(key) %>% summarise(vault=min(valt)) %>% 
  transform(fail2=if_else(vault <= 0,TRUE,FALSE)) -> tst

exogenousDat %>% group_by(key) %>% summarise(minVault=min(vault),maxVault=max(vault)) -> exogSmry

#table(finDat$theta,finDat$result)

table(finDat$result)
ggplot(data=finDat) + geom_histogram(aes(x=exoCnt,fill=result))
ggplot(data=finDat) + geom_point(aes(x=exoCnt,y=endoCnt,color=result))

finDat %>% group_by(result,exoCnt,endoCnt) %>% summarise(cnt=n()) %>% arrange(exoCnt,endoCnt)
