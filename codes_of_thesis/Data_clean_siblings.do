*************************
*       Yunfeng Wu      *
*  yw4250@columbia.edu  *
*  Columbia University  *
*  Econ  Thesis Code    *
*************************


* This do.file contains the data clean of the first part of my thesis.
* Since there are 6 years of data and the variable names changed over time, I wrote a lot of code for data cleaning.
* I attached all the code. However, the methods I used is very similar when I clean data from different years.
* From line 18 to line 274, I cleaned data from 2010 as an example.

*DATA ClEANING
* NOTE: I did not use the value labels due to the large amount of variables. Using the string is more convenient to review.


*//Collect the number of siblings (Only the survey in 2010 collect this data, so I will umerge this to latter surveys)
clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2010data/cfps2010adult_202008.dta"


tostring pid , generate(str_pid_2010)  // pid is the ID for each observation 
decode qa5code , generate(str_qa5code) // qa5code is the ethnicity of the observtaion
decode provcd , generate(str_provcd)  // provcd is the province the observation lives in 
decode qb1 ,generate (str_qb1)  // qb1 is the number of siblings(not include the observation him/herself) 


drop if str_qb1 == "不知道" | str_qb1 == "不适用" | str_qb1 == "拒绝回答" //drop the missing values


**generate a variable to represent whether the observation belongs to minority
gen minority_code = 0
drop if str_qa5code == "不适用" | str_qa5code == "拒绝回答" | str_qa5code == "不知道"  //drop the missing values
replace minority_code = 1 if str_qa5code != "汉族"  // If the observation is not a Han Chinses, then he/she belongs to a minority group.


gen sib = qb1+1   // adding the observation him/herself to the number of siblings
gen mmpid = str_pid_2010   // generate a matching ID for latter merge


** getting the age of the observation in 2014 and 2018()
gen age_2014 = 2014 -qa1y_best  // qa1y_best is the year of birth
gen age_2018 = 2018 -qa1y_best
keep mmpid str_pid sib age_2014 age_2018 minority_code str_provcd  // only keep the key variables

save "/Users/leslie/Desktop/coding sample/intergeneration_data/2010_siblings.dta",replace



**# 2010DATA
clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2010data/cfps2010adult_202008.dta"
tostring pid, generate(mmpid) // generate a matching ID for latter merge

foreach var of varlist pid pid_c1 pid_c2 pid_c3 pid_c4 pid_c5 pid_c6 pid_c7 pid_c8 pid_c9 pid_c10{
	tostring `var', generate(str_`var')
}     // converge the data to string
foreach var of varlist code_a_c1 code_a_c2 code_a_c3 code_a_c4 code_a_c5 code_a_c6 code_a_c7 code_a_c8 code_a_c9 code_a_c10{
	tostring `var', generate(str_`var')
}     // converge the data to string




** Prepare the number of the childern
* NOTE: Some of the observations can only provide the information of their younger children. I use this method to avoid missing counting.
gen numb_birth = 0
replace numb_birth = 1 if str_code_a_c1 != "-8"
replace numb_birth = 2 if str_code_a_c2 != "-8"
replace numb_birth = 3 if str_code_a_c3 != "-8"
replace numb_birth = 4 if str_code_a_c4 != "-8"
replace numb_birth = 5 if str_code_a_c5 != "-8"
replace numb_birth = 6 if str_code_a_c6 != "-8"
replace numb_birth = 7 if str_code_a_c7 != "-8"
replace numb_birth = 8 if str_code_a_c8 != "-8"
replace numb_birth = 9 if str_code_a_c9 != "-8"
replace numb_birth = 10 if str_code_a_c10 != "-8"




** Collect the gender of the childern
foreach var of varlist tb2_a_c1 tb2_a_c2 tb2_a_c3 tb2_a_c4 tb2_a_c5 tb2_a_c6 tb2_a_c7 tb2_a_c8 tb2_a_c9 tb2_a_c10{
	decode `var', generate(str_`var')
} // tb2_a_c1 represents the gender of the first child
  // tb2_a_c2 represents the gender of the first child and so on.

* 0 represents female, 1 represents male, -8 represents missing value
forvalues i = 1/10 {
    gen gender_c`i' = 0
    replace gender_c`i' = 1 if str_tb2_a_c`i' == "男"
    replace gender_c`i' = -8 if str_tb2_a_c`i' != "男" & str_tb2_a_c`i' != "女"
}




** Check whether the observation has pension insurance
foreach var of varlist qj3_s_1 qj3_s_2 qj3_s_3 qj3_s_4 qj3_s_5 qj3_s_6 qj3_s_7 qj3_s_8 qj3_s_9 qj3_s_10 qj3_s_11 qj3_s_12 qj3_s_13 qj3_s_14 qj3_s_15 qj3_s_16 qj3_s_17 qj3_s_18{
	decode `var', generate(str_`var')
}  // all the variables about pension insurance

* 0 represents no pension insurance, 1 represents having pension insurance
gen p_insurance = 0

foreach var of varlist str_qj3_s_1 str_qj3_s_2 str_qj3_s_3 str_qj3_s_4 str_qj3_s_5 str_qj3_s_6 str_qj3_s_7 str_qj3_s_8 str_qj3_s_9 str_qj3_s_10 str_qj3_s_11 str_qj3_s_12 str_qj3_s_13 str_qj3_s_14 str_qj3_s_15 str_qj3_s_16 str_qj3_s_17 str_qj3_s_18{
	drop  if `var' == "拒绝回答" | `var' == "不知道" 
} // drop the missing values


foreach var of varlist str_qj3_s_1 str_qj3_s_2 str_qj3_s_3 str_qj3_s_4 str_qj3_s_5 str_qj3_s_6 str_qj3_s_7 str_qj3_s_8 str_qj3_s_9 str_qj3_s_10 str_qj3_s_11 str_qj3_s_12 str_qj3_s_13 str_qj3_s_14 str_qj3_s_15 str_qj3_s_16 str_qj3_s_17 str_qj3_s_18{
	replace p_insurance = 1 if `var' == "城镇基本养老保险" | `var' == "农村社会养老保险" | `var' == "补充养老保险"
} // if the observation has pension insurance, replace the variable p_insurance with 1




** Check the huko(household registration) of the observation 
decode qa2 ,generate(str_qa2) // qa2 is the household registration variable

drop if str_qa2 == "不知道" | str_qa2 == "没有户口" | str_qa2 == "非中国国籍" | str_qa2 == "拒绝回答" // drop the missing values
* 0 represents rural huko, 1 represents urban huko
gen huko = 0
replace huko = 1 if str_qa2 == "非农业户口" 




