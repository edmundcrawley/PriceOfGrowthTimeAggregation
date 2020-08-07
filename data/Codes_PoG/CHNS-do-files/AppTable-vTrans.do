***************************************************************************************************************
* THIS FILE PRODUCES VARIANCE OF LOG INCOME, PUBLIC AND PRIVATE TRANSFERS, CHNS 1989-2009.
* CHNS 1989 - 2009
* STATA/SE 14.0
* CREATED BY YU ZHENG
***************************************************************************************************************
clear
set mem 500m
set more off
cap log close

cd "$mypath"

use "CHNS-dta-files---final\CHNStrimmed.dta", clear


foreach var in 	income0 	transfR_pub 	transfR_pri   	{
				gen `var'_Urban = `var' if reside==0
				gen `var'_Rural = `var' if reside==1
}


keep wave interview_year case_id transfR_pub transfR_pri transfR_pub_Rural transfR_pri_Rural transfR_pub_Urban transfR_pri_Urban income0 income0_Rural income0_Urban

* COMPUTE THE VARIANCE OF LOGS
foreach var in 	income0					income0_Rural 			income0_Urban     		///
				transfR_pub				transfR_pub_Rural		transfR_pub_Urban		///
				transfR_pri				transfR_pri_Rural		transfR_pri_Urban		{	
				gen ln`var'=ln(`var')
				bys wave: egen vln`var'=sd(ln`var')
				replace vln`var'=vln`var'*vln`var'
}

* COMPUTE COVARIANCE OF PUBLIC/PRIVATE TRANSFERS WITH INCOME
gen cov_tpub_tpri = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl lntransfR_pub lntransfR_pri if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_tpub_tpri=A[2,1] if subgroup == `i'
} 
drop subgroup

gen cov_tpub_tpri_Rural = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl lntransfR_pub_Rural lntransfR_pri_Rural if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_tpub_tpri_Rural=A[2,1] if subgroup == `i'
} 
drop subgroup

gen cov_tpub_tpri_Urban = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl lntransfR_pub_Urban lntransfR_pri_Urban if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_tpub_tpri_Urban=A[2,1] if subgroup == `i'
} 
drop subgroup

* COMPUTE COVARIANCE OF INCOME0 AND PUBLIC/PRIVATE TRANSFERS
gen cov_y_tpub = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl lnincome0 lntransfR_pub if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_y_tpub=A[2,1] if subgroup == `i'
} 
drop subgroup

gen cov_y_tpub_Rural = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl lnincome0_Rural lntransfR_pub_Rural if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_y_tpub_Rural=A[2,1] if subgroup == `i'
} 
drop subgroup

gen cov_y_tpub_Urban = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl lnincome0_Urban lntransfR_pub_Urban if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_y_tpub_Urban=A[2,1] if subgroup == `i'
} 
drop subgroup

gen cov_y_tpri = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl lnincome0 lntransfR_pri if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_y_tpri=A[2,1] if subgroup == `i'
} 
drop subgroup

gen cov_y_tpri_Rural = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl lnincome0_Rural lntransfR_pri_Rural if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_y_tpri_Rural=A[2,1] if subgroup == `i'
} 
drop subgroup

