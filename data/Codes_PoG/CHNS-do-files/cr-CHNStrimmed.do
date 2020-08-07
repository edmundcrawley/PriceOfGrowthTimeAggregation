***************************************************************************************************************
* THIS FILE DOES THE TRIMMING OF THE CHNS INCOME AND CONSUMPTION MEASRUES.
* CHNS 1989 - 2009
* STATA/SE 14.0
***************************************************************************************************************
clear
clear matrix
clear mata
set mem 500m
set maxvar 32760
set more off

 cd "$mypath"
 
 capture log close
 log using "CHNS-log\cr-CHNStrimmed", replace	
	 
 use "CHNS-dta-files---final\CHNS-no-trim-final.dta", clear

 drop anp* wf_gov sub_gov

********************
* Notes: all real values (in 2009 urban Liaoning yuan)
* HH Income side:	- ai (cfoodown is a part of ai)
*					- bi
*					- ci
*					- lmi
*					- sub_work (foodgift is a part of sub_work)
*					- sub_gvmt (sub_utility is a part of sub_gvmt)
*					- sub_coupon and sub_coupon_pw (two measures of food coupons: the former based on resale value and the latter based on price wedge.
*						In general the former is smaller than the latter)
*					- pi
*					- pt
* The net transfer, nt, would be sub_work + sub_gvmt + sub_coupon (or sub_coupon_pw) + pi + pt.
* HH Consumption side:	- cdiet: value of diet
*						- cfoodown: value of home grown food
*						- sub_coupon and sub_coupon_pw
*						- foodgift
*						- sub_utility
*						- cchildcare
*						- ptout
*						- cmed and cmedins
*						- cedu
*						- chouse
*						- cdurable
* The expenditure on food would be food expenditure = cdiet - cfoodown - sub_coupon (or sub_coupon_pw) - foodgift, with negative replaced by zero.
* I used sub_coupon. Using sub_coupon_pt would result in even higher growth rates of food expenditure in urban areas.
* If you want to substact foodgift from both sides of the budget, then substract foodgift from sub_work and don't substract it from cdiet.
**************************************************************************************************************

*******************************************
* SAMPLE SELECTION
*******************************************
* Keep head only
 replace relation2head=relation2head+1
 label define A2relation2head 1 "head" 2 "spouse" 3 "father/mother" 4 "son/daughter" 5 "brother/sister" 6 "grandson(-in-law)/granddaughter(-in-law)"  ///
							 7 "mother-in-law/father-in-law" 8 "son-in-law/daughter-in-law" 9 "other relative" 10 "maid" 11 "other non-relative"
 label values relation2head A2relation2head
 keep if relation2head==1

* Age restrictions
 drop if (age<25 | age>65) 
 
 * Household size
 drop if hh_size>6 | hh_size<2
 
 ******************************************
 * RENAME SOME VARIABLES
 ******************************************
 * WAVE
    gen wave=1 if interview_year==1989
replace wave=2 if interview_year==1991
replace wave=3 if interview_year==1993
replace wave=4 if interview_year==1997
replace wave=5 if interview_year==2000
replace wave=6 if interview_year==2004
replace wave=7 if interview_year==2006
replace wave=8 if interview_year==2009
gen 	year = interview_year

* COHORT
  gen cohort=interview_year-age

* TRANSFER-RELATED VARIABLES
rename pt 				pritR
rename ptout			pritG
rename marital        	marital_status
gen 	reside = 1 if urban == 0
replace reside = 0 if urban == 1
label variable reside "0 Urban, 1 Rural"
egen transfR_pub = rsum(sub_work sub_gvmt sub_coupon pi)  //Public  Transfers Received (note: sub_gvmt includes sub_utility)
egen transfR_pri = rsum(pritR)                            //Private Transfers Received
egen transfG_pri = rsum(pritG)                            //Private Transfers Given 

* SORT THE DATA
 sort case_id wave		 
xtset case_id wave

*******************************************
* CONVERT FROM NOMINAL TO REAL VARIABLES
*******************************************
**************************************************************************************************************
* Transform Chinese Yuan (Renminbi) (i.e, CNY) into 2009 USD. Our variables are already real CNY, so we use nominal exchange rates (source: World Bank)

        foreach var in ai bi ci lmi sub_work sub_gvmt sub_coupon sub_coupon_pw pi transfR_pub transfR_pri transfG_pri {
         	replace `var'=`var'/6.8300
		}

        foreach var in cdiet cfoodown foodgift sub_utility cchildcare cmed cmedins cedu chouse cdurable house_value downpay mortgage rent {
         	replace `var'=`var'/6.8300
		}		
********************************************
* TRIMMING
********************************************
*------------------------------------------------------------------------------------------------------------*	
*------------------------------------------------------------------------------------------------------------*
*    						(A) HOUSEHOLD INCOME LEVEL	                                                     *
*------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------*		
	