** Collect tge gender of the observation
decode gender , generate(str_gender)
* 0 represents female, 1 represents male
gen gender_code = 0
replace gender_code = 1 if str_gender == "男"





** Collect the education level of the observation
decode cfps2010edu_best, generate(str_cfps2010edu)
drop if str_cfps2010edu == "缺失" | str_cfps2010edu == "不知道" | str_cfps2010edu == "不必读书" // drop the missing values
* 0 represents illiterate/semi-illiterate, 1 represents kindergarten， 2 represents primary school, 3 represents middle school
* 4 represents high schoold, 5 represents junior college, 6 represents bachelor's degree, 7 represent master's degree
* 8 represents Phd
gen edu_code = 0
replace edu_code = 1 if str_cfps2010edu == "幼儿园"
replace edu_code = 2 if str_cfps2010edu == "小学"
replace edu_code = 3 if str_cfps2010edu == "初中"
replace edu_code = 4 if str_cfps2010edu == "高中"
replace edu_code = 5 if str_cfps2010edu == "大专"
replace edu_code = 6 if str_cfps2010edu == "大学本科"
replace edu_code = 7 if str_cfps2010edu == "硕士"
replace edu_code = 8 if str_cfps2010edu == "博士"




** Collect the health situation of the observation
decode qp3, generate(str_qp3)
drop if str_qp3 == "不适用" | str_qp3 == "不知道" | str_qp3 == "拒绝回答" // drop the missing values
*0 means unhealthy, 1 means fair, 2 means relatively healthy, 3 means healthy, and 4 means very healthy
gen health_code = 0
replace health_code = 1 if str_qp3 == "不健康"
replace health_code = 2 if str_qp3 == "比较不健康"
replace health_code = 3 if str_qp3 == "一般"
replace health_code = 4 if str_qp3 == "健康"




** Collect the income of the observation (A lot of observations refused to report their income, So I used random-forest to impute the missing values)
replace income = . if income < 0   // replace the missing values with .




** THIS IS 2010 data, so I can directly get the siblings
decode qb1 ,generate (str_qb1)
drop if str_qb1 == "不知道" | str_qb1 == "不适用" | str_qb1 == "拒绝回答"
gen sib = qb1+1





** Collect the age of the obsevation
rename qa1age age




** Collect the province that the observation lives in
decode provcd, generate(str_provcd)




**generate a variable to represent whether the observation belongs to minority
decode qa5code , generate(str_qa5code)
gen minority_code = 0
drop if str_qa5code == "不适用" | str_qa5code == "拒绝回答" | str_qa5code == "不知道" // drop the missing values
* 0 represents the observation does not belong to the minority group, 1 represents the observation belongs to the minority group
replace minority_code = 1 if str_qa5code != "汉族" // If the observation is not a Han Chinses, then he/she belongs to a minority group.





**Generate a variable to represent whether the observation lives in the urban area
decode urban , generate(str_urban)
gen urban_code = 0
* 0 represents the observation lives in the rural area, 1 represents the observation lives in the urban area
replace urban_code = 1 if str_urban == "城市"




keep mmpid sib numb_birth str_provcd minority_code age p_insurance huko gender_code edu_code health_code income gender_c1 gender_c2 gender_c3 gender_c4 gender_c5 gender_c6 gender_c7 gender_c8 gender_c9 gender_c10 urban_code // keep the key variables
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2010.dta",replace // save as cleaned_data_2010


keep mmpid minority_code age p_insurance huko gender_code edu_code health_code income gender_c1 gender_c2
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2010_before_imputation.dta" ,replace // prepare the data for imputation

**I used R to imputed the missing values in income. The following is the code.
// install.packages("mice")
// install.packages("randomForest")
// install.packages("haven")
// library(haven)
// library(mice)
// library(randomForest)
//
// data <- read_dta("/Users/leslie/Desktop/coding sample/cleaned_data_2010_before_imputation.dta")
//
//
// str(data)
//
// imputed_data <- mice(data, m = 5, method = 'rf', seed = 500)
//
//
// summary(imputed_data)
//
// complete_data <- complete(imputed_data, 1)
//
//
// head(complete_data)
// write_dta(complete_data, "/Users/leslie/Desktop/coding sample/cleaned_data_2010_after_imputation.dta")




** Using the after-imputation data to get the all-set data
clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2010.dta"
rename income income1
merge 1:1 mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2010_after_imputation.dta", keepusing(income)
drop income1
drop _merge
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2010.dta",replace //overwrite the data with missing values


clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2010.dta"
* rename the variables for convernience
rename sib siblings
rename minority_code minority
rename gender_code gender
rename edu_code edu
rename health_code health
rename numb_birth births
drop gender_c3-gender_c10
gen year = 2010
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2010_renamed.dta" , replace







***************************** NOTE *********************************************
* I have cleaned the data for other years using the same method and standards. *
* For your reference, I have attached the code below. In some years, the infor-*
* mation of the children is in other dta file. I used the matching ID to merge *
* them. Also, I merged the siblings that I got in 2010 with the later year's   *
* data.                                                                        *
********************************************************************************       
   
**# 2012DATA

* Prepare the information of the children.
clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2012data/cfps2012famconf_092015.dta"

tostring pid, generate(mmpid) // generate a matching ID 




* Collect the number of the children
foreach var of varlist code_a_c1 code_a_c2 code_a_c3 code_a_c4 code_a_c5 code_a_c6 code_a_c7 code_a_c8 code_a_c9 code_a_c10{
	tostring `var', generate(str_`var')
}
* NOTE: Some of the observations can only provide the information of their younger children. I use this method to avoid missing counting.
gen numb_birth = 0
replace numb_birth = 1 if str_code_a_c1 != "-8"
replace numb_birth = 2 if str_code_a_c2 != "-8"
replace numb_birth = 3 if str_code_a_c3 != "-8"
replace numb_birth = 4 if str_code_a_c4 != "-8"
replace numb_birth = 5 if str_code_a_c5 != "-8"
replace numb_birth = 6 if str_code_a_c6 != "-8"
replace numb_birth = 7 if str_code_a_c7 != "-8"
replace numb_birth = 8 if str_code_a_c8 != "-8"
replace numb_birth = 9 if str_code_a_c9 != "-8"
replace numb_birth = 10 if str_code_a_c10 != "-8"




