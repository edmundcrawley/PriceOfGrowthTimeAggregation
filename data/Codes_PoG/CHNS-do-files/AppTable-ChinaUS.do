***************************************************************************************************************
* THIS FILE PRODUCES INEQUALITY MEASURES FOR PSID AND CHNS.
* CHNS 1989 - 2009
* STATA/SE 14.0
* CREATED BY YU ZHENG
***************************************************************************************************************
clear
set mem 500m
set more off
cap log close

cd "$mypath"

*****************************************
***     INEQUALITY MEASURES, PSID     ***
*****************************************
* THE PSID DATA IS TAKEN FROM THE SAMPLE IN BLUNDELL, PISTAFERRI AND PRESTON (2008)

*TABLE 6 *
/*BASELINE:	010010*/	/*Whole sample*/
/*COL. 2:	010011*/ 	/*College*/
/*COL. 3:	010012*/ 	/*No college*/
/*COL. 4:	010013*/ 	/*Born 1940s*/
/*COL. 5:	010014*/	/*Born 1930s*/
*TABLE 7 *
/*COL. 2:	200010*/ 	/*y=earnings*/
/*COL. 3:	400010*/ 	/*y=male earnings*/
*TABLE 8 *
/*COL. 2:	810010*/  	/*y excludes help*/
/*COL. 6:	010110*/ 	/*Add SEO*/

version 6.0
		scalar incdef  =2		/* 0=earnings+transfers, 1=earnings+transfer+financial income		*/
						/* 2=earnings, 3=earnings+financial income, 4=male earnings			*/
						/* 5=male+female earnings, 6=male earnings net of own taxes			*/
						/* 7=avhy, 8=income net of intrerg. transfers					*/
		scalar aftertax=0		/* 0=income before tax, 1=income after tax 					*/
		scalar totexp  =0		/* 0=non dur cons, 1=tot exp, 2=food, 3=non dur cons+ services from dur */
						/* 4=tot exp+services from dur							*/
		scalar SEO     =0		/* 0=representative sample, 1=representative sample+SEO, 2=Just SEO 	*/
		scalar agesel  =1		/* 0=20-65, 1=30-65, 2=25-65								*/
		scalar group   =0		/* 0=whole sample, 1=no college, 2= college, 3=born 1940s, 4=born 1930s */

use "BPP-dta-files\data3.dta",clear

******Does not use osbervations with topcoded income or financial income or federal taxes paid******
replace asset=. if trunca==1
replace y    =. if truncy==1
replace ftax =. if ftax==99999 & year>=1982 & year<=1985

gen ratio_ya=(y-asset)/y
replace ratio_ya=0 if ratio_ya<0			/*Ratio of non-financial income to income*/
								/*We have total federal taxes, ftax*/
								/*We assume that taxes paid on non-financial income*/
								/*are equal to (ratio_ya*ftax)*/

if SEO==0		{keep if seo==0}      
else if SEO==1	{keep if seo==0|seo==1}
else			{keep if seo==1}

if agesel==0	{drop if age<20|age>65}      
else if agesel==1	{drop if age<30|age>65}
else if agesel==2	{drop if age<25|age>65}

ren ncomp fsize

*Add a CPI price index and transform variables in real term
*This series is drawn from http://woodrow.mpls.frb.fed.us/economy/calc/hist1913.html
*CPI Base year is chained; 1982-1984 = 100
*2000 U.S. Department Of Labor, Bureau of Labor Statistics, Washington, D.C. 20212
*Consumer Price Index All Urban Consumers - (CPI-U) U.S. city average All items 1982-84=100

gen     price=1.403 if year==1992
replace price=1.362 if year==1991
replace price=1.307 if year==1990
replace price=1.240 if year==1989
replace price=1.183 if year==1988
replace price=1.136 if year==1987
replace price=1.096 if year==1986
replace price=1.076 if year==1985
replace price=1.039 if year==1984
replace price=0.996 if year==1983
replace price=0.965 if year==1982
replace price=0.909 if year==1981
replace price=0.824 if year==1980
replace price=0.726 if year==1979
replace price=0.652 if year==1980
replace price=0.606 if year==1977
replace price=0.569 if year==1976
replace price=0.538 if year==1975
replace price=0.493 if year==1974
replace price=0.444 if year==1973
replace price=0.418 if year==1972
replace price=0.405 if year==1971
replace price=0.388 if year==1970
replace price=0.367 if year==1969
replace price=0.348 if year==1968
replace price=0.334 if year==1967
replace price=1.445 if year==1993
replace price=1.482 if year==1994
replace price=1.524 if year==1995
replace price=1.569 if year==1996

