***************************************************************************************************************
* THIS FILE PRODUCES SUMMARY STATISTICS FROM CHNS BY INCOME PARTITION FOR 1991-2006 WAVES.
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

* COMPUTE THE ADULT EQUIVALENT MEASURES OF INCOME AND CONSUMPTION
* Compute equivalence scales
	qui gen equiv_KP       =  (numi_geq_15 +  .7*numi_lt_15)^(.7) /* These are the NAS scales used by Krueger and Perri ReStud who cite . If you read that reference you will find they refer to page 59 in "Measuring Poverty, A New Approach" published by the National Academy of Sciencies (NAS) scales. "																							It is Also used by Heathcote, Storesletten, and Violante JPE (Consumption Insurance and Labor Supply) */	
	qui gen numi_15_60 = numi_geq_15-numi_gt_60
	qui gen equiv_ad   = numi_geq_15
	qui gen equiv_ad2  = numi_15_60

* Compute adult-equivalent income
	qui gen consumption1_KP = consumption1 /equiv_KP
	qui gen income0_ad2 = income0 /equiv_ad2
	qui gen income1_ad2 = income1 /equiv_ad2

keep income0_ad2 income1_ad2 consumption1_KP urban interview_year case_id
duplicates drop
keep if income1_ad2~=.

rename consumption1_KP  c
rename income1_ad2		y1
rename income0_ad2		y0

bys interview_year urban:  egen s_c = total(c) 	  if y1~=.
bys interview_year urban:  egen s_y0= total(y0) 	  if y1~=.
bys interview_year urban:  egen s_y1= total(y1) 	  if y1~=.

qui gen sbybin1_c=.
qui gen sbybin2_c=.
qui gen sbybin3_c=.
qui gen sbybin1_y0=.
qui gen sbybin2_y0=.
qui gen sbybin3_y0=.
qui gen sbybin1_y1=.
qui gen sbybin2_y1=.
qui gen sbybin3_y1=.
foreach xwave in 1991 1993 1997 2000 2004 2006   {
	forvalues urb=0/1 {
	* GENERATE INCOME PARTITION
		qui xtile 	pincome`xwave'_`urb' = y1  if interview_year == `xwave' & urban == `urb', nq(100)
		qui gen		bin1_`xwave'_`urb' = 1 	if pincome`xwave'_`urb'<=1  & pincome`xwave'_`urb'~=.
		qui replace bin1_`xwave'_`urb' = 2 	if pincome`xwave'_`urb'>1   & pincome`xwave'_`urb'<=5
		qui replace bin1_`xwave'_`urb' = 3 	if pincome`xwave'_`urb'>5   & pincome`xwave'_`urb'<=10
		qui gen		bin2_`xwave'_`urb' = 1 	if pincome`xwave'_`urb'<=20 & pincome`xwave'_`urb'~=.
		qui replace bin2_`xwave'_`urb' = 2 	if pincome`xwave'_`urb'>20  & pincome`xwave'_`urb'<=40
		qui replace bin2_`xwave'_`urb' = 3 	if pincome`xwave'_`urb'>40  & pincome`xwave'_`urb'<=60
		qui replace bin2_`xwave'_`urb' = 4 	if pincome`xwave'_`urb'>60  & pincome`xwave'_`urb'<=80
		qui replace bin2_`xwave'_`urb' = 5 	if pincome`xwave'_`urb'>80  & pincome`xwave'_`urb'<=100
		qui gen		bin3_`xwave'_`urb' = 1 	if pincome`xwave'_`urb'>90  & pincome`xwave'_`urb'<=95
		qui replace bin3_`xwave'_`urb' = 2 	if pincome`xwave'_`urb'>95  & pincome`xwave'_`urb'<=99
		qui replace bin3_`xwave'_`urb' = 3 	if pincome`xwave'_`urb'>99  & pincome`xwave'_`urb'<=100
		
		foreach var in c y0 y1  {
			bys bin1_`xwave'_`urb':  egen sbybin1_`var'_aux = total(`var')  if bin1_`xwave'_`urb'~=.
			bys bin2_`xwave'_`urb':  egen sbybin2_`var'_aux = total(`var')  if bin2_`xwave'_`urb'~=.
			bys bin3_`xwave'_`urb':  egen sbybin3_`var'_aux = total(`var')  if bin3_`xwave'_`urb'~=.
			
			qui replace sbybin1_`var' = sbybin1_`var'_aux if interview_year == `xwave' & urban == `urb'
			qui replace sbybin2_`var' = sbybin2_`var'_aux if interview_year == `xwave' & urban == `urb'
			qui replace sbybin3_`var' = sbybin3_`var'_aux if interview_year == `xwave' & urban == `urb'
			drop *_aux
		}
	}
}	
drop  pincome* 
* GENERATE SHARES
foreach var in c y0 y1  {		
		* GENERATE SHARES
		qui gen shbybin1_`var' = sbybin1_`var'/s_`var'*100
		qui gen shbybin2_`var' = sbybin2_`var'/s_`var'*100
		qui gen shbybin3_`var' = sbybin3_`var'/s_`var'*100
	}
drop sbybin1_* sbybin2_* sbybin3_* s_*
	