* Collect the gender of the children
foreach var of varlist tb2_a_c1 tb2_a_c2 tb2_a_c3 tb2_a_c4 tb2_a_c5 tb2_a_c6 tb2_a_c7 tb2_a_c8 tb2_a_c9 tb2_a_c10{
	decode `var', generate(str_`var')
}

* 0 represents female, 1 represents male, -8 represents missing value
forvalues i = 1/10 {
    gen gender_c`i' = 0
    replace gender_c`i' = 1 if str_tb2_a_c`i' == "男"
    replace gender_c`i' = -8 if str_tb2_a_c`i' != "男" & str_tb2_a_c`i' != "女"
}

keep mmpid numb_birth gender_c1 gender_c2 gender_c3 gender_c4 gender_c5 gender_c6 gender_c7 gender_c8 gender_c9 gender_c10
save "/Users/leslie/Desktop/coding sample/intergeneration_data/child_information_2012.dta",replace

clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2012data/cfps2012adult_201906.dta"
tostring pid , generate(mmpid) //generate a matching ID

rename qv201b  age // get the age of the observation
drop if age < 0  // drop the missing values


* 	qi5011 qi5012 qi5013 qi5014 qi5015 qi5016 qi502 represent the questions about the pension insurance
foreach var of varlist qi5011 qi5012 qi5013 qi5014 qi5015 qi5016 qi502{
	decode `var', generate(str_`var')
}

foreach var of varlist  str_qi5011 str_qi5012 str_qi5013 str_qi5014 str_qi5015 str_qi5016 str_qi502{
	drop if `var' == "不知道"
} // drop the missing values

* 0 represents no pension insurance, 1 represents having pension insurance
generate p_insurance = 0
foreach var of varlist  str_qi5011 str_qi5012 str_qi5013 str_qi5014 str_qi5015 str_qi5016 str_qi502{
	replace p_insurance = 1 if `var' == "是"
}





** Check the huko(household registration) of the observation 
decode qa301 ,generate(str_qa301)
drop if str_qa301 == "不知道" | str_qa301 == "没有户口" | str_qa301 == "不适用" | str_qa301 == "拒绝回答" // drop the missing values

* 0 represents rural huko, 1 represents urban huko
gen huko = 0
replace huko = 1 if str_qa301 == "非农户口"




** Get the gender of the observation
decode cfps2012_gender_best , generate(str_gender)
* 0 represents female, 1 represents male
gen gender_code = 0
replace gender_code = 1 if str_gender == "男"





** Collect the education level of the observation
decode edu2012, generate(str_cfps2010edu)
drop if str_cfps2010edu == "缺失" | str_cfps2010edu == "不知道" | str_cfps2010edu == "不必读书" // drop the missing values

* 0 represents illiterate/semi-illiterate, 1 represents kindergarten， 2 represents primary school, 3 represents middle school
* 4 represents high schoold, 5 represents junior college, 6 represents bachelor's degree, 7 represent master's degree
* 8 represents Phd
gen edu_code = 0
replace edu_code = 1 if str_cfps2010edu == "幼儿园"
replace edu_code = 2 if str_cfps2010edu == "小学"
replace edu_code = 3 if str_cfps2010edu == "初中"
replace edu_code = 4 if str_cfps2010edu == "高中/中专/职高/技校"
replace edu_code = 5 if str_cfps2010edu == "大专"
replace edu_code = 6 if str_cfps2010edu == "大学本科"
replace edu_code = 7 if str_cfps2010edu == "硕士"
replace edu_code = 8 if str_cfps2010edu == "博士"




** Collect the health situation of the observation
decode qp201, generate(str_qp201)
drop if str_qp201 == "不适用" | str_qp201 == "不知道" | str_qp201 == "拒绝回答" // drop the missing values

*0 means unhealthy, 1 means fair, 2 means relatively healthy, 3 means healthy, and 4 means very healthy
gen health_code = 0
replace health_code = 1 if str_qp201 == "一般【不读出】"
replace health_code = 2 if str_qp201 == "比较健康"
replace health_code = 3 if str_qp201 == "很健康"
replace health_code = 4 if str_qp201 == "非常健康"
drop if age ==.




** merge the siblings data
merge m:m mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/2010_siblings.dta"
keep if _merge == 3
drop _merge




** merge the children information
merge m:m mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/child_information_2012.dta"
keep if _merge == 3
drop _merge



keep mmpid sib numb_birth str_provcd minority_code age p_insurance huko gender_code edu_code health_code income gender_c1 gender_c2 gender_c3 gender_c4 gender_c5 gender_c6 gender_c7 gender_c8 gender_c9 gender_c10    // keep the key variables
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2012.dta",replace  // save as cleaned_data_2012



clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2012.dta"
drop sib numb_birth
duplicates drop mmpid, force 
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2012_before_imputation.dta", replace // prepare the data for imputation

**I used R to imputed the missing values in income. The following is the code.
// install.packages("mice")
// install.packages("randomForest")
// install.packages("haven")
// library(haven)
// library(mice)
// library(randomForest)
//
// data <- read_dta("/Users/leslie/Desktop/coding sample/cleaned_data_2012_before_imputation.dta")
//
//
// str(data)
//
// imputed_data <- mice(data, m = 5, method = 'rf', seed = 500)
//
//
// summary(imputed_data)
//
// complete_data <- complete(imputed_data, 1)
//
//
// head(complete_data)
// write_dta(complete_data, "/Users/leslie/Desktop/coding sample/cleaned_data_2012_after_imputation.dta")

clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2012.dta"
duplicates drop mmpid, force
rename income income1
merge 1:1 mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2012_after_imputation.dta", keepusing(income)
drop income1
drop _merge
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2012.dta",replace  //overwrite the data with missing values


clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2012.dta"
rename sib siblings
rename minority_code minority
rename gender_code gender
rename edu_code edu
rename health_code health
rename numb_birth births
drop gender_c3-gender_c10
gen year = 2012
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2012_renamed.dta" , replace










**# 2014DATA
* Prepare the information of the children
clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2014data/cfps2014famconf_170630.dta"

** Get the number of children
foreach var of varlist code_a_c1 code_a_c2 code_a_c3 code_a_c4 code_a_c5 code_a_c6 code_a_c7 code_a_c8 code_a_c9 code_a_c10{
	tostring `var', generate(str_`var')
}
gen numb_birth_c = 0
replace numb_birth_c = 1 if str_code_a_c1 != "-8"
replace numb_birth_c = 2 if str_code_a_c2 != "-8"
replace numb_birth_c = 3 if str_code_a_c3 != "-8"
replace numb_birth_c = 4 if str_code_a_c4 != "-8"
replace numb_birth_c = 5 if str_code_a_c5 != "-8"
replace numb_birth_c = 6 if str_code_a_c6 != "-8"
replace numb_birth_c = 7 if str_code_a_c7 != "-8"
replace numb_birth_c = 8 if str_code_a_c8 != "-8"
replace numb_birth_c = 9 if str_code_a_c9 != "-8"
replace numb_birth_c = 10 if str_code_a_c10 != "-8"


