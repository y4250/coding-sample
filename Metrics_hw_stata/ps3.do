*****Econometrics PS3   Yunfeng Wu(yw4250)
clear all
set more off
********

 use "/Users/leslie/Desktop/statafile/ps3/caschool.dta",clear
 **load data
 
 ***(a)
 reg testscr str el_pct meal_pct
**From the result, we have TSS=152109.594,ESS=117811.294,SSR=34298.3001
**R-squared is ESS/TSS=117811.294/152109.594=0.77451587
**Adj R-squared is 1-(((1-R-squared)(n-1))/(n-k-1))=1-(((1-0.77451587)(n-1))/(n-k-1))=0.77288978
*****************
clear all
set more off
********

 use "/Users/leslie/Desktop/statafile/ps3/caschool.dta",clear
 **load data
 reg testscr enrl_tot teachers calw_pct meal_pct computer comp_stu expn_stu str avginc el_pct
 ***(b)
gen cons =1
mkmat cons enrl_tot teachers calw_pct meal_pct computer comp_stu expn_stu str avginc el_pct, matrix(X) 
mat list X
*** gen X
matrix Xtranspose = X'
*\\\mat list Xtranspose
matrix XprimeX= Xtranspose * X
matrix invXprimeX= invsym(XprimeX)

mat list invXprimeX

***(c)
matrix P=X*invXprimeX*Xtranspose
matrix M=I(420)-P

***(d)check whether P and M are symmetric and idempotent 
**** check P symmetric
matrix Pprime=P'
local rowsPprime= rowsof(Pprime)
local colsPprime= colsof(Pprime)
local equalPp = 1
forval i = 1/`rowsPprime' {
    forval j = 1/`colsPprime' {
        if(abs(P[`i',`j'] - Pprime[`i',`j']) > 1e-6) {
            local equalPp = 0
            exit
        }
    }
}
display "Matrix P is " cond(`equalPp' == 1, "symmetric", "not symmetric")
**** check M symmetric
matrix Mprime=M'
local rowsMprime= rowsof(Mprime)
local colsMprime= colsof(Mprime)
local equalMp = 1
forval i = 1/`rowsMprime' {
    forval j = 1/`colsMprime' {
        if(abs(M[`i',`j'] - Mprime[`i',`j']) > 1e-6) {
            local equalMp = 0
            exit
        }
    }
}
display "Matrix M is " cond(`equalMp' == 1, "symmetric", "not symmetric")
***verify symmetric*****************************************************************************
***verify idempotent****************************************************************************
matrix P2=P*P
local rowsP2= rowsof(P2)
local colsP2= colsof(P2)
local equalP2 = 1
forval i = 1/`rowsP2' {
    forval j = 1/`colsP2' {
        if(abs(P[`i',`j'] - P2[`i',`j']) > 1e-6) {
            local equalP2 = 0
            exit
        }
    }
}
display "Matrix P is " cond(`equalP2' == 1, "idempotent", "not idempotent")
***********
matrix M2=M*M
local rowsM2= rowsof(M2)
local colsM2= colsof(M2)
local equalM2 = 1
forval i = 1/`rowsM2' {
    forval j = 1/`colsM2' {
        if(abs(M[`i',`j'] - M2[`i',`j']) > 1e-6) {
            local equalM2 = 0
            exit
        }
    }
}
display "Matrix M is " cond(`equalM2' == 1, "idempotent", "not idempotent")

***verify idempotent****************************************************************************
******since symmetric and idempotent,trace equals rank
di trace(P)
di trace(M)
***(e)check Py=yhat and My=ephat
****************************
mkmat testscr, matrix(Y)
**matrix list Y
matrix Py=P*Y
*\\\matrix list Py
**and we have yhat=X*betahat
matrix betahat_stata=e(b)
*\\\matrix list betahat_stata
matrix betahat=invXprimeX*X'*Y
*\\\matrix list betahat
matrix yhat=X*betahat
**difference in Py and yhat
local rowsyhat= rowsof(yhat)
local colsyhat= colsof(yhat)
local equalyhat = 1
forval i = 1/`rowsyhat' {
    forval j = 1/`colsyhat' {
        if(abs(Py[`i',`j'] - yhat[`i',`j']) > 1e-6) {
            local equalyhat = 0
            exit
        }
    }
}
display "Matrix Py and yhat is " cond(`equalyhat' == 1, "equal", "not equal")
************Py=yhat part*****
************My=ephat part****
matrix My=M*Y
matrix ephat=Y-yhat
*\\\matrix list ephat
**difference in My and ephat
local rowsephat= rowsof(ephat)
local colsephat= colsof(ephat)
local equalephat = 1
forval i = 1/`rowsephat' {
    forval j = 1/`colsephat' {
        if(abs(My[`i',`j'] - ephat[`i',`j']) > 1e-6) {
            local equalephat = 0
            exit
        }
    }
}
display "Matrix My and ephat is " cond(`equalephat' == 1, "equal", "not equal")
******************************
***(f)check MX and PM is zero
matrix MX=M*X
local rowsMX= rowsof(MX)
local colsMX= colsof(MX)
local equalMX = 1
forval i = 1/`rowsMX' {
    forval j = 1/`colsMX' {
        if(abs(MX[`i',`j'] ) >1e-6) {
            local equalMX = 0
            exit
        }
    }
}
display "Matrix MX  is " cond(`equalMX' == 1, "zero matrix", "not zero matrix")
***************************************************
matrix PM=P*M
local rowsPM= rowsof(PM)
local colsPM= colsof(PM)
local equalPM = 1
forval i = 1/`rowsPM' {
    forval j = 1/`colsPM' {
        if(abs(PM[`i',`j'] ) >1e-6) {
            local equalPM = 0
            exit
        }
    }
}
display "Matrix PM  is " cond(`equalPM' == 1, "zero matrix", "not zero matrix")


***(g)
reg testscr str el_pct meal_pct,r

***(h)
reg testscr str expn_stu el_pct meal_pct, r


