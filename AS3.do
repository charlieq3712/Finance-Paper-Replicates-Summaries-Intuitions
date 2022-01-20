**************************************************************************
***  BA952 Assignment3
***  Replication for "Passive Investors, Not Passive Owners"
***  Authors: Chunyu Qu
**************************************************************************
clear
clear matrix
clear mata
set mem 512m
set more 1 

gl rawdata "D:\Duke\17Spring\BA952\Assignment3\rawdata"
gl tempdata "D:\Duke\17Spring\BA952\Assignment3\tempdata"
gl dofile "D:\Duke\17Spring\BA952\Assignment3\dofile"
gl logfile "D:\Duke\17Spring\BA952\Assignment3\logfile"
gl output "D:\Duke\17Spring\BA952\Assignment3\output"

capture log close
log using $logfile/AS3.log,replace

*************************** Raw Data *******************************

*process CRSP_stock accounting data (in this table date=fdate, no difference)
use "$rawdata\CRSP_Stock.dta", replace
gen year=year(date)
gen month_1=month(date)
ren prc prc_stock1
ren shrout shrout_stock1
save "$tempdata\CRSP_Stock1.dta",replace

*Russell data
use "$rawdata\russell_all.dta",replace
gen date=dofm(yearmonth)
format date %d
gen year=year(date)
sort year r2000 adj_mrktvalue
*rank 1 = the smallest
duplicates tag year r2000, gen(tag)
by year r2000: egen ran=rank(adj_mrktvalue)
by year r2000: drop if r2000==0 & ran>250
by year r2000: drop if r2000==1 & ran<(tag+1-250+1)
save "$tempdata\Russell.dta",replace

*Independent Board from Riskmetrics(Directors)
use "$rawdata\Board.dta",replace
gen ind=1 if classification=="I"
replace ind=0 if ind==.
gen num=1
ren cusip cusip6
collapse (sum) ind num, by(cusip6 year)
gen ind_board=100*ind/num
save "$tempdata\Board_ind.dta",replace

*Takeover defenses and dual class shares from Riskmetrics(Governance)
use "$rawdata\Governance.dta", replace
ren cn6 cusip6
sort cusip6 year
by cusip6: gen lspmtlag=lspmt[_n-1]
gen glspmt = lspmt-lspmtlag
replace glspmt=0 if glspmt==.
save "$tempdata\Governance_1.dta",replace

*ROA(Compustat)
use "$rawdata\Compstat_annual.dta", replace
gen ROA=ni/at
save "$tempdata\Compstat_1.dta",replace

**************************************************************************

*Mutual Fund Holdings from Thomson
use "$rawdata\TRMF12S.dta", replace

gen year=year(rdate)
gen month=month(rdate)
keep if month==6 | month==9
drop if year<1998 | year>2006
drop if cusip==""
duplicates tag fundno year, gen(label_y)
duplicates tag fundno year month, gen(label_m)

gen month_1=month
replace month_1=9 if label_y==label_m & year<2004
drop if month_1==6

*merge with CRSP_stock to adjust stock outstanding shares and prices
merge m:1 cusip year month_1 using "$tempdata\CRSP_Stock1.dta",keepusing(prc_stock1 shrout_stock1)
drop if _merge==2
drop _merge
ren prc_stock1 prc_stock
ren shrout_stock1 shrout_stock
*replace missing data of shrout2 using shrout1*1000
*shrout_stock is in 1000s
replace shrout2=shrout1*1000 if shrout2==.

replace prc_stock=prc if fdate==rdate & prc_stock==.
replace shrout_stock=shrout2 if fdate==rdate & shrout_stock==.

****** identify passive and active fund ******

*merge with MFLink
merge m:1 fundno fdate using "$rawdata\mflink2_raw.dta", keepusing(wficn fundname mgrcoab num_holdings)
drop if _merge==1 |_merge==2
drop _merge
save "$tempdata\TRMF12S_1.dta",replace

*CRSP mutual fund quarterly data lacks observations in 1998
use "$rawdata\CRSP_MFDB_annual.dta",replace
gen year=year(caldt)
keep if year<=1998
drop year
save "$tempdata\CRSP_MFDB_a1.dta",replace
*append CRSP mutual fund annual data in year 1998
use "$rawdata\CRSP_MFDB.dta",replace
ap using "$tempdata\CRSP_MFDB_a1.dta"
merge m:1 crsp_fundno using "$rawdata\mflink1_raw.dta", keepusing(wficn fund_name)
drop if _merge==2
drop _merge