** Get the  age of the children
tostring pid, generate(mmpid)
gen age_c1 = 2014-tb1y_a_c1
gen age_c2 = 2014-tb1y_a_c2
gen age_c3 = 2014-tb1y_a_c3
gen age_c4 = 2014-tb1y_a_c4
gen age_c5 = 2014-tb1y_a_c5
gen age_c6 = 2014-tb1y_a_c6
gen age_c7 = 2014-tb1y_a_c7
gen age_c8 = 2014-tb1y_a_c8
gen age_c9 = 2014-tb1y_a_c9
gen age_c10 = 2014-tb1y_a_c10


** Get the gender of the children
foreach var of varlist tb2_a_c1 tb2_a_c2 tb2_a_c3 tb2_a_c4 tb2_a_c5 tb2_a_c6 tb2_a_c7 tb2_a_c8 tb2_a_c9 tb2_a_c10{
	decode `var', generate(str_`var')
}
* 0 represents female, 1 represents male, -8 represents missing value
forvalues i = 1/10 {
    gen gender_c`i' = 0
    replace gender_c`i' = 1 if str_tb2_a_c`i' == "男"
    replace gender_c`i' = -8 if str_tb2_a_c`i' != "男" & str_tb2_a_c`i' != "女"
}

keep mmpid numb_birth_c  age_c1 age_c2 age_c3 age_c4 age_c5 age_c6 age_c7 age_c8 age_c9 age_c10 gender_c1 gender_c2 gender_c3 gender_c4 gender_c5 gender_c6 gender_c7 gender_c8 gender_c9 gender_c10  // keep the key variables

save "/Users/leslie/Desktop/coding sample/intergeneration_data/child_information_2014.dta",replace




clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2014data/cfps2014adult_201906.dta"
tostring pid , generate(str_pid_2014)
gen mmpid = str_pid_2014  // generate a matching ID



** Check whether the observation lives in urban area or rural area
decode urban14 , generate(str_urban)
gen urban_code = 0
drop if str_urban == "缺失"
replace urban_code = 1 if str_urban == "城镇"


** Check whether the observation has pension insurance
foreach var of varlist cfps_gender qa301 cfps2014edu qp201 qi201_s_1 qi201_s_2 qi201_s_3 qi201_s_4 qi201_s_5 qg9_s_1 qg9_s_2 qg9_s_3 qg9_s_4 qg9_s_5{
	decode `var', generate(str_`var')
}

gen retire_insurance = 0
gen working_insurance = 0

forvalues i = 1/5 {
    replace retire_insurance = 1 if str_qi201_s_`i' != "不适用" & str_qi201_s_`i' != "拒绝回答" & str_qi201_s_`i' != "不知道" & str_qi201_s_`i' != "确实" & str_qi201_s_`i' != "以上都没有"
}

replace working_insurance = 1 if str_qg9_s_1 == "养老保险" | str_qg9_s_2 == "养老保险" | str_qg9_s_3 == "养老保险" | str_qg9_s_4 == "养老保险" | str_qg9_s_5 == "养老保险"

* 0 represents no pension insurance, 1 represents having pension insurance
gen insurance_code = 0
replace insurance_code = 1 if retire_insurance == 1 | working_insurance == 1





** Collect the huko
drop if str_qa301 == "不知道" | str_qa301 == "没有户口" | str_qa301 == "不适用(非中国国籍)"
gen huko = 0
replace huko = 1 if str_qa301 == "非农业户口"




** Collect the gender
gen gender_code = 0
replace gender_code = 1 if str_cfps_gender == "男"





** Collect the education level of the observations
drop if str_cfps2014edu == "缺失" | str_cfps2014edu == "不知道" | str_cfps2014edu == "不必读书" //drop the missing value
gen edu_code = 0
replace edu_code = 1 if str_cfps2014edu == "文盲/半文盲"
replace edu_code = 2 if str_cfps2014edu == "小学"
replace edu_code = 3 if str_cfps2014edu == "初中"
replace edu_code = 4 if str_cfps2014edu == "高中/中专/技校/职高"
replace edu_code = 5 if str_cfps2014edu == "大专"
replace edu_code = 6 if str_cfps2014edu == "大学本科"
replace edu_code = 7 if str_cfps2014edu == "硕士"
replace edu_code = 8 if str_cfps2014edu == "博士"




** Collect the health situation of the observation
drop if str_qp201 == "不适用" | str_qp201 == "不知道" | str_qp201 == "拒绝回答" //drop the missing values
gen health_code = 0
replace health_code = 1 if str_qp201 == "一般"
replace health_code = 2 if str_qp201 == "比较健康"
replace health_code = 3 if str_qp201 == "很健康"
replace health_code = 4 if str_qp201 == "非常健康"


** Collect the ideal number of children
decode qm501, generate(str_qm501)
drop if qm501 == .
drop if str_qm501 == "拒绝回答" | str_qm501 == "不知道"



** Collect the number of children
foreach var of varlist code_a_c1 code_a_c2 code_a_c3 code_a_c4 code_a_c5 code_a_c6 code_a_c7 code_a_c8 code_a_c9 code_a_c10{
	tostring `var', generate(str_`var')
}
gen numb_birth = 0
replace numb_birth = 1 if str_code_a_c1 != "-8"
replace numb_birth = 2 if str_code_a_c2 != "-8"
replace numb_birth = 3 if str_code_a_c3 != "-8"
replace numb_birth = 4 if str_code_a_c4 != "-8"
replace numb_birth = 5 if str_code_a_c5 != "-8"
replace numb_birth = 6 if str_code_a_c6 != "-8"
replace numb_birth = 7 if str_code_a_c7 != "-8"
replace numb_birth = 8 if str_code_a_c8 != "-8"
replace numb_birth = 9 if str_code_a_c9 != "-8"
replace numb_birth = 10 if str_code_a_c10 != "-8"

** merge the number of siblings 
merge m:m mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/2010_siblings.dta"
keep if _merge == 3
drop _merge