* GENERATE ENTRY TO THE TABLE
foreach xwave in 1991 1993 1997 2000 2004 2006   {
	forvalues urb=0/1 {
		foreach var in c y1 y0	{
		* STATISTICS
			qui sum `var' if interview_year == `xwave' & urban == `urb'
			local m`var'_`urb'_`xwave' = string(r(mean),"%10.0fc")
	
			foreach bin in bin1_`xwave'_`urb' bin2_`xwave'_`urb' bin3_`xwave'_`urb'	{
				levelsof `bin', local(lbin)
				foreach l of local lbin		{
					* AVERAGE
					qui sum `var' if `bin'==`l' & interview_year == `xwave' & urban == `urb'
					local m`var'_`bin'_`l'=string(r(mean),"%10.0fc")
				}
			}
			* SHARE
			forvalues l=1/3	{
				sum shbybin1_`var' if interview_year == `xwave' & urban == `urb' & bin1_`xwave'_`urb' == `l'
				local shbybin1_`var'_`urb'_`xwave'_`l'=string(r(mean),"%10.1f")
			}
			forvalues l=1/5	{	
				sum shbybin2_`var' if interview_year == `xwave' & urban == `urb' & bin2_`xwave'_`urb' == `l'
				local shbybin2_`var'_`urb'_`xwave'_`l'=string(r(mean),"%10.1f")
			}
			forvalues l=1/3	{
				sum shbybin3_`var' if interview_year == `xwave' & urban == `urb' & bin3_`xwave'_`urb' == `l'
				local shbybin3_`var'_`urb'_`xwave'_`l'=string(r(mean),"%10.1f")
			}
		}
	}
}

* TABLE
	* RURAL 1991
	cap file close _all
	file open ofile using "Tables\table2_1991r.tex", write replace	
	file write ofile "\begin{tabular}{l c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"&\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"& 0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{13}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `mc_bin1_1991_0_1'  & `mc_bin1_1991_0_2'  & `mc_bin1_1991_0_3'  & `mc_bin2_1991_0_1'  & `mc_bin2_1991_0_2'  & `mc_bin2_1991_0_3'  & `mc_bin2_1991_0_4'  & `mc_bin2_1991_0_5'  & `mc_bin3_1991_0_1'  & `mc_bin3_1991_0_2'  & `mc_bin3_1991_0_3'  & `mc_0_1991' \\"  _n ///
	"Earnings 	  & `my0_bin1_1991_0_1' & `my0_bin1_1991_0_2' & `my0_bin1_1991_0_3' & `my0_bin2_1991_0_1' & `my0_bin2_1991_0_2' & `my0_bin2_1991_0_3' & `my0_bin2_1991_0_4' & `my0_bin2_1991_0_5' & `my0_bin3_1991_0_1' & `my0_bin3_1991_0_2' & `my0_bin3_1991_0_3' & `my0_0_1991' \\"  _n ///
	"Disp. Income & `my1_bin1_1991_0_1' & `my1_bin1_1991_0_2' & `my1_bin1_1991_0_3' & `my1_bin2_1991_0_1' & `my1_bin2_1991_0_2' & `my1_bin2_1991_0_3' & `my1_bin2_1991_0_4' & `my1_bin2_1991_0_5' & `my1_bin3_1991_0_1' & `my1_bin3_1991_0_2' & `my1_bin3_1991_0_3' & `my1_0_1991' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `shbybin1_c_0_1991_1'   & `shbybin1_c_0_1991_2'   & `shbybin1_c_0_1991_3'   & `shbybin2_c_0_1991_1'   & `shbybin2_c_0_1991_2'   & `shbybin2_c_0_1991_3'   & `shbybin2_c_0_1991_4'   & `shbybin2_c_0_1991_5'   & `shbybin3_c_0_1991_1'   & `shbybin3_c_0_1991_2'   & `shbybin3_c_0_1991_3'   & 100 \\"  _n ///
	"Earnings 	  & `shbybin1_y0_0_1991_1'  & `shbybin1_y0_0_1991_2'  & `shbybin1_y0_0_1991_3'  & `shbybin2_y0_0_1991_1'  & `shbybin2_y0_0_1991_2'  & `shbybin2_y0_0_1991_3'  & `shbybin2_y0_0_1991_4'  & `shbybin2_y0_0_1991_5'  & `shbybin3_y0_0_1991_1'  & `shbybin3_y0_0_1991_2'  & `shbybin3_y0_0_1991_3'  & 100 \\"  _n ///
	"Disp. Income & `shbybin1_y1_0_1991_1'  & `shbybin1_y1_0_1991_2'  & `shbybin1_y1_0_1991_3'  & `shbybin2_y1_0_1991_1'  & `shbybin2_y1_0_1991_2'  & `shbybin2_y1_0_1991_3'  & `shbybin2_y1_0_1991_4'  & `shbybin2_y1_0_1991_5'  & `shbybin3_y1_0_1991_1'  & `shbybin3_y1_0_1991_2'  & `shbybin3_y1_0_1991_3'  & 100 \\"  _n ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* URBAN 1991
	cap file close _all
	file open ofile using "Tables\table2_1991u.tex", write replace	
	file write ofile "\begin{tabular}{c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{12}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"`mc_bin1_1991_1_1'  & `mc_bin1_1991_1_2'  & `mc_bin1_1991_1_3'  & `mc_bin2_1991_1_1'  & `mc_bin2_1991_1_2'  & `mc_bin2_1991_1_3'  & `mc_bin2_1991_1_4'  & `mc_bin2_1991_1_5'  & `mc_bin3_1991_1_1'  & `mc_bin3_1991_1_2'  & `mc_bin3_1991_1_3'  & `mc_1_1991' \\"  _n ///
	"`my0_bin1_1991_1_1' & `my0_bin1_1991_1_2' & `my0_bin1_1991_1_3' & `my0_bin2_1991_1_1' & `my0_bin2_1991_1_2' & `my0_bin2_1991_1_3' & `my0_bin2_1991_1_4' & `my0_bin2_1991_1_5' & `my0_bin3_1991_1_1' & `my0_bin3_1991_1_2' & `my0_bin3_1991_1_3' & `my0_1_1991' \\"  _n ///
	"`my1_bin1_1991_1_1' & `my1_bin1_1991_1_2' & `my1_bin1_1991_1_3' & `my1_bin2_1991_1_1' & `my1_bin2_1991_1_2' & `my1_bin2_1991_1_3' & `my1_bin2_1991_1_4' & `my1_bin2_1991_1_5' & `my1_bin3_1991_1_1' & `my1_bin3_1991_1_2' & `my1_bin3_1991_1_3' & `my1_1_1991' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"`shbybin1_c_1_1991_1'   & `shbybin1_c_1_1991_2'   & `shbybin1_c_1_1991_3'   & `shbybin2_c_1_1991_1'   & `shbybin2_c_1_1991_2'   & `shbybin2_c_1_1991_3'   & `shbybin2_c_1_1991_4'   & `shbybin2_c_1_1991_5'   & `shbybin3_c_1_1991_1'   & `shbybin3_c_1_1991_2'   & `shbybin3_c_1_1991_3'   & 100 \\"  _n ///
	"`shbybin1_y0_1_1991_1'  & `shbybin1_y0_1_1991_2'  & `shbybin1_y0_1_1991_3'  & `shbybin2_y0_1_1991_1'  & `shbybin2_y0_1_1991_2'  & `shbybin2_y0_1_1991_3'  & `shbybin2_y0_1_1991_4'  & `shbybin2_y0_1_1991_5'  & `shbybin3_y0_1_1991_1'  & `shbybin3_y0_1_1991_2'  & `shbybin3_y0_1_1991_3'  & 100 \\"  _n ///
	"`shbybin1_y1_1_1991_1'  & `shbybin1_y1_1_1991_2'  & `shbybin1_y1_1_1991_3'  & `shbybin2_y1_1_1991_1'  & `shbybin2_y1_1_1991_2'  & `shbybin2_y1_1_1991_3'  & `shbybin2_y1_1_1991_4'  & `shbybin2_y1_1_1991_5'  & `shbybin3_y1_1_1991_1'  & `shbybin3_y1_1_1991_2'  & `shbybin3_y1_1_1991_3'  & 100 \\"  _n ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* RURAL 1993
	cap file close _all
	file open ofile using "Tables\table2_1993r.tex", write replace	
	file write ofile "\begin{tabular}{l c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"&\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"& 0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{13}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `mc_bin1_1993_0_1'  & `mc_bin1_1993_0_2'  & `mc_bin1_1993_0_3'  & `mc_bin2_1993_0_1'  & `mc_bin2_1993_0_2'  & `mc_bin2_1993_0_3'  & `mc_bin2_1993_0_4'  & `mc_bin2_1993_0_5'  & `mc_bin3_1993_0_1'  & `mc_bin3_1993_0_2'  & `mc_bin3_1993_0_3'  & `mc_0_1993' \\"  _n ///
	"Earnings 	  & `my0_bin1_1993_0_1' & `my0_bin1_1993_0_2' & `my0_bin1_1993_0_3' & `my0_bin2_1993_0_1' & `my0_bin2_1993_0_2' & `my0_bin2_1993_0_3' & `my0_bin2_1993_0_4' & `my0_bin2_1993_0_5' & `my0_bin3_1993_0_1' & `my0_bin3_1993_0_2' & `my0_bin3_1993_0_3' & `my0_0_1993' \\"  _n ///
	"Disp. Income & `my1_bin1_1993_0_1' & `my1_bin1_1993_0_2' & `my1_bin1_1993_0_3' & `my1_bin2_1993_0_1' & `my1_bin2_1993_0_2' & `my1_bin2_1993_0_3' & `my1_bin2_1993_0_4' & `my1_bin2_1993_0_5' & `my1_bin3_1993_0_1' & `my1_bin3_1993_0_2' & `my1_bin3_1993_0_3' & `my1_0_1993' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `shbybin1_c_0_1993_1'   & `shbybin1_c_0_1993_2'   & `shbybin1_c_0_1993_3'   & `shbybin2_c_0_1993_1'   & `shbybin2_c_0_1993_2'   & `shbybin2_c_0_1993_3'   & `shbybin2_c_0_1993_4'   & `shbybin2_c_0_1993_5'   & `shbybin3_c_0_1993_1'   & `shbybin3_c_0_1993_2'   & `shbybin3_c_0_1993_3'   & 100 \\"  _n ///
	"Earnings 	  & `shbybin1_y0_0_1993_1'  & `shbybin1_y0_0_1993_2'  & `shbybin1_y0_0_1993_3'  & `shbybin2_y0_0_1993_1'  & `shbybin2_y0_0_1993_2'  & `shbybin2_y0_0_1993_3'  & `shbybin2_y0_0_1993_4'  & `shbybin2_y0_0_1993_5'  & `shbybin3_y0_0_1993_1'  & `shbybin3_y0_0_1993_2'  & `shbybin3_y0_0_1993_3'  & 100 \\"  _n ///
	"Disp. Income & `shbybin1_y1_0_1993_1'  & `shbybin1_y1_0_1993_2'  & `shbybin1_y1_0_1993_3'  & `shbybin2_y1_0_1993_1'  & `shbybin2_y1_0_1993_2'  & `shbybin2_y1_0_1993_3'  & `shbybin2_y1_0_1993_4'  & `shbybin2_y1_0_1993_5'  & `shbybin3_y1_0_1993_1'  & `shbybin3_y1_0_1993_2'  & `shbybin3_y1_0_1993_3'  & 100 \\"  _n ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* URBAN 1993
	cap file close _all
	file open ofile using "Tables\table2_1993u.tex", write replace	
	file write ofile "\begin{tabular}{c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{12}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"`mc_bin1_1993_1_1'  & `mc_bin1_1993_1_2'  & `mc_bin1_1993_1_3'  & `mc_bin2_1993_1_1'  & `mc_bin2_1993_1_2'  & `mc_bin2_1993_1_3'  & `mc_bin2_1993_1_4'  & `mc_bin2_1993_1_5'  & `mc_bin3_1993_1_1'  & `mc_bin3_1993_1_2'  & `mc_bin3_1993_1_3'  & `mc_1_1993' \\"  _n ///
	"`my0_bin1_1993_1_1' & `my0_bin1_1993_1_2' & `my0_bin1_1993_1_3' & `my0_bin2_1993_1_1' & `my0_bin2_1993_1_2' & `my0_bin2_1993_1_3' & `my0_bin2_1993_1_4' & `my0_bin2_1993_1_5' & `my0_bin3_1993_1_1' & `my0_bin3_1993_1_2' & `my0_bin3_1993_1_3' & `my0_1_1993' \\"  _n ///
	"`my1_bin1_1993_1_1' & `my1_bin1_1993_1_2' & `my1_bin1_1993_1_3' & `my1_bin2_1993_1_1' & `my1_bin2_1993_1_2' & `my1_bin2_1993_1_3' & `my1_bin2_1993_1_4' & `my1_bin2_1993_1_5' & `my1_bin3_1993_1_1' & `my1_bin3_1993_1_2' & `my1_bin3_1993_1_3' & `my1_1_1993' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"`shbybin1_c_1_1993_1'   & `shbybin1_c_1_1993_2'   & `shbybin1_c_1_1993_3'   & `shbybin2_c_1_1993_1'   & `shbybin2_c_1_1993_2'   & `shbybin2_c_1_1993_3'   & `shbybin2_c_1_1993_4'   & `shbybin2_c_1_1993_5'   & `shbybin3_c_1_1993_1'   & `shbybin3_c_1_1993_2'   & `shbybin3_c_1_1993_3'   & 100 \\"  _n ///
	"`shbybin1_y0_1_1993_1'  & `shbybin1_y0_1_1993_2'  & `shbybin1_y0_1_1993_3'  & `shbybin2_y0_1_1993_1'  & `shbybin2_y0_1_1993_2'  & `shbybin2_y0_1_1993_3'  & `shbybin2_y0_1_1993_4'  & `shbybin2_y0_1_1993_5'  & `shbybin3_y0_1_1993_1'  & `shbybin3_y0_1_1993_2'  & `shbybin3_y0_1_1993_3'  & 100 \\"  _n ///
	"`shbybin1_y1_1_1993_1'  & `shbybin1_y1_1_1993_2'  & `shbybin1_y1_1_1993_3'  & `shbybin2_y1_1_1993_1'  & `shbybin2_y1_1_1993_2'  & `shbybin2_y1_1_1993_3'  & `shbybin2_y1_1_1993_4'  & `shbybin2_y1_1_1993_5'  & `shbybin3_y1_1_1993_1'  & `shbybin3_y1_1_1993_2'  & `shbybin3_y1_1_1993_3'  & 100 \\"  _n ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all

	* RURAL 1997
	cap file close _all
	file open ofile using "Tables\table2_1997r.tex", write replace	
	file write ofile "\begin{tabular}{l c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"&\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"& 0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{13}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `mc_bin1_1997_0_1'  & `mc_bin1_1997_0_2'  & `mc_bin1_1997_0_3'  & `mc_bin2_1997_0_1'  & `mc_bin2_1997_0_2'  & `mc_bin2_1997_0_3'  & `mc_bin2_1997_0_4'  & `mc_bin2_1997_0_5'  & `mc_bin3_1997_0_1'  & `mc_bin3_1997_0_2'  & `mc_bin3_1997_0_3'  & `mc_0_1997' \\"  _n ///
	"Earnings 	  & `my0_bin1_1997_0_1' & `my0_bin1_1997_0_2' & `my0_bin1_1997_0_3' & `my0_bin2_1997_0_1' & `my0_bin2_1997_0_2' & `my0_bin2_1997_0_3' & `my0_bin2_1997_0_4' & `my0_bin2_1997_0_5' & `my0_bin3_1997_0_1' & `my0_bin3_1997_0_2' & `my0_bin3_1997_0_3' & `my0_0_1997' \\"  _n ///
	"Disp. Income & `my1_bin1_1997_0_1' & `my1_bin1_1997_0_2' & `my1_bin1_1997_0_3' & `my1_bin2_1997_0_1' & `my1_bin2_1997_0_2' & `my1_bin2_1997_0_3' & `my1_bin2_1997_0_4' & `my1_bin2_1997_0_5' & `my1_bin3_1997_0_1' & `my1_bin3_1997_0_2' & `my1_bin3_1997_0_3' & `my1_0_1997' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `shbybin1_c_0_1997_1'   & `shbybin1_c_0_1997_2'   & `shbybin1_c_0_1997_3'   & `shbybin2_c_0_1997_1'   & `shbybin2_c_0_1997_2'   & `shbybin2_c_0_1997_3'   & `shbybin2_c_0_1997_4'   & `shbybin2_c_0_1997_5'   & `shbybin3_c_0_1997_1'   & `shbybin3_c_0_1997_2'   & `shbybin3_c_0_1997_3'   & 100 \\"  _n ///
	"Earnings 	  & `shbybin1_y0_0_1997_1'  & `shbybin1_y0_0_1997_2'  & `shbybin1_y0_0_1997_3'  & `shbybin2_y0_0_1997_1'  & `shbybin2_y0_0_1997_2'  & `shbybin2_y0_0_1997_3'  & `shbybin2_y0_0_1997_4'  & `shbybin2_y0_0_1997_5'  & `shbybin3_y0_0_1997_1'  & `shbybin3_y0_0_1997_2'  & `shbybin3_y0_0_1997_3'  & 100 \\"  _n ///
	"Disp. Income & `shbybin1_y1_0_1997_1'  & `shbybin1_y1_0_1997_2'  & `shbybin1_y1_0_1997_3'  & `shbybin2_y1_0_1997_1'  & `shbybin2_y1_0_1997_2'  & `shbybin2_y1_0_1997_3'  & `shbybin2_y1_0_1997_4'  & `shbybin2_y1_0_1997_5'  & `shbybin3_y1_0_1997_1'  & `shbybin3_y1_0_1997_2'  & `shbybin3_y1_0_1997_3'  & 100 \\"  _n ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* URBAN 1997
	cap file close _all
	file open ofile using "Tables\table2_1997u.tex", write replace	
	file write ofile "\begin{tabular}{c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{12}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"`mc_bin1_1997_1_1'  & `mc_bin1_1997_1_2'  & `mc_bin1_1997_1_3'  & `mc_bin2_1997_1_1'  & `mc_bin2_1997_1_2'  & `mc_bin2_1997_1_3'  & `mc_bin2_1997_1_4'  & `mc_bin2_1997_1_5'  & `mc_bin3_1997_1_1'  & `mc_bin3_1997_1_2'  & `mc_bin3_1997_1_3'  & `mc_1_1997' \\"  _n ///
	"`my0_bin1_1997_1_1' & `my0_bin1_1997_1_2' & `my0_bin1_1997_1_3' & `my0_bin2_1997_1_1' & `my0_bin2_1997_1_2' & `my0_bin2_1997_1_3' & `my0_bin2_1997_1_4' & `my0_bin2_1997_1_5' & `my0_bin3_1997_1_1' & `my0_bin3_1997_1_2' & `my0_bin3_1997_1_3' & `my0_1_1997' \\"  _n ///
	"`my1_bin1_1997_1_1' & `my1_bin1_1997_1_2' & `my1_bin1_1997_1_3' & `my1_bin2_1997_1_1' & `my1_bin2_1997_1_2' & `my1_bin2_1997_1_3' & `my1_bin2_1997_1_4' & `my1_bin2_1997_1_5' & `my1_bin3_1997_1_1' & `my1_bin3_1997_1_2' & `my1_bin3_1997_1_3' & `my1_1_1997' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"`shbybin1_c_1_1997_1'   & `shbybin1_c_1_1997_2'   & `shbybin1_c_1_1997_3'   & `shbybin2_c_1_1997_1'   & `shbybin2_c_1_1997_2'   & `shbybin2_c_1_1997_3'   & `shbybin2_c_1_1997_4'   & `shbybin2_c_1_1997_5'   & `shbybin3_c_1_1997_1'   & `shbybin3_c_1_1997_2'   & `shbybin3_c_1_1997_3'   & 100 \\"  _n ///
	"`shbybin1_y0_1_1997_1'  & `shbybin1_y0_1_1997_2'  & `shbybin1_y0_1_1997_3'  & `shbybin2_y0_1_1997_1'  & `shbybin2_y0_1_1997_2'  & `shbybin2_y0_1_1997_3'  & `shbybin2_y0_1_1997_4'  & `shbybin2_y0_1_1997_5'  & `shbybin3_y0_1_1997_1'  & `shbybin3_y0_1_1997_2'  & `shbybin3_y0_1_1997_3'  & 100 \\"  _n ///
	"`shbybin1_y1_1_1997_1'  & `shbybin1_y1_1_1997_2'  & `shbybin1_y1_1_1997_3'  & `shbybin2_y1_1_1997_1'  & `shbybin2_y1_1_1997_2'  & `shbybin2_y1_1_1997_3'  & `shbybin2_y1_1_1997_4'  & `shbybin2_y1_1_1997_5'  & `shbybin3_y1_1_1997_1'  & `shbybin3_y1_1_1997_2'  & `shbybin3_y1_1_1997_3'  & 100 \\"  _n ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all

	* RURAL 2000
	cap file close _all
	file open ofile using "Tables\table2_2000r.tex", write replace	
	file write ofile "\begin{tabular}{l c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"&\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"& 0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{13}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `mc_bin1_2000_0_1'  & `mc_bin1_2000_0_2'  & `mc_bin1_2000_0_3'  & `mc_bin2_2000_0_1'  & `mc_bin2_2000_0_2'  & `mc_bin2_2000_0_3'  & `mc_bin2_2000_0_4'  & `mc_bin2_2000_0_5'  & `mc_bin3_2000_0_1'  & `mc_bin3_2000_0_2'  & `mc_bin3_2000_0_3'  & `mc_0_2000' \\"  _n ///
	"Earnings 	  & `my0_bin1_2000_0_1' & `my0_bin1_2000_0_2' & `my0_bin1_2000_0_3' & `my0_bin2_2000_0_1' & `my0_bin2_2000_0_2' & `my0_bin2_2000_0_3' & `my0_bin2_2000_0_4' & `my0_bin2_2000_0_5' & `my0_bin3_2000_0_1' & `my0_bin3_2000_0_2' & `my0_bin3_2000_0_3' & `my0_0_2000' \\"  _n ///
	"Disp. Income & `my1_bin1_2000_0_1' & `my1_bin1_2000_0_2' & `my1_bin1_2000_0_3' & `my1_bin2_2000_0_1' & `my1_bin2_2000_0_2' & `my1_bin2_2000_0_3' & `my1_bin2_2000_0_4' & `my1_bin2_2000_0_5' & `my1_bin3_2000_0_1' & `my1_bin3_2000_0_2' & `my1_bin3_2000_0_3' & `my1_0_2000' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `shbybin1_c_0_2000_1'   & `shbybin1_c_0_2000_2'   & `shbybin1_c_0_2000_3'   & `shbybin2_c_0_2000_1'   & `shbybin2_c_0_2000_2'   & `shbybin2_c_0_2000_3'   & `shbybin2_c_0_2000_4'   & `shbybin2_c_0_2000_5'   & `shbybin3_c_0_2000_1'   & `shbybin3_c_0_2000_2'   & `shbybin3_c_0_2000_3'   & 100 \\"  _n ///
	"Earnings 	  & `shbybin1_y0_0_2000_1'  & `shbybin1_y0_0_2000_2'  & `shbybin1_y0_0_2000_3'  & `shbybin2_y0_0_2000_1'  & `shbybin2_y0_0_2000_2'  & `shbybin2_y0_0_2000_3'  & `shbybin2_y0_0_2000_4'  & `shbybin2_y0_0_2000_5'  & `shbybin3_y0_0_2000_1'  & `shbybin3_y0_0_2000_2'  & `shbybin3_y0_0_2000_3'  & 100 \\"  _n ///
	"Disp. Income & `shbybin1_y1_0_2000_1'  & `shbybin1_y1_0_2000_2'  & `shbybin1_y1_0_2000_3'  & `shbybin2_y1_0_2000_1'  & `shbybin2_y1_0_2000_2'  & `shbybin2_y1_0_2000_3'  & `shbybin2_y1_0_2000_4'  & `shbybin2_y1_0_2000_5'  & `shbybin3_y1_0_2000_1'  & `shbybin3_y1_0_2000_2'  & `shbybin3_y1_0_2000_3'  & 100 \\"  _n ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* URBAN 2000
	cap file close _all
	file open ofile using "Tables\table2_2000u.tex", write replace	
	file write ofile "\begin{tabular}{c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{12}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"`mc_bin1_2000_1_1'  & `mc_bin1_2000_1_2'  & `mc_bin1_2000_1_3'  & `mc_bin2_2000_1_1'  & `mc_bin2_2000_1_2'  & `mc_bin2_2000_1_3'  & `mc_bin2_2000_1_4'  & `mc_bin2_2000_1_5'  & `mc_bin3_2000_1_1'  & `mc_bin3_2000_1_2'  & `mc_bin3_2000_1_3'  & `mc_1_2000' \\"  _n ///
	"`my0_bin1_2000_1_1' & `my0_bin1_2000_1_2' & `my0_bin1_2000_1_3' & `my0_bin2_2000_1_1' & `my0_bin2_2000_1_2' & `my0_bin2_2000_1_3' & `my0_bin2_2000_1_4' & `my0_bin2_2000_1_5' & `my0_bin3_2000_1_1' & `my0_bin3_2000_1_2' & `my0_bin3_2000_1_3' & `my0_1_2000' \\"  _n ///
	"`my1_bin1_2000_1_1' & `my1_bin1_2000_1_2' & `my1_bin1_2000_1_3' & `my1_bin2_2000_1_1' & `my1_bin2_2000_1_2' & `my1_bin2_2000_1_3' & `my1_bin2_2000_1_4' & `my1_bin2_2000_1_5' & `my1_bin3_2000_1_1' & `my1_bin3_2000_1_2' & `my1_bin3_2000_1_3' & `my1_1_2000' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"`shbybin1_c_1_2000_1'   & `shbybin1_c_1_2000_2'   & `shbybin1_c_1_2000_3'   & `shbybin2_c_1_2000_1'   & `shbybin2_c_1_2000_2'   & `shbybin2_c_1_2000_3'   & `shbybin2_c_1_2000_4'   & `shbybin2_c_1_2000_5'   & `shbybin3_c_1_2000_1'   & `shbybin3_c_1_2000_2'   & `shbybin3_c_1_2000_3'   & 100 \\"  _n ///
	"`shbybin1_y0_1_2000_1'  & `shbybin1_y0_1_2000_2'  & `shbybin1_y0_1_2000_3'  & `shbybin2_y0_1_2000_1'  & `shbybin2_y0_1_2000_2'  & `shbybin2_y0_1_2000_3'  & `shbybin2_y0_1_2000_4'  & `shbybin2_y0_1_2000_5'  & `shbybin3_y0_1_2000_1'  & `shbybin3_y0_1_2000_2'  & `shbybin3_y0_1_2000_3'  & 100 \\"  _n ///
	"`shbybin1_y1_1_2000_1'  & `shbybin1_y1_1_2000_2'  & `shbybin1_y1_1_2000_3'  & `shbybin2_y1_1_2000_1'  & `shbybin2_y1_1_2000_2'  & `shbybin2_y1_1_2000_3'  & `shbybin2_y1_1_2000_4'  & `shbybin2_y1_1_2000_5'  & `shbybin3_y1_1_2000_1'  & `shbybin3_y1_1_2000_2'  & `shbybin3_y1_1_2000_3'  & 100 \\"  _n ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all

	* RURAL 2004
	cap file close _all
	file open ofile using "Tables\table2_2004r.tex", write replace	
	file write ofile "\begin{tabular}{l c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"&\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"& 0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{13}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `mc_bin1_2004_0_1'  & `mc_bin1_2004_0_2'  & `mc_bin1_2004_0_3'  & `mc_bin2_2004_0_1'  & `mc_bin2_2004_0_2'  & `mc_bin2_2004_0_3'  & `mc_bin2_2004_0_4'  & `mc_bin2_2004_0_5'  & `mc_bin3_2004_0_1'  & `mc_bin3_2004_0_2'  & `mc_bin3_2004_0_3'  & `mc_0_2004' \\"  _n ///
	"Earnings 	  & `my0_bin1_2004_0_1' & `my0_bin1_2004_0_2' & `my0_bin1_2004_0_3' & `my0_bin2_2004_0_1' & `my0_bin2_2004_0_2' & `my0_bin2_2004_0_3' & `my0_bin2_2004_0_4' & `my0_bin2_2004_0_5' & `my0_bin3_2004_0_1' & `my0_bin3_2004_0_2' & `my0_bin3_2004_0_3' & `my0_0_2004' \\"  _n ///
	"Disp. Income & `my1_bin1_2004_0_1' & `my1_bin1_2004_0_2' & `my1_bin1_2004_0_3' & `my1_bin2_2004_0_1' & `my1_bin2_2004_0_2' & `my1_bin2_2004_0_3' & `my1_bin2_2004_0_4' & `my1_bin2_2004_0_5' & `my1_bin3_2004_0_1' & `my1_bin3_2004_0_2' & `my1_bin3_2004_0_3' & `my1_0_2004' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `shbybin1_c_0_2004_1'   & `shbybin1_c_0_2004_2'   & `shbybin1_c_0_2004_3'   & `shbybin2_c_0_2004_1'   & `shbybin2_c_0_2004_2'   & `shbybin2_c_0_2004_3'   & `shbybin2_c_0_2004_4'   & `shbybin2_c_0_2004_5'   & `shbybin3_c_0_2004_1'   & `shbybin3_c_0_2004_2'   & `shbybin3_c_0_2004_3'   & 100 \\"  _n ///
	"Earnings 	  & `shbybin1_y0_0_2004_1'  & `shbybin1_y0_0_2004_2'  & `shbybin1_y0_0_2004_3'  & `shbybin2_y0_0_2004_1'  & `shbybin2_y0_0_2004_2'  & `shbybin2_y0_0_2004_3'  & `shbybin2_y0_0_2004_4'  & `shbybin2_y0_0_2004_5'  & `shbybin3_y0_0_2004_1'  & `shbybin3_y0_0_2004_2'  & `shbybin3_y0_0_2004_3'  & 100 \\"  _n ///
	"Disp. Income & `shbybin1_y1_0_2004_1'  & `shbybin1_y1_0_2004_2'  & `shbybin1_y1_0_2004_3'  & `shbybin2_y1_0_2004_1'  & `shbybin2_y1_0_2004_2'  & `shbybin2_y1_0_2004_3'  & `shbybin2_y1_0_2004_4'  & `shbybin2_y1_0_2004_5'  & `shbybin3_y1_0_2004_1'  & `shbybin3_y1_0_2004_2'  & `shbybin3_y1_0_2004_3'  & 100 \\"  _n ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* URBAN 2004
	cap file close _all
	file open ofile using "Tables\table2_2004u.tex", write replace	
	file write ofile "\begin{tabular}{c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{12}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"`mc_bin1_2004_1_1'  & `mc_bin1_2004_1_2'  & `mc_bin1_2004_1_3'  & `mc_bin2_2004_1_1'  & `mc_bin2_2004_1_2'  & `mc_bin2_2004_1_3'  & `mc_bin2_2004_1_4'  & `mc_bin2_2004_1_5'  & `mc_bin3_2004_1_1'  & `mc_bin3_2004_1_2'  & `mc_bin3_2004_1_3'  & `mc_1_2004' \\"  _n ///
	"`my0_bin1_2004_1_1' & `my0_bin1_2004_1_2' & `my0_bin1_2004_1_3' & `my0_bin2_2004_1_1' & `my0_bin2_2004_1_2' & `my0_bin2_2004_1_3' & `my0_bin2_2004_1_4' & `my0_bin2_2004_1_5' & `my0_bin3_2004_1_1' & `my0_bin3_2004_1_2' & `my0_bin3_2004_1_3' & `my0_1_2004' \\"  _n ///
	"`my1_bin1_2004_1_1' & `my1_bin1_2004_1_2' & `my1_bin1_2004_1_3' & `my1_bin2_2004_1_1' & `my1_bin2_2004_1_2' & `my1_bin2_2004_1_3' & `my1_bin2_2004_1_4' & `my1_bin2_2004_1_5' & `my1_bin3_2004_1_1' & `my1_bin3_2004_1_2' & `my1_bin3_2004_1_3' & `my1_1_2004' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"`shbybin1_c_1_2004_1'   & `shbybin1_c_1_2004_2'   & `shbybin1_c_1_2004_3'   & `shbybin2_c_1_2004_1'   & `shbybin2_c_1_2004_2'   & `shbybin2_c_1_2004_3'   & `shbybin2_c_1_2004_4'   & `shbybin2_c_1_2004_5'   & `shbybin3_c_1_2004_1'   & `shbybin3_c_1_2004_2'   & `shbybin3_c_1_2004_3'   & 100 \\"  _n ///
	"`shbybin1_y0_1_2004_1'  & `shbybin1_y0_1_2004_2'  & `shbybin1_y0_1_2004_3'  & `shbybin2_y0_1_2004_1'  & `shbybin2_y0_1_2004_2'  & `shbybin2_y0_1_2004_3'  & `shbybin2_y0_1_2004_4'  & `shbybin2_y0_1_2004_5'  & `shbybin3_y0_1_2004_1'  & `shbybin3_y0_1_2004_2'  & `shbybin3_y0_1_2004_3'  & 100 \\"  _n ///
	"`shbybin1_y1_1_2004_1'  & `shbybin1_y1_1_2004_2'  & `shbybin1_y1_1_2004_3'  & `shbybin2_y1_1_2004_1'  & `shbybin2_y1_1_2004_2'  & `shbybin2_y1_1_2004_3'  & `shbybin2_y1_1_2004_4'  & `shbybin2_y1_1_2004_5'  & `shbybin3_y1_1_2004_1'  & `shbybin3_y1_1_2004_2'  & `shbybin3_y1_1_2004_3'  & 100 \\"  _n ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all

	* RURAL 2006
	cap file close _all
	file open ofile using "Tables\table2_2006r.tex", write replace	
	file write ofile "\begin{tabular}{l c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"&\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"& 0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{13}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `mc_bin1_2006_0_1'  & `mc_bin1_2006_0_2'  & `mc_bin1_2006_0_3'  & `mc_bin2_2006_0_1'  & `mc_bin2_2006_0_2'  & `mc_bin2_2006_0_3'  & `mc_bin2_2006_0_4'  & `mc_bin2_2006_0_5'  & `mc_bin3_2006_0_1'  & `mc_bin3_2006_0_2'  & `mc_bin3_2006_0_3'  & `mc_0_2006' \\"  _n ///
	"Earnings 	  & `my0_bin1_2006_0_1' & `my0_bin1_2006_0_2' & `my0_bin1_2006_0_3' & `my0_bin2_2006_0_1' & `my0_bin2_2006_0_2' & `my0_bin2_2006_0_3' & `my0_bin2_2006_0_4' & `my0_bin2_2006_0_5' & `my0_bin3_2006_0_1' & `my0_bin3_2006_0_2' & `my0_bin3_2006_0_3' & `my0_0_2006' \\"  _n ///
	"Disp. Income & `my1_bin1_2006_0_1' & `my1_bin1_2006_0_2' & `my1_bin1_2006_0_3' & `my1_bin2_2006_0_1' & `my1_bin2_2006_0_2' & `my1_bin2_2006_0_3' & `my1_bin2_2006_0_4' & `my1_bin2_2006_0_5' & `my1_bin3_2006_0_1' & `my1_bin3_2006_0_2' & `my1_bin3_2006_0_3' & `my1_0_2006' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `shbybin1_c_0_2006_1'   & `shbybin1_c_0_2006_2'   & `shbybin1_c_0_2006_3'   & `shbybin2_c_0_2006_1'   & `shbybin2_c_0_2006_2'   & `shbybin2_c_0_2006_3'   & `shbybin2_c_0_2006_4'   & `shbybin2_c_0_2006_5'   & `shbybin3_c_0_2006_1'   & `shbybin3_c_0_2006_2'   & `shbybin3_c_0_2006_3'   & 100 \\"  _n ///
	"Earnings 	  & `shbybin1_y0_0_2006_1'  & `shbybin1_y0_0_2006_2'  & `shbybin1_y0_0_2006_3'  & `shbybin2_y0_0_2006_1'  & `shbybin2_y0_0_2006_2'  & `shbybin2_y0_0_2006_3'  & `shbybin2_y0_0_2006_4'  & `shbybin2_y0_0_2006_5'  & `shbybin3_y0_0_2006_1'  & `shbybin3_y0_0_2006_2'  & `shbybin3_y0_0_2006_3'  & 100 \\"  _n ///
	"Disp. Income & `shbybin1_y1_0_2006_1'  & `shbybin1_y1_0_2006_2'  & `shbybin1_y1_0_2006_3'  & `shbybin2_y1_0_2006_1'  & `shbybin2_y1_0_2006_2'  & `shbybin2_y1_0_2006_3'  & `shbybin2_y1_0_2006_4'  & `shbybin2_y1_0_2006_5'  & `shbybin3_y1_0_2006_1'  & `shbybin3_y1_0_2006_2'  & `shbybin3_y1_0_2006_3'  & 100 \\"  _n ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* URBAN 2006
	cap file close _all
	file open ofile using "Tables\table2_2006u.tex", write replace	
	file write ofile "\begin{tabular}{c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{12}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"`mc_bin1_2006_1_1'  & `mc_bin1_2006_1_2'  & `mc_bin1_2006_1_3'  & `mc_bin2_2006_1_1'  & `mc_bin2_2006_1_2'  & `mc_bin2_2006_1_3'  & `mc_bin2_2006_1_4'  & `mc_bin2_2006_1_5'  & `mc_bin3_2006_1_1'  & `mc_bin3_2006_1_2'  & `mc_bin3_2006_1_3'  & `mc_1_2006' \\"  _n ///
	"`my0_bin1_2006_1_1' & `my0_bin1_2006_1_2' & `my0_bin1_2006_1_3' & `my0_bin2_2006_1_1' & `my0_bin2_2006_1_2' & `my0_bin2_2006_1_3' & `my0_bin2_2006_1_4' & `my0_bin2_2006_1_5' & `my0_bin3_2006_1_1' & `my0_bin3_2006_1_2' & `my0_bin3_2006_1_3' & `my0_1_2006' \\"  _n ///
	"`my1_bin1_2006_1_1' & `my1_bin1_2006_1_2' & `my1_bin1_2006_1_3' & `my1_bin2_2006_1_1' & `my1_bin2_2006_1_2' & `my1_bin2_2006_1_3' & `my1_bin2_2006_1_4' & `my1_bin2_2006_1_5' & `my1_bin3_2006_1_1' & `my1_bin3_2006_1_2' & `my1_bin3_2006_1_3' & `my1_1_2006' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"`shbybin1_c_1_2006_1'   & `shbybin1_c_1_2006_2'   & `shbybin1_c_1_2006_3'   & `shbybin2_c_1_2006_1'   & `shbybin2_c_1_2006_2'   & `shbybin2_c_1_2006_3'   & `shbybin2_c_1_2006_4'   & `shbybin2_c_1_2006_5'   & `shbybin3_c_1_2006_1'   & `shbybin3_c_1_2006_2'   & `shbybin3_c_1_2006_3'   & 100 \\"  _n ///
	"`shbybin1_y0_1_2006_1'  & `shbybin1_y0_1_2006_2'  & `shbybin1_y0_1_2006_3'  & `shbybin2_y0_1_2006_1'  & `shbybin2_y0_1_2006_2'  & `shbybin2_y0_1_2006_3'  & `shbybin2_y0_1_2006_4'  & `shbybin2_y0_1_2006_5'  & `shbybin3_y0_1_2006_1'  & `shbybin3_y0_1_2006_2'  & `shbybin3_y0_1_2006_3'  & 100 \\"  _n ///
	"`shbybin1_y1_1_2006_1'  & `shbybin1_y1_1_2006_2'  & `shbybin1_y1_1_2006_3'  & `shbybin2_y1_1_2006_1'  & `shbybin2_y1_1_2006_2'  & `shbybin2_y1_1_2006_3'  & `shbybin2_y1_1_2006_4'  & `shbybin2_y1_1_2006_5'  & `shbybin3_y1_1_2006_1'  & `shbybin3_y1_1_2006_2'  & `shbybin3_y1_1_2006_3'  & 100 \\"  _n ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
