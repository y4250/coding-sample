*************************
*       Yunfeng Wu      *
*  yw4250@columbia.edu  *
*  Columbia University  *
*  Econ  Thesis Code    *
*************************


* This do.file prepared the IDs of the treatment group and the control group.

**# The analysis of the policy effect of the "Comprehensive two-child Policy".
* The main regression used data from 2016 and 2018.
* For robust test, I also used the data from 2014 and 2020.


* First I will collect the treatment group IDs and the control group IDs.

//Before that, I firstly prepared the information of whether the area that the observation lives in is ethnic minority concentrated areas。
clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2010data/cfps2010comm_201906.dta"
tostring cid, generate(str_cid_2010)
decode cb6, generate(str_cb6)
save "/Users/leslie/Desktop/coding sample/DID/area_information.dta",replace // merge with observations latter


* Families are allowed to have two children if both of the parents were not the only child in their original family only after 2016.
* So, again I need to use the siblings.
clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2010data/cfps2010adult_202008.dta"

foreach var of varlist tb1m_a_s tb2_a_s t1_s tb4_a_s provcd urban qa5code qb1  gender  qa2 qc1 qp3 qj3_s_1 qj3_s_2 qj3_s_3 qj3_s_4 qj3_s_5 qj3_s_6 qj3_s_7 qj3_s_8 qj3_s_9 qj3_s_10 qj3_s_11 qj3_s_12 qj3_s_13 qj3_s_14 qj3_s_15 qj3_s_16 qj3_s_17 qj3_s_18 qe1_best pid_c1  tb1m_a_c1 tb1y_a_c1 tb2_a_c1 pid_c2 tb1m_a_c2 tb1y_a_c2 tb2_a_c2 pid_c3 tb1m_a_c3 tb1y_a_c3 tb2_a_c3 pid_c4  tb1m_a_c4 tb1y_a_c4 tb2_a_c4 pid_c5 tb1m_a_c5 tb1y_a_c5 tb2_a_c5 pid_c6 tb1m_a_c6 tb1y_a_c6 tb2_a_c6 pid_c7 tb1m_a_c7 tb1y_a_c7 tb2_a_c7 pid_c8 tb1m_a_c8 tb1y_a_c8 tb2_a_c8 pid_c9 tb1m_a_c9 tb1y_a_c9 tb2_a_c9 pid_c10 tb1m_a_c10 tb1y_a_c10 tb2_a_c10 {
    decode `var', generate(str_`var')
}
foreach var of varlist pid cid fid pid_s tb1y_a_s qa1age income{
	tostring `var', generate(str_`var')
}
gen mpid = str_pid_s //the personal ID of the spouse

foreach var of varlist * {
    local newname `var'_2010   // adding _2010 at the end of the variable name for convernience
    rename `var' `newname'
}

gen mpid = str_pid_s_2010
gen year2010 = 2010
save "/Users/leslie/Desktop/coding sample/DID/with_mpid.dta",replace

use "/Users/leslie/Desktop/coding sample/CFPS/2010data/cfps2010adult_202008_new.dta"

foreach var of varlist tb1m_a_s tb2_a_s t1_s tb4_a_s provcd urban qa5code qb1  gender  qa2 qc1 qp3 qj3_s_1 qj3_s_2 qj3_s_3 qj3_s_4 qj3_s_5 qj3_s_6 qj3_s_7 qj3_s_8 qj3_s_9 qj3_s_10 qj3_s_11 qj3_s_12 qj3_s_13 qj3_s_14 qj3_s_15 qj3_s_16 qj3_s_17 qj3_s_18 qe1_best code_a_c1  tb1m_a_c1 tb1y_a_c1 tb2_a_c1 code_a_c2 tb1m_a_c2 tb1y_a_c2 tb2_a_c2 code_a_c3 tb1m_a_c3 tb1y_a_c3 tb2_a_c3 code_a_c4  tb1m_a_c4 tb1y_a_c4 tb2_a_c4 code_a_c5 tb1m_a_c5 tb1y_a_c5 tb2_a_c5 code_a_c6 tb1m_a_c6 tb1y_a_c6 tb2_a_c6 code_a_c7 tb1m_a_c7 tb1y_a_c7 tb2_a_c7 code_a_c8 tb1m_a_c8 tb1y_a_c8 tb2_a_c8 code_a_c9 tb1m_a_c9 tb1y_a_c9 tb2_a_c9  code_a_c10 tb1m_a_c10 tb1y_a_c10 tb2_a_c10 {
    decode `var', generate(str_`var')
}
foreach var of varlist cid pid fid pid_s tb1y_a_s qa1age income{
	tostring `var', generate(str_`var')
}