keep  mmpid sib qm501 numb_birth str_provcd minority_code age_2014 retire_insurance working_insurance huko gender_code edu_code health_code insurance_code income provcd14 urban_code  // keep the key variables
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2014.dta",replace // save as cleaned_data_2014




clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2014.dta"
merge m:m mmpid using "/Users/leslie/Desktop/coding sample/intergeneration_data/child_information_2014.dta"
gen diff = numb_birth-numb_birth_c
drop if _merge != 3
drop _merge
drop if diff != 0
drop diff  // drop if there are wrong information


bysort mmpid: gen count = _N

drop if count != 1
drop count   //drop the observations appear more than once
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2014.dta", replace  // overwrite the cleaned_data_2014


clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2014.dta"
drop sib age_c1 - gender_c10 numb_birth qm501 
replace income = . if income < 0
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2014_before_imputation.dta", replace  // prepare the data for imputation


**I used R to imputed the missing values in income. The following is the code.
// install.packages("mice")
// install.packages("randomForest")
// install.packages("haven")
// library(haven)
// library(mice)
// library(randomForest)
//
// data <- read_dta("/Users/leslie/Desktop/coding sample/cleaned_data_2014_before_imputation.dta")
//
//
// str(data)
//
// imputed_data <- mice(data, m = 5, method = 'rf', seed = 500)
//
//
// summary(imputed_data)
//
// complete_data <- complete(imputed_data, 1)
//
//
// head(complete_data)
// write_dta(complete_data, "/Users/leslie/Desktop/coding sample/cleaned_data_2014_after_imputation.dta")


clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2014.dta"
rename income income1
merge 1:1 mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2014_after_imputation.dta", keepusing(income)
drop income1
drop _merge
tabu numb_birth // the tabel 2 in the writing sample
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2014.dta",replace  // overwrite the cleaned_data_2014



clear all 
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2014.dta"
rename qm501 i_numb_c
rename sib siblings
rename minority_code minority
rename age_2014 age
rename insurance_code p_insurance
rename gender_code gender
rename edu_code edu
rename health_code health
rename numb_birth births
drop age_c1-age_c10 gender_c3-gender_c10 provcd14 i_numb_c working_insurance retire_insurance numb_birth_c
gen year = 2014
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2014_renamed.dta" , replace









**# 2016DATA
clear all
use "/Users/leslie/Desktop/coding sample//CFPS/2016data/cfps2016famconf_201804.dta"
tostring pid, generate(mmpid)  // generate the matching ID

foreach var of varlist pid pid_c1 pid_c2 pid_c3 pid_c4 pid_c5 pid_c6 pid_c7 pid_c8 pid_c9 pid_c10{
	tostring `var', generate(str_`var')
}
foreach var of varlist code_a_c1 code_a_c2 code_a_c3 code_a_c4 code_a_c5 code_a_c6 code_a_c7 code_a_c8 code_a_c9 code_a_c10{
	tostring `var', generate(str_`var')
}

** Get the number of children
gen numb_birth = 0
replace numb_birth = 1 if str_code_a_c1 != "-8" &  str_code_a_c1 != "79"
replace numb_birth = 2 if str_code_a_c2 != "-8" &  str_code_a_c2 != "79"
replace numb_birth = 3 if str_code_a_c3 != "-8" &  str_code_a_c3 != "79"
replace numb_birth = 4 if str_code_a_c4 != "-8" &  str_code_a_c4 != "79"
replace numb_birth = 5 if str_code_a_c5 != "-8" &  str_code_a_c5 != "79"
replace numb_birth = 6 if str_code_a_c6 != "-8" &  str_code_a_c6 != "79"
replace numb_birth = 7 if str_code_a_c7 != "-8" &  str_code_a_c7 != "79"
replace numb_birth = 8 if str_code_a_c8 != "-8" &  str_code_a_c8 != "79"
replace numb_birth = 9 if str_code_a_c9 != "-8" &  str_code_a_c9 != "79"
replace numb_birth = 10 if str_code_a_c10 != "-8" &  str_code_a_c10 != "79"


** Get the gender of the children
foreach var of varlist tb2_a_c1 tb2_a_c2 tb2_a_c3 tb2_a_c4 tb2_a_c5 tb2_a_c6 tb2_a_c7 tb2_a_c8 tb2_a_c9 tb2_a_c10{
	decode `var', generate(str_`var')
}

* 0 represents female, 1 represents male, -8 represents missing value
forvalues i = 1/10 {
    gen gender_c`i' = 0
    replace gender_c`i' = 1 if str_tb2_a_c`i' == "男"
    replace gender_c`i' = -8 if str_tb2_a_c`i' != "男" & str_tb2_a_c`i' != "女"
}
keep mmpid numb_birth gender_c1 gender_c2 gender_c3 gender_c4 gender_c5 gender_c6 gender_c7 gender_c8 gender_c9 gender_c10 
save "/Users/leslie/Desktop/coding sample/intergeneration_data/child_information_2016.dta",replace



clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2016data/cfps2016adult_201906.dta"
tostring pid, generate(mmpid)
rename cfps_age age
drop if age < 0



** Check whether the observation has pension insurance
foreach var of varlist qi2001 qg9_s_1 qg9_s_2 qg9_s_3 qg9_s_4 qg9_s_5{
	decode `var', generate(str_`var')
}
foreach var of varlist str_qi2001 str_qg9_s_1 str_qg9_s_2 str_qg9_s_3 str_qg9_s_4 str_qg9_s_5{
	drop if `var' == "不知道"
} // drop the missing values
generate p_insurance = 0
* 0 represents no pension insurance, 1 represents having pension insurance
foreach var of varlist  str_qi2001 str_qg9_s_1 str_qg9_s_2 str_qg9_s_3 str_qg9_s_4 str_qg9_s_5{
	replace p_insurance = 1 if `var' == "是" | `var' == "养老保险"
}





** Check the huko of the observation
decode pa301 ,generate(str_pa301)
drop if str_pa301 == "不知道" | str_pa301 == "没有户口" | str_pa301 == "不适用(非中国国籍)" | str_pa301 == "拒绝回答"
* 0 represents rural huko, 1 represents urban huko
gen huko = 0
replace huko = 1 if str_pa301 == "非农业户口"


** Collect the gender of the observation
decode cfps_gender , generate(str_gender)
gen gender_code = 0
replace gender_code = 1 if str_gender == "男"



