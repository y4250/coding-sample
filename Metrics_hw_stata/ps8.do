clear all
set more off
***Question(3)
***(a)
use "/Users/leslie/Desktop/statafile/ps8/gpa.dta"
xtset id term
xtreg trmgpa spring crsgpa frstsem season sat verbmath hsperc hssize black female, re
estimates store re

***(b)
xtreg trmgpa spring crsgpa frstsem season sat verbmath hsperc hssize black female, fe
estimates store fe

***(c)
hausman fe re

***Question5
clear all
set more off
use "/Users/leslie/Desktop/statafile/ps8/income_democracy.dta"
***(a)
xtset code year
tab year
tab code

***(b)
list dem_ind if country=="United States" & year==1965
list dem_ind if country=="Uruguay" & year==1965
list dem_ind if country=="Trinidad and Tobago" & year==1995
list dem_ind if country=="Venezuela, RB" & year==1995

***(c)
summarize dem_ind
centile dem_ind,centile(10 25 50 75 90)

***(d)
reg dem_ind log_gdppc, cluster(country)

***(e)
***The coefficient of log of gdp in part(d) is significant since the p-value is 0.000, so we can reject the null that the coefficent is equal to 0. And this coefficient means that if gdp per captia increase 1%, democracy index increase 0.002356731 unit.

***(f)
***As in part(e), if there is 20% increase in gdp per captia, democracy index is predicted to increase 0.0472 unit. And the 95% confidence interval for the prediction is [0.0425,0.518]

***(g)
xtreg dem_ind log_gdppc,fe cluster(country)

***(h)
xtreg dem_ind log_gdppc i.year ,fe cluster(country)

***(i)
xtreg dem_ind log_gdppc,fe
estimates store fe
xtreg dem_ind log_gdppc,re
estimates store re
hausman fe re
