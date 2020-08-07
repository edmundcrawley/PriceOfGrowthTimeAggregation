***************************************************************************************************************
* THIS FILE PRODUCES FIGURE 1.
* CHNS 1989 - 2009
* STATA/SE 14.0
***************************************************************************************************************
clear
set mem 500m
set more off
cap log close

cd "$mypath"

use "CHNS-dta-files---final\CHNStrimmed.dta", clear

drop pritG pritR  // VARIABLES STILL IN RMB
		   
*===============================================================	 
* FIGURE 1 IN THE PAPER
*===============================================================
gen sub_work_Rural	 = sub_work		if reside == 1
gen sub_work_Urban   = sub_work		if reside == 0
gen sub_gvmt_Rural   = sub_gvmt		if reside == 1
gen sub_gvmt_Urban   = sub_gvmt		if reside == 0
gen sub_coupon_Rural = sub_coupon	if reside == 1
gen sub_coupon_Urban = sub_coupon 	if reside == 0
gen pi_Rural		 = pi			if reside == 1
gen pi_Urban		 = pi			if reside == 0
gen transfR_pub_Rural= transfR_pub  if reside == 1
gen transfR_pub_Urban= transfR_pub  if reside == 0
gen transfR_pri_Rural= transfR_pri	if reside == 1
gen transfR_pri_Urban= transfR_pri	if reside == 0
gen income1_Rural	 = income1		if reside == 1
gen income1_Urban	 = income1		if reside == 0

bys year reside (case_id): egen sum_income1_Rural = total(income1_Rural)  if reside == 1
bys year reside (case_id): egen sum_income1_Urban = total(income1_Urban)  if reside == 0

foreach var in sub_coupon sub_work sub_gvmt pi transfR_pub transfR_pri	{
		bys year reside (case_id): egen sum_`var'_Rural = total(`var'_Rural)  if reside == 1
		bys year reside (case_id): egen sum_`var'_Urban = total(`var'_Urban)  if reside == 0
		
		gen Tsh`var'_Rural = sum_`var'_Rural/sum_income1_Rural
		gen Tsh`var'_Urban = sum_`var'_Urban/sum_income1_Urban
		}

bys year reside (case_id): gen x = _n

twoway (line    Tshsub_coupon_Rural  year if x==1, lcolor(purple))    ///	   
       (scatter Tshsub_coupon_Rural  year if x==1, mcolor(purple) msymbol(O))    ///	   
	   (line    Tshsub_work_Rural    year if x==1, lcolor(eltblue))   ///	 	    
	   (scatter Tshsub_work_Rural    year if x==1, mcolor(eltblue) msymbol(D))   ///	 	    
       (line    Tshsub_gvmt_Rural    year if x==1, lcolor(red))     ///
       (scatter Tshsub_gvmt_Rural    year if x==1, mcolor(red) msymbol(T))     ///
	   (line    Tshpi_Rural          year if x==1, lcolor(khaki))    ///
	   (scatter Tshpi_Rural          year if x==1, mcolor(khaki) msymbol(S))    ///
       (line    TshtransfR_pub_Rural year if x==1, lcolor(orange))  ///
	   (scatter TshtransfR_pub_Rural year if x==1, mcolor(orange) msymbol(+))  ///
       (line    TshtransfR_pri_Rural year if x==1, lcolor(yellow))  ///	   
	   (scatter TshtransfR_pri_Rural year if x==1, mcolor(yellow) msymbol(X))  ///	   
	   , ylabel(0(.05).4,labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1mono) xlabel(1989(2)2009) xtitle("", size(small)) title("Rural", size(medium)) legend(nobox symxsize(3) ring(0) region(lstyle(none)) size(small) pos(12) row(2) region(fcolor(none)) order(2 "Food Coupon" 4 "Subsidy Work" 6 "Subsidy Gvmt" 8 "Pension" 10 "Public Transfers" 12 "Private Transfers"))
	graph save   "CHNS-Figures/Figure1_c1.gph", replace  
   *graph export "CHNS Figures/Figure1_c1.eps", replace  
	
twoway (line    Tshsub_coupon_Urban  year if x==1, lcolor(purple))    ///	   
       (scatter Tshsub_coupon_Urban  year if x==1, mcolor(purple) msymbol(O))    ///	   
	   (line    Tshsub_work_Urban    year if x==1, lcolor(eltblue))   ///	 	    
	   (scatter Tshsub_work_Urban    year if x==1, mcolor(eltblue) msymbol(D))   ///	 	    
       (line    Tshsub_gvmt_Urban    year if x==1, lcolor(red))     ///
       (scatter Tshsub_gvmt_Urban    year if x==1, mcolor(red) msymbol(T))     ///
	   (line    Tshpi_Urban          year if x==1, lcolor(khaki))    ///
	   (scatter Tshpi_Urban          year if x==1, mcolor(khaki) msymbol(S))    ///
       (line    TshtransfR_pub_Urban year if x==1, lcolor(orange))  ///
	   (scatter TshtransfR_pub_Urban year if x==1, mcolor(orange) msymbol(+))  ///
       (line    TshtransfR_pri_Urban year if x==1, lcolor(yellow))  ///	   
	   (scatter TshtransfR_pri_Urban year if x==1, mcolor(yellow) msymbol(X))  ///		   
	   , ylabel(0(.05).4,labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1mono) xlabel(1989(2)2009) xtitle("", size(small)) title("Urban", size(medium)) legend(nobox symxsize(3) ring(0) region(lstyle(none)) size(small) pos(12) row(2) region(fcolor(none)) order(2 "Food Coupon" 4 "Subsidy Work" 6 "Subsidy Gvmt" 8 "Pension" 10 "Public Transfers" 12 "Private Transfers"))
	graph save   "CHNS-Figures/Figure1_c2.gph", replace  
   *graph export "CHNS Figures/Figure1_c2.eps", replace  
	
 graph combine "CHNS-Figures/Figure1_c1.gph" "CHNS-Figures/Figure1_c2.gph" , cols(2) scheme(s1mono) /*title("Total Transfers (% of Total Income)", size(small))*/
 graph export "CHNS-Figures/Figure1.png", width(1400) height(1000) replace
 graph export "CHNS-Figures/Figure1.eps", replace

 
 erase "CHNS-Figures/Figure1_c1.gph"
 erase "CHNS-Figures/Figure1_c2.gph"