*------------------------------------------------------------------------------------------------------------*
*    						(A1) TRIMMING INCOME (SUB)ITEMS (LEVEL)	                                         *
*------------------------------------------------------------------------------------------------------------*

	* Trim level of income items 
	*-------------------------------------------------------	
	//       Notes: ai & bi can be positive or negative (we trim top and bottom 1%). 
	//              ci lmi sub_work sub_gvmt sub_coupon sub_coupon_pw pi transfR_pub transfR_pri transfG_pri are always positive, and we trim the top 1% and also bottom 1% excluding the zeros
	//	            Note that here transfG_pri takes positive values, two sections below we transform this into negative to compute net transfers.
	
	* Replace outliers by missing					
	local  xwave  = 1
	while `xwave' < 9 {
						foreach var in ai bi {
							xtile p`xwave'_`var'Urban = `var' if wave==`xwave' & reside==0, nq(100)					
							xtile p`xwave'_`var'Rural = `var' if wave==`xwave' & reside==1, nq(100)										
							qui replace `var'=. if (p`xwave'_`var'Urban==100) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==100) &  wave==`xwave' & reside==1
							qui replace `var'=. if (p`xwave'_`var'Urban==  1) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==  1) &  wave==`xwave' & reside==1					 
						 drop p`xwave'_`var'Urban p`xwave'_`var'Rural 				    
						}
						display  " wave" `xwave'
						local     xwave = `xwave'+1
		} 

	local  xwave  = 1
	while `xwave' < 9 {
						foreach var in ci lmi sub_work sub_gvmt pi transfR_pub transfR_pri {
							xtile p`xwave'_`var'Urban = `var' if wave==`xwave' & reside==0 & `var'~=0, nq(100)	  /*These items take only positive values and they can be zero: for this reason we trim very small non-zero values */				
							xtile p`xwave'_`var'Rural = `var' if wave==`xwave' & reside==1 & `var'~=0, nq(100)										
							qui replace `var'=. if (p`xwave'_`var'Urban==  100) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==  100) &  wave==`xwave' & reside==1					 
							qui replace `var'=. if (p`xwave'_`var'Urban==    1) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==    1) &  wave==`xwave' & reside==1	
							drop p`xwave'_`var'Urban p`xwave'_`var'Rural 				    
						} 
						display  " wave" `xwave'
						local     xwave = `xwave'+1
		} 

	* Notes: transfG_pri is not available for wave 8.
	local  xwave  = 1
	while `xwave' < 8 {
						foreach var in transfG_pri {
							xtile p`xwave'_`var'Urban = `var' if wave==`xwave' & reside==0 & `var'~=0, nq(100)	  /*These items take only positive values and they can be zero: for this reason we trim very small non-zero values */				
							xtile p`xwave'_`var'Rural = `var' if wave==`xwave' & reside==1 & `var'~=0, nq(100)										
							qui replace `var'=. if (p`xwave'_`var'Urban==  100) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==  100) &  wave==`xwave' & reside==1					 
							qui replace `var'=. if (p`xwave'_`var'Urban==    1) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==    1) &  wave==`xwave' & reside==1	
							drop p`xwave'_`var'Urban p`xwave'_`var'Rural 				    
						}
						display  " wave" `xwave'
						local     xwave = `xwave'+1
		} 

	* Notes: sub_coupon & sub_coupon_pw are available only for wave 1, 2 and 3.
	local  xwave  = 1
	while `xwave' < 4 {
						foreach var in sub_coupon sub_coupon_pw {
							xtile p`xwave'_`var'Urban = `var' if wave==`xwave' & reside==0 & `var'~=0, nq(100)	  /*These items take only positive values and they can be zero: for this reason we trim very small non-zero values */				
							xtile p`xwave'_`var'Rural = `var' if wave==`xwave' & reside==1 & `var'~=0, nq(100)										
							qui replace `var'=. if (p`xwave'_`var'Urban==  100) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==  100) &  wave==`xwave' & reside==1					 
							qui replace `var'=. if (p`xwave'_`var'Urban==    1) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==    1) &  wave==`xwave' & reside==1	
							drop p`xwave'_`var'Urban p`xwave'_`var'Rural 				    
						}
						display  " wave" `xwave'
						local     xwave = `xwave'+1
		} 

*------------------------------------------------------------------------------------------------------------*
*    						(A2) AGGREGATING AND TRIMMING HOUSEHOLD INCOME (LEVEL)               	         *
*------------------------------------------------------------------------------------------------------------*

	* DEFINE HOUSEHOLD INCOME:
		// EARNINGS
		egen income0 = rsum(ai bi ci lmi)		// IN THE OLD CODE
		*egen income0 = rsum(ai bi ci lmi), missing
		// DISPOSABLE INCOME (EARNINGS + PRIVATE TRANSFERS RECEIVED + PUBLIC TRANSFERS RECEIVED)
		egen income1 = rsum(income0 transfR_pub transfR_pri) if income0~=.
		// EARNINGS + PRIVATE TRANSFERS RECEIVED
		egen income2 = rsum(income0 transfR_pri) if income0~=.
		// EARNINGS + PUBLIC TRANSFERS RECEIVED
		egen income3 = rsum(income0 transfR_pub) if income0~=.
		// EARNINGS + NON-IN-KIND PUBLIC TRANSFERS RECEIVED
		gen  nsub_coupon = -sub_coupon
		gen  nsub_work   = -sub_work
		egen income4 = rsum(income3 nsub_coupon nsub_work) if income3~=.	

	* Trim level of household income
	*-------------------------------------------------------	
	drop if income1==0	
	local  xwave  = 1
	while `xwave' < 9 {
						foreach var in income0 income1 income2 income3 income4 {
							xtile p`xwave'_`var'Urban = `var' if wave==`xwave' & reside==0, nq(100)				/*all these items can take negative and postivie values */					 
							xtile p`xwave'_`var'Rural = `var' if wave==`xwave' & reside==1, nq(100)										
							qui replace `var'=. if (p`xwave'_`var'Urban==100) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==100) &  wave==`xwave' & reside==1
							qui replace `var'=. if (p`xwave'_`var'Urban==1)   &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==1)   &  wave==`xwave' & reside==1
							drop p`xwave'_`var'Urban p`xwave'_`var'Rural 				    
						}
						display  " wave" `xwave'
						local     xwave = `xwave'+1
	} 

*------------------------------------------------------------------------------------------------------------*	
*------------------------------------------------------------------------------------------------------------*
*    						(B) HOUSEHOLD CONSUMPTION LEVEL	                                                 *
*------------------------------------------------------------------------------------------------------------*
*------------------------------------------------------------------------------------------------------------*		
	
*------------------------------------------------------------------------------------------------------------*
*    						(B1) TRIMMING CONSUMPTION (SUB)ITEMS (LEVEL)	                                 *
*------------------------------------------------------------------------------------------------------------*
	
	* Trim level of consumption items 
	*-------------------------------------------------------	
	//       Notes: All these items take positive values, for that reason we trim the top 1% and also the bottom 1% of strictly positive values.
	* Replace outliers by missing
	local  xwave  = 1
	while `xwave' < 9 {
						foreach var in cdiet foodgift cdurable rent  {
							xtile p`xwave'_`var'Urban = `var' if wave==`xwave' & reside==0 & `var'~=0, nq(100)					
							xtile p`xwave'_`var'Rural = `var' if wave==`xwave' & reside==1 & `var'~=0, nq(100)										
							qui replace `var'=. if (p`xwave'_`var'Urban==  100) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==  100) &  wave==`xwave' & reside==1					 
							qui replace `var'=. if (p`xwave'_`var'Urban==    1) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==    1) &  wave==`xwave' & reside==1	
						 drop p`xwave'_`var'Urban p`xwave'_`var'Rural 				    
						}
						display  " wave" `xwave'
						local     xwave = `xwave'+1
	} 

	* For foodown, i.e., food produced at home (farm), we only trim the rural by percentiles because there are few observations in urban areas (less than 100).
	* table wave reside if cfoodown~=0, c(n cfoodown) 
	local  xwave  = 1
	while `xwave' < 9 {
						foreach var in cfoodown {
							xtile p`xwave'_`var'Rural = `var' if wave==`xwave' & reside==1 & `var'~=0, nq(100)										
							qui replace `var'=. if (p`xwave'_`var'Rural==  100) &  wave==`xwave' & reside==1					 
							qui replace `var'=. if (p`xwave'_`var'Rural==    1) &  wave==`xwave' & reside==1	
						 drop p`xwave'_`var'Rural 				    
						}
						display  " wave" `xwave'
						local     xwave = `xwave'+1
	}
	local  xwave  = 4
	while `xwave' < 9 {
						foreach var in sub_utility {
							xtile p`xwave'_`var'Urban = `var' if wave==`xwave' & reside==0 & `var'~=0, nq(100)					
							xtile p`xwave'_`var'Rural = `var' if wave==`xwave' & reside==1 & `var'~=0, nq(100)										
							qui replace `var'=. if (p`xwave'_`var'Urban==  100) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==  100) &  wave==`xwave' & reside==1					 
							qui replace `var'=. if (p`xwave'_`var'Urban==    1) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==    1) &  wave==`xwave' & reside==1	
						 drop p`xwave'_`var'Urban p`xwave'_`var'Rural 				    
						}
						display  " wave" `xwave'
						local     xwave = `xwave'+1
	} 				
	local  xwave  = 7
	while `xwave' < 8 {
						foreach var in cedu {
							xtile p`xwave'_`var'Urban = `var' if wave==`xwave' & reside==0 & `var'~=0, nq(100)					
							xtile p`xwave'_`var'Rural = `var' if wave==`xwave' & reside==1 & `var'~=0, nq(100)										
							qui replace `var'=. if (p`xwave'_`var'Urban==  100) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==  100) &  wave==`xwave' & reside==1					 
							qui replace `var'=. if (p`xwave'_`var'Urban==    1) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==    1) &  wave==`xwave' & reside==1	
						 drop p`xwave'_`var'Urban p`xwave'_`var'Rural 				    
						}
						display  " wave" `xwave'
						local     xwave = `xwave'+1
	} 

*------------------------------------------------------------------------------------------------------------*
*    						(B2) AGGREGATING AND TRIMMING HOUSEHOLD CONSUMPTION (LEVEL)               	     *
*------------------------------------------------------------------------------------------------------------*

	* DEFINE HOUSEHOLD CONSUMPTION:
	gen  	ncfoodown = -cfoodown
	gen  	nfoodgift = -foodgift
	gen 	nsub_utility = -sub_utility
	egen 	food_exp = rsum(cdiet ncfoodown nsub_coupon nfoodgift) if cdiet~=. & cdiet~=0				// CASH EXPENDITURE ON FOOD
	replace food_exp=0 if food_exp<0
	gen		consumption0 = cdiet
	egen 	consumption1 = rsum(cdiet cmed cmedins cdurable sub_utility) if cdiet~=. & cdiet~=0		// CONSUMPTION OF CONSISTENTLY SURVEYED ITEMS
	egen 	consumption2 = rsum(consumption1 nsub_coupon nsub_utility) 	 if consumption1~=.			// CONSUMPTION OF CONSISTENTLY SURVEYED ITEMS EXCEPT IN-KIND PUBLIC TRANSFERS
	replace consumption2 =. if consumption2<0
	egen 	consumption6 = rsum(cdiet sub_utility)						 if cdiet~=. & cdiet~=0		// CONSUMPTION OF CONSISTENTLY SURVEYED ITEMS: FOOD AND UTILITY
	egen 	consumption7 = rsum(cdiet sub_utility cmed cmedins)			 if cdiet~=. & cdiet~=0		// CONSUMPTION OF CONSISTENTLY SURVEYED ITEMS: FOOD, UTILITY AND HEALTH
	egen 	consumption8 = rsum(cdiet cmed cmedins cdurable sub_utility rent) if cdiet~=. & cdiet~=0 & rent~=.		// CONSUMPTION OF CONSISTENTLY SURVEYED ITEMS PLUS (IMPUTED) RENT FROM HOUSING SERVICE
	* Trim level of household consumption
	*-------------------------------------------------------	
	drop if consumption1==0	
	local  xwave  = 1
	while `xwave' < 9 {
						foreach var in food_exp consumption1 consumption2 consumption6 consumption7 consumption8 {
							xtile p`xwave'_`var'Urban = `var' if wave==`xwave' & reside==0 & `var'~=0, nq(100)					
							xtile p`xwave'_`var'Rural = `var' if wave==`xwave' & reside==1 & `var'~=0, nq(100)										
							qui replace `var'=. if (p`xwave'_`var'Urban==  100) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==  100) &  wave==`xwave' & reside==1					 
							qui replace `var'=. if (p`xwave'_`var'Urban==    1) &  wave==`xwave' & reside==0
							qui replace `var'=. if (p`xwave'_`var'Rural==    1) &  wave==`xwave' & reside==1	
							drop p`xwave'_`var'Urban p`xwave'_`var'Rural 				    
						}
						display  " wave" `xwave'
						local     xwave = `xwave'+1
	} 

	label var income0 "earnings"
	label var income1 "disposable income"
	label var income2 "earnings+private transfers"
	label var income3 "earnings+public transfers"
	label var income4 "earnings+cash public transfers"
	
	label var food_exp 		"cash expenditure onfood"
	label var consumption0  "food"
	label var consumption1  "all items consistent in chns"
	label var consumption2  "all items consistent in chns minus in-kind transfers"
	label var consumption6	"food and utility consistent in chns"
	label var consumption7  "food, utility and health consistent in chns"
	label var consumption8  "all items consistent in chns plus (imputed) rent from housing service"
	
drop ncfoodown nsub_coupon nfoodgift nsub_utility nsub_work

 saveold "CHNS-dta-files---final\CHNStrimmed.dta", replace
 
 
log close