** Collect the education level of the observations
decode cfps2016edu, generate(str_cfps2010edu)
drop if str_cfps2010edu == "缺失" | str_cfps2010edu == "不知道" | str_cfps2010edu == "不必读书" //drop the missing values
* 0 represents illiterate/semi-illiterate, 1 represents kindergarten， 2 represents primary school, 3 represents middle school
* 4 represents high schoold, 5 represents junior college, 6 represents bachelor's degree, 7 represent master's degree
* 8 represents Phd
gen edu_code = 0
replace edu_code = 1 if str_cfps2010edu == "文盲/半文盲"
replace edu_code = 2 if str_cfps2010edu == "小学"
replace edu_code = 3 if str_cfps2010edu == "初中"
replace edu_code = 4 if str_cfps2010edu == "高中/中专/技校/职高"
replace edu_code = 5 if str_cfps2010edu == "大专"
replace edu_code = 6 if str_cfps2010edu == "大学本科"
replace edu_code = 7 if str_cfps2010edu == "硕士"
replace edu_code = 8 if str_cfps2010edu == "博士"






** Collect the health situation of the observation
decode qp201, generate(str_qp201)
drop if str_qp201 == "不适用" | str_qp201 == "不知道" | str_qp201 == "拒绝回答" | str_qp201 == "缺失" // drop the missing values
*0 means unhealthy, 1 means fair, 2 means relatively healthy, 3 means healthy, and 4 means very healthy
gen health_code = 0
replace health_code = 1 if str_qp201 == "一般"
replace health_code = 2 if str_qp201 == "比较健康"
replace health_code = 3 if str_qp201 == "很健康"
replace health_code = 4 if str_qp201 == "非常健康"


merge m:m mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/2010_siblings.dta"  // merge the siblings
keep if _merge == 3
drop _merge


merge m:m mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/child_information_2016.dta" // merge the number of children
keep if _merge == 3
drop _merge



keep mmpid sib numb_birth str_provcd minority_code age p_insurance huko gender_code edu_code health_code income gender_c1 gender_c2 gender_c3 gender_c4 gender_c5 gender_c6 gender_c7 gender_c8 gender_c9 gender_c10
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016.dta",replace // save as cleaned_data_2016


clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016.dta"
drop sib numb_birth
duplicates drop mmpid, force
replace income = . if income < 0
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016_before_imputation.dta", replace  // prepare the data for imputation

**I used R to imputed the missing values in income. The following is the code.
// install.packages("mice")
// install.packages("randomForest")
// install.packages("haven")
// library(haven)
// library(mice)
// library(randomForest)
//
// data <- read_dta("/Users/leslie/Desktop/coding sample/cleaned_data_2016_before_imputation.dta")
//
//
// str(data)
//
// imputed_data <- mice(data, m = 5, method = 'rf', seed = 500)
//
//
// summary(imputed_data)
//
// complete_data <- complete(imputed_data, 1)
//
//
// head(complete_data)
// write_dta(complete_data, "/Users/leslie/Desktop/coding sample/cleaned_data_2016_after_imputation.dta")





clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016.dta"
duplicates drop mmpid, force
rename income income1
merge 1:1 mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016_after_imputation.dta", keepusing(income)
drop income1
drop _merge
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016.dta",replace


clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016.dta"
rename sib siblings
rename minority_code minority
rename gender_code gender
rename edu_code edu
rename health_code health
rename numb_birth births
drop gender_c3-gender_c10 
gen year = 2016
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016_renamed.dta" , replace











**# 2018DATA
clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2018data/cfps2018famconf_202008.dta", clear
foreach var of varlist pid pid_a_c1 pid_a_c2 pid_a_c3 pid_a_c4 pid_a_c5 pid_a_c6 pid_a_c7 pid_a_c8 pid_a_c9 pid_a_c10{
	tostring `var', generate(str_`var')
}
gen mmpid = str_pid

** Prepare the number of the childern
* NOTE: Some of the observations can only provide the information of their younger children. I use this method to avoid missing counting.
foreach var of varlist code_a_c1 code_a_c2 code_a_c3 code_a_c4 code_a_c5 code_a_c6 code_a_c7 code_a_c8 code_a_c9 code_a_c10{
	tostring `var', generate(str_`var')
}
gen numb_birth = 0
replace numb_birth = 1 if str_code_a_c1 != "-8"
replace numb_birth = 2 if str_code_a_c2 != "-8"
replace numb_birth = 3 if str_code_a_c3 != "-8"
replace numb_birth = 4 if str_code_a_c4 != "-8"
replace numb_birth = 5 if str_code_a_c5 != "-8"
replace numb_birth = 6 if str_code_a_c6 != "-8"
replace numb_birth = 7 if str_code_a_c7 != "-8"
replace numb_birth = 8 if str_code_a_c8 != "-8"
replace numb_birth = 9 if str_code_a_c9 != "-8"
replace numb_birth = 10 if str_code_a_c10 != "-8"





** Collect the gender of the childern
foreach var of varlist tb2_a_c1 tb2_a_c2 tb2_a_c3 tb2_a_c4 tb2_a_c5 tb2_a_c6 tb2_a_c7 tb2_a_c8 tb2_a_c9 tb2_a_c10{
	decode `var', generate(str_`var')
}
* 0 represents female, 1 represents male, -8 represents missing value
forvalues i = 1/10 {
    gen gender_c`i' = 0
    replace gender_c`i' = 1 if str_tb2_a_c`i' == "男"
    replace gender_c`i' = -8 if str_tb2_a_c`i' != "男" & str_tb2_a_c`i' != "女"
}




keep mmpid numb_birth gender_c1 gender_c2 gender_c3 gender_c4 gender_c5 gender_c6 gender_c7 gender_c8 gender_c9 gender_c10
save "/Users/leslie/Desktop/coding sample/intergeneration_data/child_information_2018.dta",replace  // save the prepared children information



clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2018data/cfps2018person_202012.dta"
tostring pid,generate(str_pid_2018)
gen mmpid = str_pid_2018


foreach var of varlist gender_update cfps2018edu qa301 qp201 qi301_a_2 qi301_a_3 qi301_a_4 qi301_a_5 qi301_a_6 qi301_a_7 qg9_a_1 qi2001{
	decode `var', generate(str_`var')
}

** Check whether the observation has pension insurance
gen retire_insurance = 0
gen working_insurance = 0
drop if str_qi2001 == "不知道"
replace retire_insurance = 1 if str_qi2001 == "是"
replace working_insurance = 1 if str_qg9_a_1 == "是" | str_qi301_a_2 == "是" | str_qi301_a_3 == "是" | str_qi301_a_4 == "是" | str_qi301_a_5 == "是" | str_qi301_a_6 == "是" | str_qi301_a_7 == "是"
* 0 represents no pension insurance, 1 represents having pension insurance
gen p_insurance = 0
replace p_insurance = 1 if retire_insurance == 1 | working_insurance == 1 







