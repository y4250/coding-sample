*************************
*       Yunfeng Wu      *
*  yw4250@columbia.edu  *
*  Columbia University  *
*  Econ  Thesis Code    *
*************************


*****************************NOTE***********************************************
* In the following part, I used the same methods as above. I created two "fake"*
* policies to check whether the treatment effect is significant.               *
********************************************************************************


**# robust DID 2014 and 2016

** Append all the data into one file 
*Treatment Group 2014
clear all
use "/Users/leslie/Desktop/coding sample/DID/1416treatment_ID.dta"
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2014.dta"
keep if _merge == 3
drop _merge
rename numb_birth numb_children
gen time = 0
gen year = 2014
rename edu_code edu
rename insurance_code insurance
rename gender_code gender
rename health_code health
rename minority_code minority
rename age_2014 age
drop working_insurance retire_insurance numb_birth_c-age_c10 gender_c2-gender_c10
save "/Users/leslie/Desktop/coding sample/DID/robust_treat_2014.dta",replace
summarize numb_children
*Treatment Group 2016
clear all
use "/Users/leslie/Desktop/coding sample/DID/1416treatment_ID.dta"
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016.dta"
keep if _merge == 3
drop _merge
gen time = 1
gen year = 2016
rename numb_birth numb_children 
rename gender_code gender
rename edu_code edu
rename p_insurance insurance
rename health_code health
rename minority_code minority
drop gender_c2-gender_c10
save "/Users/leslie/Desktop/coding sample/DID/robust_treat_2016.dta",replace
summarize numb_children
*Control Group 2014
clear all
use "/Users/leslie/Desktop/coding sample/DID/1416control_ID.dta"
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2014.dta"
keep if _merge == 3
drop _merge
rename numb_birth numb_children
gen time = 0
gen year = 2014
rename edu_code edu
rename insurance_code insurance
rename gender_code gender
rename health_code health
rename minority_code minority
rename age_2014 age
drop working_insurance retire_insurance numb_birth_c-age_c10 gender_c2-gender_c10
save "/Users/leslie/Desktop/coding sample/DID/robust_control_2014.dta",replace
summarize numb_children
*Control Group 2016
clear all
use "/Users/leslie/Desktop/coding sample/DID/1416control_ID.dta"
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016.dta"
keep if _merge == 3
drop _merge
rename numb_birth numb_children 
gen time = 1
gen year = 2016
rename gender_code gender
rename edu_code edu
rename p_insurance insurance
rename health_code health
rename minority_code minority
drop gender_c2-gender_c10
save "/Users/leslie/Desktop/coding sample/DID/robust_control_2016.dta",replace
summarize numb_children



* robust 2014 2016 DID regression

clear all
ssc install estout
use "/Users/leslie/Desktop/coding sample/DID/robust_treat_2014.dta"
append using "/Users/leslie/Desktop/coding sample/DID/robust_treat_2016.dta", nolabel
append using "/Users/leslie/Desktop/coding sample/DID/robust_control_2014.dta", nolabel
append using "/Users/leslie/Desktop/coding sample/DID/robust_control_2016.dta", nolabel


drop if numb_children == 0 & treat == 1 & time ==0 // make sure the treatment group observations have 1 child

* drop the observations that only appear once
bysort mmpid: gen count = _N
drop if count == 1
drop count

* descriptive statistics
summarize numb_children if treat == 0 & time == 0
summarize numb_children if treat == 0 & time == 1
summarize numb_children if treat == 1 & time == 0
summarize numb_children if treat == 1 & time == 1
save "/Users/leslie/Desktop/coding sample/DID/robust_all_1416.dta", replace


gen treattime = treat * time
destring mmpid, replace


eststo:reg numb_children treat time treattime,robust
eststo:reg numb_children treat time treattime age insurance income health edu gender huko gender_c1 if  gender_c1>=0,robust

poisson numb_children treat time treattime,robust
poisson numb_children treat time treattime age insurance income health edu gender huko gender_c1 if gender_c1>=0,robust
summarize income


* DID with fixed effect 
xtset mmpid year
eststo:xtreg numb_children treat time treattime  if gender_c1>=0, fe
eststo:xtreg numb_children treat time treattime age income insurance health edu gender huko gender_c1 if gender_c1>=0, fe
estimates store fe
esttab using all_results1416.csv, replace  // All the results


**# robust DID 2018 and 2020

** Append all the data into one file
* Treat Group 2018
clear all
use "/Users/leslie/Desktop/coding sample/DID/1618treatment_ID.dta"
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2018.dta"
keep if _merge == 3
drop _merge
gen time = 0
gen year = 2018
rename numb_birth numb_children 
rename gender_code gender
rename edu_code edu
rename p_insurance insurance
rename health_code health
rename minority_code minority
rename age_2018 age
save "/Users/leslie/Desktop/coding sample/DID/robust_treat_2018.dta",replace
summarize numb_children
* Treat Group 2020
clear all
use "/Users/leslie/Desktop/coding sample/DID/1618treatment_ID.dta"
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2020.dta"
keep if _merge == 3
drop _merge
gen time = 1
gen year = 2020
rename numb_birth numb_children 
rename gender_code gender
rename edu_code edu
rename p_insurance insurance
rename health_code health
rename minority_code minority
save "/Users/leslie/Desktop/coding sample/DID/robust_treat_2020.dta",replace
summarize numb_children
* Control Group 2018
clear all
use "/Users/leslie/Desktop/coding sample/DID/1618control_ID.dta"
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2018.dta"
keep if _merge == 3
drop _merge
gen time = 0
gen year = 2018
rename numb_birth numb_children 
rename gender_code gender
rename edu_code edu
rename p_insurance insurance
rename health_code health
rename minority_code minority
rename age_2018 age
save "/Users/leslie/Desktop/coding sample/DID/robust_control_2018.dta",replace
summarize numb_children
* Control Group 2020
clear all
use "/Users/leslie/Desktop/coding sample/DID/1618control_ID.dta"
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2020.dta"
keep if _merge == 3
drop _merge
gen time = 1
gen year = 2020
rename numb_birth numb_children 
rename gender_code gender
rename edu_code edu
rename p_insurance insurance
rename health_code health
rename minority_code minority
save "/Users/leslie/Desktop/coding sample/DID/robust_control_2020.dta",replace
summarize numb_children

clear all
use "/Users/leslie/Desktop/coding sample/DID/robust_treat_2018.dta"
append using "/Users/leslie/Desktop/coding sample/DID/robust_treat_2020.dta", nolabel
append using "/Users/leslie/Desktop/coding sample/DID/robust_control_2018.dta", nolabel
append using "/Users/leslie/Desktop/coding sample/DID/robust_control_2020.dta", nolabel

drop qka202 working_insurance retire_insurance


drop if treat == 1 & numb_children >= 2 & time ==0 // make sure the treatment group observations have 1 child

bysort mmpid: gen count = _N

drop if count == 1
drop count
summarize numb_children if treat == 0 & time == 0
summarize numb_children if treat == 0 & time == 1
summarize numb_children if treat == 1 & time == 0
summarize numb_children if treat == 1 & time == 1
save "/Users/leslie/Desktop/coding sample/DID/robust_all_1820.dta", replace


* DID 2018 2020

clear all
use "/Users/leslie/Desktop/coding sample/DID/robust_all_1820.dta"
ssc install estout
gen treattime = treat * time
destring mmpid, replace


eststo:reg numb_children treat time treattime,robust
eststo:reg numb_children treat time treattime age insurance income health edu gender huko gender_c1 if  gender_c1>=0,robust

poisson numb_children treat time treattime,robust
poisson numb_children treat time treattime age insurance income health edu gender huko gender_c1 if gender_c1>=0,robust
summarize income
* DID with fixed effect
xtset mmpid year
eststo:xtreg numb_children treat time treattime  if gender_c1>=0, fe
eststo:xtreg numb_children treat time treattime age income insurance health edu gender huko gender_c1 if gender_c1>=0,fe
esttab using all_results1820.csv, replace  // All the results
