**This file was used to conduct data analysis for my senior honors thesis, titled "Myopic Loss Aversion and Updating in the Presence of Safety"



**Data Analysis
**Creates the labexpalldata.dta file

**The following import statements eliminate "botched" sessions or pilot studies.


*Imports the "Monthly" treatment group data
import delimited using "../Raw Experimental Data/MLAMonthly_2022-02-16.csv", clear
drop if participant_index_in_pages != 1000
drop if participant_is_bot==1
save "../Cleaned Experimental Data (STATA)/monthlynoinfoclean.dta", replace

*Imports the "Monthly Information" treatment group data
import delimited using "../Raw Experimental Data/MLAMonthly_2022-02-10.csv",clear
drop if participant_index_in_pages != 1000
drop if participant_is_bot==1
save "../Cleaned Experimental Data (STATA)/monthlyinfoclean.dta", replace

*Imports the "Five Yearly" treatment group data, making sure to select only the sessions which were error-free
import delimited using "../Raw Experimental Data/MLAFiveYearly_2022-03-09 (2).csv", clear
drop if sessioncode != "t96dqzcx" & sessioncode != "pxzyofgo" & sessioncode != "aiib48gt"
drop if participant_index_in_pages != 25
save "../Cleaned Experimental Data (STATA)/fiveyearlynoinfoclean.dta", replace

*Imports the "Five Yearly Information" treatment group data
import delimited using "../Raw Experimental Data/MLAFiveYearlyInfo_2022-03-09 (1).csv", clear
drop if participant_index_in_pages != 25
save "../Cleaned Experimental Data (STATA)/fiveyearlyinfoclean.dta", replace


use "../Cleaned Experimental Data (STATA)/monthlynoinfoclean.dta", clear
append using "../Cleaned Experimental Data (STATA)/monthlyinfoclean.dta"
append using "../Cleaned Experimental Data (STATA)/fiveyearlynoinfoclean.dta"
append using "../Cleaned Experimental Data (STATA)/fiveyearlyinfoclean.dta"
save "../Cleaned Experimental Data (STATA)/labexpalldata", replace
**End of Data File Creation


*Table Creation

label variable subsessionround_number "Trial Number"
label variable playerfund_a_allocation "Percentage Allocation to Fund A"

****Table 2 Creation***** 


**** Monthly
eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAMonthly"
est store monthly


**** Monthly Information 
eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAMonthlyInfo"
est store monthlyinfo

**** Five-Yearly 
eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearly"
est store fiveyearly


**** Five-Yearly Information
eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearlyInfo"
est store fiveyearlyinfo

**** Monthly
eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAMonthly",cluster(participantcode)
est store monthlycluster

**** Monthly Information
eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAMonthlyInfo",cluster(participantcode)
est store monthlyinfocluster

**** Five-Yearly
eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearly",cluster(participantcode)
est store fiveyearlycluster

**** Five-Yearly Information
eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearlyInfo",cluster(participantcode)
est store fiveyearlyinfocluster

****

esttab using "../Tables/table_one.csv", replace se 
 


eststo clear

*****


****Table 3 Creation*****
suest fiveyearly fiveyearlyinfo, vce(cluster participantid_in_session)
test [fiveyearly_mean]subsessionround_number=[fiveyearlyinfo_mean]subsessionround_number

suest monthly monthlyinfo, vce(cluster participantid_in_session)
test [monthly_mean]subsessionround_number=[monthlyinfo_mean]subsessionround_number

suest fiveyearly monthly, vce(cluster participantid_in_session)
test [fiveyearly_mean]subsessionround_number=[monthly_mean]subsessionround_number

suest fiveyearlyinfo monthlyinfo, vce(cluster participantid_in_session)
test [fiveyearlyinfo_mean]subsessionround_number=[monthlyinfo_mean]subsessionround_number



****TRobustness Checks****
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
******

****Table 5****
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


**Creating variables to match observations between treatment groups in terms of how "far" they are in the experiment
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
***



eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAMonthly", cluster(participantcode)
est store monthly

eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAMonthlyInfo", cluster(participantcode)
est store monthlyinfo

eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearly", cluster(participantcode)
est store fiveyearly

eststo: reg playerfund_a_allocation subsessionround_number if participant_current_app_name == "MLAFiveYearlyInfo", cluster(participantcode)
est store fiveyearlyinfo

estout using results_regression_clustered_round.txt, replace cells("b p" se)
est clear

eststo: reg playerfund_a_allocation five_yearly_equivalent_2 five_yearly_equivalent_3 five_yearly_equivalent_4 five_yearly_equivalent_5 if participant_current_app_name == "MLAMonthly", cluster(participantcode)
est store monthly

eststo: reg playerfund_a_allocation five_yearly_equivalent_2 five_yearly_equivalent_3 five_yearly_equivalent_4 five_yearly_equivalent_5 if participant_current_app_name == "MLAMonthlyInfo", cluster(participantcode)
est store monthlyinfo

eststo: reg playerfund_a_allocation  five_yearly_equivalent_2 five_yearly_equivalent_3 five_yearly_equivalent_4 five_yearly_equivalent_5 if participant_current_app_name == "MLAFiveYearly", cluster(participantcode)
est store fiveyearly

eststo: reg playerfund_a_allocation  five_yearly_equivalent_2 five_yearly_equivalent_3 five_yearly_equivalent_4 five_yearly_equivalent_5 if participant_current_app_name == "MLAFiveYearlyInfo", cluster(participantcode)
est store fiveyearlyinfo
esttab using "../Tables/table_five.csv", replace se 
est clear


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


****Table 6****

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

*****


****Table 6****
tabstat playerfund_a_allocation if participant_current_app_name == "MLAMonthly" & subsessionround_number==1, statistics(n mean semean cv)
tabstat playerfund_a_allocation if participant_current_app_name == "MLAFiveYearly" & subsessionround_number==1, statistics(n mean semean cv)
tabstat playerfund_a_allocation if participant_current_app_name == "MLAMonthlyInfo" & subsessionround_number==1, statistics(n mean semean cv)
tabstat playerfund_a_allocation if participant_current_app_name == "MLAFiveYearlyInfo" & subsessionround_number==1, statistics(n mean semean cv)


tabstat playerfund_a_allocation if participant_current_app_name == "MLAMonthly" & subsessionround_number==5, statistics(n mean semean cv)
tabstat playerfund_a_allocation if participant_current_app_name == "MLAFiveYearly" & subsessionround_number==5, statistics(n mean semean cv)
tabstat playerfund_a_allocation if participant_current_app_name == "MLAMonthlyInfo" & subsessionround_number==5, statistics(n mean semean cv)
tabstat playerfund_a_allocation if participant_current_app_name == "MLAFiveYearlyInfo" & subsessionround_number==5, statistics(n mean semean cv)
