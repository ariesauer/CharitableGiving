cap log close
set more off
clear

log using "C:\Users\Aries\Desktop\Thesis Research\Do Files\ThesisCleaning_Env.log", replace

local files : dir "C:\Users\Aries\Desktop\Thesis Research\Data\IRS BMF\" files "*.csv"
di `files'

cd "C:\Users\Aries\Desktop\Thesis Research\Data\IRS BMF\"

/*foreach x in `files' {
import delimited "`x'" ,clear
save `x'.dta
}

ENVIROMENTAL

The Clean Power Plan was announced August 2015. 
Non profits have 5 months pass accper to submit new 990 form. For organizatinos with
accper 8, they wouldn't need to have it in until Januar(1). Therefore, to get the end of year
results for 2015, you need at least 01/16 file and for 2016 you would need 01/17.

Definitions of before, during and after
Before: 1 Year before policy
During:1 year after
After:2 years after*/

clear

*Before August 2014-July 2015

use "bmf.bm1502.csv.dta"
append using "bmf.bm1504.csv.dta", force
append using "bmf.bm1505.csv.dta", force
append using "bmf.bm1507.csv.dta", force
append using "bmf.bm1509.csv.dta", force
append using "bmf.bm1511.csv.dta", force
append using "bmf.bm1512.csv.dta", force
append using "bmf.bm1602.csv.dta",force

tostring ctaxper, replace
gen date = date(ctaxper,"YM")
format date %tmCYNN
drop if date < date("201408","YM") | date > date("201507","YM")
duplicates drop ein, force
gen period = 0
save "EnviromentalBefore.dta", replace

clear

*During August 2015-July 2016

use "bmf.bm1602.csv.dta"
append using "bmf.bm1512.csv.dta", force
append using "bmf.bm1603.csv.dta", force
append using "bmf.bm1604.csv.dta", force
append using "bmf.bm1608.csv.dta", force
append using "bmf.bm1709.csv.dta", force


tostring ctaxper, replace
gen date = date(ctaxper,"YM")
format date %tmCYNN
drop if date < date("201508","YM")
drop if date > date("201607","YM")
duplicates drop ein, force
gen period = 1
save "EnviromentalDuring.dta", replace

clear

/*After August 2016-July 2017 : Data doesn't go past 11/2016*/

use "eobmf201612us"
append using "eobmf201712us.dta", force
append using "eobmf201803us.dta", force

rename revenue_amt ctotrev
rename ruling ruledate
rename acct_pd accper
rename foundation fndncd
rename tax_per ctaxper
rename subsection subseccd 

drop if zip =="00000-0000"
gen zip5 = substr(zip,1,5)
destring zip5,replace
destring zip, replace
tostring ctaxper, replace
gen date = date(ctaxper,"YM")
format date %tmCYNN
drop if date < date("201608","YM") | date > date("201707","YM")
duplicates drop ein, force
gen period = 2
save "EnviromentalAfter.dta", replace

clear

use "EnviromentalBefore.dta"
append using "EnviromentalDuring.dta", force
append using "EnviromentalAfter.dta", force

drop if ctotrev == . | outnccs == "OUT" | accper == 0 | frcd == 0 |inrange(fndncd,1,4) | inrange(frcd,60,61)| inrange(frcd,130,131)

gen year =  substr(ctaxper,1,4)
destring year, replace

/*outnccs is out of scope aka not actually in the usa.
fndncd is organization types and 2-4 dropped are private foundations.
*/


keep ein period year name state ruledate city zip5 fips ntee1 msa_nech subseccd ntmaj5 ntmaj10 ntmaj12 majgrpb ctotrev accper ctaxper

sort ein period
bysort ein: carryforward fips ntee1 majgrpb ntmaj10 ntmaj12 ntmaj5 msa_nech, replace
gsort ein -period
by ein: carryforward fips ntee1 majgrpb ntmaj10 ntmaj12 ntmaj5 msa_nech, replace
multencode ntee1 state ntmaj5 ntmaj10 ntmaj12 majgrpb, generate(cntee cstate cntmaj5 cntmaj10 cntmaj12 cmajgrpb)

merge m:1 fips year using "C:\Users\Aries\Desktop\Thesis Research\Data\Census\uscensus_incomeandpoverty_2014.xlsx.dta", update nogenerate
merge m:1 fips year using "C:\Users\Aries\Desktop\Thesis Research\Data\Census\uscensus_incomeandpoverty_2015.xlsx.dta", update nogenerate
merge m:1 fips year using "C:\Users\Aries\Desktop\Thesis Research\Data\Census\uscensus_incomeandpoverty_2016.xlsx.dta", update nogenerate
merge m:1 fips year using "C:\Users\Aries\Desktop\Thesis Research\Data\Census\uscensus_incomeandpoverty_2017.xlsx.dta", update nogenerate
merge m:1 ctaxper using "C:\Users\Aries\Desktop\Thesis Research\Data\S&P500\Enviromental.dta", update nogenerate

drop if ein == . | fips ==.
bysort ein: drop if _N == 1 | _N == 2

label var MedianHouseholdIncome "Median Household Income"
label var PovertyPercent "Percent in Poverty"
label var SPAverage "Average S&P 500"

save "C:\Users\Aries\Desktop\Thesis Research\Data\enviromental.dta", replace

*1,025,364 observations

log close
