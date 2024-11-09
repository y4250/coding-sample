*************************
*       Yunfeng Wu      *
*  yw4250@columbia.edu  *
*  Columbia University  *
*  Econ  Thesis Code    *
*************************

** More disscussion part
* I draw the graph of the More Discussion part in my writing sample.

**#  The analysis of the difference between fertility intention and actual births using data of "2018"

clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2018data/cfps2018person_202012.dta"
tostring pid,generate(str_pid_2018)
gen mmpid = str_pid_2018 // gen matching variable
merge m:m mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/child_information_2018.dta" //matching the number of children
keep if _merge == 3
drop _merge

rename qka202 f_intention // rename the fertility intention
drop if f_intention < 0 | f_intention ==. //drop the missing values

drop if age <= 18 //drop observations younger than 18

** summarize all observations
summarize f_intention
summarize numb_birth

collapse (mean) f_intention numb_birth (count) sample_size = f_intention, by(age)
save "/Users/leslie/Desktop/coding sample/More analysis/analysis_2018.dta", replace

use "/Users/leslie/Desktop/coding sample/More analysis/analysis_2018.dta", clear

label var age "" //remove label

twoway (line f_intention age, lcolor(blue) lwidth(medium) lpattern(solid) yaxis(1)) ///
       (line numb_birth age, lcolor(red) lwidth(medium) lpattern(dash) yaxis(1)) ///
       (line sample_size age, lcolor(black) lwidth(medium) lpattern(shortdash) yaxis(2)), ///
       legend(position(6) ring(0) label(1 "Mean of f_intention") label(2 "Mean of numb_birth") label(3 "Sample Size")) ///
       xlabel(, grid) ylabel(, axis(1) grid) ///
       ytitle("Means of fertility intention and births", axis(1)) ///
       ytitle("Sample Size", axis(2)) ///
       xtitle("Age")
graph export "/Users/leslie/Desktop/coding sample/More analysis/gap_2018.png", replace
