***************************************************************************************************************
* THIS FILE PRODUCES FIGURE 3.
* CHNS 1989 - 2009
* STATA/SE 14.0
***************************************************************************************************************

clear
set mem 500m
set more off
cap log close

cd "$mypath"

use "CHNS-dta-files---final\CHNStrimmed.dta", clear

*===============================================================	 
* FIGURE 3 IN THE PAPER
*===============================================================
* COMPUTE THE ADULT EQUIVALENT MEASURES OF INCOME AND CONSUMPTION
* Compute equivalence scales
	qui gen equiv_KP       =  (numi_geq_15 +  .7*numi_lt_15)^(.7) /* These are the NAS scales used by Krueger and Perri ReStud who cite . If you read that reference you will find they refer to page 59 in "Measuring Poverty, A New Approach" published by the National Academy of Sciencies (NAS) scales. "																							It is Also used by Heathcote, Storesletten, and Violante JPE (Consumption Insurance and Labor Supply) */	
	qui gen numi_15_60 = numi_geq_15-numi_gt_60
	qui gen equiv_ad   = numi_geq_15
	qui gen equiv_ad2  = numi_15_60

* Compute adult-equivalent income
	qui gen consumption1_KP = consumption1 /equiv_KP
	qui gen income1_ad2 	= income1 /equiv_ad2

* Generate Rural and Urban counterparts
gen		equiv_KP_Rural = equiv_KP	if reside == 1
gen		equiv_KP_Urban = equiv_KP	if reside == 0
gen 	equiv_ad2_Rural= equiv_ad2	if reside == 1
gen 	equiv_ad2_Urban= equiv_ad2	if reside == 0
gen		income1_Rural  = income1	if reside == 1
gen 	income1_Urban  = income1	if reside == 0
gen		consumption1_Rural = consumption1 	if reside == 1
gen		consumption1_Urban = consumption1 	if reside == 0
gen 	income1_ad2_Rural  = income1_ad2	if reside == 1
gen 	income1_ad2_Urban  = income1_ad2	if reside == 0
gen		consumption1_KP_Rural = consumption1_KP 	if reside == 1
gen		consumption1_KP_Urban = consumption1_KP 	if reside == 0

* COMPUTE VARIANCE OF LOG
foreach var in 	income1_Rural     	consumption1_Rural		///
				income1_ad2_Rural 	consumption1_KP_Rural 	///
                income1_Urban     	consumption1_Urban    	///
				income1_ad2_Urban 	consumption1_KP_Urban 	///        
				equiv_KP_Rural 		equiv_ad2_Rural 		equiv_KP_Urban 		equiv_ad2_Urban  {
				
				gen ln`var' = ln(`var')			
	 bys wave: egen vln`var'=sd(ln`var')
			replace vln`var'=vln`var'*vln`var'
				gen mvln`var'1989  =      vln`var' if year==1989		
			   egen mvln`var'1989x = max(mvln`var'1989)	
				gen umvln`var'      =      vln`var'-mvln`var'1989x
			   drop mvln`var'1989x mvln`var'1989
}

* COMPUTE COVARIANCE OF INCOME1 AND EQUIV_AD2
gen cov_y_ad2_Rural = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl lnincome1_Rural lnequiv_ad2_Rural if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_y_ad2_Rural=A[2,1] if subgroup == `i'
} 
drop subgroup

gen cov_y_ad2_Urban = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl lnincome1_Urban lnequiv_ad2_Urban if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_y_ad2_Urban=A[2,1] if subgroup == `i'
} 
drop subgroup

* COMPUTE COVARIANCE OF CONSUMPTION1 AND EQUIV_KP
gen cov_c_KP_Rural = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl lnconsumption1_Rural lnequiv_KP_Rural if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_c_KP_Rural=A[2,1] if subgroup == `i'
} 
drop subgroup

gen cov_c_KP_Urban = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl lnconsumption1_Urban lnequiv_KP_Urban if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_c_KP_Urban=A[2,1] if subgroup == `i'
} 
drop subgroup

*COLUMN 1 
twoway (line vlnconsumption1_Rural  year, lcolor(blue) lwidth(thick))   ///	   
       (line vlnincome1_Rural       year, lpattern(dash) lcolor(red) lwidth(thick))  ///	 	    
	   , ylabel(.2(.2)1.4,labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1color) xlabel(1989(2)2009) xtitle("", size(vsmall)) subtitle("Rural", size(medium)) legend(nobox region(lstyle(none)) symxsize(6) ring(0) size(medium) pos(10) row(2) region(fcolor(none)) order(1 "var(C)" 2 "var(I)"))
		graph save   "CHNS-Figures/Figure3_c11.gph", replace  
	   *graph export "CHNS Figures/Figure3_c11.eps", replace
		
twoway (line vlnconsumption1_Urban  year, lcolor(blue) lwidth(thick))   ///	   
       (line vlnincome1_Urban       year, lpattern(dash) lcolor(red) lwidth(thick))  ///	 	    
	   , ylabel(.2(.2)1.4,labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1color) xlabel(1989(2)2009) xtitle("", size(vsmall)) subtitle("Urban", size(medium)) legend(off)
		graph save   "CHNS-Figures/Figure3_c12.gph", replace  
	   *graph export "CHNS Figures/Figure3_c12.eps", replace
   
