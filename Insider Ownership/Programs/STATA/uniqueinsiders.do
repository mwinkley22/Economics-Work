version 16.1 
use "/Users/mwinkley/Dropbox/Insider Ownership/Constructed/STATA/owni2uifinal.dta", clear
rename *, lower
drop if missing(cusip6)
egen firmpersonid = group(cusip6 personid)
sort firmpersonid year
xtset firmpersonid year


tsfill, full
local carryvars personid owner cusip6 fdate cdate noinit acqdispc acqdispch acqdispch2 derivreportvar shares_adjnew sharescount year firmpersonid
foreach arg of local carryvars {
	bysort firmpersonid: carryforward `arg', gen(new`arg')
	replace `arg' =  new`arg' if missing(`arg')
}

/*drops observations for years before an insider has records*/
drop if missing(personid)

keep personid owner cusip6 sharescount year firmpersonid

save "/Users/mwinkley/Dropbox/Insider Ownership/Constructed/STATA/owni2uicleaned.dta", replace


joinby year cusip6 using "/Users/mwinkley/Dropbox/Insider Ownership/WRDS/gvkeycusip.dta", unmatched(master)
drop if missing(gvkey)
drop _merge

save "/Users/mwinkley/Dropbox/Insider Ownership/Constructed/STATA/uicountsgvkey.dta", replace

/*eliminates counts which are negative, most likely due to an error that hasn't been accounted for*/
drop if sharescount < 0

gen totalsharecounts = 0
sort gvkey year personid
by gvkey year: replace totalsharecount = sharescount if _n == 1
by gvkey year: replace totalsharecount = totalsharecount[_n-1] + sharescount if _n != 1

by gvkey year: gen counter = _n
by gvkey year: egen maxcounter = max(counter)
by gvkey year: drop if counter != maxcounter

keep cusip6 year gvkey totalsharecount


save "/Users/mwinkley/Dropbox/Insider Ownership/Constructed/STATA/uifirmcountsgvkey.dta", replace


joinby year gvkey using "/Users/mwinkley/Dropbox/Insider Ownership/Existing Data Sets/master.dta", unmatched(using)

rename _merge _merge1
rename year fyear
joinby gvkey fyear using "/Users/mwinkley/Dropbox/Insider Ownership/Existing Data Sets/originalinsidercounts.dta", unmatched(both)


replace totalsharecount = 0 if missing(totalsharecount)
gen updateaggholdings = agg_ins_tot_hldgs_adj + totalsharecount

sort gvkey fyear
gen IOnew = updateaggholdings/(shrout_a+shrout_b)
gen IOold = agg_ins_tot_hldgs_adj/(shrout_a+shrout_b)
bysort age: egen IOmeanage = mean(IOnew)
bysort age: egen IOmedianage = median(IOnew)
bysort age: egen IOmeanage2 = mean(IOold)
bysort age: egen IOmedianage2 = median(IOold)


save "/Users/mwinkley/Dropbox/Insider Ownership/Constructed/STATA/uidualclassIO.dta", replace



estpost summarize IOnew IOold
eststo summstats
esttab summstats using "/Users/mwinkley/Dropbox/Insider Ownership/Tables and Graphics/IOnewoldui.rtf",  replace main(mean %6.2f) aux(sd) nomtitles nonumber nostar /// 
coeflabel(IOnew "Updated Insider Ownership Percentage" IOold "Old Insider Ownership Percentage") ///
title(Table 1. Summary Statistics, Insider Ownership Comparison for Unique Insiders) ///
nonotes addn(Standard deviations in parentheses.)
