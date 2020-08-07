***************************************************************************************************************
* THIS FILE PRODUCES SUMMARY STATISTICS (IN DETAIL) FROM CHNS BY INCOME PARTITION FOR ALL WAVES.
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

* ADJUST THE AGGREGATE VARIABLES TO MAKE SURE THAT THE SHARES ADD UP TO 1.

egen chealth = rsum(cmed cmedins)
foreach var in sub_utility chouse cchildcare cedu chealth cdurable cfoodown foodgift sub_coupon	{
	replace `var' =. if cdiet==. | cdiet==0
	}	
egen consumption_all = rsum(cdiet sub_utility chouse cchildcare cedu chealth cdurable)  if cdiet~=. & cdiet~=0
drop    food_exp
gen  	ncfoodown = -cfoodown if cdiet~=. & cdiet~=0
gen  	nfoodgift = -foodgift if cdiet~=. & cdiet~=0
gen 	nsub_coupon  = -sub_coupon   if cdiet~=. & cdiet~=0
egen 	food_exp = rsum(cdiet ncfoodown nsub_coupon nfoodgift) if cdiet~=. & cdiet~=0				// CASH EXPENDITURE ON FOOD
drop 	ncfoodown nfoodgift nsub_coupon 
drop	transfR_pub
egen transfR_pub = rsum(sub_coupon sub_work sub_gvmt pi)
egen transfR = rsum(transfR_pub transfR_pri)

* COMPUTE THE ADULT EQUIVALENT MEASURES OF INCOME AND CONSUMPTION
	* Compute equivalence scales
	qui gen equiv_KP   =  (numi_geq_15 +  .7*numi_lt_15)^(.7) /* These are the NAS scales used by Krueger and Perri ReStud who cite . If you read that reference you will find they refer to page 59 in "Measuring Poverty, A New Approach" published by the National Academy of Sciencies (NAS) scales. "																							It is Also used by Heathcote, Storesletten, and Violante JPE (Consumption Insurance and Labor Supply) */	
	qui gen numi_15_60 = numi_geq_15-numi_gt_60
	qui gen equiv_ad   = numi_geq_15
	qui gen equiv_ad2  = numi_15_60

	* Compute adult-equivalent income
	foreach var in income0 income1 ai bi ci lmi transfR	transfR_pub transfR_pri sub_coupon sub_work sub_gvmt pi  {
		qui gen `var'_ad2 = `var'/equiv_ad2
	}
	* Compute adult-equivalent consumption
	foreach var in consumption1 consumption_all cdiet sub_utility chouse cchildcare cedu chealth cdurable food_exp cfoodown foodgift sub_coupon   {
		qui gen `var'_KP = `var'/equiv_KP
	}

keep *_ad2 *_KP urban interview_year case_id
duplicates drop
keep if income1_ad2~=.

rename consumption1_KP  	c
rename income1_ad2			y1
rename income0_ad2			y0
rename consumption_all_KP   c0
rename cdiet_KP				c0_1
rename sub_utility_KP		c0_2
rename chouse_KP			c0_3
rename cchildcare_KP		c0_4
rename chealth_KP			c0_5
rename cedu_KP				c0_6
rename cdurable_KP			c0_7
rename cfoodown_KP			c0_11
rename sub_coupon_KP		c0_12
rename foodgift_KP			c0_13
rename food_exp_KP			c0_14
rename lmi_ad2				y1_1
rename ai_ad2				y1_2
rename bi_ad2				y1_3
rename ci_ad2				y1_4
rename transfR_ad2			y1_5
rename transfR_pub_ad2		y1_51
rename transfR_pri_ad2		y1_52
rename sub_coupon_ad2		y1_511
rename sub_work_ad2			y1_512
rename sub_gvmt_ad2			y1_513
rename pi_ad2				y1_514

bys interview_year urban:  egen s_c = total(c) 	  	  if y1~=.
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
foreach xwave in 1989 1991 1993 1997 2000 2004 2006 2009  {
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


* GENERATE CONSUMPTION COMPOSITION
foreach var in c0 c0_1 c0_2 c0_3 c0_4 c0_5 c0_6 c0_7 c0_11 c0_12 c0_13 c0_14		{
	gen sbybin1_`var'=.
	gen sbybin2_`var'=.
	gen sbybin3_`var'=.
}
foreach xwave in 1989 1991 1993 1997 2000 2004 2006 2009  {
	forvalues urb=0/1  {
		foreach var in c0 c0_1 c0_2 c0_3 c0_4 c0_5 c0_6 c0_7 c0_11 c0_12 c0_13 c0_14		{
			
			bys bin1_`xwave'_`urb': egen sbybin1_`var'_aux = total(`var') if bin1_`xwave'_`urb'~=.
			bys bin2_`xwave'_`urb': egen sbybin2_`var'_aux = total(`var') if bin2_`xwave'_`urb'~=.
			bys bin3_`xwave'_`urb': egen sbybin3_`var'_aux = total(`var') if bin3_`xwave'_`urb'~=.
			
			qui replace sbybin1_`var' = sbybin1_`var'_aux if interview_year == `xwave' & urban == `urb'
			qui replace sbybin2_`var' = sbybin2_`var'_aux if interview_year == `xwave' & urban == `urb'
			qui replace sbybin3_`var' = sbybin3_`var'_aux if interview_year == `xwave' & urban == `urb'
			drop *_aux
		}
	}
}
foreach var in c0 c0_1 c0_2 c0_3 c0_4 c0_5 c0_6 c0_7 c0_11 c0_12 c0_13 c0_14		{
	bys interview_year  urban: egen s_`var' = total(`var')
}
foreach var in c0_1 c0_2 c0_3 c0_4 c0_5 c0_6 c0_7	{
	qui gen shbybin1_`var' = sbybin1_`var'/sbybin1_c0*100
	qui gen shbybin2_`var' = sbybin2_`var'/sbybin2_c0*100
	qui gen shbybin3_`var' = sbybin3_`var'/sbybin3_c0*100
	qui gen sh_`var' 	   = s_`var'/s_c0*100
}

foreach var in c0_11 c0_12 c0_13 c0_14			{
	qui gen shbybin1_`var' = sbybin1_`var'/sbybin1_c0_1*100
	qui gen shbybin2_`var' = sbybin2_`var'/sbybin2_c0_1*100
	qui gen shbybin3_`var' = sbybin3_`var'/sbybin3_c0_1*100
	qui gen sh_`var'	   = s_`var'/s_c0_1*100
}

