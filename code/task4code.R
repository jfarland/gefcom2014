#include packages
library("date", lib.loc="~/R/win-library/3.1")
library("lattice", lib.loc="C:/Program Files/R/R-3.1.1/library")
library("forecast", lib.loc="~/R/win-library/3.1")
library("XLConnect", lib.loc="~/R/win-library/3.1")
library("gdata", lib.loc="~/R/win-library/3.1")
library("quantreg", lib.loc="~/R/win-library/3.1")
library("corrgram", lib.loc="~/R/win-library/3.1")

#location: C:\Users\jonfar\Documents\Research\GEFCOM2014

#read data
train1 = read.csv("C:\\Users\\jonfar\\Documents\\Research\\GEFCOM2014\\L4-train-fixed-date.csv")
train2 = data.frame(train1,dt=strptime(train1$FIXED_TIMESTAMP,"%m/%d/%Y %H:%M"),load=train1$LOAD,num=1:744)
train3_2 = train2[,5:32]
train3 = data.frame(train3_2[,1:25],load=train3_2$load)

#make timeseries
listts1 = lapply(train3, function(x) {ts(x, frequency=24, start=c(1,1))})
plot.ts(listts1[[1]])
#attach timeseries list
attach(listts1)

#fit arima model
listarima = lapply(listts1, function(x){auto.arima(x,stepwise=FALSE,parallel=TRUE)})
arifrcst = lapply(listarima,function(x){forecast.Arima(x,h=745)})
ariaccu = lapply(arifrcst,accuracy)
dfari <- data.frame(matrix(unlist(ariaccu), nrow=26, byrow=T))
tempnames = c("me","rmse","mae","mpe","mape","mase","acf1")
names(dfari)=tempnames
dfari2 = data.frame(modtype = rep("arima",26),var=names(ariaccu),dfari)

#fit ETS model
listets = lapply(listts1, ets)
etsfrcst = lapply(listets,function(x){forecast.ets(x,h=745)})
etsaccu = lapply(etsfrcst,accuracy)
dfets <- data.frame(matrix(unlist(etsaccu), nrow=26, byrow=T))
names(dfets)=tempnames
dfets2 = data.frame(modtype = rep("ets",26),var=names(etsaccu),dfets)

#combine arima and ets accuracy
dfcombo = rbind(dfari2,dfets2)
dfcombo2 <- dfcombo[order(dfcombo$mape),]

#check forecasts graphically
sapply(arifrcst,plot.forecast)
sapply(etsfrcst,plot.forecast)

#check correlation between load and weather
cori1 = cor(train3)
corrgram(cori1, order=TRUE, lower.panel=panel.pts,
         upper.panel=panel.pie, text.panel=panel.txt,
         main="cori")
cori2 = as.data.frame(cori1)
cori3 = as.vector(cori2[26,])
cori3 = cori3[order(cori3)]
#w6 is mostly closely correlated. chose w21
#get plots of forecast for ets and arima 21
plot.forecast(arifrcst[[21]])
plot.forecast(etsfrcst[[21]])
#going with etsw21


selts1 = etsfrcst$w21
attach(selts1)
dat1 = data.frame(tempf=as.vector(fitted),tempo=as.vector(x),num=1:nrow(as.data.frame(fitted)))
dat2 = data.frame(tempf=rep(NA,nrow(as.data.frame(mean))),tempo=as.vector(mean),num=1:nrow(as.data.frame(mean)))
dat3 = rbind(dat1,dat2)
dat4 = data.frame(intercept=rep(1,nrow(dat3)),dat3,temposq=dat3$tempo^2,tempocb=dat3$tempo^3,tempnum=tempo*num)
dat_ld1 = rbind(load=data.frame(load=train3$load),data.frame(load=rep(NA,nrow(as.data.frame(mean)))))
dat5 = cbind(dat4,dat_ld1)


#regress load with temp
attach(dat5)
plot(w5,load)
rq1 = rq(load~tempo+num+temposq+tempocb+tempnum,tau=seq(0.01, 0.99, 0.01))

#fit values
mat1 = as.matrix(dat5[c("intercept","tempo", "num" ,"temposq", "tempocb" ,"tempnum")])
mat2 = rq1$coefficients
mat3 = as.data.frame(mat1 %*% mat2)

#export data to csv
write.table(mat3, "C:\\Users\\ankgar\\Documents\\projects\\r\\L4-template-TB2.csv", sep=",")

#random checks
chkld1 = mat3[1:744,"tau= 0.50"]
chkld2 = train3$load

chkld_df = read.csv("C:\\Users\\ankgar\\Documents\\projects\\r\\L4-template-TB1.csv")
chkld3 = chkld_df$X0.5
