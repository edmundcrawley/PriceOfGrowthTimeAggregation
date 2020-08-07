*********************************************************************************************
* IN THIS FILE, WE ESTIMATE THE FOOD DEMAND SYSTEM FROM URBAN CHIP DATA, WHICH WILL BE USED
* TO IMPUTE TOTAL NON DURABLE CONSUMPTION FOR THE CHNS DATA.
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
 
  
  * ESTIMATE THE REGRESSION MODEL IN CHIP
  use "CHIP-dta-files---final\CHIPU.dta", clear
  replace year = 1989 if year==1988
  merge m:1 region urban year using "CHIP-dta-files---final\finprice.dta"
  keep if _merge == 3
  drop _merge
  replace year = 1988 if year == 1989
  
  * SAMPLE SELECTION
  keep if urban == 1
  keep if hh_age>=25 & hh_age<=65	// HEAD AGE BETWEEN 25 AND 60
  keep if hh_education~=.
  drop if region=="beijing" | region=="shanxi" | region=="gansu"
  keep if food_exp~=. & food_exp~=0
  
   * GENERATE RELEVANT VARIABLES
  
  // REGION: FROM PROVINCE TO ECONOMIC REGION
	rename  region region_aux
	// HUA BEI DI QU (NORTH REGION)
	gen	    region = 1 if region_aux == "beijing" | region_aux == "tianjin" | region_aux == "hebei" | region_aux == "shanxi" |  region_aux == "innermongolia"
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
   
   // COHORT AND AGE
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
	gen		age = hh_age
	
   // EDUCATION LEVEL: FROM # OF YEARS OF SCHOOLING TO CATEGORIES OF EDUCATIONAL ATTAINMENT
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
		
	
   // NUMBER OF CHILDREN
	gen kidcat = hh_children
	replace kidcat = 3 if hh_children>=3 & hh_children~=.		// ONLY ONE OBS WITH MORE THAN THREE CHILDREN
	
   // PRICES
    foreach var in pf palc ptran pfutil	{
		gen  l`var'=ln(`var'/100)
		}
		
   // EXPENDITURES
    gen		food_exp_pall = food_exp/(pall/100)	// REAL FOOD EXPENDITURES 
	gen 	lq  = ln(food_exp/(pf/100))
	gen 	lx1 = ln(total_exp1/(pall/100))
	gen 	lx2 = ln(total_exp2/(pall/100))
	gen 	lx3 = ln(total_exp3/(pall/100))
	
	
   // WAGES
	gen lwh = ln(wageh/(pall/100))
	gen lww = ln(wagew/(pall/100))
	
	gen age2 = age^2
	egen lwhi = mean(lwh), by(coh educ year)
	egen lwwi = mean(lww), by(coh educ year)
	
	// WAVES
	gen 	year_cp = 1 if year == 1988
	replace year_cp = 2 if year == 1995
	replace year_cp = 3 if year == 2002
	replace year_cp = 4 if year == 2007
	
  * ESTIMATION SAMPLE SELECTION
	keep if region >=2 & region<=5				// REGIONS REPRESENTED IN CHNS
	
  * GENERATE DUMMIES
    tab educ, gen(edd)			// 0/1/2
    tab region, gen(regd)		// 2/3/4/5
	tab kidcat, gen(kidd)		// 0/1/2/3
	tab coh, gen(cohd)			// 1/2/3/4/5/6/7/8/9/10/11/12
	tab year_cp, gen(yrd)		// 1998/1995/2002/2007
	
	// EXPENDITURE X EDUCATION
	gen lx1ed2 = lx1*edd2
	gen lx1ed3 = lx1*edd3
	gen lx2ed2 = lx2*edd2
	gen lx2ed3 = lx2*edd3
	gen lx3ed2 = lx3*edd2
	gen lx3ed3 = lx3*edd3
 
 // EXPENDITURE X NUMBER OF CHILDREN
	gen lx1kid2 = lx1*kidd2
	gen lx1kid3 = lx1*kidd3
	gen lx1kid4 = lx1*kidd4
	gen lx2kid2 = lx2*kidd2
	gen lx2kid3 = lx2*kidd3
	gen lx2kid4 = lx2*kidd4
	gen lx3kid2 = lx3*kidd2
	gen lx3kid3 = lx3*kidd3
	gen lx3kid4 = lx3*kidd4
 
 // EXPENDITURE X YEAR
	gen lx1yr2 = lx1*yrd2
	gen lx1yr3 = lx1*yrd3
	gen lx1yr4 = lx1*yrd4
	gen lx2yr2 = lx2*yrd2
	gen lx2yr3 = lx2*yrd3
	gen lx2yr4 = lx2*yrd4
	gen lx3yr2 = lx3*yrd2
	gen lx3yr3 = lx3*yrd3
	gen lx3yr4 = lx3*yrd4 
 
 // WAGE X YEAR
	gen lwhiy2 = lwhi*yrd2
	gen lwhiy3 = lwhi*yrd3
	gen lwhiy4 = lwhi*yrd4
	gen lwwiy2 = lwwi*yrd2
	gen lwwiy3 = lwwi*yrd3
	gen lwwiy4 = lwwi*yrd4
 
 // WAGE X NUMBER OF CHILDREN
	gen lwhik2 = lwhi*kidd2
	gen lwhik3 = lwhi*kidd3
	gen lwhik4 = lwhi*kidd4
	gen lwwik2 = lwwi*kidd2
	gen lwwik3 = lwwi*kidd3
	gen lwwik4 = lwwi*kidd4
 
 // WAGE X EDUCATION
	gen lwhied2 = lwhi*edd2
	gen lwhied3 = lwhi*edd3
	gen lwwied2 = lwwi*edd2
	gen lwwied3 = lwwi*edd3
		
	
 * LOOPING OVER THE THREE NON-DURABLE CONSUMPTION MEASURES
 foreach var in lx1 lx2 lx3		{ 
		 *** DEMAND STRATEGY IV: TOTAL_EXP1
		#delimit;
		ivreg2 lq (`var' `var'ed2 `var'ed3 `var'kid2 `var'kid3 `var'kid4 `var'yr2 `var'yr3 `var'yr4 = lwhi lwwi lwhiy2 lwhiy3 lwhiy4 lwwiy2 lwwiy3 lwwiy4 lwhik* lwwik* lwhied* lwwied*) 
						 age age2 lpf lpalc lpfutil edd2 edd3 regd2 regd3 regd4 cohd2-cohd12 kidd2-kidd4  , robust	;					
		#delimit cr
		testparm `var'y*
		
		gen b1_lx    =_b[`var']                     

		gen b1_lxed2  =_b[`var'ed2]
		gen b1_lxed3  =_b[`var'ed3]

		gen b1_lxkid2 =_b[`var'kid2]
		gen b1_lxkid3 =_b[`var'kid3]
		gen b1_lxkid4 =_b[`var'kid4]

		gen b1_lxyr2  =_b[`var'yr2]
		gen b1_lxyr3  =_b[`var'yr3]
		gen b1_lxyr4  =_b[`var'yr4]

		gen b1_age    =_b[age]
		gen b1_age2   =_b[age2]

		gen b1_lpf      =_b[lpf]
		gen b1_lpalc    =_b[lpalc]
		gen b1_lpfutil  =_b[lpfutil]

		gen b1_edd2   =_b[edd2]
		gen b1_edd3   =_b[edd3]
		gen b1_regd2  =_b[regd2] 
		gen b1_regd3  =_b[regd3] 
		gen b1_regd4  =_b[regd4]  

		gen b1_cohd2  =_b[cohd2] 
		gen b1_cohd3  =_b[cohd3] 
		gen b1_cohd4  =_b[cohd4] 
		gen b1_cohd5  =_b[cohd5] 
		gen b1_cohd6  =_b[cohd6] 
		gen b1_cohd7  =_b[cohd7]
		gen b1_cohd8  =_b[cohd8] 
		gen b1_cohd9  =_b[cohd9] 
		gen b1_cohd10 =_b[cohd10]
		gen b1_cohd11 =_b[cohd11] 
		gen b1_cohd12 =_b[cohd12]


		gen b1_kidd2   =_b[kidd2]
		gen b1_kidd3   =_b[kidd3]
		gen b1_kidd4   =_b[kidd4]

		gen b1_cons   =_b[_cons]
		
		* SAVE THE COEFFICIENTS
		preserve
		keep in 1
		collapse b1*
		gen  mergeid=1
		saveold "CHIP-dta-files---final\b_`var'.dta",replace
		restore
		
		* COMPUTE THE VARIANCE OF MEASURED NON-DURABLE CONSUMPTION
		bys year (hhcode):  egen sd_`var' = sd(`var')
							 gen var_`var'= sd_`var'*sd_`var'
		bys year (hhcode):  egen mean_`var' = mean(`var')
		
		* IMPUTATION
		#delimit;
		gen `var'hat=(lq-(
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
}
