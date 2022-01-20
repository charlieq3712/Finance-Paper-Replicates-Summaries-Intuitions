*First clean the Russell data, CRSP accounting data, setting the bandwidth as 250.
* For more close check,try240,260 for better close result,and check 500,1000 for futher exploration
*Try end of June and end of May
gl CRSPdata "D:\Duke\17Spring\BA952\Assignment3\CRSPdata"
gl RAD "D:\Duke\17Spring\BA952\Assignment3\RAD"
use "$CRSPdata\CRSP_Stock.dta", replace
generate year=year(date)
generate month=month(date)
save "$RAD250\CRSP2.dta",replace
use "$CRSPdata\russell_all.dta",replace
generate date=dofm(yearmonth)
generate year=year(date)
sort adj_mrktvalue year r2000 
duplicates band year r2000, generate(band)
by year r2000: drop if r2000==0
by year r2000: drop if rk>250
by year r2000: drop if r2000==1 
by year r2000: drop if rk<(band-249)
by year r2000: egen rk=rank(adj_mrktvalue)
use "$CRSPdata\Board.dta",replace
generate id=1 if classification=="I"
replace id=0 if id==.
generate no=1
collapse (sum) ind num, by(cusip year)
generate BoardIND=100*id/no
save "$RAD250June\BoardIND.dta",replace
use "$CRSPdata\Board.dta",replace
use "$CRSPdata\S12.dta", replace
generate year=year(rdate)
generate month=month(rdate)
drop if year<1998 
drop if year>2006
drop if cusip==""
keep if month==6 
keep if month==9
duplicates year band fundno , generate(yp)
duplicates year month band fundno, generate(mp)
replace month=9 if yp==mp 
replace month=9 if year<2004
drop if month==6
merge m:1 cusip year month using "$RAD250June\CRSP2.dta",keepusing(prc shrout)
replace shrout2=shrout1*1000 if shrout2==.
replace prc_stock=prc if fdate==rdate & prc_stock==.
replace shrout=shrout2 if fdate==rdate & shrout==.
drop _merge
drop if _merge==1 
drop if _merge==2
merge m:1 fundno fdate using "$CRSPdata\MF.dta", keepusing(wficn fundname mgrcoab num_holdings)
drop _merge
drop if _merge==1 
drop if _merge==2
save "$RAD250June\S12.dta",replace
use "$CRSPdata\CRSPMF.dta",replace
generate year=year(caldt)
keep if year<=1998
drop year
save "$RAD250June\CRSPMF.dta",replace
ap using "$RAD250June\CRSPMF.dta"
merge m:1 crsp_fundno using "$CRSPdata\mflink1_raw.dta", keepusing(wficn fund_name)
drop if _merge==1 
drop if _merge==2
drop _merge
save "$RAD250June\CRSPMF.dta"

*with May
use "$CRSPdata\S12.dta", replace
generate year=year(rdate)
generate month=month(rdate)
drop if year<1998 
drop if year>2006
keep if month==5 
keep if month==9
drop if cusip==""
duplicates band fundno year, generate(yp)
duplicates band fundno year month, generate(mp)
replace month=9 if yp==mp & year<2004
drop if month==5
merge m:1 year month cusip  using "$RAD250June\CRSP2.dta",keepusing(prc shrout)
replace shrout2=shrout1*1000 if shrout2==.
replace prc_stock=prc if fdate==rdate & prc_stock==.
replace shrout=shrout2 if fdate==rdate & shrout==.
drop _merge
drop if _merge==1 
drop if _merge==2
merge m:1 fundno fdate using "$CRSPdata\MF.dta", keepusing(wficn fundname mgrcoab num_holdings)
drop _merge
drop if _merge==1 
drop if _merge==2
save "$RAD250June\S12.dta",replace
use "$CRSPdata\CRSPMF.dta",replace
generate year=year(caldt)
keep if year<=1998
drop year
save "$RAD250June\CRSPMF.dta",replace
ap using "$RAD\CRSPMF.dta"
merge m:1 crsp_fundno using "$CRSPdata\mflink1_raw.dta", keepusing(wficn fund_name)
drop if _merge==1 
drop if _merge==2
drop _merge

