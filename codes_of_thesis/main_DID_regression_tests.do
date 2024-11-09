*************************
*       Yunfeng Wu      *
*  yw4250@columbia.edu  *
*  Columbia University  *
*  Econ  Thesis Code    *
*************************


* This do.file contains the main DID regression in my writing sample, the placebo test and the balanced test.

**# main DID 2016 and 2018

** Append all the data into one file 

* Treatment group 2016
clear all
use "/Users/leslie/Desktop/coding sample/DID/1618treatment_ID.dta"
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016.dta"
keep if _merge == 3
drop _merge
gen time = 0
gen year = 2016
rename numb_birth numb_children 
rename gender_code gender
rename edu_code edu
rename p_insurance insurance
rename health_code health
rename minority_code minority
save "/Users/leslie/Desktop/coding sample/DID/main_treat_2016.dta",replace
summarize numb_children
* Treatment group 2018
clear all
use "/Users/leslie/Desktop/coding sample/DID/1618treatment_ID.dta"
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2018.dta"
keep if _merge == 3
drop _merge
gen time = 1
gen year = 2018
rename numb_birth numb_children 
rename gender_code gender
rename edu_code edu
rename p_insurance insurance
rename health_code health
rename minority_code minority
rename age_2018 age
save "/Users/leslie/Desktop/coding sample/DID/main_treat_2018.dta",replace
summarize numb_children
* Control group 2016
clear all
use "/Users/leslie/Desktop/coding sample/DID/1618control_ID.dta"
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016.dta"
keep if _merge == 3
drop _merge
rename numb_birth numb_children 
gen time = 0
gen year = 2016
rename gender_code gender
rename edu_code edu
rename p_insurance insurance
rename health_code health
rename minority_code minority
save "/Users/leslie/Desktop/coding sample/DID/main_control_2016.dta",replace
summarize numb_children
* Control group 2018
clear all
use "/Users/leslie/Desktop/coding sample/DID/1618control_ID.dta"
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2018.dta"
keep if _merge == 3
drop _merge
gen time = 1
gen year = 2018
rename numb_birth numb_children 
rename gender_code gender
rename edu_code edu
rename p_insurance insurance
rename health_code health
rename minority_code minority
rename age_2018 age
save "/Users/leslie/Desktop/coding sample/DID/main_control_2018.dta",replace
summarize numb_children

* main 2016 2018 DID regression
clear all
use "/Users/leslie/Desktop/coding sample/DID/main_treat_2016.dta"
append using "/Users/leslie/Desktop/coding sample/DID/main_treat_2018.dta", nolabel
append using "/Users/leslie/Desktop/coding sample/DID/main_control_2016.dta", nolabel
append using "/Users/leslie/Desktop/coding sample/DID/main_control_2018.dta", nolabel

* drop the observations that only appear once
bysort mmpid: gen count = _N
drop if count == 1
drop count


* descriptive statistics // The tabel 5 in the writing sample
summarize numb_children if treat == 0 & time == 0
summarize numb_children if treat == 0 & time == 1
summarize numb_children if treat == 1 & time == 0
summarize numb_children if treat == 1 & time == 1

save "/Users/leslie/Desktop/coding sample/DID/main_all.dta", replace // save all the data


clear all
ssc install psmatch2
ssc install estout
use "/Users/leslie/Desktop/coding sample/DID/main_all.dta"

gen treattime = treat * time
destring mmpid, replace

* Propensity Score Matching
logit treat age insurance income health edu gender huko gender_c1
predict pscore
psmatch2 treat, pscore(pscore) neighbor(1) caliper(0.05) outcome(numb_children)
pstest age insurance income health edu gender huko gender_c1,both    // The table of PSM results in the writing sample

eststo:reg numb_children treat time treattime,robust
eststo:reg numb_children treat time treattime age insurance income health edu gender huko gender_c1 if  gender_c1>=0,robust

poisson numb_children treat time treattime,robust
poisson numb_children treat time treattime age insurance income health edu gender huko gender_c1 if gender_c1>=0,robust