* GENERATE INCOME COMPOSITION
foreach var in y1 y1_1 y1_2 y1_3 y1_4 y1_5 y1_51 y1_52 y1_511 y1_512 y1_513 y1_514   {
	gen sbybin1_`var'=.
	gen sbybin2_`var'=.
	gen sbybin3_`var'=.
}
foreach xwave in 1989 1991 1993 1997 2000 2004 2006 2009  {
	forvalues urb=0/1  {
		foreach var in y1 y1_1 y1_2 y1_3 y1_4 y1_5 y1_51 y1_52 y1_511 y1_512 y1_513 y1_514   {
					
			bys bin1_`xwave'_`urb': egen sbybin1_`var'_aux = total(`var') if bin1_`xwave'_`urb'~=.
			bys bin2_`xwave'_`urb': egen sbybin2_`var'_aux = total(`var') if bin2_`xwave'_`urb'~=.
			bys bin3_`xwave'_`urb': egen sbybin3_`var'_aux = total(`var') if bin3_`xwave'_`urb'~=.
			
			qui replace sbybin1_`var' = sbybin1_`var'_aux if interview_year == `xwave' & urban == `urb'
			qui replace sbybin2_`var' = sbybin2_`var'_aux if interview_year == `xwave' & urban == `urb'
			qui replace sbybin3_`var' = sbybin3_`var'_aux if interview_year == `xwave' & urban == `urb'
			drop *_aux
		}
	}
}
foreach var in y1 y1_1 y1_2 y1_3 y1_4 y1_5 y1_51 y1_52 y1_511 y1_512 y1_513 y1_514   {
	bys interview_year  urban: egen s_`var' = total(`var')
}
foreach var in y1_1 y1_2 y1_3 y1_4 y1_5		{
	qui gen shbybin1_`var' = sbybin1_`var'/sbybin1_y1*100
	qui gen shbybin2_`var' = sbybin2_`var'/sbybin2_y1*100
	qui gen shbybin3_`var' = sbybin3_`var'/sbybin3_y1*100
	qui gen sh_`var'	   = s_`var'/s_y1*100
}
foreach var in y1_51 y1_52			{
	qui gen shbybin1_`var' = sbybin1_`var'/sbybin1_y1_5*100
	qui gen shbybin2_`var' = sbybin2_`var'/sbybin2_y1_5*100
	qui gen shbybin3_`var' = sbybin3_`var'/sbybin3_y1_5*100
	qui gen sh_`var'	   = s_`var'/s_y1_5*100
}
foreach var in y1_511 y1_512 y1_513 y1_514			{
	qui gen shbybin1_`var' = sbybin1_`var'/sbybin1_y1_51*100
	qui gen shbybin2_`var' = sbybin2_`var'/sbybin2_y1_51*100
	qui gen shbybin3_`var' = sbybin3_`var'/sbybin3_y1_51*100
	qui gen sh_`var'	   = s_`var'/s_y1_51*100
}

	
* GENERATE ENTRY TO THE TABLE
foreach xwave in 1989 1991 1993 1997 2000 2004 2006 2009  {
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
foreach xwave in 1989 1991 1993 1997 2000 2004 2006 2009  {
	forvalues urb=0/1 {
		foreach var in c0_1 c0_11 c0_12 c0_13 c0_14 c0_2 c0_3 c0_4 c0_5 c0_6 c0_7 y1_1 y1_2 y1_3 y1_4 y1_5 y1_51 y1_511 y1_512 y1_513 y1_514 y1_52	{
			sum sh_`var' if interview_year == `xwave' & urban == `urb'
			local sh_`var'_`urb'_`xwave' =string(r(mean),"%10.1f")
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

	* RURAL 1989
	cap file close _all
	file open ofile using "Tables\table2_1989r_d.tex", write replace	
	file write ofile "\begin{tabular}{l c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"&\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"& 0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{13}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `mc_bin1_1989_0_1'  & `mc_bin1_1989_0_2'  & `mc_bin1_1989_0_3'  & `mc_bin2_1989_0_1'  & `mc_bin2_1989_0_2'  & `mc_bin2_1989_0_3'  & `mc_bin2_1989_0_4'  & `mc_bin2_1989_0_5'  & `mc_bin3_1989_0_1'  & `mc_bin3_1989_0_2'  & `mc_bin3_1989_0_3'  & `mc_0_1989' \\"  _n ///
	"Earnings 	  & `my0_bin1_1989_0_1' & `my0_bin1_1989_0_2' & `my0_bin1_1989_0_3' & `my0_bin2_1989_0_1' & `my0_bin2_1989_0_2' & `my0_bin2_1989_0_3' & `my0_bin2_1989_0_4' & `my0_bin2_1989_0_5' & `my0_bin3_1989_0_1' & `my0_bin3_1989_0_2' & `my0_bin3_1989_0_3' & `my0_0_1989' \\"  _n ///
	"Disp. Income & `my1_bin1_1989_0_1' & `my1_bin1_1989_0_2' & `my1_bin1_1989_0_3' & `my1_bin2_1989_0_1' & `my1_bin2_1989_0_2' & `my1_bin2_1989_0_3' & `my1_bin2_1989_0_4' & `my1_bin2_1989_0_5' & `my1_bin3_1989_0_1' & `my1_bin3_1989_0_2' & `my1_bin3_1989_0_3' & `my1_0_1989' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `shbybin1_c_0_1989_1'   & `shbybin1_c_0_1989_2'   & `shbybin1_c_0_1989_3'   & `shbybin2_c_0_1989_1'   & `shbybin2_c_0_1989_2'   & `shbybin2_c_0_1989_3'   & `shbybin2_c_0_1989_4'   & `shbybin2_c_0_1989_5'   & `shbybin3_c_0_1989_1'   & `shbybin3_c_0_1989_2'   & `shbybin3_c_0_1989_3'   & 100 \\"  _n ///
	"Earnings 	  & `shbybin1_y0_0_1989_1'  & `shbybin1_y0_0_1989_2'  & `shbybin1_y0_0_1989_3'  & `shbybin2_y0_0_1989_1'  & `shbybin2_y0_0_1989_2'  & `shbybin2_y0_0_1989_3'  & `shbybin2_y0_0_1989_4'  & `shbybin2_y0_0_1989_5'  & `shbybin3_y0_0_1989_1'  & `shbybin3_y0_0_1989_2'  & `shbybin3_y0_0_1989_3'  & 100 \\"  _n ///
	"Disp. Income & `shbybin1_y1_0_1989_1'  & `shbybin1_y1_0_1989_2'  & `shbybin1_y1_0_1989_3'  & `shbybin2_y1_0_1989_1'  & `shbybin2_y1_0_1989_2'  & `shbybin2_y1_0_1989_3'  & `shbybin2_y1_0_1989_4'  & `shbybin2_y1_0_1989_5'  & `shbybin3_y1_0_1989_1'  & `shbybin3_y1_0_1989_2'  & `shbybin3_y1_0_1989_3'  & 100 \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"Food (Diet)  & `shbybin1_c0_1_0_1989_1' & `shbybin1_c0_1_0_1989_2' & `shbybin1_c0_1_0_1989_3' & `shbybin2_c0_1_0_1989_1' & `shbybin2_c0_1_0_1989_2' & `shbybin2_c0_1_0_1989_3' & `shbybin2_c0_1_0_1989_4' & `shbybin2_c0_1_0_1989_5' & `shbybin3_c0_1_0_1989_1' & `shbybin3_c0_1_0_1989_2' & `shbybin3_c0_1_0_1989_3' & `sh_c0_1_0_1989' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Own prod.  & `shbybin1_c0_11_0_1989_1' & `shbybin1_c0_11_0_1989_2' & `shbybin1_c0_11_0_1989_3' & `shbybin2_c0_11_0_1989_1' & `shbybin2_c0_11_0_1989_2' & `shbybin2_c0_11_0_1989_3' & `shbybin2_c0_11_0_1989_4' & `shbybin2_c0_11_0_1989_5' & `shbybin3_c0_11_0_1989_1' & `shbybin3_c0_11_0_1989_2' & `shbybin3_c0_11_0_1989_3' & `sh_c0_11_0_1989' \\" _n  ///
	"\hspace{.3cm} Coupons    & `shbybin1_c0_12_0_1989_1' & `shbybin1_c0_12_0_1989_2' & `shbybin1_c0_12_0_1989_3' & `shbybin2_c0_12_0_1989_1' & `shbybin2_c0_12_0_1989_2' & `shbybin2_c0_12_0_1989_3' & `shbybin2_c0_12_0_1989_4' & `shbybin2_c0_12_0_1989_5' & `shbybin3_c0_12_0_1989_1' & `shbybin3_c0_12_0_1989_2' & `shbybin3_c0_12_0_1989_3' & `sh_c0_12_0_1989' \\" _n  ///
	"\hspace{.3cm} Gifts	  & `shbybin1_c0_13_0_1989_1' & `shbybin1_c0_13_0_1989_2' & `shbybin1_c0_13_0_1989_3' & `shbybin2_c0_13_0_1989_1' & `shbybin2_c0_13_0_1989_2' & `shbybin2_c0_13_0_1989_3' & `shbybin2_c0_13_0_1989_4' & `shbybin2_c0_13_0_1989_5' & `shbybin3_c0_13_0_1989_1' & `shbybin3_c0_13_0_1989_2' & `shbybin3_c0_13_0_1989_3' & `sh_c0_13_0_1989' \\" _n  ///
	"\hspace{.3cm} Expenditures  & `shbybin1_c0_14_0_1989_1' & `shbybin1_c0_14_0_1989_2' & `shbybin1_c0_14_0_1989_3' & `shbybin2_c0_14_0_1989_1' & `shbybin2_c0_14_0_1989_2' & `shbybin2_c0_14_0_1989_3' & `shbybin2_c0_14_0_1989_4' & `shbybin2_c0_14_0_1989_5' & `shbybin3_c0_14_0_1989_1' & `shbybin3_c0_14_0_1989_2' & `shbybin3_c0_14_0_1989_3' & `sh_c0_14_0_1989' \\" _n  ///
	"Utilities    & `shbybin1_c0_2_0_1989_1' & `shbybin1_c0_2_0_1989_2' & `shbybin1_c0_2_0_1989_3' & `shbybin2_c0_2_0_1989_1' & `shbybin2_c0_2_0_1989_2' & `shbybin2_c0_2_0_1989_3' & `shbybin2_c0_2_0_1989_4' & `shbybin2_c0_2_0_1989_5' & `shbybin3_c0_2_0_1989_1' & `shbybin3_c0_2_0_1989_2' & `shbybin3_c0_2_0_1989_3' & `sh_c0_2_0_1989' \\" _n  ///
	"Housing Services  & `shbybin1_c0_3_0_1989_1' & `shbybin1_c0_3_0_1989_2' & `shbybin1_c0_3_0_1989_3' & `shbybin2_c0_3_0_1989_1' & `shbybin2_c0_3_0_1989_2' & `shbybin2_c0_3_0_1989_3' & `shbybin2_c0_3_0_1989_4' & `shbybin2_c0_3_0_1989_5' & `shbybin3_c0_3_0_1989_1' & `shbybin3_c0_3_0_1989_2' & `shbybin3_c0_3_0_1989_3' & `sh_c0_3_0_1989' \\" _n  ///
	"Child Care   & `shbybin1_c0_4_0_1989_1' & `shbybin1_c0_4_0_1989_2' & `shbybin1_c0_4_0_1989_3' & `shbybin2_c0_4_0_1989_1' & `shbybin2_c0_4_0_1989_2' & `shbybin2_c0_4_0_1989_3' & `shbybin2_c0_4_0_1989_4' & `shbybin2_c0_4_0_1989_5' & `shbybin3_c0_4_0_1989_1' & `shbybin3_c0_4_0_1989_2' & `shbybin3_c0_4_0_1989_3' & `sh_c0_4_0_1989' \\" _n  ///
	"Health Services    & `shbybin1_c0_5_0_1989_1' & `shbybin1_c0_5_0_1989_2' & `shbybin1_c0_5_0_1989_3' & `shbybin2_c0_5_0_1989_1' & `shbybin2_c0_5_0_1989_2' & `shbybin2_c0_5_0_1989_3' & `shbybin2_c0_5_0_1989_4' & `shbybin2_c0_5_0_1989_5' & `shbybin3_c0_5_0_1989_1' & `shbybin3_c0_5_0_1989_2' & `shbybin3_c0_5_0_1989_3' & `sh_c0_5_0_1989' \\" _n  ///
	"Education   & `shbybin1_c0_6_0_1989_1' & `shbybin1_c0_6_0_1989_2' & `shbybin1_c0_6_0_1989_3' & `shbybin2_c0_6_0_1989_1' & `shbybin2_c0_6_0_1989_2' & `shbybin2_c0_6_0_1989_3' & `shbybin2_c0_6_0_1989_4' & `shbybin2_c0_6_0_1989_5' & `shbybin3_c0_6_0_1989_1' & `shbybin3_c0_6_0_1989_2' & `shbybin3_c0_6_0_1989_3' & `sh_c0_6_0_1989' \\" _n  ///
	"Semi Durables 	   & `shbybin1_c0_7_0_1989_1' & `shbybin1_c0_7_0_1989_2' & `shbybin1_c0_7_0_1989_3' & `shbybin2_c0_7_0_1989_1' & `shbybin2_c0_7_0_1989_2' & `shbybin2_c0_7_0_1989_3' & `shbybin2_c0_7_0_1989_4' & `shbybin2_c0_7_0_1989_5' & `shbybin3_c0_7_0_1989_1' & `shbybin3_c0_7_0_1989_2' & `shbybin3_c0_7_0_1989_3' & `sh_c0_7_0_1989' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"Labor        & `shbybin1_y1_1_0_1989_1' & `shbybin1_y1_1_0_1989_2' & `shbybin1_y1_1_0_1989_3' & `shbybin2_y1_1_0_1989_1' & `shbybin2_y1_1_0_1989_2' & `shbybin2_y1_1_0_1989_3' & `shbybin2_y1_1_0_1989_4' & `shbybin2_y1_1_0_1989_5' & `shbybin3_y1_1_0_1989_1' & `shbybin3_y1_1_0_1989_2' & `shbybin3_y1_1_0_1989_3' & `sh_y1_1_0_1989' \\" _n  ///
	"Agriculture  & `shbybin1_y1_2_0_1989_1' & `shbybin1_y1_2_0_1989_2' & `shbybin1_y1_2_0_1989_3' & `shbybin2_y1_2_0_1989_1' & `shbybin2_y1_2_0_1989_2' & `shbybin2_y1_2_0_1989_3' & `shbybin2_y1_2_0_1989_4' & `shbybin2_y1_2_0_1989_5' & `shbybin3_y1_2_0_1989_1' & `shbybin3_y1_2_0_1989_2' & `shbybin3_y1_2_0_1989_3' & `sh_y1_2_0_1989' \\" _n  ///
	"Business     & `shbybin1_y1_3_0_1989_1' & `shbybin1_y1_3_0_1989_2' & `shbybin1_y1_3_0_1989_3' & `shbybin2_y1_3_0_1989_1' & `shbybin2_y1_3_0_1989_2' & `shbybin2_y1_3_0_1989_3' & `shbybin2_y1_3_0_1989_4' & `shbybin2_y1_3_0_1989_5' & `shbybin3_y1_3_0_1989_1' & `shbybin3_y1_3_0_1989_2' & `shbybin3_y1_3_0_1989_3' & `sh_y1_3_0_1989' \\" _n  ///
	"Capital      & `shbybin1_y1_4_0_1989_1' & `shbybin1_y1_4_0_1989_2' & `shbybin1_y1_4_0_1989_3' & `shbybin2_y1_4_0_1989_1' & `shbybin2_y1_4_0_1989_2' & `shbybin2_y1_4_0_1989_3' & `shbybin2_y1_4_0_1989_4' & `shbybin2_y1_4_0_1989_5' & `shbybin3_y1_4_0_1989_1' & `shbybin3_y1_4_0_1989_2' & `shbybin3_y1_4_0_1989_3' & `sh_y1_4_0_1989' \\" _n  ///
	"Transfers Rec.  & `shbybin1_y1_5_0_1989_1' & `shbybin1_y1_5_0_1989_2' & `shbybin1_y1_5_0_1989_3' & `shbybin2_y1_5_0_1989_1' & `shbybin2_y1_5_0_1989_2' & `shbybin2_y1_5_0_1989_3' & `shbybin2_y1_5_0_1989_4' & `shbybin2_y1_5_0_1989_5' & `shbybin3_y1_5_0_1989_1' & `shbybin3_y1_5_0_1989_2' & `shbybin3_y1_5_0_1989_3' & `sh_y1_5_0_1989' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"Public Trans. Rec.  & `shbybin1_y1_51_0_1989_1' & `shbybin1_y1_51_0_1989_2' & `shbybin1_y1_51_0_1989_3' & `shbybin2_y1_51_0_1989_1' & `shbybin2_y1_51_0_1989_2' & `shbybin2_y1_51_0_1989_3' & `shbybin2_y1_51_0_1989_4' & `shbybin2_y1_51_0_1989_5' & `shbybin3_y1_51_0_1989_1' & `shbybin3_y1_51_0_1989_2' & `shbybin3_y1_51_0_1989_3' & `sh_y1_51_0_1989' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Food Coupons    & `shbybin1_y1_511_0_1989_1' & `shbybin1_y1_511_0_1989_2' & `shbybin1_y1_511_0_1989_3' & `shbybin2_y1_511_0_1989_1' & `shbybin2_y1_511_0_1989_2' & `shbybin2_y1_511_0_1989_3' & `shbybin2_y1_511_0_1989_4' & `shbybin2_y1_511_0_1989_5' & `shbybin3_y1_511_0_1989_1' & `shbybin3_y1_511_0_1989_2' & `shbybin3_y1_511_0_1989_3' & `sh_y1_511_0_1989' \\" _n  ///
	"\hspace{.3cm} Sub. Work Unit  & `shbybin1_y1_512_0_1989_1' & `shbybin1_y1_512_0_1989_2' & `shbybin1_y1_512_0_1989_3' & `shbybin2_y1_512_0_1989_1' & `shbybin2_y1_512_0_1989_2' & `shbybin2_y1_512_0_1989_3' & `shbybin2_y1_512_0_1989_4' & `shbybin2_y1_512_0_1989_5' & `shbybin3_y1_512_0_1989_1' & `shbybin3_y1_512_0_1989_2' & `shbybin3_y1_512_0_1989_3' & `sh_y1_512_0_1989' \\" _n  ///
	"\hspace{.3cm} Sub. Gov.       & `shbybin1_y1_513_0_1989_1' & `shbybin1_y1_513_0_1989_2' & `shbybin1_y1_513_0_1989_3' & `shbybin2_y1_513_0_1989_1' & `shbybin2_y1_513_0_1989_2' & `shbybin2_y1_513_0_1989_3' & `shbybin2_y1_513_0_1989_4' & `shbybin2_y1_513_0_1989_5' & `shbybin3_y1_513_0_1989_1' & `shbybin3_y1_513_0_1989_2' & `shbybin3_y1_513_0_1989_3' & `sh_y1_513_0_1989' \\" _n  ///
	"\hspace{.3cm} Pension         & `shbybin1_y1_514_0_1989_1' & `shbybin1_y1_514_0_1989_2' & `shbybin1_y1_514_0_1989_3' & `shbybin2_y1_514_0_1989_1' & `shbybin2_y1_514_0_1989_2' & `shbybin2_y1_514_0_1989_3' & `shbybin2_y1_514_0_1989_4' & `shbybin2_y1_514_0_1989_5' & `shbybin3_y1_514_0_1989_1' & `shbybin3_y1_514_0_1989_2' & `shbybin3_y1_514_0_1989_3' & `sh_y1_514_0_1989' \\" _n  ///
	"Private Trans. Rec. & `shbybin1_y1_52_0_1989_1' & `shbybin1_y1_52_0_1989_2' & `shbybin1_y1_52_0_1989_3' & `shbybin2_y1_52_0_1989_1' & `shbybin2_y1_52_0_1989_2' & `shbybin2_y1_52_0_1989_3' & `shbybin2_y1_52_0_1989_4' & `shbybin2_y1_52_0_1989_5' & `shbybin3_y1_52_0_1989_1' & `shbybin3_y1_52_0_1989_2' & `shbybin3_y1_52_0_1989_3' & `sh_y1_52_0_1989' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* URBAN 1989
	cap file close _all
	file open ofile using "Tables\table2_1989u_d.tex", write replace	
	file write ofile "\begin{tabular}{c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{12}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"`mc_bin1_1989_1_1'  & `mc_bin1_1989_1_2'  & `mc_bin1_1989_1_3'  & `mc_bin2_1989_1_1'  & `mc_bin2_1989_1_2'  & `mc_bin2_1989_1_3'  & `mc_bin2_1989_1_4'  & `mc_bin2_1989_1_5'  & `mc_bin3_1989_1_1'  & `mc_bin3_1989_1_2'  & `mc_bin3_1989_1_3'  & `mc_1_1989' \\"  _n ///
	"`my0_bin1_1989_1_1' & `my0_bin1_1989_1_2' & `my0_bin1_1989_1_3' & `my0_bin2_1989_1_1' & `my0_bin2_1989_1_2' & `my0_bin2_1989_1_3' & `my0_bin2_1989_1_4' & `my0_bin2_1989_1_5' & `my0_bin3_1989_1_1' & `my0_bin3_1989_1_2' & `my0_bin3_1989_1_3' & `my0_1_1989' \\"  _n ///
	"`my1_bin1_1989_1_1' & `my1_bin1_1989_1_2' & `my1_bin1_1989_1_3' & `my1_bin2_1989_1_1' & `my1_bin2_1989_1_2' & `my1_bin2_1989_1_3' & `my1_bin2_1989_1_4' & `my1_bin2_1989_1_5' & `my1_bin3_1989_1_1' & `my1_bin3_1989_1_2' & `my1_bin3_1989_1_3' & `my1_1_1989' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"`shbybin1_c_1_1989_1'   & `shbybin1_c_1_1989_2'   & `shbybin1_c_1_1989_3'   & `shbybin2_c_1_1989_1'   & `shbybin2_c_1_1989_2'   & `shbybin2_c_1_1989_3'   & `shbybin2_c_1_1989_4'   & `shbybin2_c_1_1989_5'   & `shbybin3_c_1_1989_1'   & `shbybin3_c_1_1989_2'   & `shbybin3_c_1_1989_3'   & 100 \\"  _n ///
	"`shbybin1_y0_1_1989_1'  & `shbybin1_y0_1_1989_2'  & `shbybin1_y0_1_1989_3'  & `shbybin2_y0_1_1989_1'  & `shbybin2_y0_1_1989_2'  & `shbybin2_y0_1_1989_3'  & `shbybin2_y0_1_1989_4'  & `shbybin2_y0_1_1989_5'  & `shbybin3_y0_1_1989_1'  & `shbybin3_y0_1_1989_2'  & `shbybin3_y0_1_1989_3'  & 100 \\"  _n ///
	"`shbybin1_y1_1_1989_1'  & `shbybin1_y1_1_1989_2'  & `shbybin1_y1_1_1989_3'  & `shbybin2_y1_1_1989_1'  & `shbybin2_y1_1_1989_2'  & `shbybin2_y1_1_1989_3'  & `shbybin2_y1_1_1989_4'  & `shbybin2_y1_1_1989_5'  & `shbybin3_y1_1_1989_1'  & `shbybin3_y1_1_1989_2'  & `shbybin3_y1_1_1989_3'  & 100 \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"`shbybin1_c0_1_1_1989_1' & `shbybin1_c0_1_1_1989_2' & `shbybin1_c0_1_1_1989_3' & `shbybin2_c0_1_1_1989_1' & `shbybin2_c0_1_1_1989_2' & `shbybin2_c0_1_1_1989_3' & `shbybin2_c0_1_1_1989_4' & `shbybin2_c0_1_1_1989_5' & `shbybin3_c0_1_1_1989_1' & `shbybin3_c0_1_1_1989_2' & `shbybin3_c0_1_1_1989_3' & `sh_c0_1_1_1989' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_c0_11_1_1989_1' & `shbybin1_c0_11_1_1989_2' & `shbybin1_c0_11_1_1989_3' & `shbybin2_c0_11_1_1989_1' & `shbybin2_c0_11_1_1989_2' & `shbybin2_c0_11_1_1989_3' & `shbybin2_c0_11_1_1989_4' & `shbybin2_c0_11_1_1989_5' & `shbybin3_c0_11_1_1989_1' & `shbybin3_c0_11_1_1989_2' & `shbybin3_c0_11_1_1989_3' & `sh_c0_11_1_1989' \\" _n  ///
	"`shbybin1_c0_12_1_1989_1' & `shbybin1_c0_12_1_1989_2' & `shbybin1_c0_12_1_1989_3' & `shbybin2_c0_12_1_1989_1' & `shbybin2_c0_12_1_1989_2' & `shbybin2_c0_12_1_1989_3' & `shbybin2_c0_12_1_1989_4' & `shbybin2_c0_12_1_1989_5' & `shbybin3_c0_12_1_1989_1' & `shbybin3_c0_12_1_1989_2' & `shbybin3_c0_12_1_1989_3' & `sh_c0_12_1_1989' \\" _n  ///
	"`shbybin1_c0_13_1_1989_1' & `shbybin1_c0_13_1_1989_2' & `shbybin1_c0_13_1_1989_3' & `shbybin2_c0_13_1_1989_1' & `shbybin2_c0_13_1_1989_2' & `shbybin2_c0_13_1_1989_3' & `shbybin2_c0_13_1_1989_4' & `shbybin2_c0_13_1_1989_5' & `shbybin3_c0_13_1_1989_1' & `shbybin3_c0_13_1_1989_2' & `shbybin3_c0_13_1_1989_3' & `sh_c0_13_1_1989' \\" _n  ///
	"`shbybin1_c0_14_1_1989_1' & `shbybin1_c0_14_1_1989_2' & `shbybin1_c0_14_1_1989_3' & `shbybin2_c0_14_1_1989_1' & `shbybin2_c0_14_1_1989_2' & `shbybin2_c0_14_1_1989_3' & `shbybin2_c0_14_1_1989_4' & `shbybin2_c0_14_1_1989_5' & `shbybin3_c0_14_1_1989_1' & `shbybin3_c0_14_1_1989_2' & `shbybin3_c0_14_1_1989_3' & `sh_c0_14_1_1989' \\" _n  ///
	"`shbybin1_c0_2_1_1989_1' & `shbybin1_c0_2_1_1989_2' & `shbybin1_c0_2_1_1989_3' & `shbybin2_c0_2_1_1989_1' & `shbybin2_c0_2_1_1989_2' & `shbybin2_c0_2_1_1989_3' & `shbybin2_c0_2_1_1989_4' & `shbybin2_c0_2_1_1989_5' & `shbybin3_c0_2_1_1989_1' & `shbybin3_c0_2_1_1989_2' & `shbybin3_c0_2_1_1989_3' & `sh_c0_2_1_1989' \\" _n  ///
	"`shbybin1_c0_3_1_1989_1' & `shbybin1_c0_3_1_1989_2' & `shbybin1_c0_3_1_1989_3' & `shbybin2_c0_3_1_1989_1' & `shbybin2_c0_3_1_1989_2' & `shbybin2_c0_3_1_1989_3' & `shbybin2_c0_3_1_1989_4' & `shbybin2_c0_3_1_1989_5' & `shbybin3_c0_3_1_1989_1' & `shbybin3_c0_3_1_1989_2' & `shbybin3_c0_3_1_1989_3' & `sh_c0_3_1_1989' \\" _n  ///
	"`shbybin1_c0_4_1_1989_1' & `shbybin1_c0_4_1_1989_2' & `shbybin1_c0_4_1_1989_3' & `shbybin2_c0_4_1_1989_1' & `shbybin2_c0_4_1_1989_2' & `shbybin2_c0_4_1_1989_3' & `shbybin2_c0_4_1_1989_4' & `shbybin2_c0_4_1_1989_5' & `shbybin3_c0_4_1_1989_1' & `shbybin3_c0_4_1_1989_2' & `shbybin3_c0_4_1_1989_3' & `sh_c0_4_1_1989' \\" _n  ///
	"`shbybin1_c0_5_1_1989_1' & `shbybin1_c0_5_1_1989_2' & `shbybin1_c0_5_1_1989_3' & `shbybin2_c0_5_1_1989_1' & `shbybin2_c0_5_1_1989_2' & `shbybin2_c0_5_1_1989_3' & `shbybin2_c0_5_1_1989_4' & `shbybin2_c0_5_1_1989_5' & `shbybin3_c0_5_1_1989_1' & `shbybin3_c0_5_1_1989_2' & `shbybin3_c0_5_1_1989_3' & `sh_c0_5_1_1989' \\" _n  ///
	"`shbybin1_c0_6_1_1989_1' & `shbybin1_c0_6_1_1989_2' & `shbybin1_c0_6_1_1989_3' & `shbybin2_c0_6_1_1989_1' & `shbybin2_c0_6_1_1989_2' & `shbybin2_c0_6_1_1989_3' & `shbybin2_c0_6_1_1989_4' & `shbybin2_c0_6_1_1989_5' & `shbybin3_c0_6_1_1989_1' & `shbybin3_c0_6_1_1989_2' & `shbybin3_c0_6_1_1989_3' & `sh_c0_6_1_1989' \\" _n  ///
	"`shbybin1_c0_7_1_1989_1' & `shbybin1_c0_7_1_1989_2' & `shbybin1_c0_7_1_1989_3' & `shbybin2_c0_7_1_1989_1' & `shbybin2_c0_7_1_1989_2' & `shbybin2_c0_7_1_1989_3' & `shbybin2_c0_7_1_1989_4' & `shbybin2_c0_7_1_1989_5' & `shbybin3_c0_7_1_1989_1' & `shbybin3_c0_7_1_1989_2' & `shbybin3_c0_7_1_1989_3' & `sh_c0_7_1_1989' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_1_1_1989_1' & `shbybin1_y1_1_1_1989_2' & `shbybin1_y1_1_1_1989_3' & `shbybin2_y1_1_1_1989_1' & `shbybin2_y1_1_1_1989_2' & `shbybin2_y1_1_1_1989_3' & `shbybin2_y1_1_1_1989_4' & `shbybin2_y1_1_1_1989_5' & `shbybin3_y1_1_1_1989_1' & `shbybin3_y1_1_1_1989_2' & `shbybin3_y1_1_1_1989_3' & `sh_y1_1_1_1989' \\" _n  ///
	"`shbybin1_y1_2_1_1989_1' & `shbybin1_y1_2_1_1989_2' & `shbybin1_y1_2_1_1989_3' & `shbybin2_y1_2_1_1989_1' & `shbybin2_y1_2_1_1989_2' & `shbybin2_y1_2_1_1989_3' & `shbybin2_y1_2_1_1989_4' & `shbybin2_y1_2_1_1989_5' & `shbybin3_y1_2_1_1989_1' & `shbybin3_y1_2_1_1989_2' & `shbybin3_y1_2_1_1989_3' & `sh_y1_2_1_1989' \\" _n  ///
	"`shbybin1_y1_3_1_1989_1' & `shbybin1_y1_3_1_1989_2' & `shbybin1_y1_3_1_1989_3' & `shbybin2_y1_3_1_1989_1' & `shbybin2_y1_3_1_1989_2' & `shbybin2_y1_3_1_1989_3' & `shbybin2_y1_3_1_1989_4' & `shbybin2_y1_3_1_1989_5' & `shbybin3_y1_3_1_1989_1' & `shbybin3_y1_3_1_1989_2' & `shbybin3_y1_3_1_1989_3' & `sh_y1_3_1_1989' \\" _n  ///
	"`shbybin1_y1_4_1_1989_1' & `shbybin1_y1_4_1_1989_2' & `shbybin1_y1_4_1_1989_3' & `shbybin2_y1_4_1_1989_1' & `shbybin2_y1_4_1_1989_2' & `shbybin2_y1_4_1_1989_3' & `shbybin2_y1_4_1_1989_4' & `shbybin2_y1_4_1_1989_5' & `shbybin3_y1_4_1_1989_1' & `shbybin3_y1_4_1_1989_2' & `shbybin3_y1_4_1_1989_3' & `sh_y1_4_1_1989' \\" _n  ///
	"`shbybin1_y1_5_1_1989_1' & `shbybin1_y1_5_1_1989_2' & `shbybin1_y1_5_1_1989_3' & `shbybin2_y1_5_1_1989_1' & `shbybin2_y1_5_1_1989_2' & `shbybin2_y1_5_1_1989_3' & `shbybin2_y1_5_1_1989_4' & `shbybin2_y1_5_1_1989_5' & `shbybin3_y1_5_1_1989_1' & `shbybin3_y1_5_1_1989_2' & `shbybin3_y1_5_1_1989_3' & `sh_y1_5_1_1989' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_51_1_1989_1' & `shbybin1_y1_51_1_1989_2' & `shbybin1_y1_51_1_1989_3' & `shbybin2_y1_51_1_1989_1' & `shbybin2_y1_51_1_1989_2' & `shbybin2_y1_51_1_1989_3' & `shbybin2_y1_51_1_1989_4' & `shbybin2_y1_51_1_1989_5' & `shbybin3_y1_51_1_1989_1' & `shbybin3_y1_51_1_1989_2' & `shbybin3_y1_51_1_1989_3' & `sh_y1_51_1_1989' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_y1_511_1_1989_1' & `shbybin1_y1_511_1_1989_2' & `shbybin1_y1_511_1_1989_3' & `shbybin2_y1_511_1_1989_1' & `shbybin2_y1_511_1_1989_2' & `shbybin2_y1_511_1_1989_3' & `shbybin2_y1_511_1_1989_4' & `shbybin2_y1_511_1_1989_5' & `shbybin3_y1_511_1_1989_1' & `shbybin3_y1_511_1_1989_2' & `shbybin3_y1_511_1_1989_3' & `sh_y1_511_1_1989' \\" _n  ///
	"`shbybin1_y1_512_1_1989_1' & `shbybin1_y1_512_1_1989_2' & `shbybin1_y1_512_1_1989_3' & `shbybin2_y1_512_1_1989_1' & `shbybin2_y1_512_1_1989_2' & `shbybin2_y1_512_1_1989_3' & `shbybin2_y1_512_1_1989_4' & `shbybin2_y1_512_1_1989_5' & `shbybin3_y1_512_1_1989_1' & `shbybin3_y1_512_1_1989_2' & `shbybin3_y1_512_1_1989_3' & `sh_y1_512_1_1989' \\" _n  ///
	"`shbybin1_y1_513_1_1989_1' & `shbybin1_y1_513_1_1989_2' & `shbybin1_y1_513_1_1989_3' & `shbybin2_y1_513_1_1989_1' & `shbybin2_y1_513_1_1989_2' & `shbybin2_y1_513_1_1989_3' & `shbybin2_y1_513_1_1989_4' & `shbybin2_y1_513_1_1989_5' & `shbybin3_y1_513_1_1989_1' & `shbybin3_y1_513_1_1989_2' & `shbybin3_y1_513_1_1989_3' & `sh_y1_513_1_1989' \\" _n  ///
	"`shbybin1_y1_514_1_1989_1' & `shbybin1_y1_514_1_1989_2' & `shbybin1_y1_514_1_1989_3' & `shbybin2_y1_514_1_1989_1' & `shbybin2_y1_514_1_1989_2' & `shbybin2_y1_514_1_1989_3' & `shbybin2_y1_514_1_1989_4' & `shbybin2_y1_514_1_1989_5' & `shbybin3_y1_514_1_1989_1' & `shbybin3_y1_514_1_1989_2' & `shbybin3_y1_514_1_1989_3' & `sh_y1_514_1_1989' \\" _n  ///
	"`shbybin1_y1_52_1_1989_1' & `shbybin1_y1_52_1_1989_2' & `shbybin1_y1_52_1_1989_3' & `shbybin2_y1_52_1_1989_1' & `shbybin2_y1_52_1_1989_2' & `shbybin2_y1_52_1_1989_3' & `shbybin2_y1_52_1_1989_4' & `shbybin2_y1_52_1_1989_5' & `shbybin3_y1_52_1_1989_1' & `shbybin3_y1_52_1_1989_2' & `shbybin3_y1_52_1_1989_3' & `sh_y1_52_1_1989' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* RURAL 1991
	cap file close _all
	file open ofile using "Tables\table2_1991r_d.tex", write replace	
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
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"Food (Diet)  & `shbybin1_c0_1_0_1991_1' & `shbybin1_c0_1_0_1991_2' & `shbybin1_c0_1_0_1991_3' & `shbybin2_c0_1_0_1991_1' & `shbybin2_c0_1_0_1991_2' & `shbybin2_c0_1_0_1991_3' & `shbybin2_c0_1_0_1991_4' & `shbybin2_c0_1_0_1991_5' & `shbybin3_c0_1_0_1991_1' & `shbybin3_c0_1_0_1991_2' & `shbybin3_c0_1_0_1991_3' & `sh_c0_1_0_1991' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Own prod.  & `shbybin1_c0_11_0_1991_1' & `shbybin1_c0_11_0_1991_2' & `shbybin1_c0_11_0_1991_3' & `shbybin2_c0_11_0_1991_1' & `shbybin2_c0_11_0_1991_2' & `shbybin2_c0_11_0_1991_3' & `shbybin2_c0_11_0_1991_4' & `shbybin2_c0_11_0_1991_5' & `shbybin3_c0_11_0_1991_1' & `shbybin3_c0_11_0_1991_2' & `shbybin3_c0_11_0_1991_3' & `sh_c0_11_0_1991' \\" _n  ///
	"\hspace{.3cm} Coupons    & `shbybin1_c0_12_0_1991_1' & `shbybin1_c0_12_0_1991_2' & `shbybin1_c0_12_0_1991_3' & `shbybin2_c0_12_0_1991_1' & `shbybin2_c0_12_0_1991_2' & `shbybin2_c0_12_0_1991_3' & `shbybin2_c0_12_0_1991_4' & `shbybin2_c0_12_0_1991_5' & `shbybin3_c0_12_0_1991_1' & `shbybin3_c0_12_0_1991_2' & `shbybin3_c0_12_0_1991_3' & `sh_c0_12_0_1991' \\" _n  ///
	"\hspace{.3cm} Gifts	  & `shbybin1_c0_13_0_1991_1' & `shbybin1_c0_13_0_1991_2' & `shbybin1_c0_13_0_1991_3' & `shbybin2_c0_13_0_1991_1' & `shbybin2_c0_13_0_1991_2' & `shbybin2_c0_13_0_1991_3' & `shbybin2_c0_13_0_1991_4' & `shbybin2_c0_13_0_1991_5' & `shbybin3_c0_13_0_1991_1' & `shbybin3_c0_13_0_1991_2' & `shbybin3_c0_13_0_1991_3' & `sh_c0_13_0_1991' \\" _n  ///
	"\hspace{.3cm} Expenditures  & `shbybin1_c0_14_0_1991_1' & `shbybin1_c0_14_0_1991_2' & `shbybin1_c0_14_0_1991_3' & `shbybin2_c0_14_0_1991_1' & `shbybin2_c0_14_0_1991_2' & `shbybin2_c0_14_0_1991_3' & `shbybin2_c0_14_0_1991_4' & `shbybin2_c0_14_0_1991_5' & `shbybin3_c0_14_0_1991_1' & `shbybin3_c0_14_0_1991_2' & `shbybin3_c0_14_0_1991_3' & `sh_c0_14_0_1991' \\" _n  ///
	"Utilities    & `shbybin1_c0_2_0_1991_1' & `shbybin1_c0_2_0_1991_2' & `shbybin1_c0_2_0_1991_3' & `shbybin2_c0_2_0_1991_1' & `shbybin2_c0_2_0_1991_2' & `shbybin2_c0_2_0_1991_3' & `shbybin2_c0_2_0_1991_4' & `shbybin2_c0_2_0_1991_5' & `shbybin3_c0_2_0_1991_1' & `shbybin3_c0_2_0_1991_2' & `shbybin3_c0_2_0_1991_3' & `sh_c0_2_0_1991' \\" _n  ///
	"Housing Services  & `shbybin1_c0_3_0_1991_1' & `shbybin1_c0_3_0_1991_2' & `shbybin1_c0_3_0_1991_3' & `shbybin2_c0_3_0_1991_1' & `shbybin2_c0_3_0_1991_2' & `shbybin2_c0_3_0_1991_3' & `shbybin2_c0_3_0_1991_4' & `shbybin2_c0_3_0_1991_5' & `shbybin3_c0_3_0_1991_1' & `shbybin3_c0_3_0_1991_2' & `shbybin3_c0_3_0_1991_3' & `sh_c0_3_0_1991' \\" _n  ///
	"Child Care   & `shbybin1_c0_4_0_1991_1' & `shbybin1_c0_4_0_1991_2' & `shbybin1_c0_4_0_1991_3' & `shbybin2_c0_4_0_1991_1' & `shbybin2_c0_4_0_1991_2' & `shbybin2_c0_4_0_1991_3' & `shbybin2_c0_4_0_1991_4' & `shbybin2_c0_4_0_1991_5' & `shbybin3_c0_4_0_1991_1' & `shbybin3_c0_4_0_1991_2' & `shbybin3_c0_4_0_1991_3' & `sh_c0_4_0_1991' \\" _n  ///
	"Health Services    & `shbybin1_c0_5_0_1991_1' & `shbybin1_c0_5_0_1991_2' & `shbybin1_c0_5_0_1991_3' & `shbybin2_c0_5_0_1991_1' & `shbybin2_c0_5_0_1991_2' & `shbybin2_c0_5_0_1991_3' & `shbybin2_c0_5_0_1991_4' & `shbybin2_c0_5_0_1991_5' & `shbybin3_c0_5_0_1991_1' & `shbybin3_c0_5_0_1991_2' & `shbybin3_c0_5_0_1991_3' & `sh_c0_5_0_1991' \\" _n  ///
	"Education   & `shbybin1_c0_6_0_1991_1' & `shbybin1_c0_6_0_1991_2' & `shbybin1_c0_6_0_1991_3' & `shbybin2_c0_6_0_1991_1' & `shbybin2_c0_6_0_1991_2' & `shbybin2_c0_6_0_1991_3' & `shbybin2_c0_6_0_1991_4' & `shbybin2_c0_6_0_1991_5' & `shbybin3_c0_6_0_1991_1' & `shbybin3_c0_6_0_1991_2' & `shbybin3_c0_6_0_1991_3' & `sh_c0_6_0_1991' \\" _n  ///
	"Semi Durables 	   & `shbybin1_c0_7_0_1991_1' & `shbybin1_c0_7_0_1991_2' & `shbybin1_c0_7_0_1991_3' & `shbybin2_c0_7_0_1991_1' & `shbybin2_c0_7_0_1991_2' & `shbybin2_c0_7_0_1991_3' & `shbybin2_c0_7_0_1991_4' & `shbybin2_c0_7_0_1991_5' & `shbybin3_c0_7_0_1991_1' & `shbybin3_c0_7_0_1991_2' & `shbybin3_c0_7_0_1991_3' & `sh_c0_7_0_1991' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"Labor        & `shbybin1_y1_1_0_1991_1' & `shbybin1_y1_1_0_1991_2' & `shbybin1_y1_1_0_1991_3' & `shbybin2_y1_1_0_1991_1' & `shbybin2_y1_1_0_1991_2' & `shbybin2_y1_1_0_1991_3' & `shbybin2_y1_1_0_1991_4' & `shbybin2_y1_1_0_1991_5' & `shbybin3_y1_1_0_1991_1' & `shbybin3_y1_1_0_1991_2' & `shbybin3_y1_1_0_1991_3' & `sh_y1_1_0_1991' \\" _n  ///
	"Agriculture  & `shbybin1_y1_2_0_1991_1' & `shbybin1_y1_2_0_1991_2' & `shbybin1_y1_2_0_1991_3' & `shbybin2_y1_2_0_1991_1' & `shbybin2_y1_2_0_1991_2' & `shbybin2_y1_2_0_1991_3' & `shbybin2_y1_2_0_1991_4' & `shbybin2_y1_2_0_1991_5' & `shbybin3_y1_2_0_1991_1' & `shbybin3_y1_2_0_1991_2' & `shbybin3_y1_2_0_1991_3' & `sh_y1_2_0_1991' \\" _n  ///
	"Business     & `shbybin1_y1_3_0_1991_1' & `shbybin1_y1_3_0_1991_2' & `shbybin1_y1_3_0_1991_3' & `shbybin2_y1_3_0_1991_1' & `shbybin2_y1_3_0_1991_2' & `shbybin2_y1_3_0_1991_3' & `shbybin2_y1_3_0_1991_4' & `shbybin2_y1_3_0_1991_5' & `shbybin3_y1_3_0_1991_1' & `shbybin3_y1_3_0_1991_2' & `shbybin3_y1_3_0_1991_3' & `sh_y1_3_0_1991' \\" _n  ///
	"Capital      & `shbybin1_y1_4_0_1991_1' & `shbybin1_y1_4_0_1991_2' & `shbybin1_y1_4_0_1991_3' & `shbybin2_y1_4_0_1991_1' & `shbybin2_y1_4_0_1991_2' & `shbybin2_y1_4_0_1991_3' & `shbybin2_y1_4_0_1991_4' & `shbybin2_y1_4_0_1991_5' & `shbybin3_y1_4_0_1991_1' & `shbybin3_y1_4_0_1991_2' & `shbybin3_y1_4_0_1991_3' & `sh_y1_4_0_1991' \\" _n  ///
	"Transfers Rec.  & `shbybin1_y1_5_0_1991_1' & `shbybin1_y1_5_0_1991_2' & `shbybin1_y1_5_0_1991_3' & `shbybin2_y1_5_0_1991_1' & `shbybin2_y1_5_0_1991_2' & `shbybin2_y1_5_0_1991_3' & `shbybin2_y1_5_0_1991_4' & `shbybin2_y1_5_0_1991_5' & `shbybin3_y1_5_0_1991_1' & `shbybin3_y1_5_0_1991_2' & `shbybin3_y1_5_0_1991_3' & `sh_y1_5_0_1991' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"Public Trans. Rec.  & `shbybin1_y1_51_0_1991_1' & `shbybin1_y1_51_0_1991_2' & `shbybin1_y1_51_0_1991_3' & `shbybin2_y1_51_0_1991_1' & `shbybin2_y1_51_0_1991_2' & `shbybin2_y1_51_0_1991_3' & `shbybin2_y1_51_0_1991_4' & `shbybin2_y1_51_0_1991_5' & `shbybin3_y1_51_0_1991_1' & `shbybin3_y1_51_0_1991_2' & `shbybin3_y1_51_0_1991_3' & `sh_y1_51_0_1991' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Food Coupons    & `shbybin1_y1_511_0_1991_1' & `shbybin1_y1_511_0_1991_2' & `shbybin1_y1_511_0_1991_3' & `shbybin2_y1_511_0_1991_1' & `shbybin2_y1_511_0_1991_2' & `shbybin2_y1_511_0_1991_3' & `shbybin2_y1_511_0_1991_4' & `shbybin2_y1_511_0_1991_5' & `shbybin3_y1_511_0_1991_1' & `shbybin3_y1_511_0_1991_2' & `shbybin3_y1_511_0_1991_3' & `sh_y1_511_0_1991' \\" _n  ///
	"\hspace{.3cm} Sub. Work Unit  & `shbybin1_y1_512_0_1991_1' & `shbybin1_y1_512_0_1991_2' & `shbybin1_y1_512_0_1991_3' & `shbybin2_y1_512_0_1991_1' & `shbybin2_y1_512_0_1991_2' & `shbybin2_y1_512_0_1991_3' & `shbybin2_y1_512_0_1991_4' & `shbybin2_y1_512_0_1991_5' & `shbybin3_y1_512_0_1991_1' & `shbybin3_y1_512_0_1991_2' & `shbybin3_y1_512_0_1991_3' & `sh_y1_512_0_1991' \\" _n  ///
	"\hspace{.3cm} Sub. Gov.       & `shbybin1_y1_513_0_1991_1' & `shbybin1_y1_513_0_1991_2' & `shbybin1_y1_513_0_1991_3' & `shbybin2_y1_513_0_1991_1' & `shbybin2_y1_513_0_1991_2' & `shbybin2_y1_513_0_1991_3' & `shbybin2_y1_513_0_1991_4' & `shbybin2_y1_513_0_1991_5' & `shbybin3_y1_513_0_1991_1' & `shbybin3_y1_513_0_1991_2' & `shbybin3_y1_513_0_1991_3' & `sh_y1_513_0_1991' \\" _n  ///
	"\hspace{.3cm} Pension         & `shbybin1_y1_514_0_1991_1' & `shbybin1_y1_514_0_1991_2' & `shbybin1_y1_514_0_1991_3' & `shbybin2_y1_514_0_1991_1' & `shbybin2_y1_514_0_1991_2' & `shbybin2_y1_514_0_1991_3' & `shbybin2_y1_514_0_1991_4' & `shbybin2_y1_514_0_1991_5' & `shbybin3_y1_514_0_1991_1' & `shbybin3_y1_514_0_1991_2' & `shbybin3_y1_514_0_1991_3' & `sh_y1_514_0_1991' \\" _n  ///
	"Private Trans. Rec. & `shbybin1_y1_52_0_1991_1' & `shbybin1_y1_52_0_1991_2' & `shbybin1_y1_52_0_1991_3' & `shbybin2_y1_52_0_1991_1' & `shbybin2_y1_52_0_1991_2' & `shbybin2_y1_52_0_1991_3' & `shbybin2_y1_52_0_1991_4' & `shbybin2_y1_52_0_1991_5' & `shbybin3_y1_52_0_1991_1' & `shbybin3_y1_52_0_1991_2' & `shbybin3_y1_52_0_1991_3' & `sh_y1_52_0_1991' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* URBAN 1991
	cap file close _all
	file open ofile using "Tables\table2_1991u_d.tex", write replace	
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
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"`shbybin1_c0_1_1_1991_1' & `shbybin1_c0_1_1_1991_2' & `shbybin1_c0_1_1_1991_3' & `shbybin2_c0_1_1_1991_1' & `shbybin2_c0_1_1_1991_2' & `shbybin2_c0_1_1_1991_3' & `shbybin2_c0_1_1_1991_4' & `shbybin2_c0_1_1_1991_5' & `shbybin3_c0_1_1_1991_1' & `shbybin3_c0_1_1_1991_2' & `shbybin3_c0_1_1_1991_3' & `sh_c0_1_1_1991' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_c0_11_1_1991_1' & `shbybin1_c0_11_1_1991_2' & `shbybin1_c0_11_1_1991_3' & `shbybin2_c0_11_1_1991_1' & `shbybin2_c0_11_1_1991_2' & `shbybin2_c0_11_1_1991_3' & `shbybin2_c0_11_1_1991_4' & `shbybin2_c0_11_1_1991_5' & `shbybin3_c0_11_1_1991_1' & `shbybin3_c0_11_1_1991_2' & `shbybin3_c0_11_1_1991_3' & `sh_c0_11_1_1991' \\" _n  ///
	"`shbybin1_c0_12_1_1991_1' & `shbybin1_c0_12_1_1991_2' & `shbybin1_c0_12_1_1991_3' & `shbybin2_c0_12_1_1991_1' & `shbybin2_c0_12_1_1991_2' & `shbybin2_c0_12_1_1991_3' & `shbybin2_c0_12_1_1991_4' & `shbybin2_c0_12_1_1991_5' & `shbybin3_c0_12_1_1991_1' & `shbybin3_c0_12_1_1991_2' & `shbybin3_c0_12_1_1991_3' & `sh_c0_12_1_1991' \\" _n  ///
	"`shbybin1_c0_13_1_1991_1' & `shbybin1_c0_13_1_1991_2' & `shbybin1_c0_13_1_1991_3' & `shbybin2_c0_13_1_1991_1' & `shbybin2_c0_13_1_1991_2' & `shbybin2_c0_13_1_1991_3' & `shbybin2_c0_13_1_1991_4' & `shbybin2_c0_13_1_1991_5' & `shbybin3_c0_13_1_1991_1' & `shbybin3_c0_13_1_1991_2' & `shbybin3_c0_13_1_1991_3' & `sh_c0_13_1_1991' \\" _n  ///
	"`shbybin1_c0_14_1_1991_1' & `shbybin1_c0_14_1_1991_2' & `shbybin1_c0_14_1_1991_3' & `shbybin2_c0_14_1_1991_1' & `shbybin2_c0_14_1_1991_2' & `shbybin2_c0_14_1_1991_3' & `shbybin2_c0_14_1_1991_4' & `shbybin2_c0_14_1_1991_5' & `shbybin3_c0_14_1_1991_1' & `shbybin3_c0_14_1_1991_2' & `shbybin3_c0_14_1_1991_3' & `sh_c0_14_1_1991' \\" _n  ///
	"`shbybin1_c0_2_1_1991_1' & `shbybin1_c0_2_1_1991_2' & `shbybin1_c0_2_1_1991_3' & `shbybin2_c0_2_1_1991_1' & `shbybin2_c0_2_1_1991_2' & `shbybin2_c0_2_1_1991_3' & `shbybin2_c0_2_1_1991_4' & `shbybin2_c0_2_1_1991_5' & `shbybin3_c0_2_1_1991_1' & `shbybin3_c0_2_1_1991_2' & `shbybin3_c0_2_1_1991_3' & `sh_c0_2_1_1991' \\" _n  ///
	"`shbybin1_c0_3_1_1991_1' & `shbybin1_c0_3_1_1991_2' & `shbybin1_c0_3_1_1991_3' & `shbybin2_c0_3_1_1991_1' & `shbybin2_c0_3_1_1991_2' & `shbybin2_c0_3_1_1991_3' & `shbybin2_c0_3_1_1991_4' & `shbybin2_c0_3_1_1991_5' & `shbybin3_c0_3_1_1991_1' & `shbybin3_c0_3_1_1991_2' & `shbybin3_c0_3_1_1991_3' & `sh_c0_3_1_1991' \\" _n  ///
	"`shbybin1_c0_4_1_1991_1' & `shbybin1_c0_4_1_1991_2' & `shbybin1_c0_4_1_1991_3' & `shbybin2_c0_4_1_1991_1' & `shbybin2_c0_4_1_1991_2' & `shbybin2_c0_4_1_1991_3' & `shbybin2_c0_4_1_1991_4' & `shbybin2_c0_4_1_1991_5' & `shbybin3_c0_4_1_1991_1' & `shbybin3_c0_4_1_1991_2' & `shbybin3_c0_4_1_1991_3' & `sh_c0_4_1_1991' \\" _n  ///
	"`shbybin1_c0_5_1_1991_1' & `shbybin1_c0_5_1_1991_2' & `shbybin1_c0_5_1_1991_3' & `shbybin2_c0_5_1_1991_1' & `shbybin2_c0_5_1_1991_2' & `shbybin2_c0_5_1_1991_3' & `shbybin2_c0_5_1_1991_4' & `shbybin2_c0_5_1_1991_5' & `shbybin3_c0_5_1_1991_1' & `shbybin3_c0_5_1_1991_2' & `shbybin3_c0_5_1_1991_3' & `sh_c0_5_1_1991' \\" _n  ///
	"`shbybin1_c0_6_1_1991_1' & `shbybin1_c0_6_1_1991_2' & `shbybin1_c0_6_1_1991_3' & `shbybin2_c0_6_1_1991_1' & `shbybin2_c0_6_1_1991_2' & `shbybin2_c0_6_1_1991_3' & `shbybin2_c0_6_1_1991_4' & `shbybin2_c0_6_1_1991_5' & `shbybin3_c0_6_1_1991_1' & `shbybin3_c0_6_1_1991_2' & `shbybin3_c0_6_1_1991_3' & `sh_c0_6_1_1991' \\" _n  ///
	"`shbybin1_c0_7_1_1991_1' & `shbybin1_c0_7_1_1991_2' & `shbybin1_c0_7_1_1991_3' & `shbybin2_c0_7_1_1991_1' & `shbybin2_c0_7_1_1991_2' & `shbybin2_c0_7_1_1991_3' & `shbybin2_c0_7_1_1991_4' & `shbybin2_c0_7_1_1991_5' & `shbybin3_c0_7_1_1991_1' & `shbybin3_c0_7_1_1991_2' & `shbybin3_c0_7_1_1991_3' & `sh_c0_7_1_1991' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_1_1_1991_1' & `shbybin1_y1_1_1_1991_2' & `shbybin1_y1_1_1_1991_3' & `shbybin2_y1_1_1_1991_1' & `shbybin2_y1_1_1_1991_2' & `shbybin2_y1_1_1_1991_3' & `shbybin2_y1_1_1_1991_4' & `shbybin2_y1_1_1_1991_5' & `shbybin3_y1_1_1_1991_1' & `shbybin3_y1_1_1_1991_2' & `shbybin3_y1_1_1_1991_3' & `sh_y1_1_1_1991' \\" _n  ///
	"`shbybin1_y1_2_1_1991_1' & `shbybin1_y1_2_1_1991_2' & `shbybin1_y1_2_1_1991_3' & `shbybin2_y1_2_1_1991_1' & `shbybin2_y1_2_1_1991_2' & `shbybin2_y1_2_1_1991_3' & `shbybin2_y1_2_1_1991_4' & `shbybin2_y1_2_1_1991_5' & `shbybin3_y1_2_1_1991_1' & `shbybin3_y1_2_1_1991_2' & `shbybin3_y1_2_1_1991_3' & `sh_y1_2_1_1991' \\" _n  ///
	"`shbybin1_y1_3_1_1991_1' & `shbybin1_y1_3_1_1991_2' & `shbybin1_y1_3_1_1991_3' & `shbybin2_y1_3_1_1991_1' & `shbybin2_y1_3_1_1991_2' & `shbybin2_y1_3_1_1991_3' & `shbybin2_y1_3_1_1991_4' & `shbybin2_y1_3_1_1991_5' & `shbybin3_y1_3_1_1991_1' & `shbybin3_y1_3_1_1991_2' & `shbybin3_y1_3_1_1991_3' & `sh_y1_3_1_1991' \\" _n  ///
	"`shbybin1_y1_4_1_1991_1' & `shbybin1_y1_4_1_1991_2' & `shbybin1_y1_4_1_1991_3' & `shbybin2_y1_4_1_1991_1' & `shbybin2_y1_4_1_1991_2' & `shbybin2_y1_4_1_1991_3' & `shbybin2_y1_4_1_1991_4' & `shbybin2_y1_4_1_1991_5' & `shbybin3_y1_4_1_1991_1' & `shbybin3_y1_4_1_1991_2' & `shbybin3_y1_4_1_1991_3' & `sh_y1_4_1_1991' \\" _n  ///
	"`shbybin1_y1_5_1_1991_1' & `shbybin1_y1_5_1_1991_2' & `shbybin1_y1_5_1_1991_3' & `shbybin2_y1_5_1_1991_1' & `shbybin2_y1_5_1_1991_2' & `shbybin2_y1_5_1_1991_3' & `shbybin2_y1_5_1_1991_4' & `shbybin2_y1_5_1_1991_5' & `shbybin3_y1_5_1_1991_1' & `shbybin3_y1_5_1_1991_2' & `shbybin3_y1_5_1_1991_3' & `sh_y1_5_1_1991' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_51_1_1991_1' & `shbybin1_y1_51_1_1991_2' & `shbybin1_y1_51_1_1991_3' & `shbybin2_y1_51_1_1991_1' & `shbybin2_y1_51_1_1991_2' & `shbybin2_y1_51_1_1991_3' & `shbybin2_y1_51_1_1991_4' & `shbybin2_y1_51_1_1991_5' & `shbybin3_y1_51_1_1991_1' & `shbybin3_y1_51_1_1991_2' & `shbybin3_y1_51_1_1991_3' & `sh_y1_51_1_1991' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_y1_511_1_1991_1' & `shbybin1_y1_511_1_1991_2' & `shbybin1_y1_511_1_1991_3' & `shbybin2_y1_511_1_1991_1' & `shbybin2_y1_511_1_1991_2' & `shbybin2_y1_511_1_1991_3' & `shbybin2_y1_511_1_1991_4' & `shbybin2_y1_511_1_1991_5' & `shbybin3_y1_511_1_1991_1' & `shbybin3_y1_511_1_1991_2' & `shbybin3_y1_511_1_1991_3' & `sh_y1_511_1_1991' \\" _n  ///
	"`shbybin1_y1_512_1_1991_1' & `shbybin1_y1_512_1_1991_2' & `shbybin1_y1_512_1_1991_3' & `shbybin2_y1_512_1_1991_1' & `shbybin2_y1_512_1_1991_2' & `shbybin2_y1_512_1_1991_3' & `shbybin2_y1_512_1_1991_4' & `shbybin2_y1_512_1_1991_5' & `shbybin3_y1_512_1_1991_1' & `shbybin3_y1_512_1_1991_2' & `shbybin3_y1_512_1_1991_3' & `sh_y1_512_1_1991' \\" _n  ///
	"`shbybin1_y1_513_1_1991_1' & `shbybin1_y1_513_1_1991_2' & `shbybin1_y1_513_1_1991_3' & `shbybin2_y1_513_1_1991_1' & `shbybin2_y1_513_1_1991_2' & `shbybin2_y1_513_1_1991_3' & `shbybin2_y1_513_1_1991_4' & `shbybin2_y1_513_1_1991_5' & `shbybin3_y1_513_1_1991_1' & `shbybin3_y1_513_1_1991_2' & `shbybin3_y1_513_1_1991_3' & `sh_y1_513_1_1991' \\" _n  ///
	"`shbybin1_y1_514_1_1991_1' & `shbybin1_y1_514_1_1991_2' & `shbybin1_y1_514_1_1991_3' & `shbybin2_y1_514_1_1991_1' & `shbybin2_y1_514_1_1991_2' & `shbybin2_y1_514_1_1991_3' & `shbybin2_y1_514_1_1991_4' & `shbybin2_y1_514_1_1991_5' & `shbybin3_y1_514_1_1991_1' & `shbybin3_y1_514_1_1991_2' & `shbybin3_y1_514_1_1991_3' & `sh_y1_514_1_1991' \\" _n  ///
	"`shbybin1_y1_52_1_1991_1' & `shbybin1_y1_52_1_1991_2' & `shbybin1_y1_52_1_1991_3' & `shbybin2_y1_52_1_1991_1' & `shbybin2_y1_52_1_1991_2' & `shbybin2_y1_52_1_1991_3' & `shbybin2_y1_52_1_1991_4' & `shbybin2_y1_52_1_1991_5' & `shbybin3_y1_52_1_1991_1' & `shbybin3_y1_52_1_1991_2' & `shbybin3_y1_52_1_1991_3' & `sh_y1_52_1_1991' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* RURAL 1993
	cap file close _all
	file open ofile using "Tables\table2_1993r_d.tex", write replace	
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
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"Food (Diet)  & `shbybin1_c0_1_0_1993_1' & `shbybin1_c0_1_0_1993_2' & `shbybin1_c0_1_0_1993_3' & `shbybin2_c0_1_0_1993_1' & `shbybin2_c0_1_0_1993_2' & `shbybin2_c0_1_0_1993_3' & `shbybin2_c0_1_0_1993_4' & `shbybin2_c0_1_0_1993_5' & `shbybin3_c0_1_0_1993_1' & `shbybin3_c0_1_0_1993_2' & `shbybin3_c0_1_0_1993_3' & `sh_c0_1_0_1993' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Own prod.  & `shbybin1_c0_11_0_1993_1' & `shbybin1_c0_11_0_1993_2' & `shbybin1_c0_11_0_1993_3' & `shbybin2_c0_11_0_1993_1' & `shbybin2_c0_11_0_1993_2' & `shbybin2_c0_11_0_1993_3' & `shbybin2_c0_11_0_1993_4' & `shbybin2_c0_11_0_1993_5' & `shbybin3_c0_11_0_1993_1' & `shbybin3_c0_11_0_1993_2' & `shbybin3_c0_11_0_1993_3' & `sh_c0_11_0_1993' \\" _n  ///
	"\hspace{.3cm} Coupons    & `shbybin1_c0_12_0_1993_1' & `shbybin1_c0_12_0_1993_2' & `shbybin1_c0_12_0_1993_3' & `shbybin2_c0_12_0_1993_1' & `shbybin2_c0_12_0_1993_2' & `shbybin2_c0_12_0_1993_3' & `shbybin2_c0_12_0_1993_4' & `shbybin2_c0_12_0_1993_5' & `shbybin3_c0_12_0_1993_1' & `shbybin3_c0_12_0_1993_2' & `shbybin3_c0_12_0_1993_3' & `sh_c0_12_0_1993' \\" _n  ///
	"\hspace{.3cm} Gifts	  & `shbybin1_c0_13_0_1993_1' & `shbybin1_c0_13_0_1993_2' & `shbybin1_c0_13_0_1993_3' & `shbybin2_c0_13_0_1993_1' & `shbybin2_c0_13_0_1993_2' & `shbybin2_c0_13_0_1993_3' & `shbybin2_c0_13_0_1993_4' & `shbybin2_c0_13_0_1993_5' & `shbybin3_c0_13_0_1993_1' & `shbybin3_c0_13_0_1993_2' & `shbybin3_c0_13_0_1993_3' & `sh_c0_13_0_1993' \\" _n  ///
	"\hspace{.3cm} Expenditures  & `shbybin1_c0_14_0_1993_1' & `shbybin1_c0_14_0_1993_2' & `shbybin1_c0_14_0_1993_3' & `shbybin2_c0_14_0_1993_1' & `shbybin2_c0_14_0_1993_2' & `shbybin2_c0_14_0_1993_3' & `shbybin2_c0_14_0_1993_4' & `shbybin2_c0_14_0_1993_5' & `shbybin3_c0_14_0_1993_1' & `shbybin3_c0_14_0_1993_2' & `shbybin3_c0_14_0_1993_3' & `sh_c0_14_0_1993' \\" _n  ///
	"Utilities    & `shbybin1_c0_2_0_1993_1' & `shbybin1_c0_2_0_1993_2' & `shbybin1_c0_2_0_1993_3' & `shbybin2_c0_2_0_1993_1' & `shbybin2_c0_2_0_1993_2' & `shbybin2_c0_2_0_1993_3' & `shbybin2_c0_2_0_1993_4' & `shbybin2_c0_2_0_1993_5' & `shbybin3_c0_2_0_1993_1' & `shbybin3_c0_2_0_1993_2' & `shbybin3_c0_2_0_1993_3' & `sh_c0_2_0_1993' \\" _n  ///
	"Housing Services  & `shbybin1_c0_3_0_1993_1' & `shbybin1_c0_3_0_1993_2' & `shbybin1_c0_3_0_1993_3' & `shbybin2_c0_3_0_1993_1' & `shbybin2_c0_3_0_1993_2' & `shbybin2_c0_3_0_1993_3' & `shbybin2_c0_3_0_1993_4' & `shbybin2_c0_3_0_1993_5' & `shbybin3_c0_3_0_1993_1' & `shbybin3_c0_3_0_1993_2' & `shbybin3_c0_3_0_1993_3' & `sh_c0_3_0_1993' \\" _n  ///
	"Child Care   & `shbybin1_c0_4_0_1993_1' & `shbybin1_c0_4_0_1993_2' & `shbybin1_c0_4_0_1993_3' & `shbybin2_c0_4_0_1993_1' & `shbybin2_c0_4_0_1993_2' & `shbybin2_c0_4_0_1993_3' & `shbybin2_c0_4_0_1993_4' & `shbybin2_c0_4_0_1993_5' & `shbybin3_c0_4_0_1993_1' & `shbybin3_c0_4_0_1993_2' & `shbybin3_c0_4_0_1993_3' & `sh_c0_4_0_1993' \\" _n  ///
	"Health Services    & `shbybin1_c0_5_0_1993_1' & `shbybin1_c0_5_0_1993_2' & `shbybin1_c0_5_0_1993_3' & `shbybin2_c0_5_0_1993_1' & `shbybin2_c0_5_0_1993_2' & `shbybin2_c0_5_0_1993_3' & `shbybin2_c0_5_0_1993_4' & `shbybin2_c0_5_0_1993_5' & `shbybin3_c0_5_0_1993_1' & `shbybin3_c0_5_0_1993_2' & `shbybin3_c0_5_0_1993_3' & `sh_c0_5_0_1993' \\" _n  ///
	"Education   & `shbybin1_c0_6_0_1993_1' & `shbybin1_c0_6_0_1993_2' & `shbybin1_c0_6_0_1993_3' & `shbybin2_c0_6_0_1993_1' & `shbybin2_c0_6_0_1993_2' & `shbybin2_c0_6_0_1993_3' & `shbybin2_c0_6_0_1993_4' & `shbybin2_c0_6_0_1993_5' & `shbybin3_c0_6_0_1993_1' & `shbybin3_c0_6_0_1993_2' & `shbybin3_c0_6_0_1993_3' & `sh_c0_6_0_1993' \\" _n  ///
	"Semi Durables 	   & `shbybin1_c0_7_0_1993_1' & `shbybin1_c0_7_0_1993_2' & `shbybin1_c0_7_0_1993_3' & `shbybin2_c0_7_0_1993_1' & `shbybin2_c0_7_0_1993_2' & `shbybin2_c0_7_0_1993_3' & `shbybin2_c0_7_0_1993_4' & `shbybin2_c0_7_0_1993_5' & `shbybin3_c0_7_0_1993_1' & `shbybin3_c0_7_0_1993_2' & `shbybin3_c0_7_0_1993_3' & `sh_c0_7_0_1993' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"Labor        & `shbybin1_y1_1_0_1993_1' & `shbybin1_y1_1_0_1993_2' & `shbybin1_y1_1_0_1993_3' & `shbybin2_y1_1_0_1993_1' & `shbybin2_y1_1_0_1993_2' & `shbybin2_y1_1_0_1993_3' & `shbybin2_y1_1_0_1993_4' & `shbybin2_y1_1_0_1993_5' & `shbybin3_y1_1_0_1993_1' & `shbybin3_y1_1_0_1993_2' & `shbybin3_y1_1_0_1993_3' & `sh_y1_1_0_1993' \\" _n  ///
	"Agriculture  & `shbybin1_y1_2_0_1993_1' & `shbybin1_y1_2_0_1993_2' & `shbybin1_y1_2_0_1993_3' & `shbybin2_y1_2_0_1993_1' & `shbybin2_y1_2_0_1993_2' & `shbybin2_y1_2_0_1993_3' & `shbybin2_y1_2_0_1993_4' & `shbybin2_y1_2_0_1993_5' & `shbybin3_y1_2_0_1993_1' & `shbybin3_y1_2_0_1993_2' & `shbybin3_y1_2_0_1993_3' & `sh_y1_2_0_1993' \\" _n  ///
	"Business     & `shbybin1_y1_3_0_1993_1' & `shbybin1_y1_3_0_1993_2' & `shbybin1_y1_3_0_1993_3' & `shbybin2_y1_3_0_1993_1' & `shbybin2_y1_3_0_1993_2' & `shbybin2_y1_3_0_1993_3' & `shbybin2_y1_3_0_1993_4' & `shbybin2_y1_3_0_1993_5' & `shbybin3_y1_3_0_1993_1' & `shbybin3_y1_3_0_1993_2' & `shbybin3_y1_3_0_1993_3' & `sh_y1_3_0_1993' \\" _n  ///
	"Capital      & `shbybin1_y1_4_0_1993_1' & `shbybin1_y1_4_0_1993_2' & `shbybin1_y1_4_0_1993_3' & `shbybin2_y1_4_0_1993_1' & `shbybin2_y1_4_0_1993_2' & `shbybin2_y1_4_0_1993_3' & `shbybin2_y1_4_0_1993_4' & `shbybin2_y1_4_0_1993_5' & `shbybin3_y1_4_0_1993_1' & `shbybin3_y1_4_0_1993_2' & `shbybin3_y1_4_0_1993_3' & `sh_y1_4_0_1993' \\" _n  ///
	"Transfers Rec.  & `shbybin1_y1_5_0_1993_1' & `shbybin1_y1_5_0_1993_2' & `shbybin1_y1_5_0_1993_3' & `shbybin2_y1_5_0_1993_1' & `shbybin2_y1_5_0_1993_2' & `shbybin2_y1_5_0_1993_3' & `shbybin2_y1_5_0_1993_4' & `shbybin2_y1_5_0_1993_5' & `shbybin3_y1_5_0_1993_1' & `shbybin3_y1_5_0_1993_2' & `shbybin3_y1_5_0_1993_3' & `sh_y1_5_0_1993' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"Public Trans. Rec.  & `shbybin1_y1_51_0_1993_1' & `shbybin1_y1_51_0_1993_2' & `shbybin1_y1_51_0_1993_3' & `shbybin2_y1_51_0_1993_1' & `shbybin2_y1_51_0_1993_2' & `shbybin2_y1_51_0_1993_3' & `shbybin2_y1_51_0_1993_4' & `shbybin2_y1_51_0_1993_5' & `shbybin3_y1_51_0_1993_1' & `shbybin3_y1_51_0_1993_2' & `shbybin3_y1_51_0_1993_3' & `sh_y1_51_0_1993' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Food Coupons    & `shbybin1_y1_511_0_1993_1' & `shbybin1_y1_511_0_1993_2' & `shbybin1_y1_511_0_1993_3' & `shbybin2_y1_511_0_1993_1' & `shbybin2_y1_511_0_1993_2' & `shbybin2_y1_511_0_1993_3' & `shbybin2_y1_511_0_1993_4' & `shbybin2_y1_511_0_1993_5' & `shbybin3_y1_511_0_1993_1' & `shbybin3_y1_511_0_1993_2' & `shbybin3_y1_511_0_1993_3' & `sh_y1_511_0_1993' \\" _n  ///
	"\hspace{.3cm} Sub. Work Unit  & `shbybin1_y1_512_0_1993_1' & `shbybin1_y1_512_0_1993_2' & `shbybin1_y1_512_0_1993_3' & `shbybin2_y1_512_0_1993_1' & `shbybin2_y1_512_0_1993_2' & `shbybin2_y1_512_0_1993_3' & `shbybin2_y1_512_0_1993_4' & `shbybin2_y1_512_0_1993_5' & `shbybin3_y1_512_0_1993_1' & `shbybin3_y1_512_0_1993_2' & `shbybin3_y1_512_0_1993_3' & `sh_y1_512_0_1993' \\" _n  ///
	"\hspace{.3cm} Sub. Gov.       & `shbybin1_y1_513_0_1993_1' & `shbybin1_y1_513_0_1993_2' & `shbybin1_y1_513_0_1993_3' & `shbybin2_y1_513_0_1993_1' & `shbybin2_y1_513_0_1993_2' & `shbybin2_y1_513_0_1993_3' & `shbybin2_y1_513_0_1993_4' & `shbybin2_y1_513_0_1993_5' & `shbybin3_y1_513_0_1993_1' & `shbybin3_y1_513_0_1993_2' & `shbybin3_y1_513_0_1993_3' & `sh_y1_513_0_1993' \\" _n  ///
	"\hspace{.3cm} Pension         & `shbybin1_y1_514_0_1993_1' & `shbybin1_y1_514_0_1993_2' & `shbybin1_y1_514_0_1993_3' & `shbybin2_y1_514_0_1993_1' & `shbybin2_y1_514_0_1993_2' & `shbybin2_y1_514_0_1993_3' & `shbybin2_y1_514_0_1993_4' & `shbybin2_y1_514_0_1993_5' & `shbybin3_y1_514_0_1993_1' & `shbybin3_y1_514_0_1993_2' & `shbybin3_y1_514_0_1993_3' & `sh_y1_514_0_1993' \\" _n  ///
	"Private Trans. Rec. & `shbybin1_y1_52_0_1993_1' & `shbybin1_y1_52_0_1993_2' & `shbybin1_y1_52_0_1993_3' & `shbybin2_y1_52_0_1993_1' & `shbybin2_y1_52_0_1993_2' & `shbybin2_y1_52_0_1993_3' & `shbybin2_y1_52_0_1993_4' & `shbybin2_y1_52_0_1993_5' & `shbybin3_y1_52_0_1993_1' & `shbybin3_y1_52_0_1993_2' & `shbybin3_y1_52_0_1993_3' & `sh_y1_52_0_1993' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* URBAN 1993
	cap file close _all
	file open ofile using "Tables\table2_1993u_d.tex", write replace	
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
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"`shbybin1_c0_1_1_1993_1' & `shbybin1_c0_1_1_1993_2' & `shbybin1_c0_1_1_1993_3' & `shbybin2_c0_1_1_1993_1' & `shbybin2_c0_1_1_1993_2' & `shbybin2_c0_1_1_1993_3' & `shbybin2_c0_1_1_1993_4' & `shbybin2_c0_1_1_1993_5' & `shbybin3_c0_1_1_1993_1' & `shbybin3_c0_1_1_1993_2' & `shbybin3_c0_1_1_1993_3' & `sh_c0_1_1_1993' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_c0_11_1_1993_1' & `shbybin1_c0_11_1_1993_2' & `shbybin1_c0_11_1_1993_3' & `shbybin2_c0_11_1_1993_1' & `shbybin2_c0_11_1_1993_2' & `shbybin2_c0_11_1_1993_3' & `shbybin2_c0_11_1_1993_4' & `shbybin2_c0_11_1_1993_5' & `shbybin3_c0_11_1_1993_1' & `shbybin3_c0_11_1_1993_2' & `shbybin3_c0_11_1_1993_3' & `sh_c0_11_1_1993' \\" _n  ///
	"`shbybin1_c0_12_1_1993_1' & `shbybin1_c0_12_1_1993_2' & `shbybin1_c0_12_1_1993_3' & `shbybin2_c0_12_1_1993_1' & `shbybin2_c0_12_1_1993_2' & `shbybin2_c0_12_1_1993_3' & `shbybin2_c0_12_1_1993_4' & `shbybin2_c0_12_1_1993_5' & `shbybin3_c0_12_1_1993_1' & `shbybin3_c0_12_1_1993_2' & `shbybin3_c0_12_1_1993_3' & `sh_c0_12_1_1993' \\" _n  ///
	"`shbybin1_c0_13_1_1993_1' & `shbybin1_c0_13_1_1993_2' & `shbybin1_c0_13_1_1993_3' & `shbybin2_c0_13_1_1993_1' & `shbybin2_c0_13_1_1993_2' & `shbybin2_c0_13_1_1993_3' & `shbybin2_c0_13_1_1993_4' & `shbybin2_c0_13_1_1993_5' & `shbybin3_c0_13_1_1993_1' & `shbybin3_c0_13_1_1993_2' & `shbybin3_c0_13_1_1993_3' & `sh_c0_13_1_1993' \\" _n  ///
	"`shbybin1_c0_14_1_1993_1' & `shbybin1_c0_14_1_1993_2' & `shbybin1_c0_14_1_1993_3' & `shbybin2_c0_14_1_1993_1' & `shbybin2_c0_14_1_1993_2' & `shbybin2_c0_14_1_1993_3' & `shbybin2_c0_14_1_1993_4' & `shbybin2_c0_14_1_1993_5' & `shbybin3_c0_14_1_1993_1' & `shbybin3_c0_14_1_1993_2' & `shbybin3_c0_14_1_1993_3' & `sh_c0_14_1_1993' \\" _n  ///
	"`shbybin1_c0_2_1_1993_1' & `shbybin1_c0_2_1_1993_2' & `shbybin1_c0_2_1_1993_3' & `shbybin2_c0_2_1_1993_1' & `shbybin2_c0_2_1_1993_2' & `shbybin2_c0_2_1_1993_3' & `shbybin2_c0_2_1_1993_4' & `shbybin2_c0_2_1_1993_5' & `shbybin3_c0_2_1_1993_1' & `shbybin3_c0_2_1_1993_2' & `shbybin3_c0_2_1_1993_3' & `sh_c0_2_1_1993' \\" _n  ///
	"`shbybin1_c0_3_1_1993_1' & `shbybin1_c0_3_1_1993_2' & `shbybin1_c0_3_1_1993_3' & `shbybin2_c0_3_1_1993_1' & `shbybin2_c0_3_1_1993_2' & `shbybin2_c0_3_1_1993_3' & `shbybin2_c0_3_1_1993_4' & `shbybin2_c0_3_1_1993_5' & `shbybin3_c0_3_1_1993_1' & `shbybin3_c0_3_1_1993_2' & `shbybin3_c0_3_1_1993_3' & `sh_c0_3_1_1993' \\" _n  ///
	"`shbybin1_c0_4_1_1993_1' & `shbybin1_c0_4_1_1993_2' & `shbybin1_c0_4_1_1993_3' & `shbybin2_c0_4_1_1993_1' & `shbybin2_c0_4_1_1993_2' & `shbybin2_c0_4_1_1993_3' & `shbybin2_c0_4_1_1993_4' & `shbybin2_c0_4_1_1993_5' & `shbybin3_c0_4_1_1993_1' & `shbybin3_c0_4_1_1993_2' & `shbybin3_c0_4_1_1993_3' & `sh_c0_4_1_1993' \\" _n  ///
	"`shbybin1_c0_5_1_1993_1' & `shbybin1_c0_5_1_1993_2' & `shbybin1_c0_5_1_1993_3' & `shbybin2_c0_5_1_1993_1' & `shbybin2_c0_5_1_1993_2' & `shbybin2_c0_5_1_1993_3' & `shbybin2_c0_5_1_1993_4' & `shbybin2_c0_5_1_1993_5' & `shbybin3_c0_5_1_1993_1' & `shbybin3_c0_5_1_1993_2' & `shbybin3_c0_5_1_1993_3' & `sh_c0_5_1_1993' \\" _n  ///
	"`shbybin1_c0_6_1_1993_1' & `shbybin1_c0_6_1_1993_2' & `shbybin1_c0_6_1_1993_3' & `shbybin2_c0_6_1_1993_1' & `shbybin2_c0_6_1_1993_2' & `shbybin2_c0_6_1_1993_3' & `shbybin2_c0_6_1_1993_4' & `shbybin2_c0_6_1_1993_5' & `shbybin3_c0_6_1_1993_1' & `shbybin3_c0_6_1_1993_2' & `shbybin3_c0_6_1_1993_3' & `sh_c0_6_1_1993' \\" _n  ///
	"`shbybin1_c0_7_1_1993_1' & `shbybin1_c0_7_1_1993_2' & `shbybin1_c0_7_1_1993_3' & `shbybin2_c0_7_1_1993_1' & `shbybin2_c0_7_1_1993_2' & `shbybin2_c0_7_1_1993_3' & `shbybin2_c0_7_1_1993_4' & `shbybin2_c0_7_1_1993_5' & `shbybin3_c0_7_1_1993_1' & `shbybin3_c0_7_1_1993_2' & `shbybin3_c0_7_1_1993_3' & `sh_c0_7_1_1993' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_1_1_1993_1' & `shbybin1_y1_1_1_1993_2' & `shbybin1_y1_1_1_1993_3' & `shbybin2_y1_1_1_1993_1' & `shbybin2_y1_1_1_1993_2' & `shbybin2_y1_1_1_1993_3' & `shbybin2_y1_1_1_1993_4' & `shbybin2_y1_1_1_1993_5' & `shbybin3_y1_1_1_1993_1' & `shbybin3_y1_1_1_1993_2' & `shbybin3_y1_1_1_1993_3' & `sh_y1_1_1_1993' \\" _n  ///
	"`shbybin1_y1_2_1_1993_1' & `shbybin1_y1_2_1_1993_2' & `shbybin1_y1_2_1_1993_3' & `shbybin2_y1_2_1_1993_1' & `shbybin2_y1_2_1_1993_2' & `shbybin2_y1_2_1_1993_3' & `shbybin2_y1_2_1_1993_4' & `shbybin2_y1_2_1_1993_5' & `shbybin3_y1_2_1_1993_1' & `shbybin3_y1_2_1_1993_2' & `shbybin3_y1_2_1_1993_3' & `sh_y1_2_1_1993' \\" _n  ///
	"`shbybin1_y1_3_1_1993_1' & `shbybin1_y1_3_1_1993_2' & `shbybin1_y1_3_1_1993_3' & `shbybin2_y1_3_1_1993_1' & `shbybin2_y1_3_1_1993_2' & `shbybin2_y1_3_1_1993_3' & `shbybin2_y1_3_1_1993_4' & `shbybin2_y1_3_1_1993_5' & `shbybin3_y1_3_1_1993_1' & `shbybin3_y1_3_1_1993_2' & `shbybin3_y1_3_1_1993_3' & `sh_y1_3_1_1993' \\" _n  ///
	"`shbybin1_y1_4_1_1993_1' & `shbybin1_y1_4_1_1993_2' & `shbybin1_y1_4_1_1993_3' & `shbybin2_y1_4_1_1993_1' & `shbybin2_y1_4_1_1993_2' & `shbybin2_y1_4_1_1993_3' & `shbybin2_y1_4_1_1993_4' & `shbybin2_y1_4_1_1993_5' & `shbybin3_y1_4_1_1993_1' & `shbybin3_y1_4_1_1993_2' & `shbybin3_y1_4_1_1993_3' & `sh_y1_4_1_1993' \\" _n  ///
	"`shbybin1_y1_5_1_1993_1' & `shbybin1_y1_5_1_1993_2' & `shbybin1_y1_5_1_1993_3' & `shbybin2_y1_5_1_1993_1' & `shbybin2_y1_5_1_1993_2' & `shbybin2_y1_5_1_1993_3' & `shbybin2_y1_5_1_1993_4' & `shbybin2_y1_5_1_1993_5' & `shbybin3_y1_5_1_1993_1' & `shbybin3_y1_5_1_1993_2' & `shbybin3_y1_5_1_1993_3' & `sh_y1_5_1_1993' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_51_1_1993_1' & `shbybin1_y1_51_1_1993_2' & `shbybin1_y1_51_1_1993_3' & `shbybin2_y1_51_1_1993_1' & `shbybin2_y1_51_1_1993_2' & `shbybin2_y1_51_1_1993_3' & `shbybin2_y1_51_1_1993_4' & `shbybin2_y1_51_1_1993_5' & `shbybin3_y1_51_1_1993_1' & `shbybin3_y1_51_1_1993_2' & `shbybin3_y1_51_1_1993_3' & `sh_y1_51_1_1993' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_y1_511_1_1993_1' & `shbybin1_y1_511_1_1993_2' & `shbybin1_y1_511_1_1993_3' & `shbybin2_y1_511_1_1993_1' & `shbybin2_y1_511_1_1993_2' & `shbybin2_y1_511_1_1993_3' & `shbybin2_y1_511_1_1993_4' & `shbybin2_y1_511_1_1993_5' & `shbybin3_y1_511_1_1993_1' & `shbybin3_y1_511_1_1993_2' & `shbybin3_y1_511_1_1993_3' & `sh_y1_511_1_1993' \\" _n  ///
	"`shbybin1_y1_512_1_1993_1' & `shbybin1_y1_512_1_1993_2' & `shbybin1_y1_512_1_1993_3' & `shbybin2_y1_512_1_1993_1' & `shbybin2_y1_512_1_1993_2' & `shbybin2_y1_512_1_1993_3' & `shbybin2_y1_512_1_1993_4' & `shbybin2_y1_512_1_1993_5' & `shbybin3_y1_512_1_1993_1' & `shbybin3_y1_512_1_1993_2' & `shbybin3_y1_512_1_1993_3' & `sh_y1_512_1_1993' \\" _n  ///
	"`shbybin1_y1_513_1_1993_1' & `shbybin1_y1_513_1_1993_2' & `shbybin1_y1_513_1_1993_3' & `shbybin2_y1_513_1_1993_1' & `shbybin2_y1_513_1_1993_2' & `shbybin2_y1_513_1_1993_3' & `shbybin2_y1_513_1_1993_4' & `shbybin2_y1_513_1_1993_5' & `shbybin3_y1_513_1_1993_1' & `shbybin3_y1_513_1_1993_2' & `shbybin3_y1_513_1_1993_3' & `sh_y1_513_1_1993' \\" _n  ///
	"`shbybin1_y1_514_1_1993_1' & `shbybin1_y1_514_1_1993_2' & `shbybin1_y1_514_1_1993_3' & `shbybin2_y1_514_1_1993_1' & `shbybin2_y1_514_1_1993_2' & `shbybin2_y1_514_1_1993_3' & `shbybin2_y1_514_1_1993_4' & `shbybin2_y1_514_1_1993_5' & `shbybin3_y1_514_1_1993_1' & `shbybin3_y1_514_1_1993_2' & `shbybin3_y1_514_1_1993_3' & `sh_y1_514_1_1993' \\" _n  ///
	"`shbybin1_y1_52_1_1993_1' & `shbybin1_y1_52_1_1993_2' & `shbybin1_y1_52_1_1993_3' & `shbybin2_y1_52_1_1993_1' & `shbybin2_y1_52_1_1993_2' & `shbybin2_y1_52_1_1993_3' & `shbybin2_y1_52_1_1993_4' & `shbybin2_y1_52_1_1993_5' & `shbybin3_y1_52_1_1993_1' & `shbybin3_y1_52_1_1993_2' & `shbybin3_y1_52_1_1993_3' & `sh_y1_52_1_1993' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* RURAL 1997
	cap file close _all
	file open ofile using "Tables\table2_1997r_d.tex", write replace	
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
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"Food (Diet)  & `shbybin1_c0_1_0_1997_1' & `shbybin1_c0_1_0_1997_2' & `shbybin1_c0_1_0_1997_3' & `shbybin2_c0_1_0_1997_1' & `shbybin2_c0_1_0_1997_2' & `shbybin2_c0_1_0_1997_3' & `shbybin2_c0_1_0_1997_4' & `shbybin2_c0_1_0_1997_5' & `shbybin3_c0_1_0_1997_1' & `shbybin3_c0_1_0_1997_2' & `shbybin3_c0_1_0_1997_3' & `sh_c0_1_0_1997' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Own prod.  & `shbybin1_c0_11_0_1997_1' & `shbybin1_c0_11_0_1997_2' & `shbybin1_c0_11_0_1997_3' & `shbybin2_c0_11_0_1997_1' & `shbybin2_c0_11_0_1997_2' & `shbybin2_c0_11_0_1997_3' & `shbybin2_c0_11_0_1997_4' & `shbybin2_c0_11_0_1997_5' & `shbybin3_c0_11_0_1997_1' & `shbybin3_c0_11_0_1997_2' & `shbybin3_c0_11_0_1997_3' & `sh_c0_11_0_1997' \\" _n  ///
	"\hspace{.3cm} Coupons    & `shbybin1_c0_12_0_1997_1' & `shbybin1_c0_12_0_1997_2' & `shbybin1_c0_12_0_1997_3' & `shbybin2_c0_12_0_1997_1' & `shbybin2_c0_12_0_1997_2' & `shbybin2_c0_12_0_1997_3' & `shbybin2_c0_12_0_1997_4' & `shbybin2_c0_12_0_1997_5' & `shbybin3_c0_12_0_1997_1' & `shbybin3_c0_12_0_1997_2' & `shbybin3_c0_12_0_1997_3' & `sh_c0_12_0_1997' \\" _n  ///
	"\hspace{.3cm} Gifts	  & `shbybin1_c0_13_0_1997_1' & `shbybin1_c0_13_0_1997_2' & `shbybin1_c0_13_0_1997_3' & `shbybin2_c0_13_0_1997_1' & `shbybin2_c0_13_0_1997_2' & `shbybin2_c0_13_0_1997_3' & `shbybin2_c0_13_0_1997_4' & `shbybin2_c0_13_0_1997_5' & `shbybin3_c0_13_0_1997_1' & `shbybin3_c0_13_0_1997_2' & `shbybin3_c0_13_0_1997_3' & `sh_c0_13_0_1997' \\" _n  ///
	"\hspace{.3cm} Expenditures  & `shbybin1_c0_14_0_1997_1' & `shbybin1_c0_14_0_1997_2' & `shbybin1_c0_14_0_1997_3' & `shbybin2_c0_14_0_1997_1' & `shbybin2_c0_14_0_1997_2' & `shbybin2_c0_14_0_1997_3' & `shbybin2_c0_14_0_1997_4' & `shbybin2_c0_14_0_1997_5' & `shbybin3_c0_14_0_1997_1' & `shbybin3_c0_14_0_1997_2' & `shbybin3_c0_14_0_1997_3' & `sh_c0_14_0_1997' \\" _n  ///
	"Utilities    & `shbybin1_c0_2_0_1997_1' & `shbybin1_c0_2_0_1997_2' & `shbybin1_c0_2_0_1997_3' & `shbybin2_c0_2_0_1997_1' & `shbybin2_c0_2_0_1997_2' & `shbybin2_c0_2_0_1997_3' & `shbybin2_c0_2_0_1997_4' & `shbybin2_c0_2_0_1997_5' & `shbybin3_c0_2_0_1997_1' & `shbybin3_c0_2_0_1997_2' & `shbybin3_c0_2_0_1997_3' & `sh_c0_2_0_1997' \\" _n  ///
	"Housing Services  & `shbybin1_c0_3_0_1997_1' & `shbybin1_c0_3_0_1997_2' & `shbybin1_c0_3_0_1997_3' & `shbybin2_c0_3_0_1997_1' & `shbybin2_c0_3_0_1997_2' & `shbybin2_c0_3_0_1997_3' & `shbybin2_c0_3_0_1997_4' & `shbybin2_c0_3_0_1997_5' & `shbybin3_c0_3_0_1997_1' & `shbybin3_c0_3_0_1997_2' & `shbybin3_c0_3_0_1997_3' & `sh_c0_3_0_1997' \\" _n  ///
	"Child Care   & `shbybin1_c0_4_0_1997_1' & `shbybin1_c0_4_0_1997_2' & `shbybin1_c0_4_0_1997_3' & `shbybin2_c0_4_0_1997_1' & `shbybin2_c0_4_0_1997_2' & `shbybin2_c0_4_0_1997_3' & `shbybin2_c0_4_0_1997_4' & `shbybin2_c0_4_0_1997_5' & `shbybin3_c0_4_0_1997_1' & `shbybin3_c0_4_0_1997_2' & `shbybin3_c0_4_0_1997_3' & `sh_c0_4_0_1997' \\" _n  ///
	"Health Services    & `shbybin1_c0_5_0_1997_1' & `shbybin1_c0_5_0_1997_2' & `shbybin1_c0_5_0_1997_3' & `shbybin2_c0_5_0_1997_1' & `shbybin2_c0_5_0_1997_2' & `shbybin2_c0_5_0_1997_3' & `shbybin2_c0_5_0_1997_4' & `shbybin2_c0_5_0_1997_5' & `shbybin3_c0_5_0_1997_1' & `shbybin3_c0_5_0_1997_2' & `shbybin3_c0_5_0_1997_3' & `sh_c0_5_0_1997' \\" _n  ///
	"Education   & `shbybin1_c0_6_0_1997_1' & `shbybin1_c0_6_0_1997_2' & `shbybin1_c0_6_0_1997_3' & `shbybin2_c0_6_0_1997_1' & `shbybin2_c0_6_0_1997_2' & `shbybin2_c0_6_0_1997_3' & `shbybin2_c0_6_0_1997_4' & `shbybin2_c0_6_0_1997_5' & `shbybin3_c0_6_0_1997_1' & `shbybin3_c0_6_0_1997_2' & `shbybin3_c0_6_0_1997_3' & `sh_c0_6_0_1997' \\" _n  ///
	"Semi Durables 	   & `shbybin1_c0_7_0_1997_1' & `shbybin1_c0_7_0_1997_2' & `shbybin1_c0_7_0_1997_3' & `shbybin2_c0_7_0_1997_1' & `shbybin2_c0_7_0_1997_2' & `shbybin2_c0_7_0_1997_3' & `shbybin2_c0_7_0_1997_4' & `shbybin2_c0_7_0_1997_5' & `shbybin3_c0_7_0_1997_1' & `shbybin3_c0_7_0_1997_2' & `shbybin3_c0_7_0_1997_3' & `sh_c0_7_0_1997' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"Labor        & `shbybin1_y1_1_0_1997_1' & `shbybin1_y1_1_0_1997_2' & `shbybin1_y1_1_0_1997_3' & `shbybin2_y1_1_0_1997_1' & `shbybin2_y1_1_0_1997_2' & `shbybin2_y1_1_0_1997_3' & `shbybin2_y1_1_0_1997_4' & `shbybin2_y1_1_0_1997_5' & `shbybin3_y1_1_0_1997_1' & `shbybin3_y1_1_0_1997_2' & `shbybin3_y1_1_0_1997_3' & `sh_y1_1_0_1997' \\" _n  ///
	"Agriculture  & `shbybin1_y1_2_0_1997_1' & `shbybin1_y1_2_0_1997_2' & `shbybin1_y1_2_0_1997_3' & `shbybin2_y1_2_0_1997_1' & `shbybin2_y1_2_0_1997_2' & `shbybin2_y1_2_0_1997_3' & `shbybin2_y1_2_0_1997_4' & `shbybin2_y1_2_0_1997_5' & `shbybin3_y1_2_0_1997_1' & `shbybin3_y1_2_0_1997_2' & `shbybin3_y1_2_0_1997_3' & `sh_y1_2_0_1997' \\" _n  ///
	"Business     & `shbybin1_y1_3_0_1997_1' & `shbybin1_y1_3_0_1997_2' & `shbybin1_y1_3_0_1997_3' & `shbybin2_y1_3_0_1997_1' & `shbybin2_y1_3_0_1997_2' & `shbybin2_y1_3_0_1997_3' & `shbybin2_y1_3_0_1997_4' & `shbybin2_y1_3_0_1997_5' & `shbybin3_y1_3_0_1997_1' & `shbybin3_y1_3_0_1997_2' & `shbybin3_y1_3_0_1997_3' & `sh_y1_3_0_1997' \\" _n  ///
	"Capital      & `shbybin1_y1_4_0_1997_1' & `shbybin1_y1_4_0_1997_2' & `shbybin1_y1_4_0_1997_3' & `shbybin2_y1_4_0_1997_1' & `shbybin2_y1_4_0_1997_2' & `shbybin2_y1_4_0_1997_3' & `shbybin2_y1_4_0_1997_4' & `shbybin2_y1_4_0_1997_5' & `shbybin3_y1_4_0_1997_1' & `shbybin3_y1_4_0_1997_2' & `shbybin3_y1_4_0_1997_3' & `sh_y1_4_0_1997' \\" _n  ///
	"Transfers Rec.  & `shbybin1_y1_5_0_1997_1' & `shbybin1_y1_5_0_1997_2' & `shbybin1_y1_5_0_1997_3' & `shbybin2_y1_5_0_1997_1' & `shbybin2_y1_5_0_1997_2' & `shbybin2_y1_5_0_1997_3' & `shbybin2_y1_5_0_1997_4' & `shbybin2_y1_5_0_1997_5' & `shbybin3_y1_5_0_1997_1' & `shbybin3_y1_5_0_1997_2' & `shbybin3_y1_5_0_1997_3' & `sh_y1_5_0_1997' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"Public Trans. Rec.  & `shbybin1_y1_51_0_1997_1' & `shbybin1_y1_51_0_1997_2' & `shbybin1_y1_51_0_1997_3' & `shbybin2_y1_51_0_1997_1' & `shbybin2_y1_51_0_1997_2' & `shbybin2_y1_51_0_1997_3' & `shbybin2_y1_51_0_1997_4' & `shbybin2_y1_51_0_1997_5' & `shbybin3_y1_51_0_1997_1' & `shbybin3_y1_51_0_1997_2' & `shbybin3_y1_51_0_1997_3' & `sh_y1_51_0_1997' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Food Coupons    & `shbybin1_y1_511_0_1997_1' & `shbybin1_y1_511_0_1997_2' & `shbybin1_y1_511_0_1997_3' & `shbybin2_y1_511_0_1997_1' & `shbybin2_y1_511_0_1997_2' & `shbybin2_y1_511_0_1997_3' & `shbybin2_y1_511_0_1997_4' & `shbybin2_y1_511_0_1997_5' & `shbybin3_y1_511_0_1997_1' & `shbybin3_y1_511_0_1997_2' & `shbybin3_y1_511_0_1997_3' & `sh_y1_511_0_1997' \\" _n  ///
	"\hspace{.3cm} Sub. Work Unit  & `shbybin1_y1_512_0_1997_1' & `shbybin1_y1_512_0_1997_2' & `shbybin1_y1_512_0_1997_3' & `shbybin2_y1_512_0_1997_1' & `shbybin2_y1_512_0_1997_2' & `shbybin2_y1_512_0_1997_3' & `shbybin2_y1_512_0_1997_4' & `shbybin2_y1_512_0_1997_5' & `shbybin3_y1_512_0_1997_1' & `shbybin3_y1_512_0_1997_2' & `shbybin3_y1_512_0_1997_3' & `sh_y1_512_0_1997' \\" _n  ///
	"\hspace{.3cm} Sub. Gov.       & `shbybin1_y1_513_0_1997_1' & `shbybin1_y1_513_0_1997_2' & `shbybin1_y1_513_0_1997_3' & `shbybin2_y1_513_0_1997_1' & `shbybin2_y1_513_0_1997_2' & `shbybin2_y1_513_0_1997_3' & `shbybin2_y1_513_0_1997_4' & `shbybin2_y1_513_0_1997_5' & `shbybin3_y1_513_0_1997_1' & `shbybin3_y1_513_0_1997_2' & `shbybin3_y1_513_0_1997_3' & `sh_y1_513_0_1997' \\" _n  ///
	"\hspace{.3cm} Pension         & `shbybin1_y1_514_0_1997_1' & `shbybin1_y1_514_0_1997_2' & `shbybin1_y1_514_0_1997_3' & `shbybin2_y1_514_0_1997_1' & `shbybin2_y1_514_0_1997_2' & `shbybin2_y1_514_0_1997_3' & `shbybin2_y1_514_0_1997_4' & `shbybin2_y1_514_0_1997_5' & `shbybin3_y1_514_0_1997_1' & `shbybin3_y1_514_0_1997_2' & `shbybin3_y1_514_0_1997_3' & `sh_y1_514_0_1997' \\" _n  ///
	"Private Trans. Rec. & `shbybin1_y1_52_0_1997_1' & `shbybin1_y1_52_0_1997_2' & `shbybin1_y1_52_0_1997_3' & `shbybin2_y1_52_0_1997_1' & `shbybin2_y1_52_0_1997_2' & `shbybin2_y1_52_0_1997_3' & `shbybin2_y1_52_0_1997_4' & `shbybin2_y1_52_0_1997_5' & `shbybin3_y1_52_0_1997_1' & `shbybin3_y1_52_0_1997_2' & `shbybin3_y1_52_0_1997_3' & `sh_y1_52_0_1997' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* URBAN 1997
	cap file close _all
	file open ofile using "Tables\table2_1997u_d.tex", write replace	
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
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"`shbybin1_c0_1_1_1997_1' & `shbybin1_c0_1_1_1997_2' & `shbybin1_c0_1_1_1997_3' & `shbybin2_c0_1_1_1997_1' & `shbybin2_c0_1_1_1997_2' & `shbybin2_c0_1_1_1997_3' & `shbybin2_c0_1_1_1997_4' & `shbybin2_c0_1_1_1997_5' & `shbybin3_c0_1_1_1997_1' & `shbybin3_c0_1_1_1997_2' & `shbybin3_c0_1_1_1997_3' & `sh_c0_1_1_1997' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_c0_11_1_1997_1' & `shbybin1_c0_11_1_1997_2' & `shbybin1_c0_11_1_1997_3' & `shbybin2_c0_11_1_1997_1' & `shbybin2_c0_11_1_1997_2' & `shbybin2_c0_11_1_1997_3' & `shbybin2_c0_11_1_1997_4' & `shbybin2_c0_11_1_1997_5' & `shbybin3_c0_11_1_1997_1' & `shbybin3_c0_11_1_1997_2' & `shbybin3_c0_11_1_1997_3' & `sh_c0_11_1_1997' \\" _n  ///
	"`shbybin1_c0_12_1_1997_1' & `shbybin1_c0_12_1_1997_2' & `shbybin1_c0_12_1_1997_3' & `shbybin2_c0_12_1_1997_1' & `shbybin2_c0_12_1_1997_2' & `shbybin2_c0_12_1_1997_3' & `shbybin2_c0_12_1_1997_4' & `shbybin2_c0_12_1_1997_5' & `shbybin3_c0_12_1_1997_1' & `shbybin3_c0_12_1_1997_2' & `shbybin3_c0_12_1_1997_3' & `sh_c0_12_1_1997' \\" _n  ///
	"`shbybin1_c0_13_1_1997_1' & `shbybin1_c0_13_1_1997_2' & `shbybin1_c0_13_1_1997_3' & `shbybin2_c0_13_1_1997_1' & `shbybin2_c0_13_1_1997_2' & `shbybin2_c0_13_1_1997_3' & `shbybin2_c0_13_1_1997_4' & `shbybin2_c0_13_1_1997_5' & `shbybin3_c0_13_1_1997_1' & `shbybin3_c0_13_1_1997_2' & `shbybin3_c0_13_1_1997_3' & `sh_c0_13_1_1997' \\" _n  ///
	"`shbybin1_c0_14_1_1997_1' & `shbybin1_c0_14_1_1997_2' & `shbybin1_c0_14_1_1997_3' & `shbybin2_c0_14_1_1997_1' & `shbybin2_c0_14_1_1997_2' & `shbybin2_c0_14_1_1997_3' & `shbybin2_c0_14_1_1997_4' & `shbybin2_c0_14_1_1997_5' & `shbybin3_c0_14_1_1997_1' & `shbybin3_c0_14_1_1997_2' & `shbybin3_c0_14_1_1997_3' & `sh_c0_14_1_1997' \\" _n  ///
	"`shbybin1_c0_2_1_1997_1' & `shbybin1_c0_2_1_1997_2' & `shbybin1_c0_2_1_1997_3' & `shbybin2_c0_2_1_1997_1' & `shbybin2_c0_2_1_1997_2' & `shbybin2_c0_2_1_1997_3' & `shbybin2_c0_2_1_1997_4' & `shbybin2_c0_2_1_1997_5' & `shbybin3_c0_2_1_1997_1' & `shbybin3_c0_2_1_1997_2' & `shbybin3_c0_2_1_1997_3' & `sh_c0_2_1_1997' \\" _n  ///
	"`shbybin1_c0_3_1_1997_1' & `shbybin1_c0_3_1_1997_2' & `shbybin1_c0_3_1_1997_3' & `shbybin2_c0_3_1_1997_1' & `shbybin2_c0_3_1_1997_2' & `shbybin2_c0_3_1_1997_3' & `shbybin2_c0_3_1_1997_4' & `shbybin2_c0_3_1_1997_5' & `shbybin3_c0_3_1_1997_1' & `shbybin3_c0_3_1_1997_2' & `shbybin3_c0_3_1_1997_3' & `sh_c0_3_1_1997' \\" _n  ///
	"`shbybin1_c0_4_1_1997_1' & `shbybin1_c0_4_1_1997_2' & `shbybin1_c0_4_1_1997_3' & `shbybin2_c0_4_1_1997_1' & `shbybin2_c0_4_1_1997_2' & `shbybin2_c0_4_1_1997_3' & `shbybin2_c0_4_1_1997_4' & `shbybin2_c0_4_1_1997_5' & `shbybin3_c0_4_1_1997_1' & `shbybin3_c0_4_1_1997_2' & `shbybin3_c0_4_1_1997_3' & `sh_c0_4_1_1997' \\" _n  ///
	"`shbybin1_c0_5_1_1997_1' & `shbybin1_c0_5_1_1997_2' & `shbybin1_c0_5_1_1997_3' & `shbybin2_c0_5_1_1997_1' & `shbybin2_c0_5_1_1997_2' & `shbybin2_c0_5_1_1997_3' & `shbybin2_c0_5_1_1997_4' & `shbybin2_c0_5_1_1997_5' & `shbybin3_c0_5_1_1997_1' & `shbybin3_c0_5_1_1997_2' & `shbybin3_c0_5_1_1997_3' & `sh_c0_5_1_1997' \\" _n  ///
	"`shbybin1_c0_6_1_1997_1' & `shbybin1_c0_6_1_1997_2' & `shbybin1_c0_6_1_1997_3' & `shbybin2_c0_6_1_1997_1' & `shbybin2_c0_6_1_1997_2' & `shbybin2_c0_6_1_1997_3' & `shbybin2_c0_6_1_1997_4' & `shbybin2_c0_6_1_1997_5' & `shbybin3_c0_6_1_1997_1' & `shbybin3_c0_6_1_1997_2' & `shbybin3_c0_6_1_1997_3' & `sh_c0_6_1_1997' \\" _n  ///
	"`shbybin1_c0_7_1_1997_1' & `shbybin1_c0_7_1_1997_2' & `shbybin1_c0_7_1_1997_3' & `shbybin2_c0_7_1_1997_1' & `shbybin2_c0_7_1_1997_2' & `shbybin2_c0_7_1_1997_3' & `shbybin2_c0_7_1_1997_4' & `shbybin2_c0_7_1_1997_5' & `shbybin3_c0_7_1_1997_1' & `shbybin3_c0_7_1_1997_2' & `shbybin3_c0_7_1_1997_3' & `sh_c0_7_1_1997' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_1_1_1997_1' & `shbybin1_y1_1_1_1997_2' & `shbybin1_y1_1_1_1997_3' & `shbybin2_y1_1_1_1997_1' & `shbybin2_y1_1_1_1997_2' & `shbybin2_y1_1_1_1997_3' & `shbybin2_y1_1_1_1997_4' & `shbybin2_y1_1_1_1997_5' & `shbybin3_y1_1_1_1997_1' & `shbybin3_y1_1_1_1997_2' & `shbybin3_y1_1_1_1997_3' & `sh_y1_1_1_1997' \\" _n  ///
	"`shbybin1_y1_2_1_1997_1' & `shbybin1_y1_2_1_1997_2' & `shbybin1_y1_2_1_1997_3' & `shbybin2_y1_2_1_1997_1' & `shbybin2_y1_2_1_1997_2' & `shbybin2_y1_2_1_1997_3' & `shbybin2_y1_2_1_1997_4' & `shbybin2_y1_2_1_1997_5' & `shbybin3_y1_2_1_1997_1' & `shbybin3_y1_2_1_1997_2' & `shbybin3_y1_2_1_1997_3' & `sh_y1_2_1_1997' \\" _n  ///
	"`shbybin1_y1_3_1_1997_1' & `shbybin1_y1_3_1_1997_2' & `shbybin1_y1_3_1_1997_3' & `shbybin2_y1_3_1_1997_1' & `shbybin2_y1_3_1_1997_2' & `shbybin2_y1_3_1_1997_3' & `shbybin2_y1_3_1_1997_4' & `shbybin2_y1_3_1_1997_5' & `shbybin3_y1_3_1_1997_1' & `shbybin3_y1_3_1_1997_2' & `shbybin3_y1_3_1_1997_3' & `sh_y1_3_1_1997' \\" _n  ///
	"`shbybin1_y1_4_1_1997_1' & `shbybin1_y1_4_1_1997_2' & `shbybin1_y1_4_1_1997_3' & `shbybin2_y1_4_1_1997_1' & `shbybin2_y1_4_1_1997_2' & `shbybin2_y1_4_1_1997_3' & `shbybin2_y1_4_1_1997_4' & `shbybin2_y1_4_1_1997_5' & `shbybin3_y1_4_1_1997_1' & `shbybin3_y1_4_1_1997_2' & `shbybin3_y1_4_1_1997_3' & `sh_y1_4_1_1997' \\" _n  ///
	"`shbybin1_y1_5_1_1997_1' & `shbybin1_y1_5_1_1997_2' & `shbybin1_y1_5_1_1997_3' & `shbybin2_y1_5_1_1997_1' & `shbybin2_y1_5_1_1997_2' & `shbybin2_y1_5_1_1997_3' & `shbybin2_y1_5_1_1997_4' & `shbybin2_y1_5_1_1997_5' & `shbybin3_y1_5_1_1997_1' & `shbybin3_y1_5_1_1997_2' & `shbybin3_y1_5_1_1997_3' & `sh_y1_5_1_1997' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_51_1_1997_1' & `shbybin1_y1_51_1_1997_2' & `shbybin1_y1_51_1_1997_3' & `shbybin2_y1_51_1_1997_1' & `shbybin2_y1_51_1_1997_2' & `shbybin2_y1_51_1_1997_3' & `shbybin2_y1_51_1_1997_4' & `shbybin2_y1_51_1_1997_5' & `shbybin3_y1_51_1_1997_1' & `shbybin3_y1_51_1_1997_2' & `shbybin3_y1_51_1_1997_3' & `sh_y1_51_1_1997' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_y1_511_1_1997_1' & `shbybin1_y1_511_1_1997_2' & `shbybin1_y1_511_1_1997_3' & `shbybin2_y1_511_1_1997_1' & `shbybin2_y1_511_1_1997_2' & `shbybin2_y1_511_1_1997_3' & `shbybin2_y1_511_1_1997_4' & `shbybin2_y1_511_1_1997_5' & `shbybin3_y1_511_1_1997_1' & `shbybin3_y1_511_1_1997_2' & `shbybin3_y1_511_1_1997_3' & `sh_y1_511_1_1997' \\" _n  ///
	"`shbybin1_y1_512_1_1997_1' & `shbybin1_y1_512_1_1997_2' & `shbybin1_y1_512_1_1997_3' & `shbybin2_y1_512_1_1997_1' & `shbybin2_y1_512_1_1997_2' & `shbybin2_y1_512_1_1997_3' & `shbybin2_y1_512_1_1997_4' & `shbybin2_y1_512_1_1997_5' & `shbybin3_y1_512_1_1997_1' & `shbybin3_y1_512_1_1997_2' & `shbybin3_y1_512_1_1997_3' & `sh_y1_512_1_1997' \\" _n  ///
	"`shbybin1_y1_513_1_1997_1' & `shbybin1_y1_513_1_1997_2' & `shbybin1_y1_513_1_1997_3' & `shbybin2_y1_513_1_1997_1' & `shbybin2_y1_513_1_1997_2' & `shbybin2_y1_513_1_1997_3' & `shbybin2_y1_513_1_1997_4' & `shbybin2_y1_513_1_1997_5' & `shbybin3_y1_513_1_1997_1' & `shbybin3_y1_513_1_1997_2' & `shbybin3_y1_513_1_1997_3' & `sh_y1_513_1_1997' \\" _n  ///
	"`shbybin1_y1_514_1_1997_1' & `shbybin1_y1_514_1_1997_2' & `shbybin1_y1_514_1_1997_3' & `shbybin2_y1_514_1_1997_1' & `shbybin2_y1_514_1_1997_2' & `shbybin2_y1_514_1_1997_3' & `shbybin2_y1_514_1_1997_4' & `shbybin2_y1_514_1_1997_5' & `shbybin3_y1_514_1_1997_1' & `shbybin3_y1_514_1_1997_2' & `shbybin3_y1_514_1_1997_3' & `sh_y1_514_1_1997' \\" _n  ///
	"`shbybin1_y1_52_1_1997_1' & `shbybin1_y1_52_1_1997_2' & `shbybin1_y1_52_1_1997_3' & `shbybin2_y1_52_1_1997_1' & `shbybin2_y1_52_1_1997_2' & `shbybin2_y1_52_1_1997_3' & `shbybin2_y1_52_1_1997_4' & `shbybin2_y1_52_1_1997_5' & `shbybin3_y1_52_1_1997_1' & `shbybin3_y1_52_1_1997_2' & `shbybin3_y1_52_1_1997_3' & `sh_y1_52_1_1997' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* RURAL 2000
	cap file close _all
	file open ofile using "Tables\table2_2000r_d.tex", write replace	
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
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"Food (Diet)  & `shbybin1_c0_1_0_2000_1' & `shbybin1_c0_1_0_2000_2' & `shbybin1_c0_1_0_2000_3' & `shbybin2_c0_1_0_2000_1' & `shbybin2_c0_1_0_2000_2' & `shbybin2_c0_1_0_2000_3' & `shbybin2_c0_1_0_2000_4' & `shbybin2_c0_1_0_2000_5' & `shbybin3_c0_1_0_2000_1' & `shbybin3_c0_1_0_2000_2' & `shbybin3_c0_1_0_2000_3' & `sh_c0_1_0_2000' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Own prod.  & `shbybin1_c0_11_0_2000_1' & `shbybin1_c0_11_0_2000_2' & `shbybin1_c0_11_0_2000_3' & `shbybin2_c0_11_0_2000_1' & `shbybin2_c0_11_0_2000_2' & `shbybin2_c0_11_0_2000_3' & `shbybin2_c0_11_0_2000_4' & `shbybin2_c0_11_0_2000_5' & `shbybin3_c0_11_0_2000_1' & `shbybin3_c0_11_0_2000_2' & `shbybin3_c0_11_0_2000_3' & `sh_c0_11_0_2000' \\" _n  ///
	"\hspace{.3cm} Coupons    & `shbybin1_c0_12_0_2000_1' & `shbybin1_c0_12_0_2000_2' & `shbybin1_c0_12_0_2000_3' & `shbybin2_c0_12_0_2000_1' & `shbybin2_c0_12_0_2000_2' & `shbybin2_c0_12_0_2000_3' & `shbybin2_c0_12_0_2000_4' & `shbybin2_c0_12_0_2000_5' & `shbybin3_c0_12_0_2000_1' & `shbybin3_c0_12_0_2000_2' & `shbybin3_c0_12_0_2000_3' & `sh_c0_12_0_2000' \\" _n  ///
	"\hspace{.3cm} Gifts	  & `shbybin1_c0_13_0_2000_1' & `shbybin1_c0_13_0_2000_2' & `shbybin1_c0_13_0_2000_3' & `shbybin2_c0_13_0_2000_1' & `shbybin2_c0_13_0_2000_2' & `shbybin2_c0_13_0_2000_3' & `shbybin2_c0_13_0_2000_4' & `shbybin2_c0_13_0_2000_5' & `shbybin3_c0_13_0_2000_1' & `shbybin3_c0_13_0_2000_2' & `shbybin3_c0_13_0_2000_3' & `sh_c0_13_0_2000' \\" _n  ///
	"\hspace{.3cm} Expenditures  & `shbybin1_c0_14_0_2000_1' & `shbybin1_c0_14_0_2000_2' & `shbybin1_c0_14_0_2000_3' & `shbybin2_c0_14_0_2000_1' & `shbybin2_c0_14_0_2000_2' & `shbybin2_c0_14_0_2000_3' & `shbybin2_c0_14_0_2000_4' & `shbybin2_c0_14_0_2000_5' & `shbybin3_c0_14_0_2000_1' & `shbybin3_c0_14_0_2000_2' & `shbybin3_c0_14_0_2000_3' & `sh_c0_14_0_2000' \\" _n  ///
	"Utilities    & `shbybin1_c0_2_0_2000_1' & `shbybin1_c0_2_0_2000_2' & `shbybin1_c0_2_0_2000_3' & `shbybin2_c0_2_0_2000_1' & `shbybin2_c0_2_0_2000_2' & `shbybin2_c0_2_0_2000_3' & `shbybin2_c0_2_0_2000_4' & `shbybin2_c0_2_0_2000_5' & `shbybin3_c0_2_0_2000_1' & `shbybin3_c0_2_0_2000_2' & `shbybin3_c0_2_0_2000_3' & `sh_c0_2_0_2000' \\" _n  ///
	"Housing Services  & `shbybin1_c0_3_0_2000_1' & `shbybin1_c0_3_0_2000_2' & `shbybin1_c0_3_0_2000_3' & `shbybin2_c0_3_0_2000_1' & `shbybin2_c0_3_0_2000_2' & `shbybin2_c0_3_0_2000_3' & `shbybin2_c0_3_0_2000_4' & `shbybin2_c0_3_0_2000_5' & `shbybin3_c0_3_0_2000_1' & `shbybin3_c0_3_0_2000_2' & `shbybin3_c0_3_0_2000_3' & `sh_c0_3_0_2000' \\" _n  ///
	"Child Care   & `shbybin1_c0_4_0_2000_1' & `shbybin1_c0_4_0_2000_2' & `shbybin1_c0_4_0_2000_3' & `shbybin2_c0_4_0_2000_1' & `shbybin2_c0_4_0_2000_2' & `shbybin2_c0_4_0_2000_3' & `shbybin2_c0_4_0_2000_4' & `shbybin2_c0_4_0_2000_5' & `shbybin3_c0_4_0_2000_1' & `shbybin3_c0_4_0_2000_2' & `shbybin3_c0_4_0_2000_3' & `sh_c0_4_0_2000' \\" _n  ///
	"Health Services    & `shbybin1_c0_5_0_2000_1' & `shbybin1_c0_5_0_2000_2' & `shbybin1_c0_5_0_2000_3' & `shbybin2_c0_5_0_2000_1' & `shbybin2_c0_5_0_2000_2' & `shbybin2_c0_5_0_2000_3' & `shbybin2_c0_5_0_2000_4' & `shbybin2_c0_5_0_2000_5' & `shbybin3_c0_5_0_2000_1' & `shbybin3_c0_5_0_2000_2' & `shbybin3_c0_5_0_2000_3' & `sh_c0_5_0_2000' \\" _n  ///
	"Education   & `shbybin1_c0_6_0_2000_1' & `shbybin1_c0_6_0_2000_2' & `shbybin1_c0_6_0_2000_3' & `shbybin2_c0_6_0_2000_1' & `shbybin2_c0_6_0_2000_2' & `shbybin2_c0_6_0_2000_3' & `shbybin2_c0_6_0_2000_4' & `shbybin2_c0_6_0_2000_5' & `shbybin3_c0_6_0_2000_1' & `shbybin3_c0_6_0_2000_2' & `shbybin3_c0_6_0_2000_3' & `sh_c0_6_0_2000' \\" _n  ///
	"Semi Durables 	   & `shbybin1_c0_7_0_2000_1' & `shbybin1_c0_7_0_2000_2' & `shbybin1_c0_7_0_2000_3' & `shbybin2_c0_7_0_2000_1' & `shbybin2_c0_7_0_2000_2' & `shbybin2_c0_7_0_2000_3' & `shbybin2_c0_7_0_2000_4' & `shbybin2_c0_7_0_2000_5' & `shbybin3_c0_7_0_2000_1' & `shbybin3_c0_7_0_2000_2' & `shbybin3_c0_7_0_2000_3' & `sh_c0_7_0_2000' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"Labor        & `shbybin1_y1_1_0_2000_1' & `shbybin1_y1_1_0_2000_2' & `shbybin1_y1_1_0_2000_3' & `shbybin2_y1_1_0_2000_1' & `shbybin2_y1_1_0_2000_2' & `shbybin2_y1_1_0_2000_3' & `shbybin2_y1_1_0_2000_4' & `shbybin2_y1_1_0_2000_5' & `shbybin3_y1_1_0_2000_1' & `shbybin3_y1_1_0_2000_2' & `shbybin3_y1_1_0_2000_3' & `sh_y1_1_0_2000' \\" _n  ///
	"Agriculture  & `shbybin1_y1_2_0_2000_1' & `shbybin1_y1_2_0_2000_2' & `shbybin1_y1_2_0_2000_3' & `shbybin2_y1_2_0_2000_1' & `shbybin2_y1_2_0_2000_2' & `shbybin2_y1_2_0_2000_3' & `shbybin2_y1_2_0_2000_4' & `shbybin2_y1_2_0_2000_5' & `shbybin3_y1_2_0_2000_1' & `shbybin3_y1_2_0_2000_2' & `shbybin3_y1_2_0_2000_3' & `sh_y1_2_0_2000' \\" _n  ///
	"Business     & `shbybin1_y1_3_0_2000_1' & `shbybin1_y1_3_0_2000_2' & `shbybin1_y1_3_0_2000_3' & `shbybin2_y1_3_0_2000_1' & `shbybin2_y1_3_0_2000_2' & `shbybin2_y1_3_0_2000_3' & `shbybin2_y1_3_0_2000_4' & `shbybin2_y1_3_0_2000_5' & `shbybin3_y1_3_0_2000_1' & `shbybin3_y1_3_0_2000_2' & `shbybin3_y1_3_0_2000_3' & `sh_y1_3_0_2000' \\" _n  ///
	"Capital      & `shbybin1_y1_4_0_2000_1' & `shbybin1_y1_4_0_2000_2' & `shbybin1_y1_4_0_2000_3' & `shbybin2_y1_4_0_2000_1' & `shbybin2_y1_4_0_2000_2' & `shbybin2_y1_4_0_2000_3' & `shbybin2_y1_4_0_2000_4' & `shbybin2_y1_4_0_2000_5' & `shbybin3_y1_4_0_2000_1' & `shbybin3_y1_4_0_2000_2' & `shbybin3_y1_4_0_2000_3' & `sh_y1_4_0_2000' \\" _n  ///
	"Transfers Rec.  & `shbybin1_y1_5_0_2000_1' & `shbybin1_y1_5_0_2000_2' & `shbybin1_y1_5_0_2000_3' & `shbybin2_y1_5_0_2000_1' & `shbybin2_y1_5_0_2000_2' & `shbybin2_y1_5_0_2000_3' & `shbybin2_y1_5_0_2000_4' & `shbybin2_y1_5_0_2000_5' & `shbybin3_y1_5_0_2000_1' & `shbybin3_y1_5_0_2000_2' & `shbybin3_y1_5_0_2000_3' & `sh_y1_5_0_2000' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"Public Trans. Rec.  & `shbybin1_y1_51_0_2000_1' & `shbybin1_y1_51_0_2000_2' & `shbybin1_y1_51_0_2000_3' & `shbybin2_y1_51_0_2000_1' & `shbybin2_y1_51_0_2000_2' & `shbybin2_y1_51_0_2000_3' & `shbybin2_y1_51_0_2000_4' & `shbybin2_y1_51_0_2000_5' & `shbybin3_y1_51_0_2000_1' & `shbybin3_y1_51_0_2000_2' & `shbybin3_y1_51_0_2000_3' & `sh_y1_51_0_2000' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Food Coupons    & `shbybin1_y1_511_0_2000_1' & `shbybin1_y1_511_0_2000_2' & `shbybin1_y1_511_0_2000_3' & `shbybin2_y1_511_0_2000_1' & `shbybin2_y1_511_0_2000_2' & `shbybin2_y1_511_0_2000_3' & `shbybin2_y1_511_0_2000_4' & `shbybin2_y1_511_0_2000_5' & `shbybin3_y1_511_0_2000_1' & `shbybin3_y1_511_0_2000_2' & `shbybin3_y1_511_0_2000_3' & `sh_y1_511_0_2000' \\" _n  ///
	"\hspace{.3cm} Sub. Work Unit  & `shbybin1_y1_512_0_2000_1' & `shbybin1_y1_512_0_2000_2' & `shbybin1_y1_512_0_2000_3' & `shbybin2_y1_512_0_2000_1' & `shbybin2_y1_512_0_2000_2' & `shbybin2_y1_512_0_2000_3' & `shbybin2_y1_512_0_2000_4' & `shbybin2_y1_512_0_2000_5' & `shbybin3_y1_512_0_2000_1' & `shbybin3_y1_512_0_2000_2' & `shbybin3_y1_512_0_2000_3' & `sh_y1_512_0_2000' \\" _n  ///
	"\hspace{.3cm} Sub. Gov.       & `shbybin1_y1_513_0_2000_1' & `shbybin1_y1_513_0_2000_2' & `shbybin1_y1_513_0_2000_3' & `shbybin2_y1_513_0_2000_1' & `shbybin2_y1_513_0_2000_2' & `shbybin2_y1_513_0_2000_3' & `shbybin2_y1_513_0_2000_4' & `shbybin2_y1_513_0_2000_5' & `shbybin3_y1_513_0_2000_1' & `shbybin3_y1_513_0_2000_2' & `shbybin3_y1_513_0_2000_3' & `sh_y1_513_0_2000' \\" _n  ///
	"\hspace{.3cm} Pension         & `shbybin1_y1_514_0_2000_1' & `shbybin1_y1_514_0_2000_2' & `shbybin1_y1_514_0_2000_3' & `shbybin2_y1_514_0_2000_1' & `shbybin2_y1_514_0_2000_2' & `shbybin2_y1_514_0_2000_3' & `shbybin2_y1_514_0_2000_4' & `shbybin2_y1_514_0_2000_5' & `shbybin3_y1_514_0_2000_1' & `shbybin3_y1_514_0_2000_2' & `shbybin3_y1_514_0_2000_3' & `sh_y1_514_0_2000' \\" _n  ///
	"Private Trans. Rec. & `shbybin1_y1_52_0_2000_1' & `shbybin1_y1_52_0_2000_2' & `shbybin1_y1_52_0_2000_3' & `shbybin2_y1_52_0_2000_1' & `shbybin2_y1_52_0_2000_2' & `shbybin2_y1_52_0_2000_3' & `shbybin2_y1_52_0_2000_4' & `shbybin2_y1_52_0_2000_5' & `shbybin3_y1_52_0_2000_1' & `shbybin3_y1_52_0_2000_2' & `shbybin3_y1_52_0_2000_3' & `sh_y1_52_0_2000' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* URBAN 2000
	cap file close _all
	file open ofile using "Tables\table2_2000u_d.tex", write replace	
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
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"`shbybin1_c0_1_1_2000_1' & `shbybin1_c0_1_1_2000_2' & `shbybin1_c0_1_1_2000_3' & `shbybin2_c0_1_1_2000_1' & `shbybin2_c0_1_1_2000_2' & `shbybin2_c0_1_1_2000_3' & `shbybin2_c0_1_1_2000_4' & `shbybin2_c0_1_1_2000_5' & `shbybin3_c0_1_1_2000_1' & `shbybin3_c0_1_1_2000_2' & `shbybin3_c0_1_1_2000_3' & `sh_c0_1_1_2000' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_c0_11_1_2000_1' & `shbybin1_c0_11_1_2000_2' & `shbybin1_c0_11_1_2000_3' & `shbybin2_c0_11_1_2000_1' & `shbybin2_c0_11_1_2000_2' & `shbybin2_c0_11_1_2000_3' & `shbybin2_c0_11_1_2000_4' & `shbybin2_c0_11_1_2000_5' & `shbybin3_c0_11_1_2000_1' & `shbybin3_c0_11_1_2000_2' & `shbybin3_c0_11_1_2000_3' & `sh_c0_11_1_2000' \\" _n  ///
	"`shbybin1_c0_12_1_2000_1' & `shbybin1_c0_12_1_2000_2' & `shbybin1_c0_12_1_2000_3' & `shbybin2_c0_12_1_2000_1' & `shbybin2_c0_12_1_2000_2' & `shbybin2_c0_12_1_2000_3' & `shbybin2_c0_12_1_2000_4' & `shbybin2_c0_12_1_2000_5' & `shbybin3_c0_12_1_2000_1' & `shbybin3_c0_12_1_2000_2' & `shbybin3_c0_12_1_2000_3' & `sh_c0_12_1_2000' \\" _n  ///
	"`shbybin1_c0_13_1_2000_1' & `shbybin1_c0_13_1_2000_2' & `shbybin1_c0_13_1_2000_3' & `shbybin2_c0_13_1_2000_1' & `shbybin2_c0_13_1_2000_2' & `shbybin2_c0_13_1_2000_3' & `shbybin2_c0_13_1_2000_4' & `shbybin2_c0_13_1_2000_5' & `shbybin3_c0_13_1_2000_1' & `shbybin3_c0_13_1_2000_2' & `shbybin3_c0_13_1_2000_3' & `sh_c0_13_1_2000' \\" _n  ///
	"`shbybin1_c0_14_1_2000_1' & `shbybin1_c0_14_1_2000_2' & `shbybin1_c0_14_1_2000_3' & `shbybin2_c0_14_1_2000_1' & `shbybin2_c0_14_1_2000_2' & `shbybin2_c0_14_1_2000_3' & `shbybin2_c0_14_1_2000_4' & `shbybin2_c0_14_1_2000_5' & `shbybin3_c0_14_1_2000_1' & `shbybin3_c0_14_1_2000_2' & `shbybin3_c0_14_1_2000_3' & `sh_c0_14_1_2000' \\" _n  ///
	"`shbybin1_c0_2_1_2000_1' & `shbybin1_c0_2_1_2000_2' & `shbybin1_c0_2_1_2000_3' & `shbybin2_c0_2_1_2000_1' & `shbybin2_c0_2_1_2000_2' & `shbybin2_c0_2_1_2000_3' & `shbybin2_c0_2_1_2000_4' & `shbybin2_c0_2_1_2000_5' & `shbybin3_c0_2_1_2000_1' & `shbybin3_c0_2_1_2000_2' & `shbybin3_c0_2_1_2000_3' & `sh_c0_2_1_2000' \\" _n  ///
	"`shbybin1_c0_3_1_2000_1' & `shbybin1_c0_3_1_2000_2' & `shbybin1_c0_3_1_2000_3' & `shbybin2_c0_3_1_2000_1' & `shbybin2_c0_3_1_2000_2' & `shbybin2_c0_3_1_2000_3' & `shbybin2_c0_3_1_2000_4' & `shbybin2_c0_3_1_2000_5' & `shbybin3_c0_3_1_2000_1' & `shbybin3_c0_3_1_2000_2' & `shbybin3_c0_3_1_2000_3' & `sh_c0_3_1_2000' \\" _n  ///
	"`shbybin1_c0_4_1_2000_1' & `shbybin1_c0_4_1_2000_2' & `shbybin1_c0_4_1_2000_3' & `shbybin2_c0_4_1_2000_1' & `shbybin2_c0_4_1_2000_2' & `shbybin2_c0_4_1_2000_3' & `shbybin2_c0_4_1_2000_4' & `shbybin2_c0_4_1_2000_5' & `shbybin3_c0_4_1_2000_1' & `shbybin3_c0_4_1_2000_2' & `shbybin3_c0_4_1_2000_3' & `sh_c0_4_1_2000' \\" _n  ///
	"`shbybin1_c0_5_1_2000_1' & `shbybin1_c0_5_1_2000_2' & `shbybin1_c0_5_1_2000_3' & `shbybin2_c0_5_1_2000_1' & `shbybin2_c0_5_1_2000_2' & `shbybin2_c0_5_1_2000_3' & `shbybin2_c0_5_1_2000_4' & `shbybin2_c0_5_1_2000_5' & `shbybin3_c0_5_1_2000_1' & `shbybin3_c0_5_1_2000_2' & `shbybin3_c0_5_1_2000_3' & `sh_c0_5_1_2000' \\" _n  ///
	"`shbybin1_c0_6_1_2000_1' & `shbybin1_c0_6_1_2000_2' & `shbybin1_c0_6_1_2000_3' & `shbybin2_c0_6_1_2000_1' & `shbybin2_c0_6_1_2000_2' & `shbybin2_c0_6_1_2000_3' & `shbybin2_c0_6_1_2000_4' & `shbybin2_c0_6_1_2000_5' & `shbybin3_c0_6_1_2000_1' & `shbybin3_c0_6_1_2000_2' & `shbybin3_c0_6_1_2000_3' & `sh_c0_6_1_2000' \\" _n  ///
	"`shbybin1_c0_7_1_2000_1' & `shbybin1_c0_7_1_2000_2' & `shbybin1_c0_7_1_2000_3' & `shbybin2_c0_7_1_2000_1' & `shbybin2_c0_7_1_2000_2' & `shbybin2_c0_7_1_2000_3' & `shbybin2_c0_7_1_2000_4' & `shbybin2_c0_7_1_2000_5' & `shbybin3_c0_7_1_2000_1' & `shbybin3_c0_7_1_2000_2' & `shbybin3_c0_7_1_2000_3' & `sh_c0_7_1_2000' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_1_1_2000_1' & `shbybin1_y1_1_1_2000_2' & `shbybin1_y1_1_1_2000_3' & `shbybin2_y1_1_1_2000_1' & `shbybin2_y1_1_1_2000_2' & `shbybin2_y1_1_1_2000_3' & `shbybin2_y1_1_1_2000_4' & `shbybin2_y1_1_1_2000_5' & `shbybin3_y1_1_1_2000_1' & `shbybin3_y1_1_1_2000_2' & `shbybin3_y1_1_1_2000_3' & `sh_y1_1_1_2000' \\" _n  ///
	"`shbybin1_y1_2_1_2000_1' & `shbybin1_y1_2_1_2000_2' & `shbybin1_y1_2_1_2000_3' & `shbybin2_y1_2_1_2000_1' & `shbybin2_y1_2_1_2000_2' & `shbybin2_y1_2_1_2000_3' & `shbybin2_y1_2_1_2000_4' & `shbybin2_y1_2_1_2000_5' & `shbybin3_y1_2_1_2000_1' & `shbybin3_y1_2_1_2000_2' & `shbybin3_y1_2_1_2000_3' & `sh_y1_2_1_2000' \\" _n  ///
	"`shbybin1_y1_3_1_2000_1' & `shbybin1_y1_3_1_2000_2' & `shbybin1_y1_3_1_2000_3' & `shbybin2_y1_3_1_2000_1' & `shbybin2_y1_3_1_2000_2' & `shbybin2_y1_3_1_2000_3' & `shbybin2_y1_3_1_2000_4' & `shbybin2_y1_3_1_2000_5' & `shbybin3_y1_3_1_2000_1' & `shbybin3_y1_3_1_2000_2' & `shbybin3_y1_3_1_2000_3' & `sh_y1_3_1_2000' \\" _n  ///
	"`shbybin1_y1_4_1_2000_1' & `shbybin1_y1_4_1_2000_2' & `shbybin1_y1_4_1_2000_3' & `shbybin2_y1_4_1_2000_1' & `shbybin2_y1_4_1_2000_2' & `shbybin2_y1_4_1_2000_3' & `shbybin2_y1_4_1_2000_4' & `shbybin2_y1_4_1_2000_5' & `shbybin3_y1_4_1_2000_1' & `shbybin3_y1_4_1_2000_2' & `shbybin3_y1_4_1_2000_3' & `sh_y1_4_1_2000' \\" _n  ///
	"`shbybin1_y1_5_1_2000_1' & `shbybin1_y1_5_1_2000_2' & `shbybin1_y1_5_1_2000_3' & `shbybin2_y1_5_1_2000_1' & `shbybin2_y1_5_1_2000_2' & `shbybin2_y1_5_1_2000_3' & `shbybin2_y1_5_1_2000_4' & `shbybin2_y1_5_1_2000_5' & `shbybin3_y1_5_1_2000_1' & `shbybin3_y1_5_1_2000_2' & `shbybin3_y1_5_1_2000_3' & `sh_y1_5_1_2000' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_51_1_2000_1' & `shbybin1_y1_51_1_2000_2' & `shbybin1_y1_51_1_2000_3' & `shbybin2_y1_51_1_2000_1' & `shbybin2_y1_51_1_2000_2' & `shbybin2_y1_51_1_2000_3' & `shbybin2_y1_51_1_2000_4' & `shbybin2_y1_51_1_2000_5' & `shbybin3_y1_51_1_2000_1' & `shbybin3_y1_51_1_2000_2' & `shbybin3_y1_51_1_2000_3' & `sh_y1_51_1_2000' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_y1_511_1_2000_1' & `shbybin1_y1_511_1_2000_2' & `shbybin1_y1_511_1_2000_3' & `shbybin2_y1_511_1_2000_1' & `shbybin2_y1_511_1_2000_2' & `shbybin2_y1_511_1_2000_3' & `shbybin2_y1_511_1_2000_4' & `shbybin2_y1_511_1_2000_5' & `shbybin3_y1_511_1_2000_1' & `shbybin3_y1_511_1_2000_2' & `shbybin3_y1_511_1_2000_3' & `sh_y1_511_1_2000' \\" _n  ///
	"`shbybin1_y1_512_1_2000_1' & `shbybin1_y1_512_1_2000_2' & `shbybin1_y1_512_1_2000_3' & `shbybin2_y1_512_1_2000_1' & `shbybin2_y1_512_1_2000_2' & `shbybin2_y1_512_1_2000_3' & `shbybin2_y1_512_1_2000_4' & `shbybin2_y1_512_1_2000_5' & `shbybin3_y1_512_1_2000_1' & `shbybin3_y1_512_1_2000_2' & `shbybin3_y1_512_1_2000_3' & `sh_y1_512_1_2000' \\" _n  ///
	"`shbybin1_y1_513_1_2000_1' & `shbybin1_y1_513_1_2000_2' & `shbybin1_y1_513_1_2000_3' & `shbybin2_y1_513_1_2000_1' & `shbybin2_y1_513_1_2000_2' & `shbybin2_y1_513_1_2000_3' & `shbybin2_y1_513_1_2000_4' & `shbybin2_y1_513_1_2000_5' & `shbybin3_y1_513_1_2000_1' & `shbybin3_y1_513_1_2000_2' & `shbybin3_y1_513_1_2000_3' & `sh_y1_513_1_2000' \\" _n  ///
	"`shbybin1_y1_514_1_2000_1' & `shbybin1_y1_514_1_2000_2' & `shbybin1_y1_514_1_2000_3' & `shbybin2_y1_514_1_2000_1' & `shbybin2_y1_514_1_2000_2' & `shbybin2_y1_514_1_2000_3' & `shbybin2_y1_514_1_2000_4' & `shbybin2_y1_514_1_2000_5' & `shbybin3_y1_514_1_2000_1' & `shbybin3_y1_514_1_2000_2' & `shbybin3_y1_514_1_2000_3' & `sh_y1_514_1_2000' \\" _n  ///
	"`shbybin1_y1_52_1_2000_1' & `shbybin1_y1_52_1_2000_2' & `shbybin1_y1_52_1_2000_3' & `shbybin2_y1_52_1_2000_1' & `shbybin2_y1_52_1_2000_2' & `shbybin2_y1_52_1_2000_3' & `shbybin2_y1_52_1_2000_4' & `shbybin2_y1_52_1_2000_5' & `shbybin3_y1_52_1_2000_1' & `shbybin3_y1_52_1_2000_2' & `shbybin3_y1_52_1_2000_3' & `sh_y1_52_1_2000' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all

	* RURAL 2004
	cap file close _all
	file open ofile using "Tables\table2_2004r_d.tex", write replace	
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
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"Food (Diet)  & `shbybin1_c0_1_0_2004_1' & `shbybin1_c0_1_0_2004_2' & `shbybin1_c0_1_0_2004_3' & `shbybin2_c0_1_0_2004_1' & `shbybin2_c0_1_0_2004_2' & `shbybin2_c0_1_0_2004_3' & `shbybin2_c0_1_0_2004_4' & `shbybin2_c0_1_0_2004_5' & `shbybin3_c0_1_0_2004_1' & `shbybin3_c0_1_0_2004_2' & `shbybin3_c0_1_0_2004_3' & `sh_c0_1_0_2004' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Own prod.  & `shbybin1_c0_11_0_2004_1' & `shbybin1_c0_11_0_2004_2' & `shbybin1_c0_11_0_2004_3' & `shbybin2_c0_11_0_2004_1' & `shbybin2_c0_11_0_2004_2' & `shbybin2_c0_11_0_2004_3' & `shbybin2_c0_11_0_2004_4' & `shbybin2_c0_11_0_2004_5' & `shbybin3_c0_11_0_2004_1' & `shbybin3_c0_11_0_2004_2' & `shbybin3_c0_11_0_2004_3' & `sh_c0_11_0_2004' \\" _n  ///
	"\hspace{.3cm} Coupons    & `shbybin1_c0_12_0_2004_1' & `shbybin1_c0_12_0_2004_2' & `shbybin1_c0_12_0_2004_3' & `shbybin2_c0_12_0_2004_1' & `shbybin2_c0_12_0_2004_2' & `shbybin2_c0_12_0_2004_3' & `shbybin2_c0_12_0_2004_4' & `shbybin2_c0_12_0_2004_5' & `shbybin3_c0_12_0_2004_1' & `shbybin3_c0_12_0_2004_2' & `shbybin3_c0_12_0_2004_3' & `sh_c0_12_0_2004' \\" _n  ///
	"\hspace{.3cm} Gifts	  & `shbybin1_c0_13_0_2004_1' & `shbybin1_c0_13_0_2004_2' & `shbybin1_c0_13_0_2004_3' & `shbybin2_c0_13_0_2004_1' & `shbybin2_c0_13_0_2004_2' & `shbybin2_c0_13_0_2004_3' & `shbybin2_c0_13_0_2004_4' & `shbybin2_c0_13_0_2004_5' & `shbybin3_c0_13_0_2004_1' & `shbybin3_c0_13_0_2004_2' & `shbybin3_c0_13_0_2004_3' & `sh_c0_13_0_2004' \\" _n  ///
	"\hspace{.3cm} Expenditures  & `shbybin1_c0_14_0_2004_1' & `shbybin1_c0_14_0_2004_2' & `shbybin1_c0_14_0_2004_3' & `shbybin2_c0_14_0_2004_1' & `shbybin2_c0_14_0_2004_2' & `shbybin2_c0_14_0_2004_3' & `shbybin2_c0_14_0_2004_4' & `shbybin2_c0_14_0_2004_5' & `shbybin3_c0_14_0_2004_1' & `shbybin3_c0_14_0_2004_2' & `shbybin3_c0_14_0_2004_3' & `sh_c0_14_0_2004' \\" _n  ///
	"Utilities    & `shbybin1_c0_2_0_2004_1' & `shbybin1_c0_2_0_2004_2' & `shbybin1_c0_2_0_2004_3' & `shbybin2_c0_2_0_2004_1' & `shbybin2_c0_2_0_2004_2' & `shbybin2_c0_2_0_2004_3' & `shbybin2_c0_2_0_2004_4' & `shbybin2_c0_2_0_2004_5' & `shbybin3_c0_2_0_2004_1' & `shbybin3_c0_2_0_2004_2' & `shbybin3_c0_2_0_2004_3' & `sh_c0_2_0_2004' \\" _n  ///
	"Housing Services  & `shbybin1_c0_3_0_2004_1' & `shbybin1_c0_3_0_2004_2' & `shbybin1_c0_3_0_2004_3' & `shbybin2_c0_3_0_2004_1' & `shbybin2_c0_3_0_2004_2' & `shbybin2_c0_3_0_2004_3' & `shbybin2_c0_3_0_2004_4' & `shbybin2_c0_3_0_2004_5' & `shbybin3_c0_3_0_2004_1' & `shbybin3_c0_3_0_2004_2' & `shbybin3_c0_3_0_2004_3' & `sh_c0_3_0_2004' \\" _n  ///
	"Child Care   & `shbybin1_c0_4_0_2004_1' & `shbybin1_c0_4_0_2004_2' & `shbybin1_c0_4_0_2004_3' & `shbybin2_c0_4_0_2004_1' & `shbybin2_c0_4_0_2004_2' & `shbybin2_c0_4_0_2004_3' & `shbybin2_c0_4_0_2004_4' & `shbybin2_c0_4_0_2004_5' & `shbybin3_c0_4_0_2004_1' & `shbybin3_c0_4_0_2004_2' & `shbybin3_c0_4_0_2004_3' & `sh_c0_4_0_2004' \\" _n  ///
	"Health Services    & `shbybin1_c0_5_0_2004_1' & `shbybin1_c0_5_0_2004_2' & `shbybin1_c0_5_0_2004_3' & `shbybin2_c0_5_0_2004_1' & `shbybin2_c0_5_0_2004_2' & `shbybin2_c0_5_0_2004_3' & `shbybin2_c0_5_0_2004_4' & `shbybin2_c0_5_0_2004_5' & `shbybin3_c0_5_0_2004_1' & `shbybin3_c0_5_0_2004_2' & `shbybin3_c0_5_0_2004_3' & `sh_c0_5_0_2004' \\" _n  ///
	"Education   & `shbybin1_c0_6_0_2004_1' & `shbybin1_c0_6_0_2004_2' & `shbybin1_c0_6_0_2004_3' & `shbybin2_c0_6_0_2004_1' & `shbybin2_c0_6_0_2004_2' & `shbybin2_c0_6_0_2004_3' & `shbybin2_c0_6_0_2004_4' & `shbybin2_c0_6_0_2004_5' & `shbybin3_c0_6_0_2004_1' & `shbybin3_c0_6_0_2004_2' & `shbybin3_c0_6_0_2004_3' & `sh_c0_6_0_2004' \\" _n  ///
	"Semi Durables 	   & `shbybin1_c0_7_0_2004_1' & `shbybin1_c0_7_0_2004_2' & `shbybin1_c0_7_0_2004_3' & `shbybin2_c0_7_0_2004_1' & `shbybin2_c0_7_0_2004_2' & `shbybin2_c0_7_0_2004_3' & `shbybin2_c0_7_0_2004_4' & `shbybin2_c0_7_0_2004_5' & `shbybin3_c0_7_0_2004_1' & `shbybin3_c0_7_0_2004_2' & `shbybin3_c0_7_0_2004_3' & `sh_c0_7_0_2004' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"Labor        & `shbybin1_y1_1_0_2004_1' & `shbybin1_y1_1_0_2004_2' & `shbybin1_y1_1_0_2004_3' & `shbybin2_y1_1_0_2004_1' & `shbybin2_y1_1_0_2004_2' & `shbybin2_y1_1_0_2004_3' & `shbybin2_y1_1_0_2004_4' & `shbybin2_y1_1_0_2004_5' & `shbybin3_y1_1_0_2004_1' & `shbybin3_y1_1_0_2004_2' & `shbybin3_y1_1_0_2004_3' & `sh_y1_1_0_2004' \\" _n  ///
	"Agriculture  & `shbybin1_y1_2_0_2004_1' & `shbybin1_y1_2_0_2004_2' & `shbybin1_y1_2_0_2004_3' & `shbybin2_y1_2_0_2004_1' & `shbybin2_y1_2_0_2004_2' & `shbybin2_y1_2_0_2004_3' & `shbybin2_y1_2_0_2004_4' & `shbybin2_y1_2_0_2004_5' & `shbybin3_y1_2_0_2004_1' & `shbybin3_y1_2_0_2004_2' & `shbybin3_y1_2_0_2004_3' & `sh_y1_2_0_2004' \\" _n  ///
	"Business     & `shbybin1_y1_3_0_2004_1' & `shbybin1_y1_3_0_2004_2' & `shbybin1_y1_3_0_2004_3' & `shbybin2_y1_3_0_2004_1' & `shbybin2_y1_3_0_2004_2' & `shbybin2_y1_3_0_2004_3' & `shbybin2_y1_3_0_2004_4' & `shbybin2_y1_3_0_2004_5' & `shbybin3_y1_3_0_2004_1' & `shbybin3_y1_3_0_2004_2' & `shbybin3_y1_3_0_2004_3' & `sh_y1_3_0_2004' \\" _n  ///
	"Capital      & `shbybin1_y1_4_0_2004_1' & `shbybin1_y1_4_0_2004_2' & `shbybin1_y1_4_0_2004_3' & `shbybin2_y1_4_0_2004_1' & `shbybin2_y1_4_0_2004_2' & `shbybin2_y1_4_0_2004_3' & `shbybin2_y1_4_0_2004_4' & `shbybin2_y1_4_0_2004_5' & `shbybin3_y1_4_0_2004_1' & `shbybin3_y1_4_0_2004_2' & `shbybin3_y1_4_0_2004_3' & `sh_y1_4_0_2004' \\" _n  ///
	"Transfers Rec.  & `shbybin1_y1_5_0_2004_1' & `shbybin1_y1_5_0_2004_2' & `shbybin1_y1_5_0_2004_3' & `shbybin2_y1_5_0_2004_1' & `shbybin2_y1_5_0_2004_2' & `shbybin2_y1_5_0_2004_3' & `shbybin2_y1_5_0_2004_4' & `shbybin2_y1_5_0_2004_5' & `shbybin3_y1_5_0_2004_1' & `shbybin3_y1_5_0_2004_2' & `shbybin3_y1_5_0_2004_3' & `sh_y1_5_0_2004' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"Public Trans. Rec.  & `shbybin1_y1_51_0_2004_1' & `shbybin1_y1_51_0_2004_2' & `shbybin1_y1_51_0_2004_3' & `shbybin2_y1_51_0_2004_1' & `shbybin2_y1_51_0_2004_2' & `shbybin2_y1_51_0_2004_3' & `shbybin2_y1_51_0_2004_4' & `shbybin2_y1_51_0_2004_5' & `shbybin3_y1_51_0_2004_1' & `shbybin3_y1_51_0_2004_2' & `shbybin3_y1_51_0_2004_3' & `sh_y1_51_0_2004' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Food Coupons    & `shbybin1_y1_511_0_2004_1' & `shbybin1_y1_511_0_2004_2' & `shbybin1_y1_511_0_2004_3' & `shbybin2_y1_511_0_2004_1' & `shbybin2_y1_511_0_2004_2' & `shbybin2_y1_511_0_2004_3' & `shbybin2_y1_511_0_2004_4' & `shbybin2_y1_511_0_2004_5' & `shbybin3_y1_511_0_2004_1' & `shbybin3_y1_511_0_2004_2' & `shbybin3_y1_511_0_2004_3' & `sh_y1_511_0_2004' \\" _n  ///
	"\hspace{.3cm} Sub. Work Unit  & `shbybin1_y1_512_0_2004_1' & `shbybin1_y1_512_0_2004_2' & `shbybin1_y1_512_0_2004_3' & `shbybin2_y1_512_0_2004_1' & `shbybin2_y1_512_0_2004_2' & `shbybin2_y1_512_0_2004_3' & `shbybin2_y1_512_0_2004_4' & `shbybin2_y1_512_0_2004_5' & `shbybin3_y1_512_0_2004_1' & `shbybin3_y1_512_0_2004_2' & `shbybin3_y1_512_0_2004_3' & `sh_y1_512_0_2004' \\" _n  ///
	"\hspace{.3cm} Sub. Gov.       & `shbybin1_y1_513_0_2004_1' & `shbybin1_y1_513_0_2004_2' & `shbybin1_y1_513_0_2004_3' & `shbybin2_y1_513_0_2004_1' & `shbybin2_y1_513_0_2004_2' & `shbybin2_y1_513_0_2004_3' & `shbybin2_y1_513_0_2004_4' & `shbybin2_y1_513_0_2004_5' & `shbybin3_y1_513_0_2004_1' & `shbybin3_y1_513_0_2004_2' & `shbybin3_y1_513_0_2004_3' & `sh_y1_513_0_2004' \\" _n  ///
	"\hspace{.3cm} Pension         & `shbybin1_y1_514_0_2004_1' & `shbybin1_y1_514_0_2004_2' & `shbybin1_y1_514_0_2004_3' & `shbybin2_y1_514_0_2004_1' & `shbybin2_y1_514_0_2004_2' & `shbybin2_y1_514_0_2004_3' & `shbybin2_y1_514_0_2004_4' & `shbybin2_y1_514_0_2004_5' & `shbybin3_y1_514_0_2004_1' & `shbybin3_y1_514_0_2004_2' & `shbybin3_y1_514_0_2004_3' & `sh_y1_514_0_2004' \\" _n  ///
	"Private Trans. Rec. & `shbybin1_y1_52_0_2004_1' & `shbybin1_y1_52_0_2004_2' & `shbybin1_y1_52_0_2004_3' & `shbybin2_y1_52_0_2004_1' & `shbybin2_y1_52_0_2004_2' & `shbybin2_y1_52_0_2004_3' & `shbybin2_y1_52_0_2004_4' & `shbybin2_y1_52_0_2004_5' & `shbybin3_y1_52_0_2004_1' & `shbybin3_y1_52_0_2004_2' & `shbybin3_y1_52_0_2004_3' & `sh_y1_52_0_2004' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* URBAN 2004
	cap file close _all
	file open ofile using "Tables\table2_2004u_d.tex", write replace	
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
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"`shbybin1_c0_1_1_2004_1' & `shbybin1_c0_1_1_2004_2' & `shbybin1_c0_1_1_2004_3' & `shbybin2_c0_1_1_2004_1' & `shbybin2_c0_1_1_2004_2' & `shbybin2_c0_1_1_2004_3' & `shbybin2_c0_1_1_2004_4' & `shbybin2_c0_1_1_2004_5' & `shbybin3_c0_1_1_2004_1' & `shbybin3_c0_1_1_2004_2' & `shbybin3_c0_1_1_2004_3' & `sh_c0_1_1_2004' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_c0_11_1_2004_1' & `shbybin1_c0_11_1_2004_2' & `shbybin1_c0_11_1_2004_3' & `shbybin2_c0_11_1_2004_1' & `shbybin2_c0_11_1_2004_2' & `shbybin2_c0_11_1_2004_3' & `shbybin2_c0_11_1_2004_4' & `shbybin2_c0_11_1_2004_5' & `shbybin3_c0_11_1_2004_1' & `shbybin3_c0_11_1_2004_2' & `shbybin3_c0_11_1_2004_3' & `sh_c0_11_1_2004' \\" _n  ///
	"`shbybin1_c0_12_1_2004_1' & `shbybin1_c0_12_1_2004_2' & `shbybin1_c0_12_1_2004_3' & `shbybin2_c0_12_1_2004_1' & `shbybin2_c0_12_1_2004_2' & `shbybin2_c0_12_1_2004_3' & `shbybin2_c0_12_1_2004_4' & `shbybin2_c0_12_1_2004_5' & `shbybin3_c0_12_1_2004_1' & `shbybin3_c0_12_1_2004_2' & `shbybin3_c0_12_1_2004_3' & `sh_c0_12_1_2004' \\" _n  ///
	"`shbybin1_c0_13_1_2004_1' & `shbybin1_c0_13_1_2004_2' & `shbybin1_c0_13_1_2004_3' & `shbybin2_c0_13_1_2004_1' & `shbybin2_c0_13_1_2004_2' & `shbybin2_c0_13_1_2004_3' & `shbybin2_c0_13_1_2004_4' & `shbybin2_c0_13_1_2004_5' & `shbybin3_c0_13_1_2004_1' & `shbybin3_c0_13_1_2004_2' & `shbybin3_c0_13_1_2004_3' & `sh_c0_13_1_2004' \\" _n  ///
	"`shbybin1_c0_14_1_2004_1' & `shbybin1_c0_14_1_2004_2' & `shbybin1_c0_14_1_2004_3' & `shbybin2_c0_14_1_2004_1' & `shbybin2_c0_14_1_2004_2' & `shbybin2_c0_14_1_2004_3' & `shbybin2_c0_14_1_2004_4' & `shbybin2_c0_14_1_2004_5' & `shbybin3_c0_14_1_2004_1' & `shbybin3_c0_14_1_2004_2' & `shbybin3_c0_14_1_2004_3' & `sh_c0_14_1_2004' \\" _n  ///
	"`shbybin1_c0_2_1_2004_1' & `shbybin1_c0_2_1_2004_2' & `shbybin1_c0_2_1_2004_3' & `shbybin2_c0_2_1_2004_1' & `shbybin2_c0_2_1_2004_2' & `shbybin2_c0_2_1_2004_3' & `shbybin2_c0_2_1_2004_4' & `shbybin2_c0_2_1_2004_5' & `shbybin3_c0_2_1_2004_1' & `shbybin3_c0_2_1_2004_2' & `shbybin3_c0_2_1_2004_3' & `sh_c0_2_1_2004' \\" _n  ///
	"`shbybin1_c0_3_1_2004_1' & `shbybin1_c0_3_1_2004_2' & `shbybin1_c0_3_1_2004_3' & `shbybin2_c0_3_1_2004_1' & `shbybin2_c0_3_1_2004_2' & `shbybin2_c0_3_1_2004_3' & `shbybin2_c0_3_1_2004_4' & `shbybin2_c0_3_1_2004_5' & `shbybin3_c0_3_1_2004_1' & `shbybin3_c0_3_1_2004_2' & `shbybin3_c0_3_1_2004_3' & `sh_c0_3_1_2004' \\" _n  ///
	"`shbybin1_c0_4_1_2004_1' & `shbybin1_c0_4_1_2004_2' & `shbybin1_c0_4_1_2004_3' & `shbybin2_c0_4_1_2004_1' & `shbybin2_c0_4_1_2004_2' & `shbybin2_c0_4_1_2004_3' & `shbybin2_c0_4_1_2004_4' & `shbybin2_c0_4_1_2004_5' & `shbybin3_c0_4_1_2004_1' & `shbybin3_c0_4_1_2004_2' & `shbybin3_c0_4_1_2004_3' & `sh_c0_4_1_2004' \\" _n  ///
	"`shbybin1_c0_5_1_2004_1' & `shbybin1_c0_5_1_2004_2' & `shbybin1_c0_5_1_2004_3' & `shbybin2_c0_5_1_2004_1' & `shbybin2_c0_5_1_2004_2' & `shbybin2_c0_5_1_2004_3' & `shbybin2_c0_5_1_2004_4' & `shbybin2_c0_5_1_2004_5' & `shbybin3_c0_5_1_2004_1' & `shbybin3_c0_5_1_2004_2' & `shbybin3_c0_5_1_2004_3' & `sh_c0_5_1_2004' \\" _n  ///
	"`shbybin1_c0_6_1_2004_1' & `shbybin1_c0_6_1_2004_2' & `shbybin1_c0_6_1_2004_3' & `shbybin2_c0_6_1_2004_1' & `shbybin2_c0_6_1_2004_2' & `shbybin2_c0_6_1_2004_3' & `shbybin2_c0_6_1_2004_4' & `shbybin2_c0_6_1_2004_5' & `shbybin3_c0_6_1_2004_1' & `shbybin3_c0_6_1_2004_2' & `shbybin3_c0_6_1_2004_3' & `sh_c0_6_1_2004' \\" _n  ///
	"`shbybin1_c0_7_1_2004_1' & `shbybin1_c0_7_1_2004_2' & `shbybin1_c0_7_1_2004_3' & `shbybin2_c0_7_1_2004_1' & `shbybin2_c0_7_1_2004_2' & `shbybin2_c0_7_1_2004_3' & `shbybin2_c0_7_1_2004_4' & `shbybin2_c0_7_1_2004_5' & `shbybin3_c0_7_1_2004_1' & `shbybin3_c0_7_1_2004_2' & `shbybin3_c0_7_1_2004_3' & `sh_c0_7_1_2004' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_1_1_2004_1' & `shbybin1_y1_1_1_2004_2' & `shbybin1_y1_1_1_2004_3' & `shbybin2_y1_1_1_2004_1' & `shbybin2_y1_1_1_2004_2' & `shbybin2_y1_1_1_2004_3' & `shbybin2_y1_1_1_2004_4' & `shbybin2_y1_1_1_2004_5' & `shbybin3_y1_1_1_2004_1' & `shbybin3_y1_1_1_2004_2' & `shbybin3_y1_1_1_2004_3' & `sh_y1_1_1_2004' \\" _n  ///
	"`shbybin1_y1_2_1_2004_1' & `shbybin1_y1_2_1_2004_2' & `shbybin1_y1_2_1_2004_3' & `shbybin2_y1_2_1_2004_1' & `shbybin2_y1_2_1_2004_2' & `shbybin2_y1_2_1_2004_3' & `shbybin2_y1_2_1_2004_4' & `shbybin2_y1_2_1_2004_5' & `shbybin3_y1_2_1_2004_1' & `shbybin3_y1_2_1_2004_2' & `shbybin3_y1_2_1_2004_3' & `sh_y1_2_1_2004' \\" _n  ///
	"`shbybin1_y1_3_1_2004_1' & `shbybin1_y1_3_1_2004_2' & `shbybin1_y1_3_1_2004_3' & `shbybin2_y1_3_1_2004_1' & `shbybin2_y1_3_1_2004_2' & `shbybin2_y1_3_1_2004_3' & `shbybin2_y1_3_1_2004_4' & `shbybin2_y1_3_1_2004_5' & `shbybin3_y1_3_1_2004_1' & `shbybin3_y1_3_1_2004_2' & `shbybin3_y1_3_1_2004_3' & `sh_y1_3_1_2004' \\" _n  ///
	"`shbybin1_y1_4_1_2004_1' & `shbybin1_y1_4_1_2004_2' & `shbybin1_y1_4_1_2004_3' & `shbybin2_y1_4_1_2004_1' & `shbybin2_y1_4_1_2004_2' & `shbybin2_y1_4_1_2004_3' & `shbybin2_y1_4_1_2004_4' & `shbybin2_y1_4_1_2004_5' & `shbybin3_y1_4_1_2004_1' & `shbybin3_y1_4_1_2004_2' & `shbybin3_y1_4_1_2004_3' & `sh_y1_4_1_2004' \\" _n  ///
	"`shbybin1_y1_5_1_2004_1' & `shbybin1_y1_5_1_2004_2' & `shbybin1_y1_5_1_2004_3' & `shbybin2_y1_5_1_2004_1' & `shbybin2_y1_5_1_2004_2' & `shbybin2_y1_5_1_2004_3' & `shbybin2_y1_5_1_2004_4' & `shbybin2_y1_5_1_2004_5' & `shbybin3_y1_5_1_2004_1' & `shbybin3_y1_5_1_2004_2' & `shbybin3_y1_5_1_2004_3' & `sh_y1_5_1_2004' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_51_1_2004_1' & `shbybin1_y1_51_1_2004_2' & `shbybin1_y1_51_1_2004_3' & `shbybin2_y1_51_1_2004_1' & `shbybin2_y1_51_1_2004_2' & `shbybin2_y1_51_1_2004_3' & `shbybin2_y1_51_1_2004_4' & `shbybin2_y1_51_1_2004_5' & `shbybin3_y1_51_1_2004_1' & `shbybin3_y1_51_1_2004_2' & `shbybin3_y1_51_1_2004_3' & `sh_y1_51_1_2004' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_y1_511_1_2004_1' & `shbybin1_y1_511_1_2004_2' & `shbybin1_y1_511_1_2004_3' & `shbybin2_y1_511_1_2004_1' & `shbybin2_y1_511_1_2004_2' & `shbybin2_y1_511_1_2004_3' & `shbybin2_y1_511_1_2004_4' & `shbybin2_y1_511_1_2004_5' & `shbybin3_y1_511_1_2004_1' & `shbybin3_y1_511_1_2004_2' & `shbybin3_y1_511_1_2004_3' & `sh_y1_511_1_2004' \\" _n  ///
	"`shbybin1_y1_512_1_2004_1' & `shbybin1_y1_512_1_2004_2' & `shbybin1_y1_512_1_2004_3' & `shbybin2_y1_512_1_2004_1' & `shbybin2_y1_512_1_2004_2' & `shbybin2_y1_512_1_2004_3' & `shbybin2_y1_512_1_2004_4' & `shbybin2_y1_512_1_2004_5' & `shbybin3_y1_512_1_2004_1' & `shbybin3_y1_512_1_2004_2' & `shbybin3_y1_512_1_2004_3' & `sh_y1_512_1_2004' \\" _n  ///
	"`shbybin1_y1_513_1_2004_1' & `shbybin1_y1_513_1_2004_2' & `shbybin1_y1_513_1_2004_3' & `shbybin2_y1_513_1_2004_1' & `shbybin2_y1_513_1_2004_2' & `shbybin2_y1_513_1_2004_3' & `shbybin2_y1_513_1_2004_4' & `shbybin2_y1_513_1_2004_5' & `shbybin3_y1_513_1_2004_1' & `shbybin3_y1_513_1_2004_2' & `shbybin3_y1_513_1_2004_3' & `sh_y1_513_1_2004' \\" _n  ///
	"`shbybin1_y1_514_1_2004_1' & `shbybin1_y1_514_1_2004_2' & `shbybin1_y1_514_1_2004_3' & `shbybin2_y1_514_1_2004_1' & `shbybin2_y1_514_1_2004_2' & `shbybin2_y1_514_1_2004_3' & `shbybin2_y1_514_1_2004_4' & `shbybin2_y1_514_1_2004_5' & `shbybin3_y1_514_1_2004_1' & `shbybin3_y1_514_1_2004_2' & `shbybin3_y1_514_1_2004_3' & `sh_y1_514_1_2004' \\" _n  ///
	"`shbybin1_y1_52_1_2004_1' & `shbybin1_y1_52_1_2004_2' & `shbybin1_y1_52_1_2004_3' & `shbybin2_y1_52_1_2004_1' & `shbybin2_y1_52_1_2004_2' & `shbybin2_y1_52_1_2004_3' & `shbybin2_y1_52_1_2004_4' & `shbybin2_y1_52_1_2004_5' & `shbybin3_y1_52_1_2004_1' & `shbybin3_y1_52_1_2004_2' & `shbybin3_y1_52_1_2004_3' & `sh_y1_52_1_2004' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	

	* RURAL 2006
	cap file close _all
	file open ofile using "Tables\table2_2006r_d.tex", write replace	
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
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"Food (Diet)  & `shbybin1_c0_1_0_2006_1' & `shbybin1_c0_1_0_2006_2' & `shbybin1_c0_1_0_2006_3' & `shbybin2_c0_1_0_2006_1' & `shbybin2_c0_1_0_2006_2' & `shbybin2_c0_1_0_2006_3' & `shbybin2_c0_1_0_2006_4' & `shbybin2_c0_1_0_2006_5' & `shbybin3_c0_1_0_2006_1' & `shbybin3_c0_1_0_2006_2' & `shbybin3_c0_1_0_2006_3' & `sh_c0_1_0_2006' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Own prod.  & `shbybin1_c0_11_0_2006_1' & `shbybin1_c0_11_0_2006_2' & `shbybin1_c0_11_0_2006_3' & `shbybin2_c0_11_0_2006_1' & `shbybin2_c0_11_0_2006_2' & `shbybin2_c0_11_0_2006_3' & `shbybin2_c0_11_0_2006_4' & `shbybin2_c0_11_0_2006_5' & `shbybin3_c0_11_0_2006_1' & `shbybin3_c0_11_0_2006_2' & `shbybin3_c0_11_0_2006_3' & `sh_c0_11_0_2006' \\" _n  ///
	"\hspace{.3cm} Coupons    & `shbybin1_c0_12_0_2006_1' & `shbybin1_c0_12_0_2006_2' & `shbybin1_c0_12_0_2006_3' & `shbybin2_c0_12_0_2006_1' & `shbybin2_c0_12_0_2006_2' & `shbybin2_c0_12_0_2006_3' & `shbybin2_c0_12_0_2006_4' & `shbybin2_c0_12_0_2006_5' & `shbybin3_c0_12_0_2006_1' & `shbybin3_c0_12_0_2006_2' & `shbybin3_c0_12_0_2006_3' & `sh_c0_12_0_2006' \\" _n  ///
	"\hspace{.3cm} Gifts	  & `shbybin1_c0_13_0_2006_1' & `shbybin1_c0_13_0_2006_2' & `shbybin1_c0_13_0_2006_3' & `shbybin2_c0_13_0_2006_1' & `shbybin2_c0_13_0_2006_2' & `shbybin2_c0_13_0_2006_3' & `shbybin2_c0_13_0_2006_4' & `shbybin2_c0_13_0_2006_5' & `shbybin3_c0_13_0_2006_1' & `shbybin3_c0_13_0_2006_2' & `shbybin3_c0_13_0_2006_3' & `sh_c0_13_0_2006' \\" _n  ///
	"\hspace{.3cm} Expenditures  & `shbybin1_c0_14_0_2006_1' & `shbybin1_c0_14_0_2006_2' & `shbybin1_c0_14_0_2006_3' & `shbybin2_c0_14_0_2006_1' & `shbybin2_c0_14_0_2006_2' & `shbybin2_c0_14_0_2006_3' & `shbybin2_c0_14_0_2006_4' & `shbybin2_c0_14_0_2006_5' & `shbybin3_c0_14_0_2006_1' & `shbybin3_c0_14_0_2006_2' & `shbybin3_c0_14_0_2006_3' & `sh_c0_14_0_2006' \\" _n  ///
	"Utilities    & `shbybin1_c0_2_0_2006_1' & `shbybin1_c0_2_0_2006_2' & `shbybin1_c0_2_0_2006_3' & `shbybin2_c0_2_0_2006_1' & `shbybin2_c0_2_0_2006_2' & `shbybin2_c0_2_0_2006_3' & `shbybin2_c0_2_0_2006_4' & `shbybin2_c0_2_0_2006_5' & `shbybin3_c0_2_0_2006_1' & `shbybin3_c0_2_0_2006_2' & `shbybin3_c0_2_0_2006_3' & `sh_c0_2_0_2006' \\" _n  ///
	"Housing Services  & `shbybin1_c0_3_0_2006_1' & `shbybin1_c0_3_0_2006_2' & `shbybin1_c0_3_0_2006_3' & `shbybin2_c0_3_0_2006_1' & `shbybin2_c0_3_0_2006_2' & `shbybin2_c0_3_0_2006_3' & `shbybin2_c0_3_0_2006_4' & `shbybin2_c0_3_0_2006_5' & `shbybin3_c0_3_0_2006_1' & `shbybin3_c0_3_0_2006_2' & `shbybin3_c0_3_0_2006_3' & `sh_c0_3_0_2006' \\" _n  ///
	"Child Care  & `shbybin1_c0_4_0_2006_1' & `shbybin1_c0_4_0_2006_2' & `shbybin1_c0_4_0_2006_3' & `shbybin2_c0_4_0_2006_1' & `shbybin2_c0_4_0_2006_2' & `shbybin2_c0_4_0_2006_3' & `shbybin2_c0_4_0_2006_4' & `shbybin2_c0_4_0_2006_5' & `shbybin3_c0_4_0_2006_1' & `shbybin3_c0_4_0_2006_2' & `shbybin3_c0_4_0_2006_3' & `sh_c0_4_0_2006' \\" _n  ///
	"Health Services   & `shbybin1_c0_5_0_2006_1' & `shbybin1_c0_5_0_2006_2' & `shbybin1_c0_5_0_2006_3' & `shbybin2_c0_5_0_2006_1' & `shbybin2_c0_5_0_2006_2' & `shbybin2_c0_5_0_2006_3' & `shbybin2_c0_5_0_2006_4' & `shbybin2_c0_5_0_2006_5' & `shbybin3_c0_5_0_2006_1' & `shbybin3_c0_5_0_2006_2' & `shbybin3_c0_5_0_2006_3' & `sh_c0_5_0_2006' \\" _n  ///
	"Education   & `shbybin1_c0_6_0_2006_1' & `shbybin1_c0_6_0_2006_2' & `shbybin1_c0_6_0_2006_3' & `shbybin2_c0_6_0_2006_1' & `shbybin2_c0_6_0_2006_2' & `shbybin2_c0_6_0_2006_3' & `shbybin2_c0_6_0_2006_4' & `shbybin2_c0_6_0_2006_5' & `shbybin3_c0_6_0_2006_1' & `shbybin3_c0_6_0_2006_2' & `shbybin3_c0_6_0_2006_3' & `sh_c0_6_0_2006' \\" _n  ///
	"Semi Durables 	   & `shbybin1_c0_7_0_2006_1' & `shbybin1_c0_7_0_2006_2' & `shbybin1_c0_7_0_2006_3' & `shbybin2_c0_7_0_2006_1' & `shbybin2_c0_7_0_2006_2' & `shbybin2_c0_7_0_2006_3' & `shbybin2_c0_7_0_2006_4' & `shbybin2_c0_7_0_2006_5' & `shbybin3_c0_7_0_2006_1' & `shbybin3_c0_7_0_2006_2' & `shbybin3_c0_7_0_2006_3' & `sh_c0_7_0_2006' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"Labor        & `shbybin1_y1_1_0_2006_1' & `shbybin1_y1_1_0_2006_2' & `shbybin1_y1_1_0_2006_3' & `shbybin2_y1_1_0_2006_1' & `shbybin2_y1_1_0_2006_2' & `shbybin2_y1_1_0_2006_3' & `shbybin2_y1_1_0_2006_4' & `shbybin2_y1_1_0_2006_5' & `shbybin3_y1_1_0_2006_1' & `shbybin3_y1_1_0_2006_2' & `shbybin3_y1_1_0_2006_3' & `sh_y1_1_0_2006' \\" _n  ///
	"Agriculture  & `shbybin1_y1_2_0_2006_1' & `shbybin1_y1_2_0_2006_2' & `shbybin1_y1_2_0_2006_3' & `shbybin2_y1_2_0_2006_1' & `shbybin2_y1_2_0_2006_2' & `shbybin2_y1_2_0_2006_3' & `shbybin2_y1_2_0_2006_4' & `shbybin2_y1_2_0_2006_5' & `shbybin3_y1_2_0_2006_1' & `shbybin3_y1_2_0_2006_2' & `shbybin3_y1_2_0_2006_3' & `sh_y1_2_0_2006' \\" _n  ///
	"Business     & `shbybin1_y1_3_0_2006_1' & `shbybin1_y1_3_0_2006_2' & `shbybin1_y1_3_0_2006_3' & `shbybin2_y1_3_0_2006_1' & `shbybin2_y1_3_0_2006_2' & `shbybin2_y1_3_0_2006_3' & `shbybin2_y1_3_0_2006_4' & `shbybin2_y1_3_0_2006_5' & `shbybin3_y1_3_0_2006_1' & `shbybin3_y1_3_0_2006_2' & `shbybin3_y1_3_0_2006_3' & `sh_y1_3_0_2006' \\" _n  ///
	"Capital      & `shbybin1_y1_4_0_2006_1' & `shbybin1_y1_4_0_2006_2' & `shbybin1_y1_4_0_2006_3' & `shbybin2_y1_4_0_2006_1' & `shbybin2_y1_4_0_2006_2' & `shbybin2_y1_4_0_2006_3' & `shbybin2_y1_4_0_2006_4' & `shbybin2_y1_4_0_2006_5' & `shbybin3_y1_4_0_2006_1' & `shbybin3_y1_4_0_2006_2' & `shbybin3_y1_4_0_2006_3' & `sh_y1_4_0_2006' \\" _n  ///
	"Transfers Rec.  & `shbybin1_y1_5_0_2006_1' & `shbybin1_y1_5_0_2006_2' & `shbybin1_y1_5_0_2006_3' & `shbybin2_y1_5_0_2006_1' & `shbybin2_y1_5_0_2006_2' & `shbybin2_y1_5_0_2006_3' & `shbybin2_y1_5_0_2006_4' & `shbybin2_y1_5_0_2006_5' & `shbybin3_y1_5_0_2006_1' & `shbybin3_y1_5_0_2006_2' & `shbybin3_y1_5_0_2006_3' & `sh_y1_5_0_2006' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"Public Trans. Rec.  & `shbybin1_y1_51_0_2006_1' & `shbybin1_y1_51_0_2006_2' & `shbybin1_y1_51_0_2006_3' & `shbybin2_y1_51_0_2006_1' & `shbybin2_y1_51_0_2006_2' & `shbybin2_y1_51_0_2006_3' & `shbybin2_y1_51_0_2006_4' & `shbybin2_y1_51_0_2006_5' & `shbybin3_y1_51_0_2006_1' & `shbybin3_y1_51_0_2006_2' & `shbybin3_y1_51_0_2006_3' & `sh_y1_51_0_2006' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Food Coupons    & `shbybin1_y1_511_0_2006_1' & `shbybin1_y1_511_0_2006_2' & `shbybin1_y1_511_0_2006_3' & `shbybin2_y1_511_0_2006_1' & `shbybin2_y1_511_0_2006_2' & `shbybin2_y1_511_0_2006_3' & `shbybin2_y1_511_0_2006_4' & `shbybin2_y1_511_0_2006_5' & `shbybin3_y1_511_0_2006_1' & `shbybin3_y1_511_0_2006_2' & `shbybin3_y1_511_0_2006_3' & `sh_y1_511_0_2006' \\" _n  ///
	"\hspace{.3cm} Sub. Work Unit  & `shbybin1_y1_512_0_2006_1' & `shbybin1_y1_512_0_2006_2' & `shbybin1_y1_512_0_2006_3' & `shbybin2_y1_512_0_2006_1' & `shbybin2_y1_512_0_2006_2' & `shbybin2_y1_512_0_2006_3' & `shbybin2_y1_512_0_2006_4' & `shbybin2_y1_512_0_2006_5' & `shbybin3_y1_512_0_2006_1' & `shbybin3_y1_512_0_2006_2' & `shbybin3_y1_512_0_2006_3' & `sh_y1_512_0_2006' \\" _n  ///
	"\hspace{.3cm} Sub. Gov.       & `shbybin1_y1_513_0_2006_1' & `shbybin1_y1_513_0_2006_2' & `shbybin1_y1_513_0_2006_3' & `shbybin2_y1_513_0_2006_1' & `shbybin2_y1_513_0_2006_2' & `shbybin2_y1_513_0_2006_3' & `shbybin2_y1_513_0_2006_4' & `shbybin2_y1_513_0_2006_5' & `shbybin3_y1_513_0_2006_1' & `shbybin3_y1_513_0_2006_2' & `shbybin3_y1_513_0_2006_3' & `sh_y1_513_0_2006' \\" _n  ///
	"\hspace{.3cm} Pension         & `shbybin1_y1_514_0_2006_1' & `shbybin1_y1_514_0_2006_2' & `shbybin1_y1_514_0_2006_3' & `shbybin2_y1_514_0_2006_1' & `shbybin2_y1_514_0_2006_2' & `shbybin2_y1_514_0_2006_3' & `shbybin2_y1_514_0_2006_4' & `shbybin2_y1_514_0_2006_5' & `shbybin3_y1_514_0_2006_1' & `shbybin3_y1_514_0_2006_2' & `shbybin3_y1_514_0_2006_3' & `sh_y1_514_0_2006' \\" _n  ///
	"Private Trans. Rec. & `shbybin1_y1_52_0_2006_1' & `shbybin1_y1_52_0_2006_2' & `shbybin1_y1_52_0_2006_3' & `shbybin2_y1_52_0_2006_1' & `shbybin2_y1_52_0_2006_2' & `shbybin2_y1_52_0_2006_3' & `shbybin2_y1_52_0_2006_4' & `shbybin2_y1_52_0_2006_5' & `shbybin3_y1_52_0_2006_1' & `shbybin3_y1_52_0_2006_2' & `shbybin3_y1_52_0_2006_3' & `sh_y1_52_0_2006' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* URBAN 2006
	cap file close _all
	file open ofile using "Tables\table2_2006u_d.tex", write replace	
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
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"`shbybin1_c0_1_1_2006_1' & `shbybin1_c0_1_1_2006_2' & `shbybin1_c0_1_1_2006_3' & `shbybin2_c0_1_1_2006_1' & `shbybin2_c0_1_1_2006_2' & `shbybin2_c0_1_1_2006_3' & `shbybin2_c0_1_1_2006_4' & `shbybin2_c0_1_1_2006_5' & `shbybin3_c0_1_1_2006_1' & `shbybin3_c0_1_1_2006_2' & `shbybin3_c0_1_1_2006_3' & `sh_c0_1_1_2006' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_c0_11_1_2006_1' & `shbybin1_c0_11_1_2006_2' & `shbybin1_c0_11_1_2006_3' & `shbybin2_c0_11_1_2006_1' & `shbybin2_c0_11_1_2006_2' & `shbybin2_c0_11_1_2006_3' & `shbybin2_c0_11_1_2006_4' & `shbybin2_c0_11_1_2006_5' & `shbybin3_c0_11_1_2006_1' & `shbybin3_c0_11_1_2006_2' & `shbybin3_c0_11_1_2006_3' & `sh_c0_11_1_2006' \\" _n  ///
	"`shbybin1_c0_12_1_2006_1' & `shbybin1_c0_12_1_2006_2' & `shbybin1_c0_12_1_2006_3' & `shbybin2_c0_12_1_2006_1' & `shbybin2_c0_12_1_2006_2' & `shbybin2_c0_12_1_2006_3' & `shbybin2_c0_12_1_2006_4' & `shbybin2_c0_12_1_2006_5' & `shbybin3_c0_12_1_2006_1' & `shbybin3_c0_12_1_2006_2' & `shbybin3_c0_12_1_2006_3' & `sh_c0_12_1_2006' \\" _n  ///
	"`shbybin1_c0_13_1_2006_1' & `shbybin1_c0_13_1_2006_2' & `shbybin1_c0_13_1_2006_3' & `shbybin2_c0_13_1_2006_1' & `shbybin2_c0_13_1_2006_2' & `shbybin2_c0_13_1_2006_3' & `shbybin2_c0_13_1_2006_4' & `shbybin2_c0_13_1_2006_5' & `shbybin3_c0_13_1_2006_1' & `shbybin3_c0_13_1_2006_2' & `shbybin3_c0_13_1_2006_3' & `sh_c0_13_1_2006' \\" _n  ///
	"`shbybin1_c0_14_1_2006_1' & `shbybin1_c0_14_1_2006_2' & `shbybin1_c0_14_1_2006_3' & `shbybin2_c0_14_1_2006_1' & `shbybin2_c0_14_1_2006_2' & `shbybin2_c0_14_1_2006_3' & `shbybin2_c0_14_1_2006_4' & `shbybin2_c0_14_1_2006_5' & `shbybin3_c0_14_1_2006_1' & `shbybin3_c0_14_1_2006_2' & `shbybin3_c0_14_1_2006_3' & `sh_c0_14_1_2006' \\" _n  ///
	"`shbybin1_c0_2_1_2006_1' & `shbybin1_c0_2_1_2006_2' & `shbybin1_c0_2_1_2006_3' & `shbybin2_c0_2_1_2006_1' & `shbybin2_c0_2_1_2006_2' & `shbybin2_c0_2_1_2006_3' & `shbybin2_c0_2_1_2006_4' & `shbybin2_c0_2_1_2006_5' & `shbybin3_c0_2_1_2006_1' & `shbybin3_c0_2_1_2006_2' & `shbybin3_c0_2_1_2006_3' & `sh_c0_2_1_2006' \\" _n  ///
	"`shbybin1_c0_3_1_2006_1' & `shbybin1_c0_3_1_2006_2' & `shbybin1_c0_3_1_2006_3' & `shbybin2_c0_3_1_2006_1' & `shbybin2_c0_3_1_2006_2' & `shbybin2_c0_3_1_2006_3' & `shbybin2_c0_3_1_2006_4' & `shbybin2_c0_3_1_2006_5' & `shbybin3_c0_3_1_2006_1' & `shbybin3_c0_3_1_2006_2' & `shbybin3_c0_3_1_2006_3' & `sh_c0_3_1_2006' \\" _n  ///
	"`shbybin1_c0_4_1_2006_1' & `shbybin1_c0_4_1_2006_2' & `shbybin1_c0_4_1_2006_3' & `shbybin2_c0_4_1_2006_1' & `shbybin2_c0_4_1_2006_2' & `shbybin2_c0_4_1_2006_3' & `shbybin2_c0_4_1_2006_4' & `shbybin2_c0_4_1_2006_5' & `shbybin3_c0_4_1_2006_1' & `shbybin3_c0_4_1_2006_2' & `shbybin3_c0_4_1_2006_3' & `sh_c0_4_1_2006' \\" _n  ///
	"`shbybin1_c0_5_1_2006_1' & `shbybin1_c0_5_1_2006_2' & `shbybin1_c0_5_1_2006_3' & `shbybin2_c0_5_1_2006_1' & `shbybin2_c0_5_1_2006_2' & `shbybin2_c0_5_1_2006_3' & `shbybin2_c0_5_1_2006_4' & `shbybin2_c0_5_1_2006_5' & `shbybin3_c0_5_1_2006_1' & `shbybin3_c0_5_1_2006_2' & `shbybin3_c0_5_1_2006_3' & `sh_c0_5_1_2006' \\" _n  ///
	"`shbybin1_c0_6_1_2006_1' & `shbybin1_c0_6_1_2006_2' & `shbybin1_c0_6_1_2006_3' & `shbybin2_c0_6_1_2006_1' & `shbybin2_c0_6_1_2006_2' & `shbybin2_c0_6_1_2006_3' & `shbybin2_c0_6_1_2006_4' & `shbybin2_c0_6_1_2006_5' & `shbybin3_c0_6_1_2006_1' & `shbybin3_c0_6_1_2006_2' & `shbybin3_c0_6_1_2006_3' & `sh_c0_6_1_2006' \\" _n  ///
	"`shbybin1_c0_7_1_2006_1' & `shbybin1_c0_7_1_2006_2' & `shbybin1_c0_7_1_2006_3' & `shbybin2_c0_7_1_2006_1' & `shbybin2_c0_7_1_2006_2' & `shbybin2_c0_7_1_2006_3' & `shbybin2_c0_7_1_2006_4' & `shbybin2_c0_7_1_2006_5' & `shbybin3_c0_7_1_2006_1' & `shbybin3_c0_7_1_2006_2' & `shbybin3_c0_7_1_2006_3' & `sh_c0_7_1_2006' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_1_1_2006_1' & `shbybin1_y1_1_1_2006_2' & `shbybin1_y1_1_1_2006_3' & `shbybin2_y1_1_1_2006_1' & `shbybin2_y1_1_1_2006_2' & `shbybin2_y1_1_1_2006_3' & `shbybin2_y1_1_1_2006_4' & `shbybin2_y1_1_1_2006_5' & `shbybin3_y1_1_1_2006_1' & `shbybin3_y1_1_1_2006_2' & `shbybin3_y1_1_1_2006_3' & `sh_y1_1_1_2006' \\" _n  ///
	"`shbybin1_y1_2_1_2006_1' & `shbybin1_y1_2_1_2006_2' & `shbybin1_y1_2_1_2006_3' & `shbybin2_y1_2_1_2006_1' & `shbybin2_y1_2_1_2006_2' & `shbybin2_y1_2_1_2006_3' & `shbybin2_y1_2_1_2006_4' & `shbybin2_y1_2_1_2006_5' & `shbybin3_y1_2_1_2006_1' & `shbybin3_y1_2_1_2006_2' & `shbybin3_y1_2_1_2006_3' & `sh_y1_2_1_2006' \\" _n  ///
	"`shbybin1_y1_3_1_2006_1' & `shbybin1_y1_3_1_2006_2' & `shbybin1_y1_3_1_2006_3' & `shbybin2_y1_3_1_2006_1' & `shbybin2_y1_3_1_2006_2' & `shbybin2_y1_3_1_2006_3' & `shbybin2_y1_3_1_2006_4' & `shbybin2_y1_3_1_2006_5' & `shbybin3_y1_3_1_2006_1' & `shbybin3_y1_3_1_2006_2' & `shbybin3_y1_3_1_2006_3' & `sh_y1_3_1_2006' \\" _n  ///
	"`shbybin1_y1_4_1_2006_1' & `shbybin1_y1_4_1_2006_2' & `shbybin1_y1_4_1_2006_3' & `shbybin2_y1_4_1_2006_1' & `shbybin2_y1_4_1_2006_2' & `shbybin2_y1_4_1_2006_3' & `shbybin2_y1_4_1_2006_4' & `shbybin2_y1_4_1_2006_5' & `shbybin3_y1_4_1_2006_1' & `shbybin3_y1_4_1_2006_2' & `shbybin3_y1_4_1_2006_3' & `sh_y1_4_1_2006' \\" _n  ///
	"`shbybin1_y1_5_1_2006_1' & `shbybin1_y1_5_1_2006_2' & `shbybin1_y1_5_1_2006_3' & `shbybin2_y1_5_1_2006_1' & `shbybin2_y1_5_1_2006_2' & `shbybin2_y1_5_1_2006_3' & `shbybin2_y1_5_1_2006_4' & `shbybin2_y1_5_1_2006_5' & `shbybin3_y1_5_1_2006_1' & `shbybin3_y1_5_1_2006_2' & `shbybin3_y1_5_1_2006_3' & `sh_y1_5_1_2006' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_51_1_2006_1' & `shbybin1_y1_51_1_2006_2' & `shbybin1_y1_51_1_2006_3' & `shbybin2_y1_51_1_2006_1' & `shbybin2_y1_51_1_2006_2' & `shbybin2_y1_51_1_2006_3' & `shbybin2_y1_51_1_2006_4' & `shbybin2_y1_51_1_2006_5' & `shbybin3_y1_51_1_2006_1' & `shbybin3_y1_51_1_2006_2' & `shbybin3_y1_51_1_2006_3' & `sh_y1_51_1_2006' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_y1_511_1_2006_1' & `shbybin1_y1_511_1_2006_2' & `shbybin1_y1_511_1_2006_3' & `shbybin2_y1_511_1_2006_1' & `shbybin2_y1_511_1_2006_2' & `shbybin2_y1_511_1_2006_3' & `shbybin2_y1_511_1_2006_4' & `shbybin2_y1_511_1_2006_5' & `shbybin3_y1_511_1_2006_1' & `shbybin3_y1_511_1_2006_2' & `shbybin3_y1_511_1_2006_3' & `sh_y1_511_1_2006' \\" _n  ///
	"`shbybin1_y1_512_1_2006_1' & `shbybin1_y1_512_1_2006_2' & `shbybin1_y1_512_1_2006_3' & `shbybin2_y1_512_1_2006_1' & `shbybin2_y1_512_1_2006_2' & `shbybin2_y1_512_1_2006_3' & `shbybin2_y1_512_1_2006_4' & `shbybin2_y1_512_1_2006_5' & `shbybin3_y1_512_1_2006_1' & `shbybin3_y1_512_1_2006_2' & `shbybin3_y1_512_1_2006_3' & `sh_y1_512_1_2006' \\" _n  ///
	"`shbybin1_y1_513_1_2006_1' & `shbybin1_y1_513_1_2006_2' & `shbybin1_y1_513_1_2006_3' & `shbybin2_y1_513_1_2006_1' & `shbybin2_y1_513_1_2006_2' & `shbybin2_y1_513_1_2006_3' & `shbybin2_y1_513_1_2006_4' & `shbybin2_y1_513_1_2006_5' & `shbybin3_y1_513_1_2006_1' & `shbybin3_y1_513_1_2006_2' & `shbybin3_y1_513_1_2006_3' & `sh_y1_513_1_2006' \\" _n  ///
	"`shbybin1_y1_514_1_2006_1' & `shbybin1_y1_514_1_2006_2' & `shbybin1_y1_514_1_2006_3' & `shbybin2_y1_514_1_2006_1' & `shbybin2_y1_514_1_2006_2' & `shbybin2_y1_514_1_2006_3' & `shbybin2_y1_514_1_2006_4' & `shbybin2_y1_514_1_2006_5' & `shbybin3_y1_514_1_2006_1' & `shbybin3_y1_514_1_2006_2' & `shbybin3_y1_514_1_2006_3' & `sh_y1_514_1_2006' \\" _n  ///
	"`shbybin1_y1_52_1_2006_1' & `shbybin1_y1_52_1_2006_2' & `shbybin1_y1_52_1_2006_3' & `shbybin2_y1_52_1_2006_1' & `shbybin2_y1_52_1_2006_2' & `shbybin2_y1_52_1_2006_3' & `shbybin2_y1_52_1_2006_4' & `shbybin2_y1_52_1_2006_5' & `shbybin3_y1_52_1_2006_1' & `shbybin3_y1_52_1_2006_2' & `shbybin3_y1_52_1_2006_3' & `sh_y1_52_1_2006' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* RURAL 2009
	cap file close _all
	file open ofile using "Tables\table2_2009r_d.tex", write replace	
	file write ofile "\begin{tabular}{l c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"&\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"& 0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{13}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `mc_bin1_2009_0_1'  & `mc_bin1_2009_0_2'  & `mc_bin1_2009_0_3'  & `mc_bin2_2009_0_1'  & `mc_bin2_2009_0_2'  & `mc_bin2_2009_0_3'  & `mc_bin2_2009_0_4'  & `mc_bin2_2009_0_5'  & `mc_bin3_2009_0_1'  & `mc_bin3_2009_0_2'  & `mc_bin3_2009_0_3'  & `mc_0_2009' \\"  _n ///
	"Earnings 	  & `my0_bin1_2009_0_1' & `my0_bin1_2009_0_2' & `my0_bin1_2009_0_3' & `my0_bin2_2009_0_1' & `my0_bin2_2009_0_2' & `my0_bin2_2009_0_3' & `my0_bin2_2009_0_4' & `my0_bin2_2009_0_5' & `my0_bin3_2009_0_1' & `my0_bin3_2009_0_2' & `my0_bin3_2009_0_3' & `my0_0_2009' \\"  _n ///
	"Disp. Income & `my1_bin1_2009_0_1' & `my1_bin1_2009_0_2' & `my1_bin1_2009_0_3' & `my1_bin2_2009_0_1' & `my1_bin2_2009_0_2' & `my1_bin2_2009_0_3' & `my1_bin2_2009_0_4' & `my1_bin2_2009_0_5' & `my1_bin3_2009_0_1' & `my1_bin3_2009_0_2' & `my1_bin3_2009_0_3' & `my1_0_2009' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"Consumption  & `shbybin1_c_0_2009_1'   & `shbybin1_c_0_2009_2'   & `shbybin1_c_0_2009_3'   & `shbybin2_c_0_2009_1'   & `shbybin2_c_0_2009_2'   & `shbybin2_c_0_2009_3'   & `shbybin2_c_0_2009_4'   & `shbybin2_c_0_2009_5'   & `shbybin3_c_0_2009_1'   & `shbybin3_c_0_2009_2'   & `shbybin3_c_0_2009_3'   & 100 \\"  _n ///
	"Earnings 	  & `shbybin1_y0_0_2009_1'  & `shbybin1_y0_0_2009_2'  & `shbybin1_y0_0_2009_3'  & `shbybin2_y0_0_2009_1'  & `shbybin2_y0_0_2009_2'  & `shbybin2_y0_0_2009_3'  & `shbybin2_y0_0_2009_4'  & `shbybin2_y0_0_2009_5'  & `shbybin3_y0_0_2009_1'  & `shbybin3_y0_0_2009_2'  & `shbybin3_y0_0_2009_3'  & 100 \\"  _n ///
	"Disp. Income & `shbybin1_y1_0_2009_1'  & `shbybin1_y1_0_2009_2'  & `shbybin1_y1_0_2009_3'  & `shbybin2_y1_0_2009_1'  & `shbybin2_y1_0_2009_2'  & `shbybin2_y1_0_2009_3'  & `shbybin2_y1_0_2009_4'  & `shbybin2_y1_0_2009_5'  & `shbybin3_y1_0_2009_1'  & `shbybin3_y1_0_2009_2'  & `shbybin3_y1_0_2009_3'  & 100 \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"Food (Diet)  & `shbybin1_c0_1_0_2009_1' & `shbybin1_c0_1_0_2009_2' & `shbybin1_c0_1_0_2009_3' & `shbybin2_c0_1_0_2009_1' & `shbybin2_c0_1_0_2009_2' & `shbybin2_c0_1_0_2009_3' & `shbybin2_c0_1_0_2009_4' & `shbybin2_c0_1_0_2009_5' & `shbybin3_c0_1_0_2009_1' & `shbybin3_c0_1_0_2009_2' & `shbybin3_c0_1_0_2009_3' & `sh_c0_1_0_2009' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Own prod.  & `shbybin1_c0_11_0_2009_1' & `shbybin1_c0_11_0_2009_2' & `shbybin1_c0_11_0_2009_3' & `shbybin2_c0_11_0_2009_1' & `shbybin2_c0_11_0_2009_2' & `shbybin2_c0_11_0_2009_3' & `shbybin2_c0_11_0_2009_4' & `shbybin2_c0_11_0_2009_5' & `shbybin3_c0_11_0_2009_1' & `shbybin3_c0_11_0_2009_2' & `shbybin3_c0_11_0_2009_3' & `sh_c0_11_0_2009' \\" _n  ///
	"\hspace{.3cm} Coupons    & `shbybin1_c0_12_0_2009_1' & `shbybin1_c0_12_0_2009_2' & `shbybin1_c0_12_0_2009_3' & `shbybin2_c0_12_0_2009_1' & `shbybin2_c0_12_0_2009_2' & `shbybin2_c0_12_0_2009_3' & `shbybin2_c0_12_0_2009_4' & `shbybin2_c0_12_0_2009_5' & `shbybin3_c0_12_0_2009_1' & `shbybin3_c0_12_0_2009_2' & `shbybin3_c0_12_0_2009_3' & `sh_c0_12_0_2009' \\" _n  ///
	"\hspace{.3cm} Gifts	  & `shbybin1_c0_13_0_2009_1' & `shbybin1_c0_13_0_2009_2' & `shbybin1_c0_13_0_2009_3' & `shbybin2_c0_13_0_2009_1' & `shbybin2_c0_13_0_2009_2' & `shbybin2_c0_13_0_2009_3' & `shbybin2_c0_13_0_2009_4' & `shbybin2_c0_13_0_2009_5' & `shbybin3_c0_13_0_2009_1' & `shbybin3_c0_13_0_2009_2' & `shbybin3_c0_13_0_2009_3' & `sh_c0_13_0_2009' \\" _n  ///
	"\hspace{.3cm} Expenditures  & `shbybin1_c0_14_0_2009_1' & `shbybin1_c0_14_0_2009_2' & `shbybin1_c0_14_0_2009_3' & `shbybin2_c0_14_0_2009_1' & `shbybin2_c0_14_0_2009_2' & `shbybin2_c0_14_0_2009_3' & `shbybin2_c0_14_0_2009_4' & `shbybin2_c0_14_0_2009_5' & `shbybin3_c0_14_0_2009_1' & `shbybin3_c0_14_0_2009_2' & `shbybin3_c0_14_0_2009_3' & `sh_c0_14_0_2009' \\" _n  ///
	"Utilities    & `shbybin1_c0_2_0_2009_1' & `shbybin1_c0_2_0_2009_2' & `shbybin1_c0_2_0_2009_3' & `shbybin2_c0_2_0_2009_1' & `shbybin2_c0_2_0_2009_2' & `shbybin2_c0_2_0_2009_3' & `shbybin2_c0_2_0_2009_4' & `shbybin2_c0_2_0_2009_5' & `shbybin3_c0_2_0_2009_1' & `shbybin3_c0_2_0_2009_2' & `shbybin3_c0_2_0_2009_3' & `sh_c0_2_0_2009' \\" _n  ///
	"Housing Services  & `shbybin1_c0_3_0_2009_1' & `shbybin1_c0_3_0_2009_2' & `shbybin1_c0_3_0_2009_3' & `shbybin2_c0_3_0_2009_1' & `shbybin2_c0_3_0_2009_2' & `shbybin2_c0_3_0_2009_3' & `shbybin2_c0_3_0_2009_4' & `shbybin2_c0_3_0_2009_5' & `shbybin3_c0_3_0_2009_1' & `shbybin3_c0_3_0_2009_2' & `shbybin3_c0_3_0_2009_3' & `sh_c0_3_0_2009' \\" _n  ///
	"Child Care   & `shbybin1_c0_4_0_2009_1' & `shbybin1_c0_4_0_2009_2' & `shbybin1_c0_4_0_2009_3' & `shbybin2_c0_4_0_2009_1' & `shbybin2_c0_4_0_2009_2' & `shbybin2_c0_4_0_2009_3' & `shbybin2_c0_4_0_2009_4' & `shbybin2_c0_4_0_2009_5' & `shbybin3_c0_4_0_2009_1' & `shbybin3_c0_4_0_2009_2' & `shbybin3_c0_4_0_2009_3' & `sh_c0_4_0_2009' \\" _n  ///
	"Health Services    & `shbybin1_c0_5_0_2009_1' & `shbybin1_c0_5_0_2009_2' & `shbybin1_c0_5_0_2009_3' & `shbybin2_c0_5_0_2009_1' & `shbybin2_c0_5_0_2009_2' & `shbybin2_c0_5_0_2009_3' & `shbybin2_c0_5_0_2009_4' & `shbybin2_c0_5_0_2009_5' & `shbybin3_c0_5_0_2009_1' & `shbybin3_c0_5_0_2009_2' & `shbybin3_c0_5_0_2009_3' & `sh_c0_5_0_2009' \\" _n  ///
	"Education   & `shbybin1_c0_6_0_2009_1' & `shbybin1_c0_6_0_2009_2' & `shbybin1_c0_6_0_2009_3' & `shbybin2_c0_6_0_2009_1' & `shbybin2_c0_6_0_2009_2' & `shbybin2_c0_6_0_2009_3' & `shbybin2_c0_6_0_2009_4' & `shbybin2_c0_6_0_2009_5' & `shbybin3_c0_6_0_2009_1' & `shbybin3_c0_6_0_2009_2' & `shbybin3_c0_6_0_2009_3' & `sh_c0_6_0_2009' \\" _n  ///
	"Semi Durables 	   & `shbybin1_c0_7_0_2009_1' & `shbybin1_c0_7_0_2009_2' & `shbybin1_c0_7_0_2009_3' & `shbybin2_c0_7_0_2009_1' & `shbybin2_c0_7_0_2009_2' & `shbybin2_c0_7_0_2009_3' & `shbybin2_c0_7_0_2009_4' & `shbybin2_c0_7_0_2009_5' & `shbybin3_c0_7_0_2009_1' & `shbybin3_c0_7_0_2009_2' & `shbybin3_c0_7_0_2009_3' & `sh_c0_7_0_2009' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"Labor        & `shbybin1_y1_1_0_2009_1' & `shbybin1_y1_1_0_2009_2' & `shbybin1_y1_1_0_2009_3' & `shbybin2_y1_1_0_2009_1' & `shbybin2_y1_1_0_2009_2' & `shbybin2_y1_1_0_2009_3' & `shbybin2_y1_1_0_2009_4' & `shbybin2_y1_1_0_2009_5' & `shbybin3_y1_1_0_2009_1' & `shbybin3_y1_1_0_2009_2' & `shbybin3_y1_1_0_2009_3' & `sh_y1_1_0_2009' \\" _n  ///
	"Agriculture  & `shbybin1_y1_2_0_2009_1' & `shbybin1_y1_2_0_2009_2' & `shbybin1_y1_2_0_2009_3' & `shbybin2_y1_2_0_2009_1' & `shbybin2_y1_2_0_2009_2' & `shbybin2_y1_2_0_2009_3' & `shbybin2_y1_2_0_2009_4' & `shbybin2_y1_2_0_2009_5' & `shbybin3_y1_2_0_2009_1' & `shbybin3_y1_2_0_2009_2' & `shbybin3_y1_2_0_2009_3' & `sh_y1_2_0_2009' \\" _n  ///
	"Business     & `shbybin1_y1_3_0_2009_1' & `shbybin1_y1_3_0_2009_2' & `shbybin1_y1_3_0_2009_3' & `shbybin2_y1_3_0_2009_1' & `shbybin2_y1_3_0_2009_2' & `shbybin2_y1_3_0_2009_3' & `shbybin2_y1_3_0_2009_4' & `shbybin2_y1_3_0_2009_5' & `shbybin3_y1_3_0_2009_1' & `shbybin3_y1_3_0_2009_2' & `shbybin3_y1_3_0_2009_3' & `sh_y1_3_0_2009' \\" _n  ///
	"Capital      & `shbybin1_y1_4_0_2009_1' & `shbybin1_y1_4_0_2009_2' & `shbybin1_y1_4_0_2009_3' & `shbybin2_y1_4_0_2009_1' & `shbybin2_y1_4_0_2009_2' & `shbybin2_y1_4_0_2009_3' & `shbybin2_y1_4_0_2009_4' & `shbybin2_y1_4_0_2009_5' & `shbybin3_y1_4_0_2009_1' & `shbybin3_y1_4_0_2009_2' & `shbybin3_y1_4_0_2009_3' & `sh_y1_4_0_2009' \\" _n  ///
	"Transfers Rec.  & `shbybin1_y1_5_0_2009_1' & `shbybin1_y1_5_0_2009_2' & `shbybin1_y1_5_0_2009_3' & `shbybin2_y1_5_0_2009_1' & `shbybin2_y1_5_0_2009_2' & `shbybin2_y1_5_0_2009_3' & `shbybin2_y1_5_0_2009_4' & `shbybin2_y1_5_0_2009_5' & `shbybin3_y1_5_0_2009_1' & `shbybin3_y1_5_0_2009_2' & `shbybin3_y1_5_0_2009_3' & `sh_y1_5_0_2009' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{13}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"Public Trans. Rec.  & `shbybin1_y1_51_0_2009_1' & `shbybin1_y1_51_0_2009_2' & `shbybin1_y1_51_0_2009_3' & `shbybin2_y1_51_0_2009_1' & `shbybin2_y1_51_0_2009_2' & `shbybin2_y1_51_0_2009_3' & `shbybin2_y1_51_0_2009_4' & `shbybin2_y1_51_0_2009_5' & `shbybin3_y1_51_0_2009_1' & `shbybin3_y1_51_0_2009_2' & `shbybin3_y1_51_0_2009_3' & `sh_y1_51_0_2009' \\" _n  ///
	"(Above=100) & & & & & & & & & & & &  \\" _n  ///
	"\hspace{.3cm} Food Coupons    & `shbybin1_y1_511_0_2009_1' & `shbybin1_y1_511_0_2009_2' & `shbybin1_y1_511_0_2009_3' & `shbybin2_y1_511_0_2009_1' & `shbybin2_y1_511_0_2009_2' & `shbybin2_y1_511_0_2009_3' & `shbybin2_y1_511_0_2009_4' & `shbybin2_y1_511_0_2009_5' & `shbybin3_y1_511_0_2009_1' & `shbybin3_y1_511_0_2009_2' & `shbybin3_y1_511_0_2009_3' & `sh_y1_511_0_2009' \\" _n  ///
	"\hspace{.3cm} Sub. Work Unit  & `shbybin1_y1_512_0_2009_1' & `shbybin1_y1_512_0_2009_2' & `shbybin1_y1_512_0_2009_3' & `shbybin2_y1_512_0_2009_1' & `shbybin2_y1_512_0_2009_2' & `shbybin2_y1_512_0_2009_3' & `shbybin2_y1_512_0_2009_4' & `shbybin2_y1_512_0_2009_5' & `shbybin3_y1_512_0_2009_1' & `shbybin3_y1_512_0_2009_2' & `shbybin3_y1_512_0_2009_3' & `sh_y1_512_0_2009' \\" _n  ///
	"\hspace{.3cm} Sub. Gov.       & `shbybin1_y1_513_0_2009_1' & `shbybin1_y1_513_0_2009_2' & `shbybin1_y1_513_0_2009_3' & `shbybin2_y1_513_0_2009_1' & `shbybin2_y1_513_0_2009_2' & `shbybin2_y1_513_0_2009_3' & `shbybin2_y1_513_0_2009_4' & `shbybin2_y1_513_0_2009_5' & `shbybin3_y1_513_0_2009_1' & `shbybin3_y1_513_0_2009_2' & `shbybin3_y1_513_0_2009_3' & `sh_y1_513_0_2009' \\" _n  ///
	"\hspace{.3cm} Pension         & `shbybin1_y1_514_0_2009_1' & `shbybin1_y1_514_0_2009_2' & `shbybin1_y1_514_0_2009_3' & `shbybin2_y1_514_0_2009_1' & `shbybin2_y1_514_0_2009_2' & `shbybin2_y1_514_0_2009_3' & `shbybin2_y1_514_0_2009_4' & `shbybin2_y1_514_0_2009_5' & `shbybin3_y1_514_0_2009_1' & `shbybin3_y1_514_0_2009_2' & `shbybin3_y1_514_0_2009_3' & `sh_y1_514_0_2009' \\" _n  ///
	"Private Trans. Rec. & `shbybin1_y1_52_0_2009_1' & `shbybin1_y1_52_0_2009_2' & `shbybin1_y1_52_0_2009_3' & `shbybin2_y1_52_0_2009_1' & `shbybin2_y1_52_0_2009_2' & `shbybin2_y1_52_0_2009_3' & `shbybin2_y1_52_0_2009_4' & `shbybin2_y1_52_0_2009_5' & `shbybin3_y1_52_0_2009_1' & `shbybin3_y1_52_0_2009_2' & `shbybin3_y1_52_0_2009_3' & `sh_y1_52_0_2009' \\" _n  ///
	"\midrule" _n ///
	" & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
	
	* URBAN 2009
	cap file close _all
	file open ofile using "Tables\table2_2009u_d.tex", write replace	
	file write ofile "\begin{tabular}{c c c| c c c c c| c c c| c}" _n ///
	"\toprule" _n ///
	"\multicolumn{3}{c|}{Bottom (\%)} & \multicolumn{5}{c|}{Quintiles} & \multicolumn{3}{c|}{Top (\%)} & All  \\" _n ///
	"0-1 & 1-5 & 5-10 &  1st & 2nd & 3rd & 4th & 5th & 10-5 & 5-1 & 1 & 0-100 \\" _n ///
	"\midrule \\"	_n  ///
	"\multicolumn{12}{c}{Averages, US\\$} \\" _n  ///
	"\midrule" _n ///
	"`mc_bin1_2009_1_1'  & `mc_bin1_2009_1_2'  & `mc_bin1_2009_1_3'  & `mc_bin2_2009_1_1'  & `mc_bin2_2009_1_2'  & `mc_bin2_2009_1_3'  & `mc_bin2_2009_1_4'  & `mc_bin2_2009_1_5'  & `mc_bin3_2009_1_1'  & `mc_bin3_2009_1_2'  & `mc_bin3_2009_1_3'  & `mc_1_2009' \\"  _n ///
	"`my0_bin1_2009_1_1' & `my0_bin1_2009_1_2' & `my0_bin1_2009_1_3' & `my0_bin2_2009_1_1' & `my0_bin2_2009_1_2' & `my0_bin2_2009_1_3' & `my0_bin2_2009_1_4' & `my0_bin2_2009_1_5' & `my0_bin3_2009_1_1' & `my0_bin3_2009_1_2' & `my0_bin3_2009_1_3' & `my0_1_2009' \\"  _n ///
	"`my1_bin1_2009_1_1' & `my1_bin1_2009_1_2' & `my1_bin1_2009_1_3' & `my1_bin2_2009_1_1' & `my1_bin2_2009_1_2' & `my1_bin2_2009_1_3' & `my1_bin2_2009_1_4' & `my1_bin2_2009_1_5' & `my1_bin3_2009_1_1' & `my1_bin3_2009_1_2' & `my1_bin3_2009_1_3' & `my1_1_2009' \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Shares of Total (\%)} \\" _n  ///
	"\midrule" _n ///
	"`shbybin1_c_1_2009_1'   & `shbybin1_c_1_2009_2'   & `shbybin1_c_1_2009_3'   & `shbybin2_c_1_2009_1'   & `shbybin2_c_1_2009_2'   & `shbybin2_c_1_2009_3'   & `shbybin2_c_1_2009_4'   & `shbybin2_c_1_2009_5'   & `shbybin3_c_1_2009_1'   & `shbybin3_c_1_2009_2'   & `shbybin3_c_1_2009_3'   & 100 \\"  _n ///
	"`shbybin1_y0_1_2009_1'  & `shbybin1_y0_1_2009_2'  & `shbybin1_y0_1_2009_3'  & `shbybin2_y0_1_2009_1'  & `shbybin2_y0_1_2009_2'  & `shbybin2_y0_1_2009_3'  & `shbybin2_y0_1_2009_4'  & `shbybin2_y0_1_2009_5'  & `shbybin3_y0_1_2009_1'  & `shbybin3_y0_1_2009_2'  & `shbybin3_y0_1_2009_3'  & 100 \\"  _n ///
	"`shbybin1_y1_1_2009_1'  & `shbybin1_y1_1_2009_2'  & `shbybin1_y1_1_2009_3'  & `shbybin2_y1_1_2009_1'  & `shbybin2_y1_1_2009_2'  & `shbybin2_y1_1_2009_3'  & `shbybin2_y1_1_2009_4'  & `shbybin2_y1_1_2009_5'  & `shbybin3_y1_1_2009_1'  & `shbybin3_y1_1_2009_2'  & `shbybin3_y1_1_2009_3'  & 100 \\"  _n ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Consumption Type (\%)}  \\" _n ///
	"\midrule" _n /// 
	"`shbybin1_c0_1_1_2009_1' & `shbybin1_c0_1_1_2009_2' & `shbybin1_c0_1_1_2009_3' & `shbybin2_c0_1_1_2009_1' & `shbybin2_c0_1_1_2009_2' & `shbybin2_c0_1_1_2009_3' & `shbybin2_c0_1_1_2009_4' & `shbybin2_c0_1_1_2009_5' & `shbybin3_c0_1_1_2009_1' & `shbybin3_c0_1_1_2009_2' & `shbybin3_c0_1_1_2009_3' & `sh_c0_1_1_2009' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_c0_11_1_2009_1' & `shbybin1_c0_11_1_2009_2' & `shbybin1_c0_11_1_2009_3' & `shbybin2_c0_11_1_2009_1' & `shbybin2_c0_11_1_2009_2' & `shbybin2_c0_11_1_2009_3' & `shbybin2_c0_11_1_2009_4' & `shbybin2_c0_11_1_2009_5' & `shbybin3_c0_11_1_2009_1' & `shbybin3_c0_11_1_2009_2' & `shbybin3_c0_11_1_2009_3' & `sh_c0_11_1_2009' \\" _n  ///
	"`shbybin1_c0_12_1_2009_1' & `shbybin1_c0_12_1_2009_2' & `shbybin1_c0_12_1_2009_3' & `shbybin2_c0_12_1_2009_1' & `shbybin2_c0_12_1_2009_2' & `shbybin2_c0_12_1_2009_3' & `shbybin2_c0_12_1_2009_4' & `shbybin2_c0_12_1_2009_5' & `shbybin3_c0_12_1_2009_1' & `shbybin3_c0_12_1_2009_2' & `shbybin3_c0_12_1_2009_3' & `sh_c0_12_1_2009' \\" _n  ///
	"`shbybin1_c0_13_1_2009_1' & `shbybin1_c0_13_1_2009_2' & `shbybin1_c0_13_1_2009_3' & `shbybin2_c0_13_1_2009_1' & `shbybin2_c0_13_1_2009_2' & `shbybin2_c0_13_1_2009_3' & `shbybin2_c0_13_1_2009_4' & `shbybin2_c0_13_1_2009_5' & `shbybin3_c0_13_1_2009_1' & `shbybin3_c0_13_1_2009_2' & `shbybin3_c0_13_1_2009_3' & `sh_c0_13_1_2009' \\" _n  ///
	"`shbybin1_c0_14_1_2009_1' & `shbybin1_c0_14_1_2009_2' & `shbybin1_c0_14_1_2009_3' & `shbybin2_c0_14_1_2009_1' & `shbybin2_c0_14_1_2009_2' & `shbybin2_c0_14_1_2009_3' & `shbybin2_c0_14_1_2009_4' & `shbybin2_c0_14_1_2009_5' & `shbybin3_c0_14_1_2009_1' & `shbybin3_c0_14_1_2009_2' & `shbybin3_c0_14_1_2009_3' & `sh_c0_14_1_2009' \\" _n  ///
	"`shbybin1_c0_2_1_2009_1' & `shbybin1_c0_2_1_2009_2' & `shbybin1_c0_2_1_2009_3' & `shbybin2_c0_2_1_2009_1' & `shbybin2_c0_2_1_2009_2' & `shbybin2_c0_2_1_2009_3' & `shbybin2_c0_2_1_2009_4' & `shbybin2_c0_2_1_2009_5' & `shbybin3_c0_2_1_2009_1' & `shbybin3_c0_2_1_2009_2' & `shbybin3_c0_2_1_2009_3' & `sh_c0_2_1_2009' \\" _n  ///
	"`shbybin1_c0_3_1_2009_1' & `shbybin1_c0_3_1_2009_2' & `shbybin1_c0_3_1_2009_3' & `shbybin2_c0_3_1_2009_1' & `shbybin2_c0_3_1_2009_2' & `shbybin2_c0_3_1_2009_3' & `shbybin2_c0_3_1_2009_4' & `shbybin2_c0_3_1_2009_5' & `shbybin3_c0_3_1_2009_1' & `shbybin3_c0_3_1_2009_2' & `shbybin3_c0_3_1_2009_3' & `sh_c0_3_1_2009' \\" _n  ///
	"`shbybin1_c0_4_1_2009_1' & `shbybin1_c0_4_1_2009_2' & `shbybin1_c0_4_1_2009_3' & `shbybin2_c0_4_1_2009_1' & `shbybin2_c0_4_1_2009_2' & `shbybin2_c0_4_1_2009_3' & `shbybin2_c0_4_1_2009_4' & `shbybin2_c0_4_1_2009_5' & `shbybin3_c0_4_1_2009_1' & `shbybin3_c0_4_1_2009_2' & `shbybin3_c0_4_1_2009_3' & `sh_c0_4_1_2009' \\" _n  ///
	"`shbybin1_c0_5_1_2009_1' & `shbybin1_c0_5_1_2009_2' & `shbybin1_c0_5_1_2009_3' & `shbybin2_c0_5_1_2009_1' & `shbybin2_c0_5_1_2009_2' & `shbybin2_c0_5_1_2009_3' & `shbybin2_c0_5_1_2009_4' & `shbybin2_c0_5_1_2009_5' & `shbybin3_c0_5_1_2009_1' & `shbybin3_c0_5_1_2009_2' & `shbybin3_c0_5_1_2009_3' & `sh_c0_5_1_2009' \\" _n  ///
	"`shbybin1_c0_6_1_2009_1' & `shbybin1_c0_6_1_2009_2' & `shbybin1_c0_6_1_2009_3' & `shbybin2_c0_6_1_2009_1' & `shbybin2_c0_6_1_2009_2' & `shbybin2_c0_6_1_2009_3' & `shbybin2_c0_6_1_2009_4' & `shbybin2_c0_6_1_2009_5' & `shbybin3_c0_6_1_2009_1' & `shbybin3_c0_6_1_2009_2' & `shbybin3_c0_6_1_2009_3' & `sh_c0_6_1_2009' \\" _n  ///
	"`shbybin1_c0_7_1_2009_1' & `shbybin1_c0_7_1_2009_2' & `shbybin1_c0_7_1_2009_3' & `shbybin2_c0_7_1_2009_1' & `shbybin2_c0_7_1_2009_2' & `shbybin2_c0_7_1_2009_3' & `shbybin2_c0_7_1_2009_4' & `shbybin2_c0_7_1_2009_5' & `shbybin3_c0_7_1_2009_1' & `shbybin3_c0_7_1_2009_2' & `shbybin3_c0_7_1_2009_3' & `sh_c0_7_1_2009' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Income Sources (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_1_1_2009_1' & `shbybin1_y1_1_1_2009_2' & `shbybin1_y1_1_1_2009_3' & `shbybin2_y1_1_1_2009_1' & `shbybin2_y1_1_1_2009_2' & `shbybin2_y1_1_1_2009_3' & `shbybin2_y1_1_1_2009_4' & `shbybin2_y1_1_1_2009_5' & `shbybin3_y1_1_1_2009_1' & `shbybin3_y1_1_1_2009_2' & `shbybin3_y1_1_1_2009_3' & `sh_y1_1_1_2009' \\" _n  ///
	"`shbybin1_y1_2_1_2009_1' & `shbybin1_y1_2_1_2009_2' & `shbybin1_y1_2_1_2009_3' & `shbybin2_y1_2_1_2009_1' & `shbybin2_y1_2_1_2009_2' & `shbybin2_y1_2_1_2009_3' & `shbybin2_y1_2_1_2009_4' & `shbybin2_y1_2_1_2009_5' & `shbybin3_y1_2_1_2009_1' & `shbybin3_y1_2_1_2009_2' & `shbybin3_y1_2_1_2009_3' & `sh_y1_2_1_2009' \\" _n  ///
	"`shbybin1_y1_3_1_2009_1' & `shbybin1_y1_3_1_2009_2' & `shbybin1_y1_3_1_2009_3' & `shbybin2_y1_3_1_2009_1' & `shbybin2_y1_3_1_2009_2' & `shbybin2_y1_3_1_2009_3' & `shbybin2_y1_3_1_2009_4' & `shbybin2_y1_3_1_2009_5' & `shbybin3_y1_3_1_2009_1' & `shbybin3_y1_3_1_2009_2' & `shbybin3_y1_3_1_2009_3' & `sh_y1_3_1_2009' \\" _n  ///
	"`shbybin1_y1_4_1_2009_1' & `shbybin1_y1_4_1_2009_2' & `shbybin1_y1_4_1_2009_3' & `shbybin2_y1_4_1_2009_1' & `shbybin2_y1_4_1_2009_2' & `shbybin2_y1_4_1_2009_3' & `shbybin2_y1_4_1_2009_4' & `shbybin2_y1_4_1_2009_5' & `shbybin3_y1_4_1_2009_1' & `shbybin3_y1_4_1_2009_2' & `shbybin3_y1_4_1_2009_3' & `sh_y1_4_1_2009' \\" _n  ///
	"`shbybin1_y1_5_1_2009_1' & `shbybin1_y1_5_1_2009_2' & `shbybin1_y1_5_1_2009_3' & `shbybin2_y1_5_1_2009_1' & `shbybin2_y1_5_1_2009_2' & `shbybin2_y1_5_1_2009_3' & `shbybin2_y1_5_1_2009_4' & `shbybin2_y1_5_1_2009_5' & `shbybin3_y1_5_1_2009_1' & `shbybin3_y1_5_1_2009_2' & `shbybin3_y1_5_1_2009_3' & `sh_y1_5_1_2009' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\midrule \\" _n ///
	"\multicolumn{12}{c}{Transfers Received (\%)}  \\" _n ///
	"\midrule" _n ///
	"`shbybin1_y1_51_1_2009_1' & `shbybin1_y1_51_1_2009_2' & `shbybin1_y1_51_1_2009_3' & `shbybin2_y1_51_1_2009_1' & `shbybin2_y1_51_1_2009_2' & `shbybin2_y1_51_1_2009_3' & `shbybin2_y1_51_1_2009_4' & `shbybin2_y1_51_1_2009_5' & `shbybin3_y1_51_1_2009_1' & `shbybin3_y1_51_1_2009_2' & `shbybin3_y1_51_1_2009_3' & `sh_y1_51_1_2009' \\" _n  ///
	" & & & & & & & & & & &  \\" _n  ///
	"`shbybin1_y1_511_1_2009_1' & `shbybin1_y1_511_1_2009_2' & `shbybin1_y1_511_1_2009_3' & `shbybin2_y1_511_1_2009_1' & `shbybin2_y1_511_1_2009_2' & `shbybin2_y1_511_1_2009_3' & `shbybin2_y1_511_1_2009_4' & `shbybin2_y1_511_1_2009_5' & `shbybin3_y1_511_1_2009_1' & `shbybin3_y1_511_1_2009_2' & `shbybin3_y1_511_1_2009_3' & `sh_y1_511_1_2009' \\" _n  ///
	"`shbybin1_y1_512_1_2009_1' & `shbybin1_y1_512_1_2009_2' & `shbybin1_y1_512_1_2009_3' & `shbybin2_y1_512_1_2009_1' & `shbybin2_y1_512_1_2009_2' & `shbybin2_y1_512_1_2009_3' & `shbybin2_y1_512_1_2009_4' & `shbybin2_y1_512_1_2009_5' & `shbybin3_y1_512_1_2009_1' & `shbybin3_y1_512_1_2009_2' & `shbybin3_y1_512_1_2009_3' & `sh_y1_512_1_2009' \\" _n  ///
	"`shbybin1_y1_513_1_2009_1' & `shbybin1_y1_513_1_2009_2' & `shbybin1_y1_513_1_2009_3' & `shbybin2_y1_513_1_2009_1' & `shbybin2_y1_513_1_2009_2' & `shbybin2_y1_513_1_2009_3' & `shbybin2_y1_513_1_2009_4' & `shbybin2_y1_513_1_2009_5' & `shbybin3_y1_513_1_2009_1' & `shbybin3_y1_513_1_2009_2' & `shbybin3_y1_513_1_2009_3' & `sh_y1_513_1_2009' \\" _n  ///
	"`shbybin1_y1_514_1_2009_1' & `shbybin1_y1_514_1_2009_2' & `shbybin1_y1_514_1_2009_3' & `shbybin2_y1_514_1_2009_1' & `shbybin2_y1_514_1_2009_2' & `shbybin2_y1_514_1_2009_3' & `shbybin2_y1_514_1_2009_4' & `shbybin2_y1_514_1_2009_5' & `shbybin3_y1_514_1_2009_1' & `shbybin3_y1_514_1_2009_2' & `shbybin3_y1_514_1_2009_3' & `sh_y1_514_1_2009' \\" _n  ///
	"`shbybin1_y1_52_1_2009_1' & `shbybin1_y1_52_1_2009_2' & `shbybin1_y1_52_1_2009_3' & `shbybin2_y1_52_1_2009_1' & `shbybin2_y1_52_1_2009_2' & `shbybin2_y1_52_1_2009_3' & `shbybin2_y1_52_1_2009_4' & `shbybin2_y1_52_1_2009_5' & `shbybin3_y1_52_1_2009_1' & `shbybin3_y1_52_1_2009_2' & `shbybin3_y1_52_1_2009_3' & `sh_y1_52_1_2009' \\" _n  ///
	"\midrule" _n ///
	"100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 & 100 \\"  _n  ///
	"\bottomrule" _n ///
	"\end{tabular}"
	file close _all
