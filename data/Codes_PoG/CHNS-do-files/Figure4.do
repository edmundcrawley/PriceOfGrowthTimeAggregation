***************************************************************************************************************
* THIS FILE PRODUCES FIGURE 4.
* CHNS 1989 - 2009
* STATA/SE 14.0
***************************************************************************************************************
clear
set mem 500m
set more off
cap log close

cd "$mypath"

* cd "C:\Users\raul\Dropbox\CIW China - PoG\PoG - Data and Code\Codes_POG"

use "CHNS-dta-files---final\CHNStrimmed.dta", clear

*===============================================================	 
* FIGURE 4 IN THE PAPER
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
gen 	income1_ad2_Rural  = income1_ad2	if reside == 1
gen 	income1_ad2_Urban  = income1_ad2	if reside == 0
gen		consumption1_KP_Rural = consumption1_KP 	if reside == 1
gen		consumption1_KP_Urban = consumption1_KP 	if reside == 0

foreach var in 	consumption1_KP_Rural income1_ad2_Rural /// 
                consumption1_KP_Urban income1_ad2_Urban   {
				
		* COMPUTE THE VARIANCE OF LOGS BY WAVE FOR RURAL AND URBAN SEPARATELY
		gen ln`var' = ln(`var')	
		bys wave:       egen sdln`var'r=sd(ln`var')
						gen   vln`var'r=sdln`var'r*sdln`var'r
						drop sdln`var'r
						gen   Rln`var'r=.
						gen  vRln`var'r=.
						gen vXBln`var'r=.			   
			   
						local  xwave =  1
						while `xwave' < 9{
							regress   ln`var' i.sex i.age i.educ i.province i.minority 	      if wave==`xwave'
							predict  Rln`var'r`xwave' if wave==`xwave', resid					   						
							replace  Rln`var'r=  Rln`var'r`xwave'                     		  if wave==`xwave'
							egen   sdRln`var'r`xwave'=sd(Rln`var'r`xwave') 		   			  if wave==`xwave'										
							gen    vRln`var'r`xwave'= sdRln`var'r`xwave'*sdRln`var'r`xwave'   if wave==`xwave'															
							replace vRln`var'r= vRln`var'r`xwave'                             if wave==`xwave'	
							drop     Rln`var'r`xwave' sdRln`var'r`xwave' vRln`var'r`xwave'
							display `xwave'
							local xwave = `xwave'+ 1
						}

					replace    vXBln`var'r= vln`var'r - vRln`var'r
					
					* NORMALIZE VARIANCE TO 0 IN WAVE 1
						gen      vln`var'atr1 =    vln`var'r if wave==1		
						egen    Mvln`var'atr1 =max(vln`var'atr1)	
						replace  vln`var'atr1 =    vln`var'r-Mvln`var'atr1
						drop    Mvln`var'atr1
			
						gen      vRln`var'atr1 =    vRln`var'r if wave==1		
						egen    MvRln`var'atr1 =max(vRln`var'atr1)	
						replace  vRln`var'atr1 =    vRln`var'r-MvRln`var'atr1
						drop    MvRln`var'atr1

						gen      vXBln`var'atr1 =    vXBln`var'r if wave==1		
						egen    MvXBln`var'atr1 =max(vXBln`var'atr1)	
						replace  vXBln`var'atr1 =    vXBln`var'r-MvXBln`var'atr1
						drop    MvXBln`var'atr1	
	}		

gen cov_Rc1_Ry1ad2_Rural = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl Rlnconsumption1_KP_Ruralr Rlnincome1_ad2_Ruralr if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_Rc1_Ry1ad2_Rural=A[2,1] if subgroup == `i'
} 
drop subgroup

