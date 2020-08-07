*********************************************************************************************
* IN THIS FILE, WE IMPUTE HH NON DURABLE CONSUMPTION IN CHNS A LA BPP.
* CREATED BY YU ZHENG
* STATA/SE 14.0
*********************************************************************************************
clear
clear matrix
clear mata
set mem 500m
set maxvar 32760
set more off
cap ssc install ranktest
cap ssc install ivreg2

cd "$mypath"

  capture log close
  log using "CHNS-log\cr-CHNSimp", replace
 
 use "CHNS-dta-files---final\CHNStrimmed.dta", clear
  gen mergeid = 1
 
 * GENERATE RELEVANT VARIABLES
	// COHORT AND AGE
	replace birthyear  = cohort   if birthyear==.  // ONE MISSING BIRTHYEAR
	gen 	cohort_aux = birthyear
	gen 	coh = 1  if cohort_aux >= 1980 & cohort_aux ~=.
	replace coh = 2  if cohort_aux >= 1975 & cohort_aux <= 1979
	replace coh = 3  if cohort_aux >= 1970 & cohort_aux <= 1974
	replace coh = 4  if cohort_aux >= 1965 & cohort_aux <= 1969
	replace coh = 5  if cohort_aux >= 1960 & cohort_aux <= 1964
	replace coh = 6  if cohort_aux >= 1955 & cohort_aux <= 1959
	replace coh = 7  if cohort_aux >= 1950 & cohort_aux <= 1954
	replace coh = 8  if cohort_aux >= 1945 & cohort_aux <= 1949
	replace coh = 9  if cohort_aux >= 1940 & cohort_aux <= 1944
	replace coh = 10 if cohort_aux >= 1935 & cohort_aux <= 1939
	replace coh = 11 if cohort_aux >= 1930 & cohort_aux <= 1934
	replace coh = 12 if cohort_aux <= 1929 & cohort_aux ~=.
	gen 	age2=age^2
	// REGION
	gen 	region = "liaoning" 	if province == 21
	replace region = "heilongjiang" if province == 23
	replace region = "jiangsu" 		if province == 32
	replace region = "shandong" 	if province == 37
	replace region = "henan" 		if province == 41
	replace region = "hubei" 		if province == 42
	replace region = "hunan" 		if province == 43
	replace region = "guangxi" 		if province == 45
	replace region = "guizhou" 		if province == 52
	
		* MERGE WITH PRICE DATA (NEED TO USE REGION AS AN IDENTIFIER)
		sort year region
		merge m:1 year region urban using "CHIP-dta-files---final\finprice.dta"
		tab year _merge
		drop if _merge!=3
		drop _merge
	
	gen   	region_aux = region
	drop	region
	gen	  	region = 1 if region_aux == "beijing" | region_aux == "tianjing" | region_aux == "hebei" | region_aux == "shanxi" |  region_aux == "innermongolia"
	// DONG BEI DI QU (NORTH-EAST REGION)
	replace region = 2 if region_aux == "liaoning" |  region_aux == "jilin" | region_aux == "heilongjiang" | region_aux == "dalian"  
	// HUA DONG DI QU (EAST REGION)
	replace region = 3 if region_aux == "shanghai" | region_aux == "jiangsu" | region_aux == "zhejiang" | region_aux == "anhui" | region_aux == "fujian" | region_aux == "jiangxi" | region_aux == "shandong" | region_aux == "ningbo" | region_aux == "xiamen" | region_aux == "qingdao"
	// ZHONG NAN DI QU (CENTER-SOUTH REGION)
	replace region = 4 if region_aux == "henan" | region_aux == "hubei" | region_aux == "hunan" | region_aux == "guangdong" | region_aux == "guangxi" | region_aux == "hainan" | region_aux == "shenzhen"
	// XI NAN DI QU (SOUTH-WEST REGION)
	replace region = 5 if region_aux == "chongqing" | region_aux == "sichuan" | region_aux == "guizhou" | region_aux == "yunnan" | region_aux == "tibet" 
	// XI BEI DI QU (NORTH-WEST REGION)
	replace region = 6 if region_aux == "shaanxi" | region_aux == "gansu" | region_aux == "qinghai" | region_aux == "ningxia" | region_aux == "xinjiang"
    
	// NUMBER OF CHILDREN
	gen kidcat = numi_lt_15
	replace kidcat = 3 if kidcat>=3 & kidcat~=.
	
	// PRICES
    foreach var in pf palc ptran pfutil	{
		gen  l`var'=ln(`var'/100)
		}
	
	// EXPENDITURES
	gen lq  = ln(cdiet*pall/pf)

	// YEAR COMPATIBLE WITH CHIP
	gen 		year_cp = 1 if year == 1989 | year == 1991
	replace 	year_cp = 2 if year == 1997 | year == 1993
	replace   	year_cp = 3 if year == 2004 | year == 2000
	replace 	year_cp = 4 if year == 2009 | year == 2006
	
	* SAMPLE SELECTION
	keep if reside == 0			// URBAN SAMPLE
	keep if age>=25 & age<=65
	keep if educ~=.
	keep if cdiet~=. & cdiet~=0
	count
 
    
	* GENERATE DUMMY VARIABLES
	tab coh,gen(cohd)			// 1/2/3/4/5/6/7/8/9/10/11/12
	tab educ, gen(edd)			// 0/1/2
	tab region, gen(regd)		// 2/3/4/5
	tab kidcat, gen(kidd)		// 0/1/2/3
	tab year_cp, gen(yrd)		// 1/2/3/4
 
 foreach var in lx1 lx2 lx3	{
  * MERGE DATA SETS
  merge m:1 mergeid using "CHIP-dta-files---final\b_`var'.dta"
  drop _merge
  
  * IMPUTATION
	#delimit;
	gen `var'_imp=(lq-(
	b1_age[1]    *age+
	b1_age2[1]   *age2+
	
	b1_lpf[1]    *lpf+
	b1_lpalc[1]  *lpalc+
	b1_lpfutil[1]*lpfutil+
	
	b1_cohd2[1]  *cohd2+
	b1_cohd3[1]  *cohd3+
	b1_cohd4[1]  *cohd4+
	b1_cohd5[1]  *cohd5+
	b1_cohd6[1]  *cohd6+
	b1_cohd7[1]  *cohd7+
	b1_cohd8[1]  *cohd8+
	b1_cohd9[1]  *cohd9+
	b1_cohd10[1] *cohd10+
	b1_cohd11[1] *cohd11+
	b1_cohd12[1] *cohd12+
	
	b1_edd2[1]   *edd2+
	b1_edd3[1]   *edd3+ 
	b1_regd2[1]  *regd2+ 
	b1_regd3[1]  *regd3+ 
	b1_regd4[1]  *regd4+
	
	b1_kidd2[1]   *kidd2+
	b1_kidd3[1]   *kidd3+
	b1_kidd4[1]   *kidd4+
	
	b1_cons[1]  ))
	/(b1_lx[1]+b1_lxed2[1]*edd2+b1_lxed3[1]*edd3+b1_lxkid2[1]*kidd2+b1_lxkid3[1]*kidd3+b1_lxkid4[1]*kidd4 + b1_lxyr2[1]*yrd2 + b1_lxyr3[1]*yrd3 + b1_lxyr4[1]*yrd4);
	#delimit cr

  drop b1_*
  
	* TABULATE
	table year_cp,  	  c(mean lq mean `var'_imp)
	table year_cp , 	  c(sd   lq sd   `var'_imp)
	table interview_year, c(mean lq mean `var'_imp)
	table interview_year, c(sd   lq sd   `var'_imp)
}


keep lq lx*_imp year_cp interview_year case_id
compress

count
gen dataset = 1
rename interview_year year
saveold "CHIP-dta-files---final\CHNSimp.dta",replace
saveold "CHNS-dta-files---final\CHNSimp.dta",replace

log close

  