gen cov_y_tpri_Urban = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl lnincome0_Urban lntransfR_pri_Urban if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_y_tpri_Urban=A[2,1] if subgroup == `i'
} 
drop subgroup

rename interview_year year
* Column 1
twoway (line vlntransfR_pub   year, lcolor(purple)) ///		 	    
	   (line vlntransfR_pri   year, lcolor(cranberry)) ///	 
	   (line cov_tpub_tpri    year, lcolor(black))  ///	 
	   , ytitle("") ylabel(0(1)5,labsize(vsmall)) xlabel(,labsize(vsmall) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(vsmall)) title("Full Sample", size(small)) legend(nobox symxsize(3) ring(0) size(vsmall) pos(12) row(1) region(fcolor(none)) order(1 "Var(Transf Pub)" 2 "Var(Transf Pri)" 3 "Cov(Pub,Pri)" ))
	graph save   "CHNS-Figures/FigureC1_c1r1.gph", replace  

twoway (line vlntransfR_pub_Rural year, lcolor(purple))  ///	 	    
	   (line vlntransfR_pri_Rural year, lcolor(cranberry)) ///	 
	   (line cov_tpub_tpri_Rural  year, lcolor(black))  ///	
	   , ytitle("") ylabel(0(1)5,labsize(vsmall)) xlabel(,labsize(vsmall) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(vsmall)) title("Rural Sample", size(small)) legend(off) /*legend(nobox symxsize(3) ring(0) size(small) pos(12) row(1) region(fcolor(none)) order(1 "I" 2 "I/Adult"))*/
	graph save   "CHNS-Figures/FigureC1_c1r2.gph", replace  
  	
twoway (line vlntransfR_pub_Urban year, lcolor(purple)) ///
	   (line vlntransfR_pri_Urban year, lcolor(cranberry)) ///
	   (line cov_tpub_tpri_Urban  year, lcolor(black))  ///		   
	   , ytitle("") ylabel(0(1)5,labsize(vsmall)) xlabel(,labsize(vsmall) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(vsmall)) title("Urban Sample", size(small)) legend(off) /*legend(nobox symxsize(3) ring(0) size(small) pos(12) row(1) region(fcolor(none)) order(1 "I" 2 "I/Adult"))*/
	graph save   "CHNS-Figures/FigureC1_c1r3.gph", replace  

 graph combine "CHNS-Figures/FigureC1_c1r1.gph" "CHNS-Figures/FigureC1_c1r2.gph" "CHNS-Figures/FigureC1_c1r3.gph", cols(1) scheme(s1color) title("Public and Private Transfers", size(vsmall))
    graph save "CHNS-Figures/FigureC1_c1.gph", replace
		  
* Column 2	
twoway (line vlnincome0   year, lcolor(black))  ///
	   (line cov_y_tpub   year, lcolor(purple))  ///	    	   	   		   	  	  
	   , ylabel(,labsize(vsmall)) ylabel(-.2(.2)1.2, labsize(vsmall)) xlabel(,labsize(vsmall) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(vsmall))   title("Full Sample", size(small)) legend(nobox symxsize(3) ring(0) size(vsmall) pos(12) row(1) region(fcolor(none)) order(1 "Var(Earnings)" 2 "Cov(Earnings,Pub)"))
	graph save   "CHNS-Figures/FigureC1_c2r1.gph", replace  
  
twoway (line vlnincome0_Rural  	  year, lcolor(black))   ///
	   (line cov_y_tpub_Rural     year, lcolor(purple)) /// 	    	   	   		   	  	  	   
	   , ylabel(,labsize(vsmall)) ylabel(-.2(.2)1.2, labsize(vsmall)) xlabel(,labsize(vsmall) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(vsmall))  title("Rural Sample", size(small)) legend(off) /*legend(nobox symxsize(3) ring(0) size(small) pos(12) row(1) region(fcolor(none)) order(1 "1+Pub.Tr./I" 2 "1+Priv.Tr./I"))*/
	graph save   "CHNS-Figures/FigureC1_c2r2.gph", replace  
      
twoway (line vlnincome0_Urban  	  year, lcolor(black))   ///
	   (line cov_y_tpub_Urban     year, lcolor(purple)) ///     	    	   	   		   	  	  
	   , ylabel(,labsize(vsmall)) ylabel(-.2(.2)1.2, labsize(vsmall)) xlabel(,labsize(vsmall) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(vsmall)) title("Urban Sample", size(small)) legend(off) /*legend(nobox symxsize(3) ring(0) size(small) pos(12) row(1) region(fcolor(none)) order(1 "1+Pub.Tr./I" 2 "1+Priv.Tr./I"))*/
	graph save   "CHNS-Figures/FigureC1_c2r3.gph", replace    
 
 graph combine "CHNS-Figures/FigureC1_c2r1.gph" "CHNS-Figures/FigureC1_c2r2.gph" "CHNS-Figures/FigureC1_c2r3.gph", cols(1) scheme(s1color) title("Earnings and Public Transfers", size(vsmall))
    graph save "CHNS-Figures/FigureC1_c2.gph", replace
		      
* Column 3  	  			 
twoway (line vlnincome0   year, lcolor(black))  /// 
	   (line cov_y_tpri   year, lcolor(cranberry))  ///	 	   
	   , ytitle(, size(small) axis(1)) ylabel(0(.25)1.25, labsize(vsmall)) xlabel(,labsize(vsmall) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(vsmall))  title("Full Sample", size(small)) legend(nobox symxsize(3) ring(0) size(vsmall) pos(12) row(1) region(fcolor(none)) order(1 "Var(Earnings)" 2 "Cov(Earnings,Pri)"))
	graph save   "CHNS-Figures/FigureC1_c3r1.gph", replace  
  
twoway (line vlnincome0_Rural   year, lcolor(black))   ///		  
	   (line cov_y_tpri_Rural   year, lcolor(cranberry)) ///	 
	   , ytitle(, size(small) axis(1)) ylabel(0(.25)1.25, labsize(vsmall)) xlabel(,labsize(vsmall) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(vsmall))  title("Rural Sample", size(small)) legend(off) /*legend(nobox symxsize(3) ring(0) size(small) pos(12) row(1) region(fcolor(none)) order(1 "I" 2 "Dis.I" 3 "1+Tr./I"))*/
	graph save   "CHNS-Figures/FigureC1_c3r2.gph", replace  
    
twoway (line vlnincome0_Urban    year, lcolor(black))   ///	
	    (line cov_y_tpri_Urban   year, lcolor(cranberry)) ///	    
	   , ytitle(, size(small) axis(1)) ylabel(0(.25)1.25, labsize(vsmall)) xlabel(,labsize(vsmall) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(vsmall))  title("Urban Sample", size(small)) legend(off) /*legend(nobox symxsize(3) ring(0) size(small) pos(12) row(1) region(fcolor(none)) order(1 "I" 2 "Dis.I" 3 "1+Tr./I"))*/
	graph save   "CHNS-Figures/FigureC1_c3r3.gph", replace  
      
 graph combine "CHNS-Figures/FigureC1_c3r1.gph" "CHNS-Figures/FigureC1_c3r2.gph" "CHNS-Figures/FigureC1_c3r3.gph", cols(1) scheme(s1color) title("Earnings and Private Transfers", size(vsmall))
 graph save    "CHNS-Figures/FigureC1_c3.gph", replace
			 	
 graph combine "CHNS-Figures/FigureC1_c1.gph" "CHNS-Figures/FigureC1_c2.gph" "CHNS-Figures/FigureC1_c3.gph", cols(3) scheme(s1color) note("Source: CHNS 1989-2009. In 2009 USD." , size(tiny))	 /*title("Lifecycle Inequality of Consumption, Income and Wealth, Malawi", size(medium)) */
 graph export  "CHNS-Figures/FigureC1.png", width(1400) height(1000) replace
 
 erase "CHNS-Figures/FigureC1_c1.gph" 
 erase "CHNS-Figures/FigureC1_c2.gph"
 erase "CHNS-Figures/FigureC1_c3.gph"
 erase "CHNS-Figures/FigureC1_c1r1.gph"
 erase "CHNS-Figures/FigureC1_c1r2.gph"
 erase "CHNS-Figures/FigureC1_c1r3.gph"
 erase "CHNS-Figures/FigureC1_c2r1.gph"
 erase "CHNS-Figures/FigureC1_c2r2.gph"
 erase "CHNS-Figures/FigureC1_c2r3.gph"
 erase "CHNS-Figures/FigureC1_c3r1.gph"
 erase "CHNS-Figures/FigureC1_c3r2.gph"
 erase "CHNS-Figures/FigureC1_c3r3.gph"	
