***************************************************************************************************************
* THIS FILE PRODUCES SUMMARY STATISTICS FROM CHNS FOLLOWING SAMPLE SELECTION AND TRIMMING.
* CHNS 1989 - 2009
* STATA/SE 14.0
* CREATED BY YU ZHENG
***************************************************************************************************************
clear
set mem 500m
set more off
cap log close

cd "$mypath"

 use "CHNS-dta-files---final\CHNS-no-trim-final.dta", clear

 drop anp* wf_gov sub_gov

 gen sampletag = 1		// THE ORIGINAL SAMPLE
 
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
 
 replace sampletag = 2 if relation2head==1 & (age>=25 & age<=65) & (hh_size>=2 & hh_size<=6)
 
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


* SORT THE DATA
 sort case_id wave		 
xtset case_id wave
gen   reside = 1-urban
keep case_id wave reside sampletag sex age

* MERGE WITH TRIMMED DATA DATASET
merge 1:1 case_id wave using "CHNS-dta-files---final\CHNStrimmed.dta", update
assert _merge==1 | _merge==3
misstable sum reside sex age

replace sampletag = 3 if sampletag==2 & _merge==3
gen		data1   = 1
gen		data2   = (sampletag == 2 | sampletag == 3)
gen		data3	= (sampletag == 3)
replace sex    = 0 if sex == 2

foreach var in reside sex	{
	forvalues t = 1/8			{
		foreach datavar in data1 data2 data3		{
			qui sum `var' if wave == `t' & `datavar'==1
			local m`var'_`t'_`datavar' = string(r(mean), "%10.3f")
		}
	}
}
foreach var in age	{
	forvalues t = 1/8			{
		foreach datavar in data1 data2 data3		{
			qui sum `var' if wave == `t' & `datavar'==1
			local m`var'_`t'_`datavar' = string(r(mean), "%10.1f")
		}
	}
}
forvalues t = 1/8		{
	foreach datavar in data1 data2 data3	{
		qui sum case_id if wave==`t' & `datavar'==1
		local nobs_`t'_`datavar' = string(r(N), "%10.0fc")
	}
}

* MAKE THE TABLE
cap file close _all
file open ofile using "Tables\table_trimming.tex", write replace	
file write ofile "\begin{tabular}{l p{2cm} p{2cm} p{2cm} p{2cm}}" _n ///
	"\toprule" _n ///
	"Survey Year & No. of Obs.  & Pct. Rural 		& Pct. Male 	& Avg. Age 			\\" _n ///
	"\midrule \\" _n ///
	"\multicolumn{5}{c}{Original Data}  \\" _n ///
	"\\" _n ///
	"1989		 &	`nobs_1_data1'	& 	`mreside_1_data1'	&  `msex_1_data1'	&	`mage_1_data1'		\\" _n ///
	"1991		 &	`nobs_2_data1'	& 	`mreside_2_data1'	&  `msex_2_data1'	&	`mage_2_data1'		\\" _n ///
	"1993		 &	`nobs_3_data1'	& 	`mreside_3_data1'	&  `msex_3_data1'	&	`mage_3_data1'		\\" _n ///
	"1997		 &	`nobs_4_data1'	& 	`mreside_4_data1'	&  `msex_4_data1'	&	`mage_4_data1'		\\" _n ///
	"2000		 &	`nobs_5_data1'	& 	`mreside_5_data1'	&  `msex_5_data1'	&	`mage_5_data1'		\\" _n ///
	"2004		 &	`nobs_6_data1'	& 	`mreside_6_data1'	&  `msex_6_data1'	&	`mage_6_data1'		\\" _n ///
	"2006		 &	`nobs_7_data1'	& 	`mreside_7_data1'	&  `msex_7_data1'	&	`mage_7_data1'		\\" _n ///
	"2009		 &	`nobs_8_data1'	& 	`mreside_8_data1'	&  `msex_8_data1'	&	`mage_8_data1'		\\" _n ///
	"\\" _n ///
	"\multicolumn{5}{c}{After Sample Selection}  \\" _n ///
	"\\" _n ///
	"1989		 &	`nobs_1_data2'	& 	`mreside_1_data2'	&  `msex_1_data2'	&	`mage_1_data2'		\\" _n ///
	"1991		 &	`nobs_2_data2'	& 	`mreside_2_data2'	&  `msex_2_data2'	&	`mage_2_data2'		\\" _n ///
	"1993		 &	`nobs_3_data2'	& 	`mreside_3_data2'	&  `msex_3_data2'	&	`mage_3_data2'		\\" _n ///
	"1997		 &	`nobs_4_data2'	& 	`mreside_4_data2'	&  `msex_4_data2'	&	`mage_4_data2'		\\" _n ///
	"2000		 &	`nobs_5_data2'	& 	`mreside_5_data2'	&  `msex_5_data2'	&	`mage_5_data2'		\\" _n ///
	"2004		 &	`nobs_6_data2'	& 	`mreside_6_data2'	&  `msex_6_data2'	&	`mage_6_data2'		\\" _n ///
	"2006		 &	`nobs_7_data2'	& 	`mreside_7_data2'	&  `msex_7_data2'	&	`mage_7_data2'		\\" _n ///
	"2009		 &	`nobs_8_data2'	& 	`mreside_8_data2'	&  `msex_8_data2'	&	`mage_8_data2'		\\" _n ///
	"\\" _n ///
	"\multicolumn{5}{c}{After Level Trimming}  \\" _n ///
	"\\" _n ///
	"1989		 &	`nobs_1_data3'	& 	`mreside_1_data3'	&  `msex_1_data3'	&	`mage_1_data3'		\\" _n ///
	"1991		 &	`nobs_2_data3'	& 	`mreside_2_data3'	&  `msex_2_data3'	&	`mage_2_data3'		\\" _n ///
	"1993		 &	`nobs_3_data3'	& 	`mreside_3_data3'	&  `msex_3_data3'	&	`mage_3_data3'		\\" _n ///
	"1997		 &	`nobs_4_data3'	& 	`mreside_4_data3'	&  `msex_4_data3'	&	`mage_4_data3'		\\" _n ///
	"2000		 &	`nobs_5_data3'	& 	`mreside_5_data3'	&  `msex_5_data3'	&	`mage_5_data3'		\\" _n ///
	"2004		 &	`nobs_6_data3'	& 	`mreside_6_data3'	&  `msex_6_data3'	&	`mage_6_data3'		\\" _n ///
	"2006		 &	`nobs_7_data3'	& 	`mreside_7_data3'	&  `msex_7_data3'	&	`mage_7_data3'		\\" _n ///
	"2009		 &	`nobs_8_data3'	& 	`mreside_8_data3'	&  `msex_8_data3'	&	`mage_8_data3'		\\" _n ///
	"\\" _n ///
"\bottomrule" _n ///
"\end{tabular}"
file close _all





