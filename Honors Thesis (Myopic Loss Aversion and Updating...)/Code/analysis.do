**This file was used to conduct data analysis for my senior honors thesis, titled "Myopic Loss Aversion and Updating in the Presence of Safety"



**Data Analysis
**Creates the labexpalldata.dta file

**The following import statements eliminate "botched" sessions or pilot studies.
import delimited using "/Users/myleswinkley/Dropbox/Honors Thesis/MLA Monthly Data/MLAMonthly_2022-02-16.csv", clear
drop if participant_index_in_pages != 1000
drop if participant_is_bot==1
save monthlynoinfoclean, replace


import delimited using "/Users/myleswinkley/Dropbox/Honors Thesis/MonthlyInfo/MLAMonthly_2022-02-10.csv",clear
drop if participant_index_in_pages != 1000
drop if participant_is_bot==1
save monthlyinfoclean, replace


import delimited using "/Users/myleswinkley/Dropbox/Honors Thesis/MLA Five Yearly/MLAFiveYearly_2022-03-09.csv", clear
drop if sessioncode != "t96dqzcx" & sessioncode != "pxzyofgo" & sessioncode != "aiib48gt"
drop if participant_index_in_pages != 25
save fiveyearlynoinfoclean, replace

import delimited using "/Users/myleswinkley/Dropbox/Honors Thesis/Data Analysis/MLAFiveYearlyInfo_2022-03-09 (1).csv", clear
drop if participant_index_in_pages != 25
save fiveyearlyinfoclean, replace


use monthlynoinfoclean, clear
append using monthlyinfoclean
append using fiveyearlynoinfoclean
append using fiveyearlyinfoclean
save labexpalldata, replace
**End of Data File Creation


eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAMonthly"
est store monthly

eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAMonthlyInfo"
est store monthlyinfo

eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearly"
est store fiveyearly

eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearlyInfo"
est store fiveyearlyinfo

suest fiveyearly fiveyearlyinfo, vce(cluster participantid_in_session)
test [fiveyearly_mean]subsessionround_number=[fiveyearlyinfo_mean]subsessionround_number

suest monthly monthlyinfo, vce(cluster participantid_in_session)
test [monthly_mean]subsessionround_number=[monthlyinfo_mean]subsessionround_number

suest fiveyearly monthly, vce(cluster participantid_in_session)
test [fiveyearly_mean]subsessionround_number=[monthly_mean]subsessionround_number

suest fiveyearlyinfo monthlyinfo, vce(cluster participantid_in_session)
test [fiveyearlyinfo_mean]subsessionround_number=[monthlyinfo_mean]subsessionround_number

estout using results_regression_unclustered.txt, replace cells("b p" se)
eststo clear

eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAMonthly",cluster(participantcode)
est store monthly

eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAMonthlyInfo",cluster(participantcode)
est store monthlyinfo

eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearly",cluster(participantcode)
est store fiveyearly

eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearlyInfo",cluster(participantcode)
est store fiveyearlyinfo

estout using results_regression_clustered.txt, replace cells("b p" se)
eststo clear


reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearly" & subsessionround_number > 2
est store fiveyearly2

reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearly" & subsessionround_number <= 2
est store fiveyearly3

reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearlyInfo" & subsessionround_number > 2
est store fiveyearlyinfo2

reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearlyInfo" & subsessionround_number <= 2
est store fiveyearlyinfo3


suest fiveyearly2 fiveyearly3
test [fiveyearly2_mean]subsessionround_number=[fiveyearly3_mean]subsessionround_number

suest fiveyearlyinfo2 fiveyearlyinfo3
test [fiveyearlyinfo2_mean]subsessionround_number=[fiveyearlyinfo3_mean]subsessionround_number


reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAMonthly" & subsessionround_number > 160
est store monthly

reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAMonthlyInfo" & subsessionround_number > 160
est store monthlyinfo