*flag=1 if passive; flag=2 if active; flag=3 if unclassified
gen ind_flag=1 if index_fund_flag!="" 

gen name1="Index"
gen name2="Idx"
gen name3="Indx"
gen name4="Ind_"
gen name5="Russell"
gen name6="S & P"
gen name7="S and P"
gen name8="S&P"
gen name9="SandP"
gen name10="SP"
gen name11="DOW"
gen name12="Dow"
gen name13="DJ"
gen name14="MSCI"
gen name15="Bloomberg"
gen name16="KBW"
gen name17="NASDAQ"
gen name18="NYSE"
gen name19="STOXX"
gen name20="FTSE"
gen name21="Wilshire"
gen name22="Morningstar"
gen name23="100"
gen name24="400"
gen name25="500"
gen name26="600"
gen name27="900"
gen name28="1000"
gen name29="1500"
gen name30="2000"
gen name31="5000"

forval i = 1(1)31{
	replace ind_flag=1 if regexm(fund_name,name`i')==1
}
drop name*

*index_flag is available after 2003 
*assumes that funds is consistent with their strategies before 2003
drop if wficn==.
bysort wficn: egen ind=max(ind_flag)
gen year=year(caldt)
gen month=month(caldt)
collapse (mean) ind, by (wficn year)
save "$tempdata\CRSP_MFDB_2.dta",replace

use "$tempdata\TRMF12S_1.dta",replace

merge m:1 wficn year using "$tempdata\CRSP_MFDB_2.dta"
drop if _merge==2

ren ind ind_flag
*flag=1 if passive; flag=2 if active; flag=3 if unclassified
replace ind_flag=2 if _merge==3 & ind_flag!=1
replace ind_flag=3 if _merge==1

collapse (sum) shares (max) prc_stock shrout_stock, by (cusip year ind_flag)

merge m:1 cusip year using "$tempdata\Russell.dta", keepusing(switch2to1 switch1to2 ran adj_mrktvalue r2000)
drop if _merge!=3
drop _merge

*share1=passive share2=active share3=unclassified
bysort cusip year: gen share1=shares if ind_flag==1
bysort cusip year: gen share2=shares if ind_flag==2
bysort cusip year: gen share3=shares if ind_flag==3
collapse (max) share1 share2 share3 prc_stock shrout_stock r2000 (mean) adj_mrktvalue, by (cusip year)

forval i = 1(1)3{
	gen percen`i'=share`i'/(shrout_stock*1000)
}
gen percen=percen1+percen2+percen3
drop if percen>1

save "$tempdata\TRMF12S_2.dta",replace

*merge with CRSP_stock to get the price and shrout at the end of May
use "$tempdata\CRSP_Stock1.dta",replace
keep if month_1==5
ren prc_stock prc_M1
ren shrout_stock shrout_M1
save "$tempdata\CRSP_Stock1_M.dta",replace

use "$tempdata\TRMF12S_2.dta",replace
merge 1:1 cusip year using "$tempdata\CRSP_Stock1_M.dta", keepusing(prc_M1 shrout_M1)
drop if _merge==2
drop _merge
ren prc_M= prc_M1
ren shrout_M=shrout_M1
ren makcap=prc_M*shrout_M
drop if makcap==.

gen ln_mktcap=log(makcap)
gen ln_mktcap2=ln_mktcap^2
gen ln_mktcap3=ln_mktcap^3
gen ln_float=log(adj_mrktvalue)

replace percen1=percen1*100
replace percen2=percen2*100
replace percen3=percen3*100
replace percen=percen*100
egen sd1 = sd(percen1)
egen sd = sd(percen)
gen percen1_sd=percen1/sd1
gen percen_sd=percen/sd
drop sd*

gen cusip6=substr(cusip,1,6)
duplicates tag cusip6 year, gen(label)
bysort cusip6: egen label1=max(label)
drop if label1!=0
drop label label1
merge 1:1 cusip6 year using "$tempdata\Board_ind.dta", keepusing(ind_board)
drop if _merge==2
drop _merge
merge 1:1 cusip6 year using "$tempdata\Governance_1.dta", keepusing(dualclass glspmt)
drop if _merge==2
drop _merge
merge 1:1 cusip year using "$tempdata\Compstat_1.dta", keepusing(ROA)
drop if _merge==2
drop _merge
winsor2 ROA, replace cuts(1 99)

egen sd1 = sd(ind_board)
egen sd2 = sd(dualclass)
egen sd3 = sd(glspmt)
gen ind_boardsd=ind_board/sd1
gen dualclasssd=dualclass/sd2
gen glspmtsd=glspmt/sd3
drop sd*

save "$tempdata\TRMF12S_F.dta",replace

******************* Table 1 *********************

use "$tempdata\TRMF12S_F.dta",replace

tabstat percen percen1 percen2 percen3 ind_board glspmt dualclass ROA, s(mean p50 sd) col(stat) f(%7.3f) 

******************* Table 2 *********************

encode cusip, gen(firm)

format %ty year

xtset firm year,y

xi:reg percen r2000 ln_mktcap ln_mktcap2 ln_mktcap3 ln_float i.year, cluster(firm)

xi:reg percen1 r2000 ln_mktcap ln_mktcap2 ln_mktcap3 ln_float i.year, cluster(firm)

xi:reg percen2 r2000 ln_mktcap ln_mktcap2 ln_mktcap3 ln_float i.year, cluster(firm)

xi:reg percen3 r2000 ln_mktcap ln_mktcap2 ln_mktcap3 ln_float i.year, cluster(firm)

******************* Table 3 *********************

xi:reg percen1_sd r2000 ln_mktcap ln_float i.year, cluster(firm)

xi:reg percen1_sd r2000 ln_mktcap ln_mktcap2 ln_float i.year, cluster(firm)

xi:reg percen1_sd r2000 ln_mktcap ln_mktcap2 ln_mktcap3 ln_float i.year, cluster(firm)

******************* Table 4 *********************

xi:ivregress 2sls ind_boardsd ln_mktcap ln_float i.year (percen1_sd=r2000),cluster(firm)

xi:ivregress 2sls ind_boardsd ln_mktcap ln_mktcap2 ln_float i.year (percen1_sd=r2000),cluster(firm)

xi:ivregress 2sls ind_boardsd ln_mktcap ln_mktcap2 ln_mktcap3 ln_float i.year (percen1_sd=r2000),cluster(firm)

******************* Table 5 *********************

keep if year<=2002

xi:ivregress 2sls ind_boardsd ln_mktcap ln_float i.year (percen1_sd=r2000),cluster(firm)

xi:ivregress 2sls ind_boardsd ln_mktcap ln_mktcap2 ln_float i.year (percen1_sd=r2000),cluster(firm)

xi:ivregress 2sls ind_boardsd ln_mktcap ln_mktcap2 ln_mktcap3 ln_float i.year (percen1_sd=r2000),cluster(firm)

keep if year>2002

xi:ivregress 2sls ind_boardsd ln_mktcap ln_float i.year (percen1_sd=r2000),cluster(firm)

xi:ivregress 2sls ind_boardsd ln_mktcap ln_mktcap2 ln_float i.year (percen1_sd=r2000),cluster(firm)

xi:ivregress 2sls ind_boardsd ln_mktcap ln_mktcap2 ln_mktcap3 ln_float i.year (percen1_sd=r2000),cluster(firm)

******************* Table 6 *********************

xi:ivregress 2sls glspmtsd ln_mktcap ln_float i.year (percen1_sd=r2000),cluster(firm)

xi:ivregress 2sls glspmtsd ln_mktcap ln_mktcap2 ln_float i.year (percen1_sd=r2000),cluster(firm)

xi:ivregress 2sls glspmtsd ln_mktcap ln_mktcap2 ln_mktcap3 ln_float i.year (percen1_sd=r2000),cluster(firm)

******************* Table 7 *********************

xi:ivregress 2sls dualclasssd ln_mktcap ln_float i.year (percen1_sd=r2000),cluster(firm)

xi:ivregress 2sls dualclasssd ln_mktcap ln_mktcap2 ln_float i.year (percen1_sd=r2000),cluster(firm)

xi:ivregress 2sls dualclasssd ln_mktcap ln_mktcap2 ln_mktcap3 ln_float i.year (percen1_sd=r2000),cluster(firm)


**************************************************************************
**************************************************************************

 