gen ratio=ly/y						/*Ratio of male earnings to total income*/
replace ratio=1 if ratio>1 & ratio!=.

if       incdef==0	{replace     y=(y-asset)/price}
else	if incdef==1	{replace     y=(y)/price}
else	if incdef==2	{replace     y=(y-trhw-troth-asset)/price}
else	if incdef==3	{replace     y=(y-trhw-troth)/price}
else	if incdef==4	{replace     y=ly/price}
else	if incdef==5	{replace     y=(ly+wly)/price}
else	if incdef==6	{replace     y=(ly-ratio*ftax)/price}
else	if incdef==7	{replace     y=log(avhy)/price}
else	if incdef==8	{replace     y=(y-asset-help)/price}

replace    ly=ly   /price
replace   wly=wly  /price
replace  ftax=ftax /price

replace lc    =lc-ln(price)
replace lC    =lC-ln(price)
replace lcs   =lcs-ln(price)
replace lCs   =lCs-ln(price)


if totexp==0    		{drop lC lcs lCs}      
else if totexp==1       {drop lc lcs lCs
                 		 ren lC lc}
else if totexp==2		{drop lc lC lcs lCs
				 gen totf=food+fout+fstmp
				 gen lc=ln(totf/pf)}
else if totexp==3		{drop lc lC lCs
				 ren lcs lc}
else if totexp==4		{drop lc lC lcs
				 ren lCs lc}

if      aftertax==0  			{gen logy=ln(y)}      
else if aftertax==1 & incdef==0  	{gen logy=ln((y-ratio_ya*ftax))}      
else if aftertax==1 & incdef==1  	{gen logy=ln((y-ftax))}      
else if aftertax==1 & incdef==6  	{gen logy=ln(y)}      
else if aftertax==1 & incdef==8  	{gen logy=ln((y-ratio_ya*ftax))}      

**In the experiments in Table 7, col.2/3 the "artificial measures of income" we consider are "before taxes" **

tab year,gen(yrd)

gen black =race==2
gen other =race>=3
gen selfe =self==3
gen empl  =empst==1
gen unempl=empst==2
gen retir =empst==3
tab state,gen(stated)
gen veteran   =vet==1
gen disability=disab==1
gen kidsout   =outkid==1
gen bigcity=smsa==1|smsa==2
tab yb,gen(ybd)
tab fsize,gen(fd)
tab kids,gen(chd)
replace smsa=6 if smsa>6
tab smsa,gen(cityd)

gen extra=(tyoth)>0
gen ybw=year-agew
tab ybw,gen(ybwd)
tab age,gen(aged)

#delimit;
xi	i.educ*i.year i.white*i.year i.black*i.year i.other*i.year i.kidsout*i.year i.region*i.year i.extra*i.year
	i.year*i.bigcity i.year*i.kids i.fsize*i.year i.empl*i.year i.unempl*i.year i.retir*i.year;

/*Controls present:	year dummies, year of birth dummies, education dummies, race dummies,# of kids dummies, #of family member dummies,
				empl. status dummies, dummy for income recipient other than h/w, region dummies, dummy for big city, dummy for kids not in FU*/
/*Interactions present: 1)educ*year 2)race dummies*year 3)empl. status dummies*year 4)region*year 5)big city*year*/	
				 	
qui reg logy	yrd* ybd* edd*  white black other fd* chd* empl  unempl retir extra regd* bigcity kidsout 
			          Iey_* Iwy_* Iby_* Ioy_*          Ieyb* Iuy_*  Irya*       Iry_* Iyb_*;