drop if (participant_current_app_name == "MLAMonthlyInfo" | participant_current_app_name == "MLAMonthly") & (subsessionround_number!= 1 & subsessionround_number!= 41 & subsessionround_number!= 81 & subsessionround_number!= 121 & subsessionround_number!=161) 
**selects for increcements of 40 to match b/w monthly and five-yearly
gen five_yearly_equivalent_1 = 0 
gen five_yearly_equivalent_2 = 0
gen five_yearly_equivalent_3 = 0
gen five_yearly_equivalent_4 = 0
gen five_yearly_equivalent_5 = 0
gen info = 0 
replace info = 1 if participant_current_app_name=="MLAMonthlyInfo" | participant_current_app_name == "MLAFiveYearlyInfo"

gen frequency = 0 
replace frequency = 1 if participant_current_app_name=="MLAFiveYearly" | participant_current_app_name=="MLAFiveYearlyInfo"

replace five_yearly_equivalent_1 = 1 if (participant_current_app_name == "MLAFiveYearly" | participant_current_app_name == "MLAFiveYearlyInfo") & subsessionround_number == 1
replace five_yearly_equivalent_1 = 1 if (participant_current_app_name == "MLAMonthly" | participant_current_app_name == "MLAMonthlyInfo") & subsessionround_number==1

replace five_yearly_equivalent_2 = 1 if (participant_current_app_name == "MLAFiveYearly" | participant_current_app_name == "MLAFiveYearlyInfo") & subsessionround_number ==  2
replace five_yearly_equivalent_2 = 1 if (participant_current_app_name == "MLAMonthly" | participant_current_app_name == "MLAMonthlyInfo") & subsessionround_number==41

replace five_yearly_equivalent_3 = 1 if (participant_current_app_name == "MLAFiveYearly" | participant_current_app_name == "MLAFiveYearlyInfo") & subsessionround_number ==  3
replace five_yearly_equivalent_3 = 1 if (participant_current_app_name == "MLAMonthly" | participant_current_app_name == "MLAMonthlyInfo") & subsessionround_number==81

replace five_yearly_equivalent_4 = 1 if (participant_current_app_name == "MLAFiveYearly" | participant_current_app_name == "MLAFiveYearlyInfo") & subsessionround_number ==  4
replace five_yearly_equivalent_4 = 1 if (participant_current_app_name == "MLAMonthly" | participant_current_app_name == "MLAMonthlyInfo") & subsessionround_number==121

replace five_yearly_equivalent_5 = 1 if (participant_current_app_name == "MLAFiveYearly" | participant_current_app_name == "MLAFiveYearlyInfo") & subsessionround_number ==  5
replace five_yearly_equivalent_5 = 1 if (participant_current_app_name == "MLAMonthly" | participant_current_app_name == "MLAMonthlyInfo") & subsessionround_number==161
replace subsessionround_number=1 if subsessionround_number==1
replace subsessionround_number=2 if subsessionround_number==41
replace subsessionround_number=3 if subsessionround_number==81
replace subsessionround_number=4 if subsessionround_number==121
replace subsessionround_number=5 if subsessionround_number==161


eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAMonthly", cluster(participantcode)
est store monthly

eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAMonthlyInfo", cluster(participantcode)
est store monthlyinfo

eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearly", cluster(participantcode)
est store fiveyearly

eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearlyInfo", cluster(participantcode)
est store fiveyearlyinfo

estout using results_regression_clustered_round.txt, replace cells("b p" se)
eststo clear


eststo: reg playerfund_a_allocation five_yearly_equivalent_2 five_yearly_equivalent_3 five_yearly_equivalent_4 five_yearly_equivalent_5 if participant_current_app_name == "MLAMonthly", cluster(participantcode)
est store monthly

eststo: reg playerfund_a_allocation five_yearly_equivalent_2 five_yearly_equivalent_3 five_yearly_equivalent_4 five_yearly_equivalent_5 if participant_current_app_name == "MLAMonthlyInfo", cluster(participantcode)
est store monthlyinfo