graph combine "CHNS-Figures/Figure3_c11.gph" "CHNS-Figures/Figure3_c12.gph", cols(1) scheme(s1color) subtitle("(a) Consumption and Income", size(small))
graph save "CHNS-Figures/Figure3_c1.gph", replace
		  
*COLUMN 2  
twoway (line vlnequiv_KP_Rural  year, lcolor(orange) lwidth(thick))   ///	   
	   (line vlnequiv_ad2_Rural year, lpattern(dash)      lcolor(lavender) lwidth(thick)) ///	 	   
	   (line cov_c_KP_Rural     year, lpattern(shortdash) lcolor(maroon) lwidth(thick))   ///	   
	   (line cov_y_ad2_Rural    year, lpattern(dash_dot)  lcolor(black) lwidth(thick))    ///		   
	   , ytitle(,size(small)) ylabel(-.05(.05).25,labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1color) xlabel(1989(2)2009) xtitle("", size(vsmall)) subtitle("Rural", size(medium)) legend(nobox region(lstyle(none)) symxsize(6) ring(0) size(medium) pos(12) row(2) region(fcolor(none)) order(1 "var(KP)" 2 "var(Adults)" 3 "cov(C,KP)" 4 "cov(I,Adults)"))
		graph save   "CHNS-Figures/Figure3_c21.gph", replace 
	   *graph export "CHNS Figures/Figure3_c21.eps", replace
		
      
twoway (line vlnequiv_KP_Urban  year, lcolor(orange) lwidth(thick))   ///	   
	   (line vlnequiv_ad2_Urban year, lpattern(dash)      lcolor(lavender) lwidth(thick)) ///	 	   
	   (line cov_c_KP_Urban     year, lpattern(shortdash) lcolor(maroon) lwidth(thick))   ///	   
	   (line cov_y_ad2_Urban    year, lpattern(dash_dot)  lcolor(black) lwidth(thick))    ///		   
	   , ytitle(,size(small)) ylabel(-.05(.05).25,labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1color) xlabel(1989(2)2009) xtitle("", size(vsmall)) subtitle("Urban", size(medium)) legend(off)
		graph save   "CHNS-Figures/Figure3_c22.gph", replace
	   *graph export "CHNS Figures/Figure3_c22.eps", replace		
 
graph combine "CHNS-Figures/Figure3_c21.gph" "CHNS-Figures/Figure3_c22.gph", cols(1) scheme(s1color) subtitle("(b) Household Structure", size(small))
graph save "CHNS-Figures/Figure3_c2.gph", replace
		
* COLUMN 3
twoway (line umvlnconsumption1_KP_Rural    year, lpattern(solid) lcolor(cyan) lwidth(thick))     ///	 	    
	   (line umvlnincome1_ad2_Rural        year, lpattern(dash)  lcolor(sand) lwidth(thick))   ///	 	    	   
	   , ylabel(0(.2)1.0,labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1color) xlabel(1989(2)2009) xtitle("", size(vsmall)) title("Rural", size(medium)) legend(nobox region(lstyle(none)) symxsize(6) ring(0) size(medium) pos(12) row(1) region(fcolor(none)) order(1 "var(C/KP)" 2 "var(I/Adults)"))
		graph save   "CHNS-Figures/Figure3_c31.gph", replace  
	   *graph export "CHNS Figures/Figure3_c31.eps", replace		
    
twoway (line umvlnconsumption1_KP_Urban    year, lpattern(solid) lcolor(cyan) lwidth(thick))     ///	 	    
	   (line umvlnincome1_ad2_Urban        year, lpattern(dash)  lcolor(sand) lwidth(thick))   ///		 	    	   
	   , ylabel(0(.2)1.0,labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1color) xlabel(1989(2)2009) xtitle("", size(vsmall)) title("Urban", size(medium)) legend(off)
		graph save   "CHNS-Figures/Figure3_c32.gph", replace 
	   *graph export "CHNS Figures/Figure3_c32.eps", replace		
    
 graph combine "CHNS-Figures/Figure3_c31.gph" "CHNS-Figures/Figure3_c32.gph", cols(1) scheme(s1color) subtitle("(c) Adult-Equiv, Normalized at 1989", size(small))
 graph save "CHNS-Figures/Figure3_c3.gph", replace
			 	
 graph combine "CHNS-Figures/Figure3_c1.gph" "CHNS-Figures/Figure3_c2.gph" "CHNS-Figures/Figure3_c3.gph", cols(3) scheme(s1color) 
 graph export "CHNS-Figures/Figure3.png", width(1400) height(1000) replace
 graph export "CHNS-Figures/Figure3.eps", replace
 
 erase "CHNS-Figures/Figure3_c1.gph" 
 erase "CHNS-Figures/Figure3_c2.gph"
 erase "CHNS-Figures/Figure3_c3.gph"
 erase "CHNS-Figures/Figure3_c11.gph"
 erase "CHNS-Figures/Figure3_c12.gph"
 erase "CHNS-Figures/Figure3_c21.gph"
 erase "CHNS-Figures/Figure3_c22.gph"
 erase "CHNS-Figures/Figure3_c31.gph"
 erase "CHNS-Figures/Figure3_c32.gph"
