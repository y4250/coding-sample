if (!requireNamespace("matrixStats", quietly = TRUE)) {
  install.packages("matrixStats")
}
library(matrixStats)
install.packages("Matching")
update.packages("Matching")
library(Matching)
A = filpoll[,1]
C = filpoll[,2]
D = filpoll[,3]
y = filpoll[,4]
data=data.frame(A,C,D,y)
##ps5
#part(1)
##I will include both A and C. Since both variables are related with the probability of accepting the treatment. Some older people may not drive their cars a lot so they may not install the filter. And Some cars are too old and will be scrapped, so these cars will also not install filters.
#part(2)
##ols
olsp <- lm(D ~ A+C , data=data)
summary(olsp)
p = predict(olsp, type = "response")
##nonpara
loess_fit1 <- loess(D ~ A+C,degree=1)
summary(loess_fit1)
np = predict(loess_fit1, type = "response")
propensityres = data.frame(p,np)
#These propensity scores are the probability of the observation enterring the treatment group.
##combine data
npinverse=1/np
data=data.frame(A,C,D,y,np,p)
#part(3)
##IPW method
sumd1=0
for (i in 1:5000){
  sumd1=sumd1+data[i,3]*(1/data[i,5])
}
sumd0=0
for (i in 1:5000){
  sumd0=sumd0+(1-data[i,3])*(1/(1-data[i,5]))
}
data$adj1 = NA
for (i in 1:5000){
  data[i,7]=((data[i,3])*(1/data[i,5])*data[i,4])/sumd1+((1-data[i,3])*(1/(1-data[i,5]))*data[i,4])/sumd0
}
sumtreat=0
sumcontrol=0
for (i in 1:5000){
  sumtreat= sumtreat+data[i,7]*data[i,3]
  sumcontrol = sumcontrol+data[i,7]*(1-data[i,3])
}
IPWest= sumtreat-sumcontrol
##OLS
atelosyuan=lm(y~ D+A+C,data=data)

ateols = lm(y ~ D+A+C+D*A+D*C,data=data)
coefficients <- coef(ateols)
coed = coefficients["D"]
coea = coefficients["A"]
coec = coefficients["C"]
coead = -0.0004852057
coecd = -0.0021933691 
##doubly robust
data$mux1 = 0
data$mux0 = 0
for (i in 1:5000){
  data[i,8] = coed+coead*data[i,1]+coecd*data[i,2]+coea*data[i,1]+coec*data[i,2]+1.172430
  data[i,9] = coea*data[i,1]+coec*data[i,2]+1.172430
}
data$phi = 0
for (i in 1:5000){
  data[i,10]=data[i,8]-data[i,9]+(data[i,3]/data[i,6])*(data[i,4]-data[i,8])+((1-data[i,3])/(1-data[i,6]))*(data[i,4]-data[i,9])
}
atedoub=mean(data[,10])
#part(4)
#No, it is not credible in this application. Conditional on A and C, y is not independent on treatment choice. Since some other properties of the cars may also affect y.

#part(5)
#z is a good instrument if it only influences the probability of treatment and do not influence the treatment result. A satisfys these requirements and C does not meet. Since the age of the car will influence the effect of the filter.

#part(6)
data$z = 0
for (i in 1:5000){
  if (data[i,1]>40)
    data[i,11]=1
}
# The assumption is Di(C,z')\geq Di(C,z) if Ci=C.

#part(7)
propest = lm(D ~ z+C,data=data)
pnew1 = predict(propest,newdata=data.frame(z=1,C=data$C))
data$pnew0 = 0
for (i in 1:5000){
  data[i,12] = 0.5398+0.047*data[i,2]
}

data$pnew1 =pnew1
mzest = lm(y ~ z+C,data=data)
ynew1 = predict(mzest,newdata=data.frame(z=1,C=data$C))
data$ynew0 = 0
for (i in 1:5000){
  data[i,14]=0.5063-0.0031*data[i,2]
}
data$ynew1 =ynew1
data$late=0
for (i in 1:5000){
  data[i,16]=(data[i,15]-data[i,14])/(data[i,13]-data[i,12])
}
summary(data[,16])
plot(data$C,data$late)
#The LATE is about equal to -2.67. And this is the treatment effect of the compliers.