** Check the huko(household registration) of the observation 
drop if str_qa301 == "不知道" | str_qa301 == "没有户口" | str_qa301 == "不适用(非中国国籍)" | str_qa301 == "不适用"
gen huko = 0
* 0 represents rural huko, 1 represents urban huko
replace huko = 1 if str_qa301 == "非农业户口"






** Collect tge gender of the observation
gen gender_code = 0
replace gender_code = 1 if str_gender == "男"
* 0 represents female, 1 represents male






** Collect the education level of the observation
drop if str_cfps2018edu == "缺失" | str_cfps2018edu == "不知道" | str_cfps2018edu == "不必读书" //drop the missing values
gen edu_code = 0
* 0 represents illiterate/semi-illiterate, 1 represents kindergarten， 2 represents primary school, 3 represents middle school
* 4 represents high schoold, 5 represents junior college, 6 represents bachelor's degree, 7 represent master's degree
* 8 represents Phd
replace edu_code = 1 if str_cfps2018edu == "文盲/半文盲"
replace edu_code = 2 if str_cfps2018edu == "小学"
replace edu_code = 3 if str_cfps2018edu == "初中"
replace edu_code = 4 if str_cfps2018edu == "高中/中专/技校/职高"
replace edu_code = 5 if str_cfps2018edu == "大专"
replace edu_code = 6 if str_cfps2018edu == "大学本科"
replace edu_code = 7 if str_cfps2018edu == "硕士"
replace edu_code = 8 if str_cfps2018edu == "博士"






** Collect the health situation of the observation
drop if str_qp201 == "不适用" | str_qp201 == "不知道" | str_qp201 == "拒绝回答" //drop the missing values
gen health_code = 0
*0 means unhealthy, 1 means fair, 2 means relatively healthy, 3 means healthy, and 4 means very healthy
replace health_code = 1 if str_qp201 == "一般"
replace health_code = 2 if str_qp201 == "比较健康"
replace health_code = 3 if str_qp201 == "很健康"
replace health_code = 4 if str_qp201 == "非常健康"



** collect the ideal number of children
decode qka202 , generate(str_qka202)
drop if qka202 ==.
drop if str_qka202 == "不适用" | str_qka202 == "拒绝回答" | str_qka202 == "不知道"





merge m:m mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/2010_siblings.dta"  //merge the siblings
keep if _merge == 3 
drop _merge



merge m:m mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/child_information_2018.dta"   // merge the children information
keep if _merge == 3
drop _merge


replace income = . if income < 0
keep mmpid sib qka202 numb_birth str_provcd minority_code age_2018 retire_insurance working_insurance  p_insurance huko gender_code edu_code health_code income gender_c1 gender_c2 gender_c3 gender_c4 gender_c5 gender_c6 gender_c7 gender_c8 gender_c9 gender_c10
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2018.dta",replace // save as cleaned_data_20199


clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2018.dta"
drop sib numb_birth qka202 
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2018_before_imputation.dta", replace  // prepare the data for imputation


**I used R to imputed the missing values in income. The following is the code.
// install.packages("mice")
// install.packages("randomForest")
// install.packages("haven")
// library(haven)
// library(mice)
// library(randomForest)
//
// data <- read_dta("/Users/leslie/Desktop/coding sample/cleaned_data_2018_before_imputation.dta")
//
//
// str(data)
//
// imputed_data <- mice(data, m = 5, method = 'rf', seed = 500)
//
//
// summary(imputed_data)
//
// complete_data <- complete(imputed_data, 1)
//
//
// head(complete_data)
// write_dta(complete_data, "/Users/leslie/Desktop/coding sample/cleaned_data_2018_after_imputation.dta")



clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2018.dta"
rename income income1
merge 1:1 mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2018_after_imputation.dta", keepusing(income)
drop income1
drop _merge
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2018.dta",replace // overwrite




clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2018.dta"

rename qka202 i_numb_c
rename sib siblings
rename minority_code minority
rename age_2018 age
rename gender_code gender
rename edu_code edu
rename health_code health
rename numb_birth births
drop working_insurance retire_insurance gender_c3-gender_c10 i_numb_c
gen year = 2018
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2018_renamed.dta" , replace










**# 2020DATA

** prepare the children information
clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2020data/cfps2020famconf_202306.dta"
foreach var of varlist pid pid_a_c1 pid_a_c2 pid_a_c3 pid_a_c4 pid_a_c5 pid_a_c6 pid_a_c7 pid_a_c8 pid_a_c9 pid_a_c10{
	tostring `var', generate(str_`var')
}
gen mmpid = str_pid

** Prepare the number of the childern
* NOTE: Some of the observations can only provide the information of their younger children. I use this method to avoid missing counting.
foreach var of varlist code_a_c1 code_a_c2 code_a_c3 code_a_c4 code_a_c5 code_a_c6 code_a_c7 code_a_c8 code_a_c9 code_a_c10{
	tostring `var', generate(str_`var')
}
gen numb_birth = 0
replace numb_birth = 1 if str_code_a_c1 != "-8" &  str_code_a_c1 != "79"
replace numb_birth = 2 if str_code_a_c2 != "-8" &  str_code_a_c2 != "79"
replace numb_birth = 3 if str_code_a_c3 != "-8" &  str_code_a_c3 != "79"
replace numb_birth = 4 if str_code_a_c4 != "-8" &  str_code_a_c4 != "79"
replace numb_birth = 5 if str_code_a_c5 != "-8" &  str_code_a_c5 != "79"
replace numb_birth = 6 if str_code_a_c6 != "-8" &  str_code_a_c6 != "79"
replace numb_birth = 7 if str_code_a_c7 != "-8" &  str_code_a_c7 != "79"
replace numb_birth = 8 if str_code_a_c8 != "-8" &  str_code_a_c8 != "79"
replace numb_birth = 9 if str_code_a_c9 != "-8" &  str_code_a_c9 != "79"
replace numb_birth = 10 if str_code_a_c10 != "-8" &  str_code_a_c10 != "79"





