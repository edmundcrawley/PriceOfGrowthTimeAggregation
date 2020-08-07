***************************************************************************************************************
* THIS FILE PRODUCES INCOME AND CONSUMPTION GINI FROM CHNS 1989-2009.
* CHNS 1989 - 2009
* STATA/SE 14.0
* CREATED BY YU ZHENG
***************************************************************************************************************
clear
set mem 500m
set more off
cap log close
cap ssc install fastgini

cd "$mypath"

use "CHNS-dta-files---final\CHNStrimmed.dta", clear

**********************************************
* CONSTRUCT ADULT-EQUIVALENT MEASURES
**********************************************
* Compute equivalence scales
	gen equiv_KP       =  (numi_geq_15 +  .7*numi_lt_15)^(.7) /* These are the NAS scales used by Krueger and Perri ReStud who cite . If you read that reference you will find they refer to page 59 in "Measuring Poverty, A New Approach" published by the National Academy of Sciencies (NAS) scales. "	It is Also used by Heathcote, Storesletten, and Violante JPE (Consumption Insurance and Labor Supply) */	
	gen numi_15_60 = numi_geq_15-numi_gt_60
	gen equiv_ad   = numi_geq_15
	gen equiv_ad2  = numi_15_60

* Compute adult-equivalent income
	gen consumption1_KP = consumption1 /equiv_KP
	
	gen income0_ad2 = income0 /equiv_ad2
	gen income1_ad2 = income1 /equiv_ad2
	
keep	income0 			income1     		income0_ad2 		income1_ad2 		consumption1 		consumption1_KP 	///
		case_id				wave				interview_year		reside
		

foreach var in 	income0 			income1     		income0_ad2 		income1_ad2 		consumption1     	consumption1_KP  	{
		gen `var'_Urban = `var' if reside==0
		gen `var'_Rural = `var' if reside==1
}
		
sort wave

* GINI INDEX
		