*Different band width
use "$CRSPdata\CRSP_Stock.dta", replace
generate year=year(date)
generate month=month(date)
save "$RAD240\CRSP2.dta",replace
use "$CRSPdata\russell_all.dta",replace
generate date=dofm(yearmonth)
generate year=year(date)
sort year r2000 adj_mrktvalue
duplicates band year r2000, generate(band)
by year r2000: egen rk=rank(adj_mrktvalue)
by year r2000: drop if r2000==0 & rk>240
by year r2000: drop if r2000==1 & rk<(band-239)
save "$RAD240\Russell.dta",replace
use "$CRSPdata\Board.dta",replace
generate id=1 if classification=="I"
replace id=0 if id==.
generate no=1
generate cusip=Junecusip
collapse (sum) ind num, by(cusip year)
generate BoardIND=100*id/no
save "$RAD240June\BoardIND.dta",replace

use "$CRSPdata\CRSP_Stock.dta", replace
generate year=year(date)
generate month=month(date)
save "$RAD260\CRSP2.dta",replace
use "$CRSPdata\russell_all.dta",replace
generate date=dofm(yearmonth)
generate year=year(date)
sort year r2000 adj_mrktvalue
duplicates band year r2000, generate(band)
by year r2000: egen rk=rank(adj_mrktvalue)
by year r2000: drop if r2000==0 & rk>260
by year r2000: drop if r2000==1 & rk<(band-259)
save "$RAD260\Russell.dta",replace
use "$CRSPdata\Board.dta",replace
generate id=1 if classification=="I"
replace id=0 if id==.
generate no=1
generate cusip=Junecusip
collapse (sum) ind num, by(cusip year)
generate BoardIND=100*id/no
save "$RAD260June\BoardIND.dta",replace

use "$CRSPdata\CRSP_Stock.dta", replace
generate year=year(date)
generate month=month(date)
save "$RAD500\CRSP2.dta",replace
use "$CRSPdata\russell_all.dta",replace
generate date=dofm(yearmonth)
generate year=year(date)
sort year r2000 adj_mrktvalue
duplicates band year r2000, generate(band)
by year r2000: egen rk=rank(adj_mrktvalue)
by year r2000: drop if r2000==0 & rk>500
by year r2000: drop if r2000==1 & rk<(band-499)
save "$RAD500\Russell.dta",replace
use "$CRSPdata\Board.dta",replace
generate id=1 if classification=="I"
replace id=0 if id==.
generate no=1
generate cusip=Junecusip
collapse (sum) ind num, by(cusip year)
generate BoardIND=100*id/no
save "$RAD500June\BoardIND.dta",replace

use "$CRSPdata\CRSP_Stock.dta", replace
generate year=year(date)
generate month=month(date)
save "$RAD750\CRSP2.dta",replace
use "$CRSPdata\russell_all.dta",replace
generate date=dofm(yearmonth)
generate year=year(date)
sort year r2000 adj_mrktvalue
duplicates band year r2000, generate(band)
by year r2000: egen rk=rank(adj_mrktvalue)
by year r2000: drop if r2000==0 & rk>750
by year r2000: drop if r2000==1 & rk<(band-749)
save "$RAD750\Russell.dta",replace
use "$CRSPdata\Board.dta",replace
generate id=1 if classification=="I"
replace id=0 if id==.
generate no=1
generate cusip=Junecusip
collapse (sum) ind num, by(cusipyear)
generate BoardIND=100*id/no
save "$RAD750June\BoardIND.dta",replace
use "$CRSPdata\Board.dta",replace

*Operate the accounting data together with the first step
use "$CRSPdata\Governance.dta", replace
sort cusip year
by cusip: generate lspmtlag=lspmt[_n-1]
generate lsl = lspmt-lspmtlag
replace lsl=0 if lsl==.
use "$CRSPdata\Compstat_annual.dta", replace
generate ROA=ni/at
save "$RAD250June\Compstat.dta",replace
save "$RAD250June\Governance.dta",replace
save "$RAD240June\Compstat.dta",replace
save "$RAD240June\Governance.dta",replace
save "$RAD260June\Compstat.dta",replace
save "$RAD260June\Governance.dta",replace
save "$RAD500June\Compstat.dta",replace
save "$RAD500June\Governance.dta",replace
save "$RAD750June\Compstat.dta",replace
save "$RAD750June\Governance.dta",replace