gen cov_Rc1_Ry1ad2_Urban = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl Rlnconsumption1_KP_Urbanr Rlnincome1_ad2_Urbanr if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_Rc1_Ry1ad2_Urban=A[2,1] if subgroup == `i'
} 
drop subgroup

* COLUMN 1
twoway (line    vlnconsumption1_KP_Ruralr    year, lcolor(blue)	   lpattern(solid) lwidth(thick)) ///	   
       (line    vlnincome1_ad2_Ruralr        year, lcolor(red)     lpattern(dash) lwidth(thick))  ///	   
       (line    vRlnconsumption1_KP_Ruralr   year, lcolor(eltblue) lpattern(solid) lwidth(thick)) ///	   
 	   (line    vRlnincome1_ad2_Ruralr       year, lcolor(pink)    lpattern(dash) lwidth(thick)) ///	   
	   , ylabel(0(.3)1.8,labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1color) xlabel(1989(2)2009) xtitle("", size(small)) subtitle("Rural", size(medium)) legend(nobox region(lstyle(none)) symxsize(6) ring(0) size(medium) pos(10) row(2) region(fcolor(none)) order(1 "var(C/KP)" 2 "var(I/Ad)" 3 "var(Resid C/KP)" 4 "var(Resid I/Ad)"))
		graph save   "CHNS-Figures/Figure4_c11.gph", replace  

      *(scatter vRlnconsumption1_KP_Ruralr   year, mcolor(eltblue) msymbol(O)) ///	   	   
	  *(scatter vRlnincome1_ad2_Ruralr       year, mcolor(pink)    msymbol(T) ) ///		   

		
twoway (line    vlnconsumption1_KP_Urbanr    year, lcolor(blue)		lpattern(solid) lwidth(thick)) ///	   
       (line    vlnincome1_ad2_Urbanr        year, lcolor(red)		lpattern(dash) lwidth(thick))  ///	   
       (line    vRlnconsumption1_KP_Urbanr   year, lcolor(eltblue)  lpattern(solid) lwidth(thick)) ///	   
       (line    vRlnincome1_ad2_Urbanr       year, lcolor(pink)     lpattern(dash) lwidth(thick)) ///	   
	   , ylabel(0(.3)1.8,labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1color) xlabel(1989(2)2009) xtitle("", size(small)) subtitle("Urban", size(medium)) legend(off) 
		graph save   "CHNS-Figures/Figure4_c12.gph", replace  

	  *(scatter vRlnconsumption1_KP_Urbanr   year, mcolor(eltblue)  msymbol(O)) ///	   	   
	  *(scatter vRlnincome1_ad2_Urbanr       year, mcolor(pink)     msymbol(T) ) ///	   	   
	
graph combine "CHNS-Figures/Figure4_c11.gph" "CHNS-Figures/Figure4_c12.gph", cols(1) scheme(s1color) subtitle("(a) Raw and Residual Inequality", size(small))
graph save "CHNS-Figures/Figure4_c1.gph", replace
						
* COLUMN 2
twoway (line    vRlnconsumption1_KP_Ruralatr1   year, lcolor(eltblue) lpattern(solid) lwidth(thick)) ///	   
	   (line    vRlnincome1_ad2_Ruralatr1       year, lcolor(pink)    lpattern(dash) lwidth(thick)) ///	   
	   , ylabel(0(.2).8,labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1color) xlabel(1989(2)2009) xtitle("", size(small)) subtitle("Rural", size(medium)) legend(nobox region(lstyle(none)) symxsize(6) ring(0) size(medium) pos(10) row(2) region(fcolor(none)) order(1 "var(Resid C/KP)" 2 "var(Resid I/Ad)"))
		graph save   "CHNS-Figures/Figure4_c21.gph", replace  

      *(scatter vRlnconsumption1_KP_Ruralatr1   year, mcolor(eltblue) msymbol(O)) ///	   	   
	  *(scatter vRlnincome1_ad2_Ruralatr1       year, mcolor(pink)    msymbol(T) ) ///	 	    		
		
twoway (line    vRlnconsumption1_KP_Urbanatr1   year, lcolor(eltblue) lpattern(solid) lwidth(thick)) ///	   
	   (line    vRlnincome1_ad2_Urbanatr1       year, lcolor(pink)    lpattern(dash) lwidth(thick)) ///	   
	   , ylabel(0(.2).8,labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1color) xlabel(1989(2)2009) xtitle("", size(small)) subtitle("Urban", size(medium)) legend(off) 
		graph save   "CHNS-Figures/Figure4_c22.gph", replace  
	
      *(scatter vRlnconsumption1_KP_Urbanatr1   year, mcolor(eltblue) msymbol(O)) ///	   	   
	  *(scatter vRlnincome1_ad2_Urbanatr1       year, mcolor(pink)    msymbol(T) ) ///	  	    

graph combine "CHNS-Figures/Figure4_c21.gph" "CHNS-Figures/Figure4_c22.gph", cols(1) scheme(s1color) title("(b) Residual Inequality, Normalized at 1989", size(small))
graph save "CHNS-Figures/Figure4_c2.gph", replace
				
* COLUMN 3
twoway (line    cov_Rc1_Ry1ad2_Rural year, lcolor(black) lwidth(thick))           ///	 	    
       (scatter cov_Rc1_Ry1ad2_Rural year, mcolor(black) msymbol(D)) ///	  	    
	   , ytitle("") ylabel(0(.1).3,labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1color) xlabel(1989(2)2009) xtitle("", size(small)) subtitle("Rural", size(medium)) legend(nobox region(lstyle(none)) symxsize(6) ring(0) size(medium) pos(12) row(1) region(fcolor(none)) order(1 "cov(Resid C/KP, Resid I/Ad)"))
		graph save   "CHNS-Figures/Figure4_c31.gph", replace  

twoway (line    cov_Rc1_Ry1ad2_Urban year, lcolor(black) lwidth(thick))           ///	 	    
       (scatter cov_Rc1_Ry1ad2_Urban year, mcolor(black) msymbol(D)) ///	   	    
	   , ytitle("") ylabel(0(.1).3,labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1color) xlabel(1989(2)2009) xtitle("", size(small)) subtitle("Urban", size(medium)) legend(off) 
		graph save   "CHNS Figures/Figure4_c32.gph", replace  
	
graph combine "CHNS-Figures/Figure4_c31.gph" "CHNS-Figures/Figure4_c32.gph", cols(1) scheme(s1color) subtitle("(c) Covariance of Residual Cons. and Inc.", size(small))
graph save "CHNS Figures/Figure4_c3.gph", replace
						
			
graph combine "CHNS-Figures/Figure4_c1.gph" "CHNS-Figures/Figure4_c2.gph" "CHNS-Figures/Figure4_c3.gph" , cols(3) scheme(s1color)	
graph export "CHNS-Figures/Figure4.png", width(1400) height(1000) replace
graph export "CHNS-Figures/Figure4.eps", replace

 erase "CHNS-Figures/Figure4_c1.gph" 
 erase "CHNS-Figures/Figure4_c2.gph"
 erase "CHNS-Figures/Figure4_c3.gph"
 erase "CHNS-Figures/Figure4_c11.gph"
 erase "CHNS-Figures/Figure4_c12.gph"
 erase "CHNS-Figures/Figure4_c21.gph"
 erase "CHNS-Figures/Figure4_c22.gph"
 erase "CHNS-Figures/Figure4_c31.gph"
 erase "CHNS-Figures/Figure4_c32.gph"
