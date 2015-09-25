#include packages
library("date", lib.loc="~/R/win-library/3.1")
library("lattice", lib.loc="C:/Program Files/R/R-3.1.1/library")
library("forecast", lib.loc="~/R/win-library/3.1")
library("XLConnect", lib.loc="~/R/win-library/3.1")
library("gdata", lib.loc="~/R/win-library/3.1")
library("quantreg", lib.loc="~/R/win-library/3.1")
library("corrgram", lib.loc="~/R/win-library/3.1")
library("splines", lib.loc="~/R/win-library/3.1")
library("plyr", lib.loc="~/R/win-library/3.1")

#read data

dat= read.csv("C:\\Users\\jonfar\\Desktop\\wo.csv")

train2 = data.frame(train1,dt=strptime(as.character(train1$DATETIME),"%m/%d/%Y %H:%M"),load=train1$LOAD,num=1:56208)


train3_2 = train2[,8:35]
train3 = data.frame(train3_2,load=train3_2$load)
#train4 <-train3[35065:90528,]

#make timeseries
listts1 = lapply(train3, function(x) {ts(x, frequency=24, start=c(1,1))})
plot.ts(listts1[[24]])

#attach timeseries list
#attach(listts1)
attach(train3)
plot(w2,load,xlab="Temperature",ylab="Load",type="n")
points(w2,load,cex = .75)
X = model.matrix(load~bs(w2,df=10))
taus <- c(0.10,0.20,0.50,0.80,0.90)
for( i in 1:length(taus)){fit<-rq(load~bs(w2,df=10),tau=taus[i])
                       temp.fit <- X %*% fit$coef 
                       lines(w2,temp.fit,col="red")
}
summary(fit)



"""
Need to generate forecasts of temperature
Let's take the average temperature for each hour of the year
"""

train3$mdh <- strftime(train3$dt, format="%m/%d/%H")
train3$m <- strftime(train3$dt, format="%m")

# calculate late 
tempf1_0=aggregate(w1~mdh,data=subset(train3),mean)
tempf2_0=aggregate(w19~mdh,data=subset(train3),mean)

fcst = cbind(tempf1_0,tempf2_0$w19)
colnames(fcst)<-c("MDH","F1","F2")

#target month
fcst0 = subset(fcst, "06/01/00"<= MDH <= "06/30/23")



#fit arima model
chk = auto.arima(listts1$w2,stepwise=FALSE,parallel=TRUE)

#listarima = lapply(listts1, function(x) {auto.arima(x,stepwise=FALSE,parallel=TRUE)})
arifrcst = lapply(listarima,function(x) {forecast.Arima(x,h=745)})
ariaccu = lapply(arifrcst,accuracy)
dfari <- data.frame(matrix(unlist(ariaccu), nrow=25, byrow=T))
tempnames = c("me","rmse","mae","mpe","mape","mase","acf1")
names(dfari)=tempnames
dfari2 = data.frame(modtype = rep("arima",25),var=names(ariaccu),dfari)

#fit ETS model
listets = lapply(listts1, ets)
etsfrcst = lapply(listets,function(x){forecast.ets(x,h=745)})
etsaccu = lapply(etsfrcst,accuracy)
dfets <- data.frame(matrix(unlist(etsaccu), nrow=25, byrow=T))
names(dfets)=tempnames
dfets2 = data.frame(modtype = rep("ets",25),var=names(etsaccu),dfets)

#combine arima and ets accuracy
dfcombo = rbind(dfari2,dfets2)
dfcombo2 <- dfcombo[order(dfcombo$mape),]

#check forecasts graphically
sapply(arifrcst,plot.forecast)
sapply(etsfrcst,plot.forecast)

#check correlation between load and weather
cori1 = cor(train3_2)
corrgram(cori1, order=TRUE, lower.panel=panel.pts,
         upper.panel=panel.pie, text.panel=panel.txt,
         main="cori")
cori2 = as.data.frame(cori1)
cori3 = as.vector(cori2[25,])
cori3 = cori3[order(cori3)]
#w10 is mostly closely correlated. chose w10
#get plots of forecast for ets w10 and arima w8
plot.forecast(arifrcst[[8]])
plot.forecast(etsfrcst[[10]])
#going with etsw10


selts1 = etsfrcst$w10
attach(selts1)
dat1 = data.frame(tempf=as.vector(fitted),tempo=as.vector(selts1$x),num=1:nrow(as.data.frame(fitted)))
dat2 = data.frame(tempf=rep(NA,nrow(as.data.frame(mean))),tempo=as.vector(mean),num=1:nrow(as.data.frame(mean)))
#prepare dataset to run percentile regression
dat3 = rbind(dat1,dat2)
#add datetime
dt1 = data.frame(dt=train3_2$dt)
dt2 = data.frame(dt=seq(dt1[nrow(dt1),1],by=3600,length.out=746))
dt2_2 = data.frame(dt=dt2[2:nrow(dt2),])
dt3=rbind(dt1,dt2_2)

#dat3_2 = cbind(dat3,dt3,day=weekdays(dt3$dt),hour=as.POSIXlt(dt3$dt)$hour,sun= (dat3_2$day=="Sunday")
#               ,mon= (dat3_2$day=="Monday"),tue= (dat3_2$day=="Tuesday"),wed= (dat3_2$day=="Wednesday")
#              ,thu= (dat3_2$day=="Thursday"),fri= (dat3_2$day=="Friday"),sat= (dat3_2$day=="Saturday"))

#add weekday and hour
dat3_2 = cbind(dat3,dt3,day=weekdays(dt3$dt),hour=as.POSIXlt(dt3$dt)$hour,weekday= (dat3_2$day=="Monday") | 
                 dat3_2$day=="Tuesday"|dat3_2$day=="Wednesday"|dat3_2$day=="Thursday"|
                 dat3_2$day=="Friday")

dat4 = data.frame(intercept=rep(1,nrow(dat3_2)),dat3_2,temposq=dat3_2$tempo^2,tempocb=dat3_2$tempo^3,tempnum=dat3_2$tempo*dat3_2$num)
dat_ld1 = rbind(load=data.frame(load=train3$load),data.frame(load=rep(NA,nrow(as.data.frame(selts1$mean)))))
dat5 = cbind(dat4,dat_ld1)


#idea: plot load versus temp vars
#corrologram: will view all variables and their relationships

#regress load with temp

attach(dat5)
plot(tempf,load)
plot(tempnum,load)
rq1 = rq(load~tempo+num+temposq+tempocb+tempnum+weekday+hour,tau=seq(0.01, 0.99, 0.01), dat5)

#fit values
mat1 = as.matrix(dat5[c("intercept","tempo", "num" ,"temposq", "tempocb" ,"tempnum","weekday","hour")])
mat2 = rq1$coefficients
mat3 = as.data.frame(mat1 %*% mat2)

#export data to csv
write.table(mat3, "C:\\Users\\ankgar\\Documents\\projects\\r\\load\\task5\\L5-template-TB2.csv", sep=",")

#random checks
chkld1 = mat3[1:744,"tau= 0.50"]
chkld2 = train3$load

plot(chkld1, chkld2)

chkld_df = read.csv("C:\\Users\\ankgar\\Documents\\projects\\r\\L4-template-TB1.csv")
chkld3 = chkld_df$X0.5

#we need to come up with a metric to test among/across models
#method 1: Pinball loss function based quantile forecasts for the entire period
#method 2: Pinball loss function based on quantile forecasts for the "out-of-sample" period

