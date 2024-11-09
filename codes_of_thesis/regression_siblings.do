*************************
*       Yunfeng Wu      *
*  yw4250@columbia.edu  *
*  Columbia University  *
*  Econ  Thesis Code    *
*************************


** Append all the cleaned data into one file, and run the regression
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

