***************************************************************************************************************
* THIS FILE CALLS THE MATLAB ESTIMATION CODES TO ESTIMATE THE PARTIAL INSURANCE MODEL AND BOOSTRAPS THE 
* STANDARD ERRORS OF THE ESTIMATES.
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

cd "$mypath\Structural-Model"
// cd G:\Edmund\time-aggregation\Papers\ThePriceOfGrowth\data\Codes_PoG\Structural-Model\

  
 
****************************************************************************
* BOOTSTRAP INNER PROGRAM
****************************************************************************  
cap program drop progbootinner
program define progbootinner, rclass
	args bootid TA
	
	cap replace case_id = bootid
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
				* STEP 1: TRIMMING GROWTH RATES
				* TRIMMING TOP AND BOTTOM 1% OF GROWTH RATES
				local xwave = 2
				while `xwave' < 9 	{
					qui xtile p`xwave'_`var' = `var'	if wave == `xwave', nq(100)
					qui replace `var' =.	if (p`xwave'_`var'==100) & wave==`xwave'
					qui replace `var' =. 	if (p`xwave'_`var'==  1) & wave==`xwave'
					drop p`xwave'_`var'
					local     xwave = `xwave'+1
				}
				
				* STEP 2: ADDITIONAL TRIMMING THE ABSOLUTE LEVEL OF TWO CONSECUTIVE GROWTH RATES
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
	
	keep id interview_year cohort y_dif c_dif
	gen dy_dif = (y_dif ~=.)
	gen dc_dif = (c_dif ~=.)
	replace c_dif = 0 if c_dif ==.
	replace y_dif = 0 if y_dif ==.
	bys id: egen allmissy = sum(dy_dif)
	bys id: egen allmissc = sum(dc_dif)
	drop if allmissy == 0 & allmissc == 0
	drop allmissy allmissc
	drop if interview == 1989
	sort id interview_year
	keep id interview_year cohort y_dif dy_dif c_dif dc_dif
	order id interview_year cohort y_dif dy_dif c_dif dc_dif
	count
	
	* CREATE PANEL DATASET FOR MATLAB
	export delimited id interview_year cohort y_dif dy_dif c_dif dc_dif using "dydc4matlab.csv", novarnames replace
	
	if `TA'==1{
		* RUN THE MATLAB CODE THAT ESTIMATES THE MODEL
		shell "$mymatlab" -wait -nodisplay -nosplash -nodesktop -r < Mainresults_boot_TA.m Mainresults_boot_TA
	
		* IMPORT ESTIMATES FROM MATLAB
		insheet using "results_TA.csv", clear
		mkmat v1, matrix(parameters)
		matrix parameters = parameters'
		return mat param = parameters
	}
	else{
		* RUN THE MATLAB CODE THAT ESTIMATES THE MODEL
		shell "$mymatlab" -wait -nodisplay -nosplash -nodesktop -r < Mainresults_boot.m Mainresults_boot
	
		* IMPORT ESTIMATES FROM MATLAB
		insheet using "results.csv", clear
		mkmat v1, matrix(parameters)
		matrix parameters = parameters'
		return mat param = parameters
		
	}
end
 
****************************************************************************
* BOOTSTRAP OUTER PROGRAM no TA
****************************************************************************
cap program drop progbootouter
program define progbootouter, eclass
	display "Called with: `0'"
	preserve
	progbootinner `0' 0
	tempname temp
	matrix define `temp'=r(param)
	ereturn local cmd="bootstrap"
	ereturn post `temp'
end
  
 
 ****************************************************************************
* BOOTSTRAP OUTER PROGRAM with TA
****************************************************************************
cap program drop progbootouter_TA
program define progbootouter_TA, eclass
	display "Called with: `0'"
	preserve
	progbootinner `0' 1
	tempname temp
	matrix define `temp'=r(param)
	ereturn local cmd="bootstrap"
	ereturn post `temp'
end


 
***************************************************************************
* BOOTSTRAPPING no TA
*************************************************************************** 
 forvalues nspec = 3/16	{
	use "Baseline_Data\dydc_spec`nspec'.dta", clear
	
	gen   double bootid = case_id
	tsset bootid interview_year

	bootstrap, /*noisily*/ nodrop cluster(case_id) idcluster(bootid) reps(50) seed(200) saving(boot_spec`nspec'_final,replace): progbootouter bootid
	estimates save est_spec`nspec'_final, replace
	
	}
	
***************************************************************************
* BOOTSTRAPPING with TA
*************************************************************************** 
 forvalues nspec = 3/16	{
	use "Baseline_Data\dydc_spec`nspec'.dta", clear
	
	gen   double bootid = case_id
	tsset bootid interview_year

	bootstrap, /*noisily*/ nodrop cluster(case_id) idcluster(bootid) reps(50) seed(200) saving(boot_spec`nspec'_final_TA,replace): progbootouter_TA bootid
	estimates save est_spec`nspec'_final_TA, replace
	
	}


	cd "$mypath\"
