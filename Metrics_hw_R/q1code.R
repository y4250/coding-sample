if (!requireNamespace("matrixStats", quietly = TRUE)) {
  install.packages("matrixStats")
}
library(matrixStats)
# Generate some sample data
set.seed(1234)
x <- runif(1000, min = 0, max = 1)
seq = x
ynum = c()
ynew = c()
a_pred0 = c()
z_pred1 = c()
for (i in 1:100) {
for (i in x){
  y = rnorm(n = 1, mean = i*( 1-i ) , sd = (2*i-1)^(2))
  ynum = c(ynum,y)
}
  data = data.frame(ynum,x)
  # Perform NW
  loess_fit1 <- loess(ynum ~ x,degree=0)
  # Perform local linear regression
  loess_fit2 <- loess(ynum ~ x,degree=1)
  # Predict values
  a_pred <- predict(loess_fit1, newdata=data.frame(x=seq))
  z_pred <- predict(loess_fit2, newdata=data.frame(x=seq))
  a_pred0 = cbind(a_pred0,a_pred)
  z_pred1 = cbind(z_pred1,z_pred)
  ynum = c()
  ynew = c()
  
}
row_sums0 <- rowSums(a_pred0)
row_sums1 <- rowSums(z_pred1)
row_sums0d = row_sums0 /100
row_sums1d = row_sums1 /100
# plot the Mn(x)
plot (seq,row_sums0d, main="Mn(x) for NW", xlab = "x", ylab = "y")
plot (seq,row_sums1d, main="Mn(x) for LL", xlab = "x", ylab = "y")
apred_new = a_pred0
zpred_new = z_pred1
rowsum_ma0=c()
rowsum_ma1=c()
for (i in 1:100){
  rowsum_ma0=cbind(rowsum_ma0,row_sums0d)
  rowsum_ma1=cbind(rowsum_ma1,row_sums1d)
}
###demean
apred_newdmean = apred_new - rowsum_ma0
zpred_newdmean = zpred_new - rowsum_ma1
###calculate the variance
arow_vars <- rowVars(apred_newdmean)
zrow_vars <- rowVars(zpred_newdmean)
##plot the variance
plot(seq,arow_vars,main="Var for NW", xlab = "x", ylab = "y")
plot(seq,zrow_vars,main="Var for LL", xlab = "x", ylab = "y")
# Plot the results
plot(seq, a_pred , main = "Local Linear Regression", xlab = "x", ylab = "y")
plot(seq, z_pred , main = "Local Linear Regression", xlab = "x", ylab = "y")