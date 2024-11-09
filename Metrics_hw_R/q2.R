##part1
# Because we omitted some variables，which hide in the error term. And this may result in the assumption that the expectation of ui equals  0 fails.

##part2
nonlr = nls(logY~ (-1/(rho))*log(K^(-rho)+L^(-rho)), data = ps1data, start = c( rho = 1 ))
summary(nonlr)


##part3
#I will choose Euiz1i=Euiz2i=0. E[yi+(1/rho)*log(Ki^{-\rho}+Li^{-rho})z1i]=0 and E[yi+(1/rho)*log(Ki^{-\rho}+Li^{-rho})z2i]=0
##part4
g1 <- function(rho,ps1data) {
  m1 <- ((ps1data[,6]+(1/(rho))*log(ps1data[,2]^(-rho)+ps1data[,3]^(-rho)))*ps1data[,4])
  m2 <- ((ps1data[,6]+(1/(rho))*log(ps1data[,2]^(-rho)+ps1data[,3]^(-rho)))*ps1data[,5])
  f <- cbind(m1,m2)
  return(f)
}
diag_mat = diag(2)
library(gmm)
gmmreg = gmm (g1 , ps1data,c(rho=1),wmatrix=c("ident"))
summary(gmmreg)
rhohat=coefficients(gmmreg)


##part5
Wn = solve(var(g1(rhohat,ps1data)))
print (Wn)


##part6
gmmnew = gmm (g1 , ps1data, c(rho=1) , weightsMatrix = Wn)
summary(gmmnew)
#the standard error is 2.4400e-01

##part7
gmmregopt = gmm (g1 , ps1data, c(rho=1) ,wmatrix = c("optimal"))
summary(gmmregopt)
#the p_value is 0.045803. We want to know whether our estimator is significant and if there is some problem with our model.