* THE MAIN DID REGRESSION WITH FIXED EFFECT
xtset mmpid year
eststo:xtreg numb_children treat time treattime  if gender_c1>=0, fe
eststo:xtreg numb_children treat time treattime age income insurance health edu gender huko gender_c1 if gender_c1>=0, fe

*PSM-DID  using the sample with positive weight
eststo:reg numb_children treat time treattime if _weight !=. ,robust
eststo:reg numb_children treat time treattime age insurance income health edu gender huko gender_c1 if  gender_c1>=0 & _weight !=. ,robust
eststo:xtreg numb_children treat time treattime  if gender_c1>=0 & _weight !=. , fe
eststo:xtreg numb_children treat time treattime age income insurance health edu gender huko gender_c1 if gender_c1>=0 & _weight !=. , fe

**DID REGRESSION in different regions (Every region contains several provinces)

eststo:xtreg numb_children treat time treattime age income insurance health edu gender huko gender_c1 if gender_c1>=0 & (str_provcd == "北京市" | str_provcd == "上海市" | str_provcd == "江苏省" | str_provcd == "浙江省" | str_provcd == "山东省" | str_provcd == "广东省" | str_provcd == "福建省" | str_provcd == "天津市" | str_provcd == "海南省"| str_provcd == "河北省"), fe // East
eststo:xtreg numb_children treat time treattime age income insurance health edu gender huko gender_c1 if gender_c1>=0 & (str_provcd == "山西省" | str_provcd == "安徽省" | str_provcd == "江西省" | str_provcd == "河南省" | str_provcd == "湖南省" | str_provcd == "湖北省"), fe //Central
eststo:xtreg numb_children treat time treattime age income insurance health edu gender huko gender_c1 if gender_c1>=0 & (str_provcd == "内蒙古自治区" | str_provcd == "广西壮族自治区" | str_provcd == "重庆市" | str_provcd == "四川省" | str_provcd == "贵州省" | str_provcd == "云南省" | str_provcd == "西藏" | str_provcd == "陕西省" | str_provcd == "甘肃省"| str_provcd == "青海省"| str_provcd == "宁夏回族自治区"| str_provcd == "新疆维吾尔自治区"), fe //West
eststo:xtreg numb_children treat time treattime age income insurance health edu gender huko gender_c1 if gender_c1>=0 & (str_provcd == "吉林省" | str_provcd == "辽宁省" | str_provcd == "黑龙江省" ), fe //North
esttab using all_results1618.csv, replace  // All the results

* Placebo Test
* Define the function
program define placebo_didf, rclass
    gen placebo_treat = 0                      
    replace placebo_treat = 1 if runiform() < 0.22 //draw 22% observations randomly
    gen placebo_did = placebo_treat * time
	xtset mmpid year
    xtreg numb_children placebo_did placebo_treat time age income insurance health edu gender huko gender_c1 if gender_c1>=0 , fe //run the regression
    return scalar coef = _b[placebo_did] // save the estimated result
    local t_stat = abs(_b[placebo_did] / _se[placebo_did])   // calculate t 
    return scalar pvalue = 2 * ttail(e(df_r), `t_stat')   // calculate the p-value
    drop placebo_treat placebo_did  // restore the data
end
set seed 12345

simulate coef=r(coef) pvalue=r(pvalue), reps(500): placebo_didf // run the function 500 times

* draw a graph of the result
twoway (kdensity coef, color(navy) lwidth(medium)) ///
       (scatter pvalue coef, msymbol(oh) mlcolor(red) yaxis(2)), ///
       xline(.0386143, lcolor(gs10) lwidth(medium)) ///
       xtitle("Coefficient") ///
       xscale(range(-0.05 0.05)) ///
       ylabel(, nolabel) ///
       legend(label(1 "Coefficient Density") label(2 "P-value"))

graph export "/Users/leslie/Desktop/coding sample/DID/placebo.png", replace
