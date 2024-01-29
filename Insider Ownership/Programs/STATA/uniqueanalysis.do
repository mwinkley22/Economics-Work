version 16.1
use "/Users/mwinkley/Dropbox/Insider Ownership/Constructed/STATA/uidualclassIO.dta", clear
joinby gvkey using "/Users/mwinkley/Dropbox/Insider Ownership/Existing Data Sets/transferpro.dta"
drop if _merge != 3
gen class_b = shrout_a if vote_a > vote_b
replace class_b = shrout_b if vote_b < vote_a
gen correctness = totalsharecount/class_b

eststo clear
estpost summarize correctness
eststo correctness2
esttab correctness2 using "/Users/mwinkley/Dropbox/Insider Ownership/Tables and Graphics/correctnessui.rtf", replace main(mean %6.2f) aux(sd) nomtitles nonumber nostar

drop if totalsharecount == 0

eststo clear
quietly regress correctness age
eststo regression
esttab regression using "/Users/mwinkley/Dropbox/Insider Ownership/Tables and Graphics/uicorrectnessagereg.rtf", replace se r2 nostar ///
title(Unique Insiders "Correctness" Regression Results) 
eststo clear


estpost corr class_b totalsharecount
eststo correlation
esttab using "/Users/mwinkley/Dropbox/Insider Ownership/Tables and Graphics/uiclassbtotalcountcorr.rtf", replace se r2 nostar
eststo clear

graph matrix class_b totalsharecount, title (Class B Shares vs. Indirect Derivative Shares)
graph save "Graph" "/Users/mwinkley/Dropbox/Insider Ownership/Programs/Graphics/UIConstructActualScatter.gph", replace

graph twoway (connected IOmeanage age), ylabel(0(.1)1.5) title (Mean Insider Ownership (Updated) vs. Age)
graph save "/Users/mwinkley/Dropbox/Insider Ownership/Programs/Graphics/UImeanIOagenew.gph", replace

graph twoway (connected IOmeanage2 age), ylabel(0(.1)1.5) title (Mean Insider Ownership (Old) vs. Age)
graph save "Graph" "/Users/mwinkley/Dropbox/Insider Ownership/Programs/Graphics/UImeanIOageold.gph", replace

graph twoway (connected IOmedianage age), ylabel(0(.1).5) title (Median Insider Ownership (Updated) vs. Age)
graph save "Graph" "/Users/mwinkley/Dropbox/Insider Ownership/Programs/Graphics/UImedianIOagenew.gph", replace

graph twoway (connected IOmedianage2 age), ylabel(0(.1).5) title (Median Insider Ownership (Old) vs. Age)
graph save "Graph" "/Users/mwinkley/Dropbox/Insider Ownership/Programs/Graphics/UImedianIOageold.gph", replace