foreach var of varlist * {
    local newname `var'_2010_C   // adding _2010_C at the end of the variable name for convernience
    rename `var' `newname'
}
gen mpid = str_pid_2010_C
save "/Users/leslie/Desktop/coding sample/DID/with_mpid2.dta",replace




clear all
use "/Users/leslie/Desktop/coding sample/DID/with_mpid.dta"
merge m:m mpid using "/Users/leslie/Desktop/coding sample/DID/with_mpid2.dta"


foreach var of varlist str_pid_2010 str_pid_s_2010 str_t1_s_2010 str_provcd_2010 str_urban_2010 str_qa5code_2010 str_qb1_2010 str_gender_2010 str_qa1age_2010 str_qa2_2010 str_qc1_2010 str_qp3_2010 {
	drop if `var' == "不知道" | `var' == "拒绝回答" | `var' == "不适用" | `var' == "非中国国籍" | `var' == "没有户口" | `var' == "-8"
} // drop the missing values


drop if str_t1_s_2010 == "否" // make sure we have the information of the spouse


drop if qb1_2010 == 0 | qb1_2010_C == 0 // drop if neither of them are the only child in their original family



drop if qa1age_2010 < 16
drop if qa1age_2010 > 41 & str_gender_2010 == "女"
drop if qa1age_2010 > 50 & str_gender_2010 == "男"
drop if str_tb2_a_s_2010 == "女" & tb1b_a_s_2010 > 41  //drop the observations that are not in the reproductive period



drop if code_a_c2_2010 > 0 // drop if the observation already have two children



drop if str_provcd_2010 == "西藏省"  // drop the Tibet sample (they have always been allowed to have two children).




* drop rural area samples from certain provinces (they are also allowed to have two children).
drop if str_provcd_2010 == "海南省" & str_urban_2010 == "乡村"
drop if str_provcd_2010 == "云南省" & str_urban_2010  == "乡村"
drop if str_provcd_2010 == "青海省" & str_urban_2010  == "乡村"
drop if str_provcd_2010 == "宁夏省" & str_urban_2010  == "乡村"
drop if str_provcd_2010 == "新疆省" & str_urban_2010  == "乡村"



* drop samples from areas with the 'one-and-a-half-child' policy (where families are allowed to have two children if the first child is a girl).
drop if str_provcd_2010 == "河北省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "山西省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "内蒙古省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "辽宁省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "吉林省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "黑龙江省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "浙江省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "安徽省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "福建省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "江西省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "山东省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "河南省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "湖北省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "湖南省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "广东省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "广西省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "山西省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "贵州省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "陕西省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"
drop if str_provcd_2010 == "甘肃省" & str_urban_2010 == "乡村" & str_tb2_a_c1_2010 == "女"




* drop ethnic minority samples (who are allowed to have two children).
drop if str_qa5code_2010 != "汉族" | str_qa5code_2010_C != "汉族"


* drop samples from ethnic minority settlement areas (where they are allowed to have two children).
merge m:m str_cid_2010 using "/Users/leslie/Desktop/coding sample/DID/area_information.dta" ,nogen  // merge the area information
drop if str_cb6 == "是"



gen treat = 1
gen time = 0 if year2010 < 2016


gen mmpid = str_pid_2010 //gernerate a matching ID



