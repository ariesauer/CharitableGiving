cap log close
set more off
clear

log using "C:\Users\Aries\Desktop\Thesis Research\Do Files\ThesisCleaning_Educ.log", replace

local files : dir "C:\Users\Aries\Desktop\Thesis Research\Data\IRS BMF\" files "*.csv"
di `files'

cd "C:\Users\Aries\Desktop\Thesis Research\Data\IRS BMF\"

/*foreach x in `files' {
import delimited "`x'" ,clear
save `x'.dta
}

*EDUCATION
 
NCLB start date is Jan 2002. Non profits have 5 months pass accper to submit new 990 form. 
For organizatinos with accper 1, they wouldn't need to have it in until June(6). 
Therefore, to get the end of year results for 2001, you need at least 0206 file 
and for 2002, you would need 0306 to get the 2002 results.

Definitions of before, during and after
Before: 1 Year before policy
During:1 year after
After:2 years after

Before: ends 01/2001-12/2001, so starting date 02/2000-01/2001*/

use "bmf.bm0201.csv.dta"
append using "bmf.bm0207.csv.dta", force

tostring ctaxper, replace
gen date = date(ctaxper,"YM")
format date %tmCYNN
drop if date < date("200101","YM") | date > date("200112","YM")
duplicates drop ein, force
gen period = 0

save "EducationBefore.dta", replace

clear

*During: 01/2002-12/2002

use "bmf.bm0301.csv.dta"
append using "bmf.bm0311.csv.dta", force

tostring ctaxper, replace
gen date = date(ctaxper,"YM")
format date %tmCYNN
drop if date < date("200201","YM") | date > date("200212","YM")
duplicates drop ein, force
gen period = 1

save "EducationDuring.dta", replace

*After : 01/2003- 12/2003

clear

use "bmf.bm0404.csv.dta"
append using "bmf.bm0412.csv.dta", force

tostring ctaxper, replace
gen date = date(ctaxper,"YM")
format date %tmCYNN
drop if date < date("200301","YM") | date > date("200312","YM")
duplicates drop ein, force
gen period = 2

save "EducationAfter.dta", replace

clear

use "EducationBefore.dta"
append using "EducationDuring.dta", force
append using "EducationAfter.dta", force


drop if ctotrev == . | outnccs == "OUT" | accper == 0 | frcd == 0 |inrange(fndncd,1,4) | inrange(frcd,60,61)| inrange(frcd,130,131)

gen year =  substr(ctaxper,1,4)
destring year, replace
keep ein period year name taxper state ruledate city zip5 fips ntee1 msa_nech subseccd ntmaj5 ntmaj10 ntmaj12 majgrpb ctotrev accper ctaxper
bysort ein period: carryforward fips ntee1 majgrpb ntmaj10 ntmaj12 ntmaj5 msa_nech, replace
gsort ein -period
by ein: carryforward fips ntee1 majgrpb ntmaj10 ntmaj12 ntmaj5 msa_nech, replace
multencode ntee1 state ntmaj5 ntmaj10 ntmaj12 majgrpb, generate(cntee cstate cntmaj5 cntmaj10 cntmaj12 cmajgrpb)


merge m:1 year fips using "C:\Users\Aries\Desktop\Thesis Research\Data\Census\uscensus_incomeandpoverty_2001.xlsx.dta", nogenerate
merge m:1 year fips using "C:\Users\Aries\Desktop\Thesis Research\Data\Census\uscensus_incomeandpoverty_2002.xlsx.dta", update nogenerate
merge m:1 year fips using "C:\Users\Aries\Desktop\Thesis Research\Data\Census\uscensus_incomeandpoverty_2003.xlsx.dta", update nogenerate
merge m:1 ctaxper using "C:\Users\Aries\Desktop\Thesis Research\Data\S&P500\Education.dta", update nogenerate

drop if ein == . | fips ==.
bysort ein: drop if _N == 1 | _N == 2

label var MedianHouseholdIncome "Median Household Income"
label var PovertyPercent "Percent in Poverty"
label var SPAverage "Average S&P 500"

save "C:\Users\Aries\Desktop\Thesis Research\Data\education.dta", replace

log close

