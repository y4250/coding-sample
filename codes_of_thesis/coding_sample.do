*************************
*       Yunfeng Wu      *
*  yw4250@columbia.edu  *
*  Columbia University  *
*  Econ  Thesis Code    *
*************************

**# Overview for this coding sample
* This do.file contains parts of the code of my Master thesis.
* The topic of the thesis is the fertility in China.
* I analyzed two problems in this thesis.

* The FIRST one is the effect of the number of siblings on people's reproductive decision.
* In this part I used logit regressions.

* The SECOND one is the analysis of the policy effect of the "Comprehensive two-child Policy".
* In this part I used DID regressions with fixed effect.

* The data is from CFPS(China Family Panel Study). Many of the text data is in Chinese.
* This survey collects data every two years from 2010 to 2020. 
* Every year they have more than 1000 questions in the questionnaire.
* The questions and the name of the variables may change overtime.
* Necessary translations have been added for your review.




*************************C O N T E N T S****************************************
*  The effect of siblings(data clean)                     ...........line 44   *    
*  The effect of siblings(regressions)                    ...........line 1429 *
*  The graphs in the siblings part                        ...........line 1496 *
*  The DID preparations                                   ...........line 1581 *
*  The DID main regression                                ...........line 1929 *
*  The Placebo Test                                       ...........line 2060 *
*  The "fake" policy regression( parallel assumption)     ...........line 2096 *
*  The graphs in the DID part                             ...........line 2330 *
*  More discussion                                        ...........line 2371 *
********************************************************************************





**# The effect of the number of siblings on people's reproductive decision.

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
*                                                                              *
* For the graphs of this part in my writing sample, Please go to line 1720.    *
*                                                                              *
* For the DID part, please go to line 1805.                                    *
*                                                                              *
* For the More analysis part, please go to line 2595.                          *
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

*** I finished the data cleaning in this part.

** Append all the renamed data into one file
clear all
ssc install coefplot
ssc install estout
use "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2010_renamed.dta"
append using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2012_renamed.dta", nolabel
append using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2014_renamed.dta", nolabel
append using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2016_renamed.dta", nolabel
append using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2018_renamed.dta", nolabel
append using "/Users/leslie/Desktop/coding sample/intergeneration_data/cleaned_data_2020_renamed.dta", nolabel
drop if age < 49 // Only use the observations that already finished their reproductive period
gen y_1 = 0
replace y_1 = 1 if births > 0 //If a child has been born, the first childbirth choice is 1
gen y_2 = 0
replace y_2 = 1 if births > 1 //If a second child has been born, the second childbirth choice is 1
gen y_3 = 0
replace y_3 = 1 if births > 2 //If a third child has been born, the third childbirth choice is 1
eststo clear
*************************N O T E************************************************
* In my writing sample, I used the data from 2014 as my main regression.       *
* For the main regression, Please go to line 1452.                             *
********************************************************************************
* analysis of 2010-first child
eststo model2010_1_1:logit y_1 siblings if year == 2010,robust
eststo model2010_1_2:logit y_1 siblings minority age p_insurance gender edu huko health income if year == 2010 ,robust
* analysis of 2010-second child
eststo model2010_2_1:logit y_2 siblings if year == 2010 & gender_c1 != -8 , robust
eststo model2010_2_2:logit y_2 siblings minority age p_insurance gender edu huko health gender_c1 income  if year == 2010 & gender_c1 != -8 ,robust
* analysis of 2010-third child
eststo model2010_3_1:logit y_3 siblings if year == 2010 & gender_c1 != -8 & gender_c2 != -8 ,robust 
eststo model2010_3_2:logit y_3 siblings minority age p_insurance gender edu huko health income gender_c1 gender_c2 if year == 2010 & gender_c1 != -8 & gender_c2 != -8  , robust

* analysis of 2012-first child
eststo model2012_1_1:logit y_1 siblings if year == 2012,robust
eststo model2012_1_2:logit y_1 siblings minority age p_insurance gender edu huko health income if year == 2012 ,robust
* analysis of 2012-second child
eststo model2012_2_1:logit y_2 siblings if year == 2012 & gender_c1 != -8 , robust
eststo model2012_2_2:logit y_2 siblings minority age p_insurance gender edu huko health gender_c1 income  if year == 2012 & gender_c1 != -8 ,robust
* analysis of 2012-third child
eststo model2012_3_1:logit y_3 siblings if year == 2012 & gender_c1 != -8 & gender_c2 != -8 ,robust 
eststo model2012_3_2:logit y_3 siblings minority age p_insurance gender edu huko health income gender_c1 gender_c2 if year == 2012 & gender_c1 != -8 & gender_c2 != -8  , robust