predict uy if e(sample),res;
qui reg lc	      yrd* ybd* edd*  white black other fd* chd* empl  unempl retir extra regd* bigcity kidsout 
			          Iey_* Iwy_* Iby_* Ioy_*          Ieyb* Iuy_*  Irya*       Iry_* Iyb_*;
predict uc if e(sample),res;
#delimit cr

* PREPARE FOR THE GRAPH
gen lev_uy=uy
gen lev_uc=uc

gen     lev_y =exp(logy)
gen     lev_c =exp(lc)
replace lev_uy =exp(uy)
replace lev_uc =exp(uc)


gen wave=year

foreach var in 	lev_c lev_y lev_uc lev_uy{

bys year: egen   av`var'=mean(`var')
bys year: egen    m`var'=median(`var')				
           gen   ln`var'=ln(`var')
bys year: egen avln`var'=mean(ln`var')
bys year: egen  mln`var'=median(ln`var')

bys year: egen vln`var'=sd(ln`var')
       replace vln`var'=vln`var'*vln`var' 
	   
gen    mav`var'1980  =      av`var' if year==1980		
egen   mav`var'1980x = max(mav`var'1980)	
gen   umav`var'      =      av`var'/mav`var'1980x
drop   mav`var'1980x mav`var'1980

gen    mm`var'1980  =       m`var' if year==1980		
egen   mm`var'1980x =  max(mm`var'1980)	
gen   umm`var'      =       m`var'/mm`var'1980x
drop   mm`var'1980x mm`var'1980

gen    mvln`var'1980  =      vln`var' if year==1980		
egen   mvln`var'1980x = max(mvln`var'1980)	
gen   umvln`var'      =      vln`var'-mvln`var'1980x
drop   mvln`var'1980x mvln`var'1980

}

table year, c(n uc n uy n lnlev_uc n lnlev_uy)


drop wave
gen wave=year if year>=1979