foreach var in   consumption1 consumption1_Rural consumption1_Urban consumption1_KP consumption1_KP_Rural consumption1_KP_Urban   ///
                 income0      income0_Rural      income0_Urban      income0_ad2     income0_ad2_Rural     income0_ad2_Urban       ///
                 income1      income1_Rural      income1_Urban      income1_ad2     income1_ad2_Rural     income1_ad2_Urban       {

				gen gini`var' = .     
					egen   subgroup = group(wave)
					levels subgroup, local(levels) 
					foreach i of local levels { 
					  fastgini     `var'           if subgroup == `i'
					  replace  gini`var' = r(gini) if subgroup == `i'
					  display `wave'

					  } 

				* Normalize variance to 0 at wave 25
					gen      gini`var'n =    gini`var' if wave==1		
					egen    Mgini`var'n =max(gini`var'n)	
					replace  gini`var'n =    gini`var'-Mgini`var'n
					drop    Mgini`var'n
				  
			  drop subgroup
}
rename interview_year year

* Column 1
twoway (line giniincome1          year, lcolor(green))   ///
       (line giniconsumption1     year, lcolor(blue))   ///	   	   	 	    
	   , ylabel(.25(.1).55,labsize(vsmall)) xlabel(,labsize(small) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(small)) title("Full Sample", size(medsmall)) legend(nobox symxsize(3) ring(0) size(small) pos(12) row(1) region(fcolor(none)) order(1 "Dis. I" 2 "C"))
graph save   "CHNS-Figures/FigureC2_c1r1.gph", replace  

twoway (line giniincome1_Rural          year, lcolor(green))   ///
       (line giniconsumption1_Rural     year, lcolor(blue))   ///	 	    
	   , ylabel(.25(.1).55,labsize(vsmall)) xlabel(,labsize(small) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(small)) title("Rural Sample", size(medsmall)) legend(off) 
graph save   "CHNS-Figures/FigureC2_c1r2.gph", replace  

twoway (line giniincome1_Urban          year, lcolor(green))   ///
       (line giniconsumption1_Urban     year, lcolor(blue))   ///		 	    
	   , ylabel(.25(.1).55,labsize(vsmall)) xlabel(,labsize(small) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(small)) title("Urban Sample", size(medsmall)) legend(off) 
graph save   "CHNS-Figures/FigureC2_c1r3.gph", replace  
	
graph combine "CHNS-Figures/FigureC2_c1r1.gph" "CHNS-Figures/FigureC2_c1r2.gph" "CHNS-Figures/FigureC2_c1r3.gph", cols(1) scheme(s1color) title("C and Dis. I", size(small))
graph save    "CHNS-Figures/FigureC2_c1.gph", replace
		
* Column 2
twoway (line giniincome1_ad2          year, lcolor(green))   ///
       (line giniconsumption1_KP      year, lcolor(blue))   ///	 
	   , ylabel(.25(.1).55,labsize(vsmall)) xlabel(,labsize(small) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(small)) title("Full Sample", size(medsmall)) legend(nobox symxsize(3) ring(0) size(small) pos(12) row(1) region(fcolor(none)) order(1 "Ad. Eq. Dis. I" 2 "Ad. Eq. C"))
graph save   "CHNS-Figures/FigureC2_c2r1.gph", replace  

twoway (line giniincome1_ad2_Rural         year, lcolor(green))   ///
       (line giniconsumption1_KP_Rural     year, lcolor(blue))   ///	 	    
	   , ylabel(.25(.1).55,labsize(vsmall)) xlabel(,labsize(small) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(small)) title("Rural Sample", size(medsmall)) legend(off) 
graph save   "CHNS-Figures/FigureC2_c2r2.gph", replace  

twoway (line giniincome1_ad2_Urban         year, lcolor(green))   ///
       (line giniconsumption1_KP_Urban     year, lcolor(blue))   ///	 	    
	   , ylabel(.25(.1).55,labsize(vsmall)) xlabel(,labsize(small) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(small)) title("Urban Sample", size(medsmall)) legend(off) 
graph save   "CHNS-Figures/FigureC2_c2r3.gph", replace  
	
graph combine "CHNS-Figures/FigureC2_c2r1.gph" "CHNS-Figures/FigureC2_c2r2.gph" "CHNS-Figures/FigureC2_c2r3.gph", cols(1) scheme(s1color) title("Adult-Equiv C and Dis. I", size(small))
graph save    "CHNS-Figures/FigureC2_c2.gph", replace
						
* Column 3	
twoway (line giniincome1_ad2    year, lcolor(green))   ///
       (line giniincome0_ad2    year, lcolor(red))   /// 	    
	   , ylabel(.25(.1).55,labsize(vsmall)) xlabel(,labsize(small) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(small)) title("Full Sample", size(medsmall)) legend(nobox symxsize(3) ring(0) size(small) pos(12) row(1) region(fcolor(none)) order(1 "Ad. Eq. Dis. I" 2 "Ad. Eq. Earnings"))
graph save   "CHNS-Figures/FigureC2_c3r1.gph", replace  

twoway (line giniincome1_ad2_Rural     year, lcolor(green))   ///
       (line giniincome0_ad2_Rural     year, lcolor(red))   ///	 	    
	   , ylabel(.25(.1).55,labsize(vsmall)) xlabel(,labsize(small) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(small)) title("Rural Sample", size(medsmall)) legend(off) 
graph save   "CHNS-Figures/FigureC2_c3r2.gph", replace  

twoway (line giniincome1_ad2_Urban     year, lcolor(green))   ///
       (line giniincome0_ad2_Urban     year, lcolor(red))   ///	 	    
	   , ylabel(.25(.1).55,labsize(vsmall)) xlabel(,labsize(small) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(small)) title("Urban Sample", size(medsmall)) legend(off) 
graph save   "CHNS-Figures/FigureC2_c3r3.gph", replace  
	
graph combine "CHNS-Figures/FigureC2_c3r1.gph" "CHNS-Figures/FigureC2_c3r2.gph" "CHNS-Figures/FigureC2_c3r3.gph", cols(1) scheme(s1color) title("Adult-Equiv Earnings and Dis. I", size(small))
graph save    "CHNS-Figures/FigureC2_c3.gph", replace
					
graph combine "CHNS-Figures/FigureC2_c1.gph" "CHNS-Figures/FigureC2_c2.gph" "CHNS-Figures/FigureC2_c3.gph" , cols(3) scheme(s1color) note("Source: CHNS 1989-2009. In 2009 USD." , size(tiny))
graph export    "CHNS-Figures/FigureC2.png", width(1400) height(1000) replace
 
 erase "CHNS-Figures/FigureC2_c1.gph" 
 erase "CHNS-Figures/FigureC2_c2.gph"
 erase "CHNS-Figures/FigureC2_c3.gph"
 erase "CHNS-Figures/FigureC2_c1r1.gph"
 erase "CHNS-Figures/FigureC2_c1r2.gph"
 erase "CHNS-Figures/FigureC2_c1r3.gph"
 erase "CHNS-Figures/FigureC2_c2r1.gph"
 erase "CHNS-Figures/FigureC2_c2r2.gph"
 erase "CHNS-Figures/FigureC2_c2r3.gph"
 erase "CHNS-Figures/FigureC2_c3r1.gph"
 erase "CHNS-Figures/FigureC2_c3r2.gph"
 erase "CHNS-Figures/FigureC2_c3r3.gph"