**////MAIN REGRESSION IN THE WRITTING SAMPLE
* analysis of 2014-first child
eststo model2014_1_1:logit y_1 siblings if year == 2014,robust
eststo model2014_1_2:logit y_1 siblings minority age p_insurance gender edu huko health income if year == 2014 ,robust
* analysis of 2014-second child
eststo model2014_2_1:logit y_2 siblings if year == 2014 & gender_c1 != -8 , robust
eststo model2014_2_2:logit y_2 siblings minority age p_insurance gender edu huko health gender_c1 income  if year == 2014 & gender_c1 != -8 ,robust
* analysis of 2014-third child
eststo model2014_3_1:logit y_3 siblings if year == 2014 & gender_c1 != -8 & gender_c2 != -8 ,robust 
eststo model2014_3_2:logit y_3 siblings minority age p_insurance gender edu huko health income gender_c1 gender_c2 if year == 2014 & gender_c1 != -8 & gender_c2 != -8  , robust

* analysis of 2016-first child
eststo model2016_1_1:logit y_1 siblings if year == 2016,robust
eststo model2016_1_2:logit y_1 siblings minority age p_insurance gender edu huko health income if year == 2016 ,robust
* analysis of 2016-second child
eststo model2016_2_1:logit y_2 siblings if year == 2016 & gender_c1 != -8 , robust
eststo model2016_2_2:logit y_2 siblings minority age p_insurance gender edu huko health gender_c1 income  if year == 2016 & gender_c1 != -8 ,robust
* analysis of 2016-third child
eststo model2016_3_1:logit y_3 siblings if year == 2016 & gender_c1 != -8 & gender_c2 != -8 ,robust 
eststo model2016_3_2:logit y_3 siblings minority age p_insurance gender edu huko health income gender_c1 gender_c2 if year == 2016 & gender_c1 != -8 & gender_c2 != -8  , robust

* analysis of 2018-first child
eststo model2018_1_1:logit y_1 siblings if year == 2018,robust
eststo model2018_1_2:logit y_1 siblings minority age p_insurance gender edu huko health income if year == 2018 ,robust
* analysis of 2018-second child
eststo model2018_2_1:logit y_2 siblings if year == 2018 & gender_c1 != -8 , robust
eststo model2018_2_2:logit y_2 siblings minority age p_insurance gender edu huko health gender_c1 income  if year == 2018 & gender_c1 != -8 ,robust
* analysis of 2018-third child
eststo model2018_3_1:logit y_3 siblings if year == 2018 & gender_c1 != -8 & gender_c2 != -8 ,robust 
eststo model2018_3_2:logit y_3 siblings minority age p_insurance gender edu huko health income gender_c1 gender_c2 if year == 2018 & gender_c1 != -8 & gender_c2 != -8  , robust

* analysis of 2020-first child
eststo model2020_1_1:logit y_1 siblings if year == 2020,robust
eststo model2020_1_2:logit y_1 siblings minority age p_insurance gender edu huko health income if year == 2020 ,robust
* analysis of 2020-second child
eststo model2020_2_1:logit y_2 siblings if year == 2020 & gender_c1 != -8 , robust
eststo model2020_2_2:logit y_2 siblings minority age p_insurance gender edu huko health gender_c1 income  if year == 2020 & gender_c1 != -8 ,robust
* analysis of 2020-third child
eststo model2020_3_1:logit y_3 siblings if year == 2020 & gender_c1 != -8 & gender_c2 != -8 ,robust 
eststo model2020_3_2:logit y_3 siblings minority age p_insurance gender edu huko health income gender_c1 gender_c2 if year == 2020 & gender_c1 != -8 & gender_c2 != -8  , robust
esttab using all_results_siblings.csv, b se replace  // All the results


** The graphs in my writing sample 
* I used R to draw the graphs. The code is attached below.