keep mmpid str_pid_2010 str_cid_2010 str_provcd_2010 year2010 str_gender_2010 str_income_2010 str_qa1age_2010 str_qa2_2010 str_qc1_2010 str_qp3_2010 str_qj3_s_1_2010 treat time
save "/Users/leslie/Desktop/coding sample/DID/2010treatment_ID.dta" , replace







** Prepare the IDs of the treatment group and the control group for 2016 and 2018 (Here I used the cleaned data in the first part)

* Treatment Group
clear all
use "/Users/leslie/Desktop/coding sample/DID/2010treatment_ID.dta"
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016.dta"
keep if _merge == 3
drop _merge
rename numb_birth numb_birth2016
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2018.dta"
keep if _merge == 3
drop _merge
drop if numb_birth2016 >1
drop if numb_birth2016 == 0
drop if numb_birth2016 > numb_birth // drop the observations that the number of births is abnormal
summarize numb_birth2016 numb_birth

drop treat
gen treat = 1
keep mmpid treat
save "/Users/leslie/Desktop/coding sample/DID/1618treatment_ID.dta",replace   // save the IDs


*Control Group
clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2010data/cfps2010adult_202008.dta"


foreach var of varlist tb1m_a_s tb2_a_s t1_s tb4_a_s provcd urban qa5code qb1 gender qa2 qc1 qp3 qj3_s_1 qe1_best{
    decode `var', generate(str_`var')
}
foreach var of varlist pid cid fid pid_s tb1y_a_s qa1age income pid_c1 pid_c2  pid_c3 pid_c4 pid_c5 pid_c6 pid_c7 pid_c8 pid_c9 pid_c10{
	tostring `var', generate(str_`var')
}
foreach var of varlist code_a_c1 code_a_c2 code_a_c3 code_a_c4 code_a_c5 code_a_c6 code_a_c7 code_a_c8 code_a_c9 code_a_c10{
	tostring `var', generate(str_`var')
}
gen mpid = str_pid_s
foreach var of varlist * {
    local newname `var'_2010   // add _2010 to the name of the variables for convenvience
    rename `var' `newname'
}

gen mmpid = str_pid_2010

* Get the number of children
gen numb_child_2010 = 0
replace numb_child_2010 = 1 if str_code_a_c1_2010 != "-8"
replace numb_child_2010 = 2 if str_code_a_c2_2010 != "-8"
replace numb_child_2010 = 3 if str_code_a_c3_2010 != "-8"
replace numb_child_2010 = 4 if str_code_a_c4_2010 != "-8"
replace numb_child_2010 = 5 if str_code_a_c5_2010 != "-8"
replace numb_child_2010 = 6 if str_code_a_c6_2010 != "-8"
replace numb_child_2010 = 7 if str_code_a_c7_2010 != "-8"
replace numb_child_2010 = 8 if str_code_a_c8_2010 != "-8"
replace numb_child_2010 = 9 if str_code_a_c9_2010 != "-8"
replace numb_child_2010 = 10 if str_code_a_c10_2010 != "-8"

* Drop if the observation is not in reproductive period
drop if qa1age_2010 < 16
drop if qa1age_2010 > 41 & str_gender_2010 == "女"
drop if str_tb2_a_s_2010 == "女" & tb1b_a_s_2010 > 41
keep mmpid numb_child_2010 qa1age_2010 str_gender_2010


* use merge function to get the ID of the control group
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/DID/1618treatment_ID.dta"
keep if _merge == 1  // keep the observations that are not in the treatment group
drop _merge  


* make sure the observations have information in both years
merge m:m mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016.dta"
keep if _merge == 3
drop _merge
rename numb_birth numb_birth2016


merge m:m mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2018.dta"
keep if _merge == 3
drop _merge
drop if numb_birth2016 > numb_birth
summarize numb_birth2016 numb_birth 
drop if numb_birth2016 == 0
summarize numb_birth2016 numb_birth