** Collect the gender of the childern
foreach var of varlist tb2_a_c1 tb2_a_c2 tb2_a_c3 tb2_a_c4 tb2_a_c5 tb2_a_c6 tb2_a_c7 tb2_a_c8 tb2_a_c9 tb2_a_c10{
	decode `var', generate(str_`var')
}
* 0 represents female, 1 represents male, -8 represents missing value
forvalues i = 1/10 {
    gen gender_c`i' = 0
    replace gender_c`i' = 1 if str_tb2_a_c`i' == "男"
    replace gender_c`i' = -8 if str_tb2_a_c`i' != "男" & str_tb2_a_c`i' != "女"
}
keep mmpid numb_birth gender_c1 gender_c2 gender_c3 gender_c4 gender_c5 gender_c6 gender_c7 gender_c8 gender_c9 gender_c10
save "/Users/leslie/Desktop/coding sample/intergeneration_data/child_information_2020.dta",replace


clear all
use "/Users/leslie/Desktop/coding sample/CFPS/2020data/cfps2020person_202306.dta"
tostring pid,generate(str_pid_2020)
gen mmpid = str_pid_2020



** Check whether the observation has pension insurance
foreach var of varlist qg9_a_1 qi2001 qi301_a_2 qi301_a_3 qi301_a_4 qi301_a_5 qi301_a_6 qi301_a_7{
	decode `var', generate(str_`var')
}

gen p_insurance = 0

* drop the missing values
drop if str_qi2001 == "不知道"
drop if str_qg9_a_1 == "拒绝回答" | str_qg9_a_1 == "不知道"
drop if str_qi301_a_2 == "缺失" | str_qi301_a_2 == "拒绝回答" | str_qi301_a_2 == "不知道"
drop if str_qi301_a_3 == "缺失" | str_qi301_a_3 == "拒绝回答" | str_qi301_a_3 == "不知道"
drop if str_qi301_a_4 == "缺失" | str_qi301_a_4 == "拒绝回答" | str_qi301_a_4 == "不知道"
drop if str_qi301_a_5 == "缺失" | str_qi301_a_5 == "拒绝回答" | str_qi301_a_5 == "不知道"
drop if str_qi301_a_6 == "缺失" | str_qi301_a_6 == "拒绝回答" | str_qi301_a_6 == "不知道"
drop if str_qi301_a_7 == "缺失" | str_qi301_a_7 == "拒绝回答" | str_qi301_a_7 == "不知道"

* 0 represents no pension insurance, 1 represents having pension insurance
replace p_insurance = 1 if str_qi2001 == "是" | str_qg9_a_1 == "是" | str_qi301_a_2 == "是" | str_qi301_a_3 == "是" | str_qi301_a_4 == "是" | str_qi301_a_5 == "是" | str_qi301_a_6 == "是" | str_qi301_a_7 == "是"





** Check the huko(household registration) of the observation 
decode qa301 ,generate(str_qa301)
drop if str_qa301 == "不知道" | str_qa301 == "没有户口" | str_qa301 == "不适用（非中国国籍）" | str_qa301 == "不适用" | str_qa301 == "拒绝回答"
gen huko = 0
* 0 represents rural huko, 1 represents urban huko
replace huko = 1 if str_qa301 == "非农业户口" | str_qa301 == "居民户口"





** Collect tge gender of the observation
decode gender , generate(str_gender)
gen gender_code = 0
replace gender_code = 1 if str_gender == "男"






** Collect the education level of the observation
decode cfps2020edu, generate(str_cfps2020edu)
drop if str_cfps2020edu == "缺失" | str_cfps2020edu == "不知道" | str_cfps2020edu == "不必读书" // drop the missing values

gen edu_code = 0
* 0 represents illiterate/semi-illiterate, 1 represents kindergarten， 2 represents primary school, 3 represents middle school
* 4 represents high schoold, 5 represents junior college, 6 represents bachelor's degree, 7 represent master's degree
* 8 represents Phd
replace edu_code = 1 if str_cfps2020edu == "文盲/半文盲"
replace edu_code = 2 if str_cfps2020edu == "小学"
replace edu_code = 3 if str_cfps2020edu == "初中"
replace edu_code = 4 if str_cfps2020edu == "高中/中专/技校/职高"
replace edu_code = 5 if str_cfps2020edu == "大专"
replace edu_code = 6 if str_cfps2020edu == "大学本科"
replace edu_code = 7 if str_cfps2020edu == "硕士"
replace edu_code = 8 if str_cfps2020edu == "博士"





** Collect the health situation of the observation
decode qp201, generate(str_qp201)
drop if str_qp201 == "不适用" | str_qp201 == "不知道" | str_qp201 == "拒绝回答" // drop the missing values
gen health_code = 0
*0 means unhealthy, 1 means fair, 2 means relatively healthy, 3 means healthy, and 4 means very healthy
replace health_code = 1 if str_qp201 == "一般"
replace health_code = 2 if str_qp201 == "比较健康"
replace health_code = 3 if str_qp201 == "很健康"
replace health_code = 4 if str_qp201 == "非常健康"





merge m:m mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/2010_siblings.dta"  // merge the siblings
keep if _merge == 3
drop _merge


merge m:m mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/child_information_2020.dta"   // merge the children information
keep if _merge == 3
drop _merge


rename emp_income income
replace income = . if income < 0
keep mmpid sib numb_birth str_provcd minority_code age p_insurance huko gender_code edu_code health_code income gender_c1 gender_c2 gender_c3 gender_c4 gender_c5 gender_c6 gender_c7 gender_c8 gender_c9 gender_c10
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2020.dta",replace // save as cleaned_data_2020



* prepare the data for impuatation

clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2020.dta"
drop sib numb_birth
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2020_before_imputation.dta", replace

**I used R to imputed the missing values in income. The following is the code.
// install.packages("mice")
// install.packages("randomForest")
// install.packages("haven")
// library(haven)
// library(mice)
// library(randomForest)
//
// data <- read_dta("/Users/leslie/Desktop/coding sample/cleaned_data_2020_before_imputation.dta")
//
//
// str(data)
//
// imputed_data <- mice(data, m = 5, method = 'rf', seed = 500)
//
//
// summary(imputed_data)
//
// complete_data <- complete(imputed_data, 1)
//
//
// head(complete_data)
// write_dta(complete_data, "/Users/leslie/Desktop/coding sample/cleaned_data_2020_after_imputation.dta")


clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2020.dta"
rename income income1
merge 1:1 mmpid using"/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2020_after_imputation.dta", keepusing(income)
drop income1
drop _merge
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2020.dta",replace  //overwrite


clear all
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2020.dta"
rename sib siblings
rename minority_code minority
rename gender_code gender
rename edu_code edu
rename health_code health
rename numb_birth births
drop gender_c3-gender_c10 
gen year = 2020
save "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2020_renamed.dta" , replace