// library(ggplot2)
// ##first-child
// data <- data.frame(
//   Year = c(2010, 2012, 2014, 2016, 2018, 2020),
//   Estimate = c(.1735312,.1603866,.1232109,.126133,.1366215,.1220189),
//   Lower_CI = c(.1045697,.1012282,.0397428, .0531483,.0674422,.0204921),
//   Upper_CI = c(.2424926,.219545,.2066791,.1991177,.2058009,.2235458)
// )
//
// ggplot(data, aes(x = Year, y = Estimate)) +
//   geom_point(color = "blue") +  
//   geom_errorbar(aes(ymin = Lower_CI, ymax = Upper_CI), width = 0.2) +  
//   labs(
//        x = "Year", y = "Estimate") +
//   scale_x_continuous(breaks = seq(2010, 2020, by = 2)) +  
//   scale_y_continuous(limits = c(0, 0.4)) +  
//   theme(
//     axis.title.x = element_text(size = 8),  
//     axis.title.y = element_text(size = 8),  
//     axis.text.x = element_text(size = 10),    
//     axis.text.y = element_text(size = 10)     
//   )
//
// ##second-child
// data <- data.frame(
//   Year = c(2010, 2012, 2014, 2016, 2018, 2020),
//   Estimate = c(.1221195,.1028458,.0792336, .1019507,.1017429,.0982737),
//   Lower_CI = c(.0981984,.0808229,.0521711,.0771254,.0780783,.0699719),
//   Upper_CI = c(.1460406,.1248688,.106296,.1267759,.1254075,.1265755)
// )
//
//
// ggplot(data, aes(x = Year, y = Estimate)) +
//   geom_point(color = "blue") +  
//   geom_errorbar(aes(ymin = Lower_CI, ymax = Upper_CI), width = 0.2) +  
//   labs( 
//        x = "Year", y = "Estimate") +
//   scale_x_continuous(breaks = seq(2010, 2020, by = 2)) +  
//   scale_y_continuous(limits = c(0,0.2)) +  
//   theme(
//     axis.title.x = element_text(size = 8),  
//     axis.title.y = element_text(size = 8),  
//     axis.text.x = element_text(size = 10),    
//     axis.text.y = element_text(size = 10)     
//   )
//
// ##third-child
// data <- data.frame(
//   Year = c(2010, 2012, 2014, 2016, 2018, 2020),
//   Estimate = c( -.0072923, -.0282919,-.0117206,-.0027642, -.0153276, -.0217559),
//   Lower_CI = c( -.029133,-.0508466,-.0364194,-.0253555, -.0407524,-.0491287),
//   Upper_CI = c(.0145484,-.0057373,.0129782,.0198271,.0100972,.005617)
// )
//
//
// ggplot(data, aes(x = Year, y = Estimate)) +
//   geom_point(color = "blue") +  
//   geom_errorbar(aes(ymin = Lower_CI, ymax = Upper_CI), width = 0.2) +  
//   labs(
//        x = "Year", y = "Estimate") +
//   scale_x_continuous(breaks = seq(2010, 2020, by = 2)) +  
//   scale_y_continuous(limits = c(-0.075,0.075)) +  
//   theme(
//     axis.title.x = element_text(size = 8),  
//     axis.title.y = element_text(size = 8),  
//     axis.text.x = element_text(size = 10),    
//     axis.text.y = element_text(size = 10)     
//   )


***********************Summary for the first part*******************************
* I used all the data to run the same regression and got same conclusion.      *
* In the writing sample, I used the results of 2014 as the main regression.    *
********************************************************************************







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
* Please go to line 2023 for regressions.                                      *
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

**DID REGRESSION in different regions
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


*****************************NOTE***********************************************
* In the following part, I used the same methods as above. I created two "fake"*
* policies to check whether the treatment effect is significant.               *
* For the graphs in my writing sample, please go to line 2330.                 *
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

** The graphs of this part in my writing sample
* Still, I used R and attached the code below.

// library(ggplot2)
// data <- data.frame(
//   Year = c(2014, 2016, 2018),
//   Estimate = c(.0100513,.0384102,-.0110373),
//   Lower_CI = c(   -.0040823,.0228732,-.0283652),
//   Upper_CI = c( .0241849,.0539472,.0062907)
// )
//
// ggplot(data, aes(x = Year, y = Estimate)) +
//   geom_point(color = "blue") + 
//   geom_errorbar(aes(ymin = Lower_CI, ymax = Upper_CI), width = 0.2) + 
//   labs(
//        x = "Year", y = "Estimate") +
//   scale_x_continuous(breaks = seq(2014,2018, by = 2)) +  
//   scale_y_continuous(limits = c(-0.03, 0.06)) +  
//   theme(
//     axis.title.x = element_text(size = 8),  
//     axis.title.y = element_text(size = 8),  
//     axis.text.x = element_text(size = 10),  
//     axis.text.y = element_text(size = 10)   
//   )


***************Summary for DID part*********************************************
* In this part, I firstly got the IDs for both treatment group and control     *
* group. Then I ran the regressions and do the tests. All the test results     *
* are good.                                                                    *
********************************************************************************









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
