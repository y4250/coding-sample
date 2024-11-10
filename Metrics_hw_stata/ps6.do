*****ps6  yw4250*****
*****question 2
clear all
set more off
use "/Users/leslie/Desktop/statafile/ps6/MRW1992.dta"
keep if N==1
gen ldiff8560= ln(Y85)-ln(Y60)
gen ly60=ln(Y60)
gen linvest=ln(invest/100)
gen techanddep=0.05
gen lnplustd=ln(0.05+pop_growth/100)
gen lschool=ln(school)
regress ldiff8560 ly60 linvest lnplustd lschool,r
constraint 1 linvest+lnplustd+lschool=0
cnsreg ldiff8560 ly60 linvest lnplustd lschool,r constraint(1)
***(c)
clear all
set more off
use "/Users/leslie/Desktop/statafile/ps6/MRW1992.dta"
keep if N==1
gen ldiff8560= ln(Y85)-ln(Y60)
gen ly60=ln(Y60)
gen linvest=ln(invest/100)
gen techanddep=0.05
gen lnplustd=ln(0.05+pop_growth/100)
gen lschool=ln(school)
regress ldiff8560 ly60 linvest lnplustd lschool,r
test linvest+lnplustd+lschool=0
*****question 3
clear all
set more off
use "/Users/leslie/Desktop/statafile/ps6/cps09mar_updated with exper (age minus educ minus 6).dta"
keep if female==0 & hisp==1 & race==1
***(a)
regress Lwage education exper exper2over100 mar1 mar2 mar3 mar4 mar5 mar6
***(b)
constraint 1 mar1=mar4
constraint 2 mar5=mar6
cnsreg Lwage education exper exper2over100 mar1 mar2 mar3 mar4 mar5 mar6, c(1-2)
*****question 5
clear all 
set more off
use "/Users/leslie/Desktop/statafile/ps6/caschool.dta"
***(a)
regress testscr str el_pct meal_pct comp_stu
***(b)
reg testscr str el_pct meal_pct comp_stu,r
***(c)
matrix b_hat=[_b[_cons]\_b[str]\_b[el_pct]\_b[meal_pct]\_b[comp_stu]]
gen cons=1
mkmat cons str el_pct meal_pct comp_stu, matrix(X)
mkmat testscr,matrix(y)
matrix ep_hat=y-X*b_hat
***matlist ep_hat
matrix diaep_hat=diag(ep_hat)
***matlist diaep_hat
matrix diaep_hat2=diaep_hat*diaep_hat
matrix estiV=(420/415)*(syminv(X'*X))*X'*diaep_hat2*X*(syminv(X'*X))
***matlist estiV
di .2789508*.2789508-.0778135
