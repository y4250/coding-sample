*****ps5 yw4250*****
*****question 1
clear all
set more off
use "/Users/leslie/Desktop/statafile/ps5/TeachingRatings.dta"
***(a)
reg course_eval beauty female minority nnenglish intro onecredit age
matrix b_hat=[_b[_cons]\_b[beauty]\_b[female]\_b[minority]\_b[nnenglish]\_b[intro]\_b[onecredit]\_b[age]]
***mat list b_hat
***(b)
***(c)
matrix Rprime=(0,1,0,0,0,0,0,0\0,0,1,0,0,0,0,0\0,0,0,1,0,0,0,0\0,0,0,0,1,0,0,0\0,0,0,0,0,1,0,0\0,0,0,0,0,0,1,0\0,0,0,0,0,0,0,1)
matrix R=Rprime'
matlist Rprime
matrix q=(0\0\0\0\0\0\0)
***matlist q
***(d)
gen cons=1
mkmat cons beauty female minority nnenglish intro onecredit age, matrix(X)
mkmat course_eval, matrix(Y)
matrix Xprime=X'
gen s_2 = 0.263955179 
***display s_2
matrix m_hat=(Rprime * b_hat) - q
matrix m_hat_prime=m_hat'
***matlist m_hat
***matlist m_hat_prime
matrix middle_nos= invsym(Rprime*(invsym(Xprime*X))*R)
matrix middle=middle_nos*(1/0.263955179)
matrix F=(m_hat_prime*middle*m_hat)/7
matlist F


*****question 4
clear all
set more off
use "/Users/leslie/Desktop/statafile/ps5/caschool.dta"
reg testscr str el_pct meal_pct
***(i)
matrix b_hat=[_b[_cons]\_b[str]\_b[el_pct]\_b[meal_pct]]
matrix Rprime=(0,1,-1,0)
***matlist Rprime
matrix q=(0)
***(ii)
***(iii)
clear all
set more off
use "/Users/leslie/Desktop/statafile/ps5/caschool.dta"
reg testscr str el_pct meal_pct
matrix b_hat=[_b[_cons]\_b[str]\_b[el_pct]\_b[meal_pct]]
matrix Rprime=(0,1,0,0\0,0,1,0\0,0,0,1)
matrix R=Rprime'
matrix q=(0\0\0)
gen cons=1
mkmat cons str el_pct meal_pct,matrix(X)
matrix Xprime=X'
gen s_2=82.4478368
matrix m_hat=(Rprime * b_hat) - q
matrix m_hat_prime=m_hat'
***matlist m_hat
***matlist m_hat_prime
matrix middle_nos= invsym(Rprime*(invsym(Xprime*X))*R)
matrix middle=middle_nos*(1/82.4478368)
matrix F=(m_hat_prime*middle*m_hat)/3
matlist F
***(iv)
test str el_pct meal_pct