drop treat 
gen treat = 0
keep mmpid treat
save "/Users/leslie/Desktop/coding sample/DID/1618control_ID.dta",replace  // save the control IDs


*************************NOTE***************************************************
* The following part shows the same methods I used to get the IDs as above.    *
********************************************************************************




** Prepare the IDs for 2014 and 2016
* Treatment Group
clear all
use "/Users/leslie/Desktop/coding sample/DID/2010treatment_ID.dta"

merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2014.dta"
keep if _merge == 3
drop _merge
rename numb_birth numb_birth2014
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016.dta"
keep if _merge == 3
drop _merge
rename numb_birth numb_birth2016
drop if numb_birth2016 < numb_birth2014
summarize numb_birth2016 numb_birth2014
drop if numb_birth2014 != 1
summarize numb_birth2016 numb_birth2014

drop treat
gen treat = 1
keep mmpid treat
save "/Users/leslie/Desktop/coding sample/DID/1416treatment_ID.dta",replace   // save the IDs


*Control Group
clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2010data/cfps2010adult_202008.dta"

foreach var of varlist tb1m_a_s tb2_a_s t1_s tb4_a_s provcd urban qa5code qb1 gender qa2 qc1 qp3 qj3_s_1 qe1_best{
    decode `var', generate(str_`var')
}
foreach var of varlist pid cid fid pid_s tb1y_a_s qa1age income pid_c1 pid_c2  pid_c3 pid_c4 pid_c5 pid_c6 pid_c7 pid_c8 pid_c9 pid_c10{
	tostring `var', generate(str_`var')
}
foreach var of varlist code_a_c1 code_a_c2 code_a_c3 code_a_c4 code_a_c5 code_a_c6 code_a_c7 code_a_c8 code_a_c9 code_a_c10{
	tostring `var', generate(str_`var')
}
gen mpid = str_pid_s
foreach var of varlist * {
    local newname `var'_2010   // add _2010 to the name of the variables for convenvience
    rename `var' `newname'
}
gen mmpid = str_pid_2010

** Collect the number of children
gen numb_child_2010 = 0
replace numb_child_2010 = 1 if str_code_a_c1_2010 != "-8"
replace numb_child_2010 = 2 if str_code_a_c2_2010 != "-8"
replace numb_child_2010 = 3 if str_code_a_c3_2010 != "-8"
replace numb_child_2010 = 4 if str_code_a_c4_2010 != "-8"
replace numb_child_2010 = 5 if str_code_a_c5_2010 != "-8"
replace numb_child_2010 = 6 if str_code_a_c6_2010 != "-8"
replace numb_child_2010 = 7 if str_code_a_c7_2010 != "-8"
replace numb_child_2010 = 8 if str_code_a_c8_2010 != "-8"
replace numb_child_2010 = 9 if str_code_a_c9_2010 != "-8"
replace numb_child_2010 = 10 if str_code_a_c10_2010 != "-8"



* Drop if the observation is not in reproductive period
drop if qa1age_2010 < 16
drop if qa1age_2010 > 41 & str_gender_2010 == "女"
drop if str_tb2_a_s_2010 == "女" & tb1b_a_s_2010 > 41
keep mmpid numb_child_2010 qa1age_2010 str_gender_2010



merge m:m mmpid using "/Users/leslie/Desktop/coding sample/DID/1416treatment_ID.dta"
keep if _merge == 1
drop _merge

merge m:m mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2014.dta"
keep if _merge == 3
drop _merge
rename numb_birth numb_birth2014

merge m:m mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016.dta"
keep if _merge == 3
drop _merge
rename numb_birth numb_birth2016
drop if numb_birth2016 < numb_birth2014
summarize numb_birth2016 numb_birth2014
drop if numb_birth2014 == 0
summarize numb_birth2016 numb_birth2014

drop treat 
gen treat = 0
keep mmpid treat
save "/Users/leslie/Desktop/coding sample/DID/1416control_ID.dta",replace  // save the control IDs
