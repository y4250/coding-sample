**Yunfeng Wu(yw4250) Econometrics PS2**

***Question3
**a)
clear all
set more off
capture program drop _all
set seed 4250

program define ctl,rclass
   version 18
   syntax [,obs(integer 1)  p(real 1)  reps(integer 1)]
   drop _all
   set obs `obs'
   gen x=rbinomial(1,`p')
   gen y=x-`p'
   egen summ=sum(y)
   gen Zn=summ/(sqrt((`p')*(1-`p'))*sqrt(`obs'))
   sum Zn,meanonly
   return scalar samplemean=r(mean)
   
 end
 
simulate ybar=r(samplemean),reps(10000):ctl, obs(200) p(0.74)
histogram ybar,bin(50)  normal
***********
**b)
**case of 150 obs
clear all
set more off
set seed 4250
set obs 150
gen x=rbinomial(1,0.74)
sum x
gen x_mean= r(mean)
gen x_Var=r(Var)

display x_mean
display x_Var

**case of 100 obs
clear all
set more off
set seed 4250
set obs 100
gen y=rbinomial(1,0.74)
sum y
gen y_mean=r(mean)
gen y_Var=r(Var)

di y_mean
di y_Var

****************
***Question 4
**(a) 150 obs
clear all 
set more off
set obs 150
set seed 4250
gen x= rchi2(10)
sum x
gen x_mean=r(mean)
gen x_Var=r(Var)

di x_mean
di x_Var

**(b) 300 obs
clear all 
set more off
set obs 300
set seed 4250
gen x= rchi2(10)
sum x
gen x_mean=r(mean)
gen x_Var=r(Var)

di x_mean
di x_Var

** 3000 obs
clear all 
set more off
set obs 3000
set seed 4250
gen x= rchi2(10)
sum x
gen x_mean=r(mean)
gen x_Var=r(Var)

di x_mean
di x_Var

**(c)
clear all

program defin clt,rclass
  drop _all
  syntax [,obs(integer 1) reps(integer 1)]
  set obs `obs'
  gen x=rchi2(10)
  gen y=x-10
  egen summ=sum(y)
  gen Zn=summ/(sqrt(20)*sqrt(`obs'))
  sum Zn ,meanonly
  return scalar samplemean=r(mean) 

end

set more off
simulate xbar=r(samplemean),seed(4250) reps(1000):clt, obs(200)
histogram xbar,normal
