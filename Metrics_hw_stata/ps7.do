*****ps7 yw4250*****
***Q1
***(a) lecture 20 slides P18
clear all 
set more off
use "/Users/leslie/Desktop/statafile/ps7/AK1991.dta"
keep if black==1
ivregress 2sls logwage (edu= i.qob#i.yob i.qob#i.state) smsa married i.yob i.region i.state


***(b) lecture 21 slides P31
reg edu i.qob#i.yob i.qob#i.state smsa married i.yob i.region i.state
testparm i.qob#i.yob i.qob#i.state


***(c) lecture21 slides P32,33
clear all 
set more off
use "/Users/leslie/Desktop/statafile/ps7/AK1991.dta"
keep if black==1
ivregress 2sls logwage (edu= i.qob#i.yob) smsa married i.yob i.region 
predict eps_hat, resid 

***(d) 
reg eps_hat i.qob#i.yob smsa married i.yob i.region
testparm i.qob#i.yob  
///
///    F( 30, 26863) =    1.05
///         Prob > F =    0.3862
///   so, J=30*1.06=31.8<39.09, we do not reject H0



***Q4
clear all
set more off
use "/Users/leslie/Desktop/statafile/ps7/AJR2001.dta", clear

***(a)
reg loggdp risk

reg risk logmort0

ivregress 2sls loggdp (risk=logmort0)


***(b)
reg loggdp risk,r

reg risk logmort0,r

ivregress 2sls loggdp (risk=logmort0),vce(robust)
/// The authors use the homoskedastic standard error.



***(c)
reg loggdp logmort0
scalar b1=e(b)[1,1]
reg risk logmort0
scalar b2=e(b)[1,1]
scalar b=b1/b2
di b

***(d)
reg risk logmort0
gen risk_hat= -.6132892*logmort0+9.365895
reg loggdp risk_hat
/// the estimates are the same, but the std.error is different


***(e)
***gen residin1=risk-risk_hat
reg risk logmort0
predict residuals,residuals
reg loggdp risk_hat residuals


***(f)
reg loggdp risk latitude africa


***(g)
ivregress 2sls loggdp (risk=logmort0) latitude africa


***(h)
gen mort=exp(logmort0)
reg risk mort


***(i)
gen logmortsq=logmort0*logmort0
reg risk logmort0 logmortsq
ivregress 2sls loggdp (risk=logmort0 logmortsq)


***(j)
estat endogenous


***(k)
reg risk logmort0 logmortsq
test logmort0 logmortsq


***(j)
ivregress 2sls loggdp (risk=logmort0 logmortsq)
predict eps_hat,resid
reg eps_hat logmort0 logmortsq
test logmort0 logmortsq

///       F(  2,    61) =    2.66
///            Prob > F =    0.0780
/// so, J=2.66*2=5.32>2.71, so we reject H0.

