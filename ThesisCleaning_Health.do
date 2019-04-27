cap log close
set more off
clear

log using "C:\Users\Aries\Desktop\Thesis Research\Do Files\ThesisCleaning_Health.log", replace

local files : dir "C:\Users\Aries\Desktop\Thesis Research\Data\IRS BMF\" files "*.csv"
di `files'

cd "C:\Users\Aries\Desktop\Thesis Research\Data\IRS BMF\"


/*foreach x in `files' {
import delimited "`x'" ,clear
save `x'.dta
}

The affordable care act was sign in March 2010. 
Non profits have 5 months pass accper to submit new 990 form.  
fndncd is organization types and 2-4 dropped are private foundations.

Definitions of before, during and after
Before: 1 Year before policy
During:1 year after
After:2 years after

Ctaxper is just the taxper variable confirmed by the NCCS files. since the Nccs 
files only go up to 2015, we have to use taxper for later years. 

Before : March 2009- February 2010*/

use "bmf.bm0904.csv.dta"
append using "bmf.bm0907.csv.dta", force
append using "bmf.bm0910.csv.dta", force
append using "bmf.bm1001.csv.dta", force
append using "bmf.bm1005.csv.dta", force
append using "bmf.bm1008.csv.dta", force
append using "bmf.bm1011.csv.dta", force

drop if substr(string(ctaxper),1,2) == "12"
tostring ctaxper, replace
gen date = date(ctaxper,"YM")
format date %tmCYNN
drop if date < date("200903","YM") | date > date("201002","YM")
duplicates drop ein, force
gen period = 0

save "HealthBefore.dta", replace

*During: March 2010- February 2011
clear
use  "bmf.bm1001.csv.dta"
append using "bmf.bm1005.csv.dta",force
append using "bmf.bm1008.csv.dta",force
append using "bmf.bm1011.csv.dta", force
append using "bmf.bm1106.csv.dta", force
append using "bmf.bm1107.csv.dta", force
append using "bmf.bm1110.csv.dta", force
append using "bmf.bm1202.csv.dta", force

drop if substr(string(ctaxper),1,2) == "12"
tostring ctaxper, replace
gen date = date(ctaxper,"YM")
format date %tmCYNN
drop if date < date("201003","YM") | date > date("201102","YM")
duplicates drop ein, force
gen period = 1

save "HealthDuring.dta", replace

*After: March 2011- February 2012

clear
use "bmf.bm1106.csv.dta"
append using "bmf.bm1110.csv.dta", force
append using "bmf.bm1111.csv.dta", force
append using "bmf.bm1112.csv.dta", force
append using "bmf.bm1202.csv.dta", force
append using "bmf.bm1206.csv.dta", force
append using "bmf.bm1208.csv.dta", force
append using "bmf.bm1212.csv.dta", force
append using "bmf.bm1302.csv.dta", force
append using "bmf.bm1304.csv.dta", force

drop if substr(string(ctaxper),1,2) == "12"
tostring ctaxper, replace
gen date = date(ctaxper,"YM")
format date %tmCYNN
drop if date < date("201103","YM") | date > date("201202","YM")
duplicates drop ein, force
gen period = 2

save "HealthAfter.dta", replace
clear

use "HealthBefore.dta"
append using "HealthDuring.dta", force
append using "HealthAfter.dta", force

drop if ctotrev == . | outnccs == "OUT" | accper == 0 | frcd == 0 |inrange(fndncd,1,4) | inrange(frcd,60,61)| inrange(frcd,130,131)
gen year =  substr(ctaxper,1,4)

keep ein period year name state ruledate city zip5 fips ntee1 msa_nech subseccd ntmaj5 ntmaj10 ntmaj12 majgrpb ctotrev accper ctaxper

destring fips,replace
destring year, replace
bysort ein period: carryforward fips ntee1 majgrpb ntmaj10 ntmaj12 ntmaj5 msa_nech, replace
gsort ein -period
by ein: carryforward fips ntee1 majgrpb ntmaj10 ntmaj12 ntmaj5 msa_nech, replace
multencode ntee1 state ntmaj5 ntmaj10 ntmaj12 majgrpb, generate(cntee cstate cntmaj5 cntmaj10 cntmaj12 cmajgrpb)

merge m:1 fips year using "C:\Users\Aries\Desktop\Thesis Research\Data\Census\uscensus_incomeandpoverty_2010.xlsx.dta", update nogenerate
merge m:1 fips year using "C:\Users\Aries\Desktop\Thesis Research\Data\Census\uscensus_incomeandpoverty_2011.xlsx.dta", update nogenerate
merge m:1 fips year using "C:\Users\Aries\Desktop\Thesis Research\Data\Census\uscensus_incomeandpoverty_2012.xlsx.dta", update nogenerate
merge m:1 fips year using "C:\Users\Aries\Desktop\Thesis Research\Data\Census\uscensus_incomeandpoverty_2013.xlsx.dta", update nogenerate
merge m:1 ctaxper using "C:\Users\Aries\Desktop\Thesis Research\Data\S&P500\Health.dta", update nogenerate

drop if ein == . | fips ==.

bysort ein: drop if _N == 1 | _N == 2

label var MedianHouseholdIncome "Median Household Income"
label var PovertyPercent "Percent in Poverty"
label var SPAverage "Average S&P 500"

save "C:\Users\Aries\Desktop\Thesis Research\Data\health.dta", replace




log close
