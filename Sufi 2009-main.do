// assignment 2-2 main
// author: Yunhao Zhang
// date: Mar 15, 2017

// violation data
use CSTATVIOLATIONS_NSS_20090701, clear
// no duplicates data by gvkey*datadate
// time span: 1996-2005

// modify gvkey 
tostring(gvkey), replace
replace gvkey = "00"+gvkey if length(gvkey) == 4
replace gvkey = "0"+gvkey if length(gvkey) == 5
// only calendar date, and string type, 1996 to partial 2008
gen datadate2 = date(datadate,"MDY")
format datadate2 %td
drop datadate
rename datadate2 datadate
gen cyear = year(datadate)

// generate lag 1
// this is also quarterly data ???
bys gvkey (datadate): gen viol_l1 = viol[_n-1]

// use datadate as key to merge data together 
// merge with firm_quarter data

// merge with firm characteristic
merge 1:1 gvkey datadate using firm_q_adj
drop if _merge != 3 //???
drop _merge

/*
// merge with credit rating
merge 1:1 gvkey datadate using credit_adj
drop if _merge == 2
drop _merge
*/

// Table 2 Summary Statistics
//tabstat debtissue equityissue bookdebt networth nwcap cash EBITDA cashflow NI interest MBratio tang lnatq, s(mean p50 sd n) col(stat) f(%7.3f)
//tabstat debtissue equityissue bookdebt networth nwcap cash EBITDA cashflow NI interest MBratio tang lnatq  if cyear<=2005, s(mean p50 sd n) col(stat) f(%7.3f)
// Table 3 Regression Result, Covenant Violations and Net Debt Issuance
// generate variables for regression
// dep var is debtissue
// indep
// fqtr is the fiscal quarter, datacqtr (str) is calendar year and quarter
// with cluster???
// no constant ???
// clustered by firm

// get a S&P rating

// Panel A, col(1)
// adjust string to date
destring gvkey, replace
xtset gvkey datadate
//xi: xtreg debtissue i.fqtr i.datacqtr viol viol_l1, fe cluster(gvkey) robust 
//xi: regress debtissue i.gvkey i.fqtr i.datacqtr viol viol_l1 if cyear<=2005, cluster(gvkey) robust 

// col(2)
xi: xtreg debtissue i.fqtr i.datacqtr viol viol_l1 bookdebt_l1 networth_l1 cash_l1 EBITDA_l1 EBITDA cashflow cashflow_l1 NI NI_l1 interest interest_l1, cluster(gvkey) robust
//xi: regress debtissue i.fqtr i.datacqtr viol viol_l1 bookdebt_l1 networth_l1 cash_l1 EBITDA_l1 EBITDA cashflow cashflow_l1 NI NI_l1 interest interest_l1 if cyear<=2005, cluster(gvkey) robust

/*
// col(3)
gen inter1 = bookdebt_l1*cashflow_l1
gen inter2 = bookdebt_l1*EBITDA_l1
gen inter3 = bookdebt_l1*networth_l1
gen inter4 = EBITDA_l1*interest_l1
//xi: regress debtissue i.fqtr i.datacqtr viol viol_l1 bookdebt_l1 networth_l1 cash_l1 EBITDA_l1 EBITDA cashflow cashflow_l1 NI NI_l1 interest interest_l1 inter1 inter2 inter3 inter4, cluster(gvkey) robust
xi: regress debtissue i.fqtr i.datacqtr viol viol_l1 bookdebt_l1 networth_l1 cash_l1 EBITDA_l1 EBITDA cashflow cashflow_l1 NI NI_l1 interest interest_l1 inter1 inter2 inter3 inter4 if cyear<=2005, cluster(gvkey) robust
*/

/*
// col(4)
xi: regress debtissue i.fqtr i.datacqtr viol viol_l1 bookdebt_l1 networth_l1 cash_l1 EBITDA_l1 EBITDA cashflow cashflow_l1 NI NI_l1 interest interest_l1 inter1 inter2 inter3 inter4 lnatq_l1 MBratio_l1 tang_l1 HasRating_l1, cluster(gvkey) robust
xi: regress debtissue i.fqtr i.datacqtr viol viol_l1 bookdebt_l1 networth_l1 cash_l1 EBITDA_l1 EBITDA cashflow cashflow_l1 NI NI_l1 interest interest_l1 inter1 inter2 inter3 inter4 lnatq_l1 MBratio_l1 tang_l1 HasRating_l1 if cyear<=2005, cluster(gvkey) robust
*/

// Panel B, col(1)
//gen del_debtissue = debtissue - debtissue_l1
//xi: regress del_debtissue i.fqtr i.datacqtr viol viol_l1, cluster(gvkey) robust 
//xi: regress debtissue i.gvkey i.fqtr i.datacqtr viol viol_l1 if cyear<=2005, cluster(gvkey) robust 

// col(2)
//xi: regress del_debtissue i.fqtr i.datacqtr viol viol_l1 bookdebt_l1 networth_l1 cash_l1 EBITDA_l1 EBITDA cashflow cashflow_l1 NI NI_l1 interest interest_l1, cluster(gvkey) robust
//xi: regress debtissue i.fqtr i.datacqtr viol viol_l1 bookdebt_l1 networth_l1 cash_l1 EBITDA_l1 EBITDA cashflow cashflow_l1 NI NI_l1 interest interest_l1 if cyear<=2005, cluster(gvkey) robust


// col(3)
//xi: regress debtissue i.fqtr i.datacqtr viol viol_l1 bookdebt_l1 networth_l1 cash_l1 EBITDA_l1 EBITDA cashflow cashflow_l1 NI NI_l1 interest interest_l1 inter1 inter2 inter3 inter4, cluster(gvkey) robust
//xi: regress debtissue i.fqtr i.datacqtr viol viol_l1 bookdebt_l1 networth_l1 cash_l1 EBITDA_l1 EBITDA cashflow cashflow_l1 NI NI_l1 interest interest_l1 inter1 inter2 inter3 inter4 if cyear<=2005, cluster(gvkey) robust