eststo: reg playerfund_a_allocation  five_yearly_equivalent_2 five_yearly_equivalent_3 five_yearly_equivalent_4 five_yearly_equivalent_5 if participant_current_app_name == "MLAFiveYearly", cluster(participantcode)
est store fiveyearly

eststo: reg playerfund_a_allocation  five_yearly_equivalent_2 five_yearly_equivalent_3 five_yearly_equivalent_4 five_yearly_equivalent_5 if participant_current_app_name == "MLAFiveYearlyInfo", cluster(participantcode)
est store fiveyearlyinfo
estout using results_regression_clustered_round_dummy.txt, replace cells("b p" se)
eststo clear


gen monthly_flag = ""
replace monthly_flag = "MLAMonthly" if participant_current_app_name == "MLAMonthly" 
replace monthly_flag = "MLAMonthlyInfo" if participant_current_app_name == "MLAMonthlyInfo"

gen yearly_flag = ""
replace yearly_flag = "MLAFiveYearly" if participant_current_app_name == "MLAFiveYearly" 
replace yearly_flag = "MLAFiveYearlyInfo" if participant_current_app_name == "MLAFiveYearlyInfo"

gen no_info_flag = ""
replace no_info_flag = "MLAMonthly" if participant_current_app_name == "MLAMonthly" 
replace no_info_flag = "MLAFiveYearly" if participant_current_app_name == "MLAFiveYearly" 

gen _info_flag = ""
replace _info_flag = "MLAMonthlyInfo" if participant_current_app_name == "MLAMonthlyInfo" 
replace _info_flag = "MLAFiveYearlyInfo" if participant_current_app_name == "MLAFiveYearlyInfo" 


**Tests of Equality of First Allocations
ttest playerfund_a_allocation if subsessionround_number==1, by(monthly_flag) unequal
ttest playerfund_a_allocation if subsessionround_number==1, by(yearly_flag) unequal
ttest playerfund_a_allocation if subsessionround_number==1, by(no_info_flag) unequal
ttest playerfund_a_allocation if subsessionround_number==1, by(_info_flag) unequal

**Tests of Equality of Final Allocations
ttest playerfund_a_allocation if subsessionround_number==5, by(monthly_flag) unequal
ttest playerfund_a_allocation if subsessionround_number==5, by(yearly_flag) unequal
ttest playerfund_a_allocation if subsessionround_number==5, by(no_info_flag) unequal
ttest playerfund_a_allocation if subsessionround_number==5, by(_info_flag) unequal


tabstat playerfund_a_allocation if participant_current_app_name == "MLAMonthly"
tabstat playerfund_a_allocation if participant_current_app_name == "MLAFiveYearly"
tabstat playerfund_a_allocation if participant_current_app_name == "MLAMonthlyInfo"
tabstat playerfund_a_allocation if participant_current_app_name == "MLAFiveYearlyInfo"


tabstat playerfund_a_allocation if participant_current_app_name == "MLAMonthly" & subsessionround_number==1, statistics(n mean semean cv)
tabstat playerfund_a_allocation if participant_current_app_name == "MLAFiveYearly" & subsessionround_number==1, statistics(n mean semean cv)
tabstat playerfund_a_allocation if participant_current_app_name == "MLAMonthlyInfo" & subsessionround_number==1, statistics(n mean semean cv)
tabstat playerfund_a_allocation if participant_current_app_name == "MLAFiveYearlyInfo" & subsessionround_number==1, statistics(n mean semean cv)


tabstat playerfund_a_allocation if participant_current_app_name == "MLAMonthly" & subsessionround_number==5, statistics(n mean semean cv)
tabstat playerfund_a_allocation if participant_current_app_name == "MLAFiveYearly" & subsessionround_number==5, statistics(n mean semean cv)
tabstat playerfund_a_allocation if participant_current_app_name == "MLAMonthlyInfo" & subsessionround_number==5, statistics(n mean semean cv)
tabstat playerfund_a_allocation if participant_current_app_name == "MLAFiveYearlyInfo" & subsessionround_number==5, statistics(n mean semean cv)