* And for May
sort cusip year
by cusip: generate lspmtlag=lspmt[_n-1]
generate lsl = lspmt-lspmtlag
replace lsl=0 if lsl==.
save "$RAD240May\Compstat.dta",replace
save "$RAD240May\Governance.dta",replace
save "$RAD260May\Compstat.dta",replace
save "$RAD260May\Governance.dta",replace
save "$RAD500May\Compstat.dta",replace
save "$RAD500May\Governance.dta",replace
save "$RAD750May\Compstat.dta",replace
save "$RAD750May\Governance.dta",replace

*Identify the passive onwerships
generate year=year(caldt)
generate month=month(caldt)
generate ownership=1 if ownership!="" 
bysort wficn: egen ind=max(ownership)
generate string1="Index"
generate string2="Idx"
generate string3="Indx"
generate string4="Ind_"
generate string5="Russell"
generate string6="S & P"
generate string7="S and P"
generate string8="S&P"
generate string9="SandP"
generate string10="SP"
generate string11="DOW"
generate string12="Dow"
generate string13="DJ"
generate string14="MSCI"
generate string15="Bloomberg"
generate string16="KBW"
generate string17="NASDAQ"
generate string18="NYSE"
generate string19="STOXX"
generate string20="FTSE"
generate string21="Wilshire"
generate string22="Morningstar"
generate string23="100"
generate string24="400"
generate string25="500"
generate string26="600"
generate string27="900"
generate string28="1000"
generate string29="1500"
generate string30="2000"
generate string31="5000"
forval i = 1(1)31{replace ownership=1 if regexm(fund_name,name`i')==1}
drop string*
drop if wficn==.
collapse (mean) ind, by (wficn year)
save "$RAD250June\CRSPMF.dta",replace

replace per1=per1*100
replace per2=per2*100
replace per3=per3*100
replace per=per*100
generate s1 = sd(per1)
generate s = sd(per)
generate per1s=per1/s1
generate pers=per/s
generate lnmkc=log(makcap)
generate lnmkc2=log(makcap)^2
generate lnmkc3=log(makcap)^3
generate lnflt=log(adj_mrktvalue)
generate cusip=(cusip,1,6)
duplicates band cusip year, generate(label)
bysort cusip: generate lb=max(label)
drop s*
drop if v!=0
merge 1:1 cusip year using "$RAD250June\BoardIND.dta", keepusing(BoardIND)
drop if _merge==2
drop _merge
merge 1:1 cusip year using "$RAD250June\Governance_1.dta", keepusing(dualclass lsl)
drop if _merge==2
drop _merge
merge 1:1 cusip year using "$RAD250June\Compstat.dta", keepusing(ROA)
drop if _merge==2
drop _merge
save "$RAD250June\Compstat.dta",replace

use "$RAD250June\S12.dta",replace
merge m:1 wficn year using "$RAD250June\CRSPMF.dta"
drop if _merge==2
replace ownership=2 if _merge==3 & ownership!=1
replace ownership=3 if _merge==1
collapse (sum) shares (max) prc_stock shrout, by (cusip year ownership)
merge m:1 cusip year using "$RAD250June\Russell.dta", keepusing(switch2to1 switch1to2 ran adj_mrktvalue r2000)
drop if _merge!=3
drop _merge
bysort cusip year: generate share1=shares if ownership==1
bysort cusip year: generate share2=shares if ownership==2
bysort cusip year: generate share3=shares if ownership==3
collapse (max) share1 share2 share3 prc_stock shrout r2000 (mean) adj_mrktvalue, by (cusip year)
forval i = 1(1)3{	generate per`i'=share`i'/(shrout*1000)}
generate per=per1+per2+per3
drop if per>1
save "$RAD250June\S12.dta",replace
use "$RAD250June\CRSP2.dta",replace
keep if month==5
save "RAD250June\CRSP2M.dta",replace
use "$RAD250June\S12.dta",replace
merge 1:1 cusip year using "$RAD250June\CRSP2M.dta", keepusing(prc_stock shrout)
drop if _merge==2
drop _merge
makcap=prc_stock*shrout
drop if makcap==.

*Here try the alternative ways to cuttoff some outliers
using "$RAD250June\Compstat.dta"
winsor2 ROA, replace cuts(0.5 99.5)
generate s1 = sd(BoardIND)
generate s2 = sd(dualclass)
generate s3 = sd(lsl)
generate BDINDs=BoardIND/s1
generate dualclasss=dualclass/s2
generate lsls=lsl/s3
drop s*

*In different levels
using "$RAD250June\Compstat.dta"
winsor2 ROA, replace cuts(1 99)
save "$RAD250June\S12.dta",replace
using "$RAD250June\Compstat.dta"
winsor2 ROA, replace cuts(1.5 98.5)
save "$RAD250June\S12.dta",replace
using "$RAD250June\Compstat.dta"
winsor2 ROA, replace cuts(2 98)
save "$RAD250June\S12.dta",replace

*table 1,using differenct combinations of bands, May and June, winsorized levels. 
*Here take June ,250, no winsorize as example
tabstat BoardIND lsl dualclass ROA s(mean p50 p) col(stat) f(%7.3f) per per1 per2 per3 ,  

*table 2 
xtset firm year,y
xi:reg lnmkc lnmkc2 lnmkc3 per r2000  lnflt i.year, cluster(firm)
xi:reg lnmkc llnmkc2 lnmkc3 per1 r2000  lnflt i.year, cluster(firm)
xi:reg lnmkc lnmkc2 lnmkc3 lnflt per2 r2000  i.year, cluster(firm)
xi:reg lnmkc lnmkc2 lnmkc3 per3 r2000  lnflt i.year, cluster(firm)

*table 3 
xi:reg lnmkc per1s r2000  lnflt i.year, cluster(firm)
xi:reg lnmkc lnmkc2 per1s r2000  lnflt i.year, cluster(firm)
xi:reg lnmkc lnmkc2 lnmkc3 per1s r2000  lnflt i.year, cluster(firm)
xi:reg lnmkc lnmkc2 lnmkc3 lnmkc4 per1s r2000  lnflt i.year, cluster(firm)
xi:reg lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 per1s r2000  lnflt i.year, cluster(firm)
xi:reg lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 per1s r2000  lnflt i.year, cluster(firm)
xi:reg lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 per1s r2000  lnflt i.year, cluster(firm)
xi:reg lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 per1s r2000  lnflt i.year, cluster(firm)
xi:reg lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 lnmkc9 per1s r2000  lnflt i.year, cluster(firm)
xi:reg lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 lnmkc9 lnmkc10 per1s r2000  lnflt i.year, cluster(firm)


*table 4 
xi:ivregress 2sls lnmkc  BDINDs  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2  BDINDs  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 BDINDs  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 BDINDs  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 BDINDs  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 BDINDs  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 BDINDs  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 BDINDs  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 lnmkc9 BDINDs  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 lnmkc9 lnmkc10 BDINDs  lnflt i.year (per1s=r2000),cluster(firm)

*table 5
keep if year<=2002
xi:ivregress 2sls lnmkcBDINDs  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnmkc4 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 lnmkc9 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 lnmkc9 lnmkc10 lnflt i.year (per1s=r2000),cluster(firm)
keep if year>2002
xi:ivregress 2sls lnmkcBDINDs  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnmkc4 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 lnmkc9 lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls BDINDs lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 lnmkc9 lnmkc10 lnflt i.year (per1s=r2000),cluster(firm)

*table 6
xi:ivregress 2sls lnmkc lsls  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lsls  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lsls  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lsls  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lsls  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lsls  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 llsls  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 lsls  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 lnmkc9 lsls  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 lnmkc9 lnmkc10 llsls  lnflt i.year (per1s=r2000),cluster(firm)

*table 7
xi:ivregress 2sls lnmkc dualclasss  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 dualclasss  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 dualclasss  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 dualclasss  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 dualclasss  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 dualclasss  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 dualclasss  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 dualclasss  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 lnmkc9 dualclasss  lnflt i.year (per1s=r2000),cluster(firm)
xi:ivregress 2sls lnmkc lnmkc2 lnmkc3 lnmkc4 lnmkc5 lnmkc6 lnmkc7 lnmkc8 lnmkc9 lnmkc10 dualclasss  lnflt i.year (per1s=r2000),cluster(firm)
