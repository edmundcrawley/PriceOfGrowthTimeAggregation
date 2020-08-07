***************************************************************************************************************
* THIS FILE CONSTRUCTS THE DATA NEEDED FOR THE ESTIMATION OF THE INCOME PROCESS IN MATLAB.
* CHNS 1989 - 2009
* STATA/SE 14.0
* CREATED BY YU ZHENG
***************************************************************************************************************
clear
clear matrix
clear mata
set mem 500m
set maxvar 32760
set more off

 cd "$mypath"
 
 *************************
 * RURAL LEVEL DATA
 *************************
 use "Structural-Model\Baseline_Data\dydc_spec1.dta", clear		// RURAL LEVEL DATA
 
	gen age = interview_year - cohort
	* COMPUTE RESIDUALS
	gen Rlogy =.
	gen Rlogc =.
	local  xwave =  1
	while `xwave' < 9{
		qui regress   logy i.sex i.age i.educ i.province i.minority	      if wave==`xwave'
		qui predict  Rlogywave`xwave' 				if wave==`xwave', resid					   						
		replace  Rlogy=  Rlogywave`xwave'       if wave==`xwave'
		drop     Rlogywave`xwave'
		
		qui regress   logc i.sex i.age i.educ i.province i.minority	      if wave==`xwave'
		qui predict  Rlogcwave`xwave' 				if wave==`xwave', resid					   						
		replace  Rlogc=  Rlogcwave`xwave'       if wave==`xwave'
		drop     Rlogcwave`xwave'
		
		local xwave = `xwave'+ 1
	}
	* COMPUTE RESIDUAL GROWTH
	tsset case_id wave
	tsfill, full
	foreach var in cohort {
		bys case_id (`var'): replace `var' = `var'[1]
		}
	replace interview_year = 1989 if wave ==1 & mi(interview_year)
	replace interview_year = 1991 if wave ==2 & mi(interview_year)
	replace interview_year = 1993 if wave ==3 & mi(interview_year)
	replace interview_year = 1997 if wave ==4 & mi(interview_year)
	replace interview_year = 2000 if wave ==5 & mi(interview_year)
	replace interview_year = 2004 if wave ==6 & mi(interview_year)
	replace interview_year = 2006 if wave ==7 & mi(interview_year)
	replace interview_year = 2009 if wave ==8 & mi(interview_year)	
	
	sort  case_id wave
	gen y_dif = D.Rlogy
	gen c_dif = D.Rlogc
	
	
	* TRIM RESIDUAL GROWTH
		foreach var in y_dif c_dif {
			* ANNUALIZE GROWTH RATES
			replace `var'=`var'/2 if wave==2
			replace `var'=`var'/2 if wave==3
			replace `var'=`var'/4 if wave==4
			replace `var'=`var'/3 if wave==5
			replace `var'=`var'/4 if wave==6
			replace `var'=`var'/2 if wave==7
			replace `var'=`var'/3 if wave==8
			* TRIMMING:
				* OPTION 1: TRIMMING GROWTH RATES ONLY (ESTIMATES SAVED AS EST`NUM_SPEC'.STER)
				* TRIMMING TOP AND BOTTOM 1% OF GROWTH RATES
				local xwave = 2
				while `xwave' < 9 	{
					qui xtile p`xwave'_`var' = `var'	if wave == `xwave', nq(100)
					qui replace `var' =.	if (p`xwave'_`var'==100) & wave==`xwave'
					qui replace `var' =. 	if (p`xwave'_`var'==  1) & wave==`xwave'
					drop p`xwave'_`var'
					local     xwave = `xwave'+1
				}
				
				* OPTION 2: ADDITIONAL TRIMMING THE ABSOLUTE LEVEL OF TWO CONSECUTIVE GROWTH RATES (ESTIMATES SAVED AS EST`NUM_SPEC'A.STER)
				*TRIMMING THE ABSOLUTE LEVEL OF TWO CONSECUTIVE GROWTH RATES
				gen  abs`var'=abs(`var')
				gen sabs`var'=abs`var'+L.abs`var'
				replace `var' =. if   sabs`var'>2.0 & 	sabs`var'~=.
				replace `var' =. if F.sabs`var'>2.0 & F.sabs`var'~=.
				
		* RECOVER THE GAPS BETWEEN INTERVIEWS
		replace `var'=`var'*2 if wave==2
		replace `var'=`var'*2 if wave==3
		replace `var'=`var'*4 if wave==4
		replace `var'=`var'*3 if wave==5
		replace `var'=`var'*4 if wave==6
		replace `var'=`var'*2 if wave==7
		replace `var'=`var'*3 if wave==8
		}
	
	egen id = group(case_id)
	gen dy_dif = (y_dif ~=.)
	gen dc_dif = (c_dif ~=.)
	replace c_dif = 0 if c_dif ==.
	replace y_dif = 0 if y_dif ==.
	bys id: egen allmissy = sum(dy_dif)
	bys id: egen allmissc = sum(dc_dif)
	drop if allmissy == 0 & allmissc == 0
	drop allmissy allmissc
	
	
	keep id interview_year cohort Rlogy Rlogc
	gen dRlogy = (Rlogy ~=.)
	gen dRlogc = (Rlogc ~=.)
	replace Rlogc = 0 if Rlogc ==.
	replace Rlogy = 0 if Rlogy ==.
	bys id: egen allmissy = sum(dRlogy)
	bys id: egen allmissc = sum(dRlogc)
	drop if allmissy == 0 & allmissc == 0
	drop allmissy allmissc
	sort  id interview_year
	keep  id interview_year cohort Rlogy dRlogy Rlogc dRlogc
	order id interview_year cohort Rlogy dRlogy Rlogc dRlogc
	count
	
	* CREATE PANEL DATASET FOR MATLAB
	export delimited id interview_year cohort Rlogy dRlogy Rlogc dRlogc using "Structural-Model\Income_Process_Data\dataLV_Rural.csv", novarnames replace
	
	
 *************************
 * URBAN LEVEL DATA
 *************************
 use "Structural-Model\Baseline_Data\dydc_spec2.dta", clear		// RURAL LEVEL DATA
 
	gen age = interview_year - cohort
	* COMPUTE RESIDUALS
	gen Rlogy =.
	gen Rlogc =.
	local  xwave =  1
	while `xwave' < 9{
		qui regress   logy i.sex i.age i.educ i.province i.minority	      if wave==`xwave'
		qui predict  Rlogywave`xwave' 				if wave==`xwave', resid					   						
		replace  Rlogy=  Rlogywave`xwave'       if wave==`xwave'
		drop     Rlogywave`xwave'
		
		qui regress   logc i.sex i.age i.educ i.province i.minority	      if wave==`xwave'
		qui predict  Rlogcwave`xwave' 				if wave==`xwave', resid					   						
		replace  Rlogc=  Rlogcwave`xwave'       if wave==`xwave'
		drop     Rlogcwave`xwave'
		
		local xwave = `xwave'+ 1
	}
	* COMPUTE RESIDUAL GROWTH
	tsset case_id wave
	tsfill, full
	foreach var in cohort {
		bys case_id (`var'): replace `var' = `var'[1]
		}
	replace interview_year = 1989 if wave ==1 & mi(interview_year)
	replace interview_year = 1991 if wave ==2 & mi(interview_year)
	replace interview_year = 1993 if wave ==3 & mi(interview_year)
	replace interview_year = 1997 if wave ==4 & mi(interview_year)
	replace interview_year = 2000 if wave ==5 & mi(interview_year)
	replace interview_year = 2004 if wave ==6 & mi(interview_year)
	replace interview_year = 2006 if wave ==7 & mi(interview_year)
	replace interview_year = 2009 if wave ==8 & mi(interview_year)	
	
	sort  case_id wave
	gen y_dif = D.Rlogy
	gen c_dif = D.Rlogc
	
	
	* TRIM RESIDUAL GROWTH
		foreach var in y_dif c_dif {
			* ANNUALIZE GROWTH RATES
			replace `var'=`var'/2 if wave==2
			replace `var'=`var'/2 if wave==3
			replace `var'=`var'/4 if wave==4
			replace `var'=`var'/3 if wave==5
			replace `var'=`var'/4 if wave==6
			replace `var'=`var'/2 if wave==7
			replace `var'=`var'/3 if wave==8
			* TRIMMING:
				* OPTION 1: TRIMMING GROWTH RATES ONLY (ESTIMATES SAVED AS EST`NUM_SPEC'.STER)
				* TRIMMING TOP AND BOTTOM 1% OF GROWTH RATES
				local xwave = 2
				while `xwave' < 9 	{
					qui xtile p`xwave'_`var' = `var'	if wave == `xwave', nq(100)
					qui replace `var' =.	if (p`xwave'_`var'==100) & wave==`xwave'
					qui replace `var' =. 	if (p`xwave'_`var'==  1) & wave==`xwave'
					drop p`xwave'_`var'
					local     xwave = `xwave'+1
				}
				
				* OPTION 2: ADDITIONAL TRIMMING THE ABSOLUTE LEVEL OF TWO CONSECUTIVE GROWTH RATES (ESTIMATES SAVED AS EST`NUM_SPEC'A.STER)
				*TRIMMING THE ABSOLUTE LEVEL OF TWO CONSECUTIVE GROWTH RATES
				gen  abs`var'=abs(`var')
				gen sabs`var'=abs`var'+L.abs`var'
				replace `var' =. if   sabs`var'>2.0 & 	sabs`var'~=.
				replace `var' =. if F.sabs`var'>2.0 & F.sabs`var'~=.
				
		* RECOVER THE GAPS BETWEEN INTERVIEWS
		replace `var'=`var'*2 if wave==2
		replace `var'=`var'*2 if wave==3
		replace `var'=`var'*4 if wave==4
		replace `var'=`var'*3 if wave==5
		replace `var'=`var'*4 if wave==6
		replace `var'=`var'*2 if wave==7
		replace `var'=`var'*3 if wave==8
		}
	
	egen id = group(case_id)
	gen dy_dif = (y_dif ~=.)
	gen dc_dif = (c_dif ~=.)
	replace c_dif = 0 if c_dif ==.
	replace y_dif = 0 if y_dif ==.
	bys id: egen allmissy = sum(dy_dif)
	bys id: egen allmissc = sum(dc_dif)
	drop if allmissy == 0 & allmissc == 0
	drop allmissy allmissc
	
	
	keep id interview_year cohort Rlogy Rlogc
	gen dRlogy = (Rlogy ~=.)
	gen dRlogc = (Rlogc ~=.)
	replace Rlogc = 0 if Rlogc ==.
	replace Rlogy = 0 if Rlogy ==.
	bys id: egen allmissy = sum(dRlogy)
	bys id: egen allmissc = sum(dRlogc)
	drop if allmissy == 0 & allmissc == 0
	drop allmissy allmissc
	sort  id interview_year
	keep  id interview_year cohort Rlogy dRlogy Rlogc dRlogc
	order id interview_year cohort Rlogy dRlogy Rlogc dRlogc
	count
	
	* CREATE PANEL DATASET FOR MATLAB
	export delimited id interview_year cohort Rlogy dRlogy Rlogc dRlogc using "Structural-Model\Income_Process_Data\dataLV_Urban.csv", novarnames replace

 cd "$mypath"
 