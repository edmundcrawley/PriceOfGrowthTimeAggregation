*********************************************************************************************
* IN THIS FILE, WE SELECT THE SAMPLE FROM THE URBAN SUBSAMPLES OF THE CHNS AND CHIP, AND 
* COMPARE THE RESULTING TWO ANALYSIS SAMPLES, WHICH ARE THE INPUTS TO THE IMPUTATION
* PROCEDURE.
* CREATED BY YU ZHENG
* STATA/SE 14.0
*********************************************************************************************
clear
clear matrix
clear mata
set mem 500m
set maxvar 32760
set more off

  cd "$mypath"  
  
  capture log close
  log using "CHIP-log\cr-Datacompare-Urban", replace

 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * SUMMARY STATISTICS OF URBAN CHNS
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  use "CHNS-dta-files---final\CHNStrimmed.dta", clear
   
  * MERGE WITH PRICE DATA
	  gen 	region = "liaoning" 	if province == 21
	replace region = "heilongjiang" if province == 23
	replace region = "jiangsu" 		if province == 32
	replace region = "shandong" 	if province == 37
	replace region = "henan" 		if province == 41
	replace region = "hubei" 		if province == 42
	replace region = "hunan" 		if province == 43
	replace region = "guangxi" 		if province == 45
	replace region = "guizhou" 		if province == 52
	sort urban year region
	merge m:1 urban year region using "CHIP-dta-files---final\finprice.dta"
    assert _merge~=1
	drop if _merge~=3
	drop _merge
	
  * SAMPLE SELECTION IN THE CHNS
  keep if urban == 1			// URBAN SAMPLE
  count
  local count0 = string(r(N),"%10.0fc")
  keep if age>=25 & age<=65 	// HEAD AGE BETWEEN 25 AND 65
  count
  local count1 = string(r(N),"%10.0fc")
  keep if educ~=.
  count
  local count2 = string(r(N),"%10.0fc")
  keep if food_exp~=. & food_exp~=0
  count
  local count3 = string(r(N),"%10.0fc")
  
	* MAKE A TABLE ABOUT SAMPLE SELECTION
	cap file close _all
	file open ofile using "Tables\table_sampleCHNS_Urban.tex", write replace	
	file write ofile "\begin{tabular}{l|c}" _n ///
	"\toprule" _n ///
	"Operation & No. of obs \\" _n ///
	"		   & (HH $\times$ wave) \\" _n ///
	"\midrule" _n  ///
	" (Initial sample)											& `count0'  \\" _n ///
	"Drop if head age$<25$ or $>65$								& `count1' 	\\" _n ///
	"Drop if missing education									& `count2'	\\" _n ///
	"Drop if missing or zero food expenditure					& `count3'	\\" _n ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
  
  * GENERATE COVARIATES
	// COHORT: COH = 1, 2,..., 12.
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
	// AGE AND AGE SQUARED
	gen 	age2=age^2
	// REGION: REGION = 2, 3, 4, 5.
		rename region region_aux
		// HUA BEI DI QU (NORTH REGION)
		gen	  	region = 1 if region_aux == "beijing" | region_aux == "tianjin" | region_aux == "hebei" | region_aux == "shanxi" |  region_aux == "innermongolia"
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
		
	// NUMBER OF CHILDREN: KIDCAT = 0, 1, 2, 3.
	gen kidcat = numi_lt_15
	replace kidcat = 3 if kidcat>3 & kidcat~=.  // ONLY 5 OBS HAVE 4 CHILDREN
	// EDUCATION: EDUC = 0, 1, 2.
	
  * EXPENDITURES
	* CONVERT THE FOOD_EXP FROM USD IN CONSTANT 2009 PRICE TO RMB IN CONSTANT 2000 PRICE
	gen  pall2009_aux1 = pall if year == 2009
	bys province (year): egen pall2009_aux2 = max(pall2009_aux1)
	replace food_exp = food_exp/pall2009_aux2*100*6.8300
	gen lq  = ln(food_exp*pall/pf)
  
  gen dataset = 1
  label define A2data 1 "CHNS" 2 "CHIP"
  label values dataset A2data
  gen 		year_cp = 1 if year == 1989 | year == 1991
  replace 	year_cp = 2 if year == 1997 | year == 1993
  replace   year_cp = 3 if year == 2004 | year == 2000
  replace 	year_cp = 4 if year == 2009 | year == 2006
  drop *_aux*
  saveold "CHIP-dta-files---final\Datacompare-Urban.dta", replace
  
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * SUMMARY STATISTICS OF URBAN CHIP
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  use "CHIP-dta-files---final\CHIPU.dta", clear
  
  * WE DON'T HAVE PRICE DATA FOR 1988, MATCH CHIP 1988 WITH THE 1989 PRICE DATA
  replace year = 1989 if year == 1988
  
  * MERGE WITH PRICE DATA
	sort urban year region
	merge m:1 urban year region using "CHIP-dta-files---final\finprice.dta"
    assert _merge~=1
	drop if _merge~=3
	drop _merge
  replace year = 1988 if year == 1989
	
  * SAMPLE SELECTION IN THE CHIP
  keep if urban == 1				// URBAN SAMPLE
  count
  local count0 = string(r(N),"%10.0fc")
  keep if hh_age>=25 & hh_age<=65	// HEAD AGE BETWEEN 25 AND 60
  count
  local count1 = string(r(N),"%10.0fc")
  keep if hh_education~=.
  count
  local count2 = string(r(N),"%10.0fc")
  drop if region=="beijing" | region=="shanxi" | region=="gansu"
  count
  local count3 = string(r(N),"%10.0fc")
  keep if food_exp~=. & food_exp~=0
  count
  local count4 = string(r(N),"%10.0fc")
	* MAKE A TABLE ABOUT SAMPLE SELECTION
	cap file close _all
	file open ofile using "Tables\table_sampleCHIP_Urban.tex", write replace	
	file write ofile "\begin{tabular}{l|c}" _n ///
	"\toprule" _n ///
	"Operation & No. of obs \\" _n ///
	"		   & (HH $\times$ wave) \\" _n ///
	"\midrule" _n  ///
	" (Initial sample)											& `count0'  \\" _n ///
	"Drop if head age$<25$ or $>65$								& `count1' 	\\" _n ///
	"Drop if missing education									& `count2'	\\" _n ///
	"Drop Beijing, Shanxi and Gansu 							& `count3'  \\" _n ///
	"Drop if missing or zero food expenditure					& `count4'	\\" _n ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
  * GENERATE COVARIATES
	// COHORT: COH = 1, 2,..., 12.
	gen 	cohort_aux = year-hh_age
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
	
	// AGE AND AGE SQUARED
	gen		age = hh_age
	gen 	age2=age^2
	
	// REGION: REGION = 1, 2, 3, 4, 5, 6.
		rename region region_aux
		// HUA BEI DI QU (NORTH REGION)
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

	// NUMBER OF CHILDREN: KIDCAT = 0, 1, 2, 3.
	gen kidcat = hh_children
	replace kidcat = 3 if kidcat>3 & kidcat~=. // 1 OBS HAS 4 CHILDREN
	
	// EDUCATION: EDUC = 0, 1, 2.
		* 1988
		gen		educ = 0 if hh_education==8  & year == 1988
		replace educ = 1 if hh_education>=5  & hh_education<=7 & year == 1988
		replace educ = 2 if hh_education>=1  & hh_education<=4 & year == 1988
		* 1995
		replace educ = 0 if hh_education>=7  & hh_education<=8 & year ==1995
		replace educ = 1 if hh_education>=5  & hh_education<=6 & year ==1995
		replace educ = 2 if hh_education>=1  & hh_education<=4 & year ==1995
		* 2002, 2007
		replace educ = 0 if hh_education>=1  & hh_education<=2 & year >=2002
		replace educ = 1 if hh_education>=3  & hh_education<=4 & year >=2002
		replace educ = 2 if hh_education>=5  & hh_education<=9 & year >=2002
		
	
  * EXPENDITURES
  gen lq  = ln(food_exp/(pf/100))		// AT 2000 CONSTANT FOOD PRICE
  gen dataset = 2
  label define A2data 1 "CHNS" 2 "CHIP"
  label values dataset A2data
  gen 		year_cp = 1 if year == 1988
  replace 	year_cp = 2 if year == 1995
  replace   year_cp = 3 if year == 2002
  replace 	year_cp = 4 if year == 2007
  drop *_aux
  
  *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  * APPEND CHIP TO CHNS
  *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  append using "CHIP-dta-files---final\Datacompare-Urban.dta"
  saveold "CHIP-dta-files---final\Datacompare-Urban.dta", replace
  
  *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  * MAKE A TABLE OF COMPARISON
  *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   keep if year_cp~=.
   keep if region >=2 & region<=6
   misstable sum year region kidcat educ hh_size age lq
   gen 		educ0 = (educ==0)
   gen 		educ1 = (educ==1)
   gen 		educ2 = (educ==2)
   replace 	educ0 = educ0*100
   replace 	educ1 = educ1*100
   replace 	educ2 = educ2*100
   gen		region2 = (region==2)
   gen 		region3 = (region==3)
   gen		region4 = (region==4)
   gen		region5 = (region==5)
   replace 	region2 = region2*100
   replace 	region3 = region3*100
   replace 	region4 = region4*100
   replace 	region5 = region5*100
   
   labe  var age 		"Age"
   label var hh_size 	"HH size"
   label var kidcat		"No. of children"   
   label var educ0 		"No education (\%)"
   label var educ1 		"Below 9th grade (\%)"
   label var educ2 		"Above 9th grade (\%)"
   label var region2 	"North-eastern (\%)"
   label var region3 	"Eastern (\%)"
   label var region4	"Center-southern (\%)"
   label var region5 	"South-western (\%)"
   label var lq		  	"Log food expenditure"

  cap file close _all
  file open ofile using "Tables\table_impute_compare_Urban.tex", write replace	
  file write ofile "\begin{tabular}{l|c c|c c|c c|c c}" _n ///
	"\toprule" _n ///
	"Data & CHIP & CHNS & CHIP & CHNS & CHIP & CHNS & CHIP & CHNS \\" _n ///
	"Wave & 1988 & 1989, 1991 & 1995 & 1993, 1997 & 2002 & 2000, 2004 & 2007 & 2006, 2009 \\" _n ///
	"\midrule" _n
  foreach var in age hh_size kidcat educ0 educ1 educ2 region2 region3 region4 region5 lq {
	local label`var': variable label `var'
	forvalues d=1/2	{
		forvalues t=1/4 {
			sum `var' if year_cp == `t' & dataset == `d'
			local mean`t'_d`d'=string(r(mean),"%10.2f")
			local sd`t'_d`d'  =string(r(sd),"%10.2f")
		}
	}
	file write ofile " `label`var'' & `mean1_d2' & `mean1_d1' & `mean2_d2' & `mean2_d1' & `mean3_d2' & `mean3_d1' & `mean4_d2' & `mean4_d1'  \\" _n ///
					 "              & (`sd1_d2') & (`sd1_d1') & (`sd2_d2') & (`sd2_d1') & (`sd3_d2') & (`sd3_d1') & (`sd4_d2') & (`sd4_d1')  \\" _n
  }
  file write ofile "\bottomrule" _n
  file write ofile "\multicolumn{9}{p{5in}}{\footnotesize \textit{Note}: Standard deviations in parentheses.}" _n

  file write ofile "\end{tabular}"
  file close _all
  saveold "CHIP-dta-files---final\Datacompare-Urban.dta", replace
  
  log close
  
  