replace uc=uy if (year==1987 | year==1988)
gen cov_Rc1_Ry1ad2 = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl uc uy if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_Rc1_Ry1ad2 =A[2,1] if subgroup == `i'
} 
drop subgroup


bys year: gen x=_n

keep if x==1

replace cov_Rc1_Ry1ad2=. if (year==1987 | year==1988)
sort year

saveold "BPP-dta-files\data3_updated.dta", replace

version 14.0
use "BPP-dta-files\data3_updated.dta", clear

* Column 2
twoway (line    vlnlev_c   year, lcolor(blue)) 		///	   
       (line    vlnlev_y   year, lcolor(red))  		///	   
       (line    vlnlev_uc  year, lcolor(eltblue) lpattern(solid)) 	///	   
       (scatter vlnlev_uc  year, mcolor(eltblue) msymbol(O)) 		///	   	   
	   (line    vlnlev_uy  year, lcolor(pink)    lpattern(dash) ) 	///	   
	   (scatter vlnlev_uy  year, mcolor(pink)    msymbol(T) ) 		///	 
	   , ylabel(0(.5)1.5,labsize(vsmall)) xlabel(,labsize(small) angle(vertical)) scheme(sj) xlabel(1978(1)1992) xtitle("year", size(small)) legend(nobox symxsize(3) ring(0) size(small) pos(12) row(1) region(fcolor(none)) order(1 "var(C/KP)" 2 "var(Disp.I/Ad)"))
	graph save   "CHNS-Figures/FigureC3_c2r1.gph", replace

twoway (line    umvlnlev_uc  year, lcolor(eltblue) lpattern(solid)) ///	   
       (scatter umvlnlev_uc  year, mcolor(eltblue) msymbol(O)) 		///	   	   
	   (line    umvlnlev_uy  year, lcolor(pink)    lpattern(dash) ) ///	   
	   (scatter umvlnlev_uy  year, mcolor(pink)    msymbol(T) ) 	///	 	
	   , ylabel(0(.2).8,labsize(vsmall)) xlabel(,labsize(small) angle(vertical)) scheme(sj) xlabel(1978(1)1992) xtitle("year", size(small)) legend(nobox symxsize(3) ring(0) size(small) pos(12) row(1) region(fcolor(none)) order(2 "var(Resid C/KP)" 4 "var(Resid Dis.I/Ad)"))
	graph save   "CHNS-Figures/FigureC3_c2r2.gph", replace
	
twoway (line    cov_Rc1_Ry1ad2 year if (year!=1987 | year!=1988), lcolor(black))           	///	 	    
       (scatter cov_Rc1_Ry1ad2 year if (year!=1987 | year!=1988), mcolor(black) msymbol(D)) ///	 	    
	   , ytitle("") ylabel(.05(.05).3,labsize(small)) xlabel(,labsize(small) angle(vertical)) scheme(sj) xlabel(1978(1)1992) xtitle("year", size(small)) legend(nobox symxsize(3) ring(0) size(small) pos(11) row(1) region(fcolor(none)) order(1 "cov(Resid C/KP, Resid Dis.I/A)"))
	graph save   "CHNS-Figures/FigureC3_c2r3.gph", replace
						
graph combine "CHNS-Figures/FigureC3_c2r1.gph" "CHNS-Figures/FigureC3_c2r2.gph" "CHNS-Figures/FigureC3_c2r3.gph", cols(1) scheme(s1color) title("PSID, U.S. 1979-1992", size(medsmall))
	graph save   "CHNS-Figures/FigureC3_c2.gph", replace			
			
erase "CHNS-Figures/FigureC3_c2r1.gph"
erase "CHNS-Figures/FigureC3_c2r2.gph"
erase "CHNS-Figures/FigureC3_c2r3.gph"

*****************************************
***     INEQUALITY MEASURES, CHNS     ***
*****************************************
use "CHNS-dta-files---final\CHNStrimmed.dta", clear

* CONSTRUCT ADULT-EQUIVALENT MEASURES
	* Compute equivalence scales
	gen equiv_KP       =  (numi_geq_15 +  .7*numi_lt_15)^(.7) 	
	gen numi_15_60 = numi_geq_15-numi_gt_60
	gen equiv_ad   = numi_geq_15
	gen equiv_ad2  = numi_15_60

	* Compute adult-equivalent income
	gen consumption1_KP = consumption1 /equiv_KP
	gen income1_ad2 = income1 /equiv_ad2
		
foreach var in 	consumption1_KP       income1_ad2       {
				
		* VARIANCE OF LOGS BY YEAR
					gen    ln`var' =ln(`var')
		bys wave:   egen sdln`var'r=sd(ln`var')
					gen   vln`var'r=sdln`var'r*sdln`var'r
					drop sdln`var'r
					
		* VARIANCE OF LOG RESIDUALS BY YEAR
					gen   Rln`var'r=.
					gen  vRln`var'r=.			   
			   
					local  xwave =  1
					while `xwave' < 9{
						regress   ln`var' i.sex i.age i.educ i.province i.minority	      if wave==`xwave'
						predict  Rln`var'r`xwave' if wave==`xwave', resid					   						
						replace  Rln`var'r=  Rln`var'r`xwave'                     		  if wave==`xwave'
						egen   sdRln`var'r`xwave'=sd(Rln`var'r`xwave') 		   			  if wave==`xwave'										
						 gen    vRln`var'r`xwave'= sdRln`var'r`xwave'*sdRln`var'r`xwave'  if wave==`xwave'															
						replace vRln`var'r= vRln`var'r`xwave'                             if wave==`xwave'	
						drop     Rln`var'r`xwave' sdRln`var'r`xwave' vRln`var'r`xwave'
						display `xwave'
						local xwave = `xwave'+ 1
					}
					
		* NORMALIZE THE VARIANCE TO 0 AT 1989
			gen      vln`var'atr1 =    vln`var'r if wave==1		
			egen    Mvln`var'atr1 =max(vln`var'atr1)	
			replace  vln`var'atr1 =    vln`var'r-Mvln`var'atr1
			drop    Mvln`var'atr1
		
			gen      vRln`var'atr1 =    vRln`var'r if wave==1		
			egen    MvRln`var'atr1 =max(vRln`var'atr1)	
			replace  vRln`var'atr1 =    vRln`var'r-MvRln`var'atr1
			drop    MvRln`var'atr1
}		

* COMPUTE THE COVARIANCES
gen cov_Rc1_Ry1ad2 = .     
	egen   subgroup = group(wave)
	levels subgroup, local(levels) 
    foreach i of local levels { 
	  correl Rlnconsumption1_KPr Rlnincome1_ad2r if subgroup == `i', cov
	  qui mat A=r(C)
      mat l A
	  replace cov_Rc1_Ry1ad2 =A[2,1] if subgroup == `i'
} 
drop subgroup

* Column 1	
twoway (line    vlnconsumption1_KPr    year, lcolor(blue)) ///	   
       (line    vlnincome1_ad2r        year, lcolor(red))  ///	   
       (line    vRlnconsumption1_KPr   year, lcolor(eltblue) lpattern(solid)) ///	   
       (scatter vRlnconsumption1_KPr   year, mcolor(eltblue) msymbol(O)) ///	   	   
	   (line    vRlnincome1_ad2r       year, lcolor(pink)    lpattern(dash) ) ///	   
	   (scatter vRlnincome1_ad2r       year, mcolor(pink)    msymbol(T) ) ///	 
	   , ylabel(0(0.5)1.5,labsize(vsmall)) xlabel(,labsize(small) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(small)) legend(nobox symxsize(3) ring(0) size(small) pos(6) row(1) region(fcolor(none)) order(1 "var(C/KP)" 2 "var(Disp.I/Ad)"))
	graph save   "CHNS-Figures/FigureC3_c1r1.gph", replace  

twoway (line    vRlnconsumption1_KPatr1   year, lcolor(eltblue) lpattern(solid)) ///	   
       (scatter vRlnconsumption1_KPatr1   year, mcolor(eltblue) msymbol(O)) ///	   	   
	   (line    vRlnincome1_ad2atr1       year, lcolor(pink)    lpattern(dash) ) ///	   
	   (scatter vRlnincome1_ad2atr1       year, mcolor(pink)    msymbol(T) ) ///	 	
	   , ylabel(0(0.2)0.8,labsize(vsmall)) xlabel(,labsize(small) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(small))  legend(nobox symxsize(3) ring(0) size(small) pos(12) row(1) region(fcolor(none)) order(2 "var(Resid C/KP)" 4 "var(Resid Dis.I/Ad)"))
	graph save   "CHNS-Figures/FigureC3_c1r2.gph", replace  

	
twoway (line    cov_Rc1_Ry1ad2 year, lcolor(black) )           ///	 	    
       (scatter cov_Rc1_Ry1ad2 year, mcolor(black) msymbol(D)) ///	 	    
	   , ytitle("") ylabel(0.05(0.05)0.3,labsize(small)) xlabel(,labsize(small) angle(vertical)) scheme(sj) xlabel(1989(1)2009) xtitle("year", size(small))  legend(nobox symxsize(3) ring(0) size(small) pos(11) row(1) region(fcolor(none)) order(1 "cov(Resid C/KP, Resid Dis.I/A)"))
	graph save   "CHNS-Figures/FigureC3_c1r3.gph", replace  

 graph combine "CHNS-Figures/FigureC3_c1r1.gph" "CHNS-Figures/FigureC3_c1r2.gph""CHNS-Figures/FigureC3_c1r3.gph", cols(1) scheme(s1color) title("CHNS, China 1989-2009", size(medsmall))
    graph save "CHNS-Figures/FigureC3_c1.gph", replace
						
			
   graph combine "CHNS-Figures/FigureC3_c1.gph" "CHNS-Figures/FigureC3_c2.gph", cols(2) scheme(s1color) note("Source: CHNS 1989-2009 and PSID 1978-1992." , size(tiny))		
   graph export "CHNS-Figures/FigureC3.png", width(1400) height(1000) replace

    erase "CHNS-Figures/FigureC3_c1.gph" 
	erase "CHNS-Figures/FigureC3_c2.gph"
	erase "CHNS-Figures/FigureC3_c1r1.gph"
	erase "CHNS-Figures/FigureC3_c1r2.gph"
	erase "CHNS-Figures/FigureC3_c1r3.gph"


