install.packages("glmnet")
library(glmnet)
install.packages("msgps")
library(msgps)
install.packages("plasso")
library(plasso)
#data preparing 
data = data.frame(pset7)
names(data)[1] = 'Y'
names(data)[2] = 'X1'
names(data)[3] = 'X2'
names(data)[4] = 'X3'
names(data)[5] = 'X4'
names(data)[6] = 'X5'
names(data)[7] = 'X6'
names(data)[8] = 'X7'
names(data)[9] = 'X8'
names(data)[10] = 'X9'
names(data)[11] = 'X10'

#generate the 2-way interactions

comb2 <- combn(2:11,2)
for (i in 2:11){
  vnew = c(i,i)
  comb2 = cbind(comb2,vnew)
}
for (i in 1:55){
  data = cbind(data,data[comb2[1,i]]*data[comb2[2,i]])
}

#generate the 3-way interactions
comb3 = combn(2:11,3)
for (i in 2:11){
  for (j in 2:11){
    vnew1 = c(i,j,j)
    comb3= cbind(comb3,vnew1)
  }
}
for (i in 1:220){
  data = cbind(data,data[comb3[1,i]]*data[comb3[2,i]]*data[comb3[3,i]])
}
####################question1
#run the lasso
x_train_matrix <- as.matrix(data[,2:286])
y_train_vector =  as.matrix(data[,1])
lasso_model <- cv.glmnet(x_train_matrix, y_train_vector,  nfolds = 5 , type.measure = "mse")
plot(lasso_model)
#get lambda
lambda_values <- lasso_model$lambda
matrixlambda = matrix(lambda_values)
cvm = lasso_model$cvm
matrixcvm = matrix(cvm)
mincvm = min(matrixcvm)
mincvmindex = which.min(matrixcvm)
lst_lam = matrixlambda[mincvmindex] 
nonzero = lasso_model$nzero
matrixnonzero = matrix(nonzero)
numbnzero = matrixnonzero[mincvmindex]
#show the result
print(paste("Minimum cv error:", mincvm))
print(paste("The lambda:",lst_lam))
print(paste("The number of non-zero coefficient covariables:", numbnzero))

####################question2
#adaptive lasso
y_train_vector= as.vector(y_train_vector)
adaptive_lasso <- msgps(x_train_matrix, y_train_vector, penalty = "alasso")
numad <- sum(coef(adaptive_lasso)[,4] != 0) - 1
print(paste("Using BIC criteria, the number of non-zero coefficients under adaptive Lasso is", numad))


####################question3
plasso = cv.plasso(x_train_matrix, y_train_vector,kf=5)
nump <- sum(plasso$coef_min_pl !=0) - 1
print(paste("The number of non-zero coefficients covarites is",nump))

