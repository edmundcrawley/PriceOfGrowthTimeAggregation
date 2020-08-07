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
cap ssc install fastgini

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
	qui gen income1_ad2 = income1 /equiv_ad2

keep income1_ad2 consumption1_KP urban interview_year case_id
keep if interview_year == 1989 | interview_year == 2009
duplicates drop
keep if income1_ad2~=.
gen  reside = 1-urban
rename consumption1_KP  c
rename income1_ad2		y1

gen lnc = ln(c)
gen lny1= ln(y1)
foreach var in c y1		{
	foreach t in 1989 2009	{
		* FULL SAMPLE
		sum `var' if interview_year==`t', d
		local `var'_MtM_`t' = string(r(mean)/r(p50),"%10.3f")
		local `var'_TB_`t'  = string(r(p90)/r(p10),"%10.3f")
		local `var'_sk_`t'	= string(r(skewness),"%10.3f")
		local `var'_ku_`t'  = string(r(kurtosis),"%10.3f")
		local `var'_cv_`t'  = string(r(sd)/r(mean),"%10.3f")
		scalar m`var' = r(mean)
		
		egen locmean = mean((`var'<m`var' & interview_year==`t') / (`var'<. & interview_year==`t'))
		sum locmean
		local `var'_lm_`t'  = string(r(mean)*100,"%10.1f")
		drop locmean
		scalar drop m`var'
		
		sum ln`var' if interview_year==`t', d
		local `var'_vln_`t' = string(r(Var),"%10.3f")
		
		fastgini `var' if interview_year==`t'
		local `var'_gini_`t'= string(r(gini),"%10.3f")
		
		* RURAL SAMPLE
		sum `var' if interview_year==`t' & reside == 1, d
		local `var'_MtM_`t'_r = string(r(mean)/r(p50),"%10.3f")
		local `var'_TB_`t'_r  = string(r(p90)/r(p10),"%10.3f")
		local `var'_sk_`t'_r  = string(r(skewness),"%10.3f")
		local `var'_ku_`t'_r  = string(r(kurtosis),"%10.3f")
		local `var'_cv_`t'_r  = string(r(sd)/r(mean),"%10.3f")
		scalar m`var' = r(mean)
		
		egen locmean = mean((`var'<m`var' & interview_year==`t' & reside==1) / (`var'<. & interview_year==`t' & reside==1))
		sum locmean
		local `var'_lm_`t'_r  = string(r(mean)*100,"%10.1f")
		drop locmean
		scalar drop m`var'
		
		sum ln`var' if interview_year==`t' & reside==1, d
		local `var'_vln_`t'_r = string(r(Var),"%10.3f")
		
		fastgini `var' if interview_year==`t' & reside==1
		local `var'_gini_`t'_r= string(r(gini),"%10.3f")
		
		* URBAN SAMPLE
		sum `var' if interview_year==`t' & reside == 0, d
		local `var'_MtM_`t'_u = string(r(mean)/r(p50),"%10.3f")
		local `var'_TB_`t'_u  = string(r(p90)/r(p10),"%10.3f")
		local `var'_sk_`t'_u  = string(r(skewness),"%10.3f")
		local `var'_ku_`t'_u  = string(r(kurtosis),"%10.3f")
		local `var'_cv_`t'_u  = string(r(sd)/r(mean),"%10.3f")
		scalar m`var' = r(mean)
		
		egen locmean = mean((`var'<m`var' & interview_year==`t' & reside==0) / (`var'<. & interview_year==`t' & reside==0))
		sum locmean
		local `var'_lm_`t'_u  = string(r(mean)*100,"%10.1f")
		drop locmean
		scalar drop m`var'
		
		sum ln`var' if interview_year==`t' & reside==0, d
		local `var'_vln_`t'_u = string(r(Var),"%10.3f")
		
		fastgini `var' if interview_year==`t' & reside==0
		local `var'_gini_`t'_u= string(r(gini),"%10.3f")
		
	}
}

* MAKE THE TABLE
cap file close _all
file open ofile using "Tables\table_ineqmeasures.tex", write replace	
file write ofile "\begin{tabular}{l p{1.4cm} p{1.4cm} p{1.4cm} p{1.4cm} p{1.4cm} p{1.4cm} p{1.4cm} p{1.4cm}}" _n ///
	"\toprule" _n ///
	"\multicolumn{9}{l}{\textbf{[A] China, CHNS 1989 (in 2009 USD)}} \\"  _n ///
	"\\" _n ///
	"			 & Mean to Median  & Location Mean (\%)	& Variance of Logs 	& Gini Index       & Coefficient of Variation   &   90/10 Ratio    & 	Skewness    	&   Kurtosis		\\" _n ///
	"\midrule \\" _n ///
	"Consumption & `c_MtM_1989'	   	& `c_lm_1989'		& `c_vln_1989'		& `c_gini_1989'    	&   `c_cv_1989'				&   `c_TB_1989'		&    `c_sk_1989'	&  `c_ku_1989'		\\" _n ///
	"Income      & `y1_MtM_1989'	& `y1_lm_1989'		& `y1_vln_1989'		& `y1_gini_1989'    &   `y1_cv_1989'			&   `y1_TB_1989'	&    `y1_sk_1989'	&  `y1_ku_1989'		\\" _n ///
	"\\" _n ///
	"\multicolumn{9}{l}{\textbf{Rural China}} \\"  _n ///
	"\midrule \\" _n ///
	"Consumption & `c_MtM_1989_r'	& `c_lm_1989_r'		& `c_vln_1989_r'	& `c_gini_1989_r'    &   `c_cv_1989_r'			&   `c_TB_1989_r'	&    `c_sk_1989_r'	&  `c_ku_1989_r'	\\" _n ///
	"Income      & `y1_MtM_1989_r'	& `y1_lm_1989_r'	& `y1_vln_1989_r'	& `y1_gini_1989_r'   &   `y1_cv_1989_r'			&   `y1_TB_1989_r'	&    `y1_sk_1989_r'	&  `y1_ku_1989_r'	\\" _n ///
	"\\" _n ///
	"\multicolumn{9}{l}{\textbf{Urban China}} \\"  _n ///
	"\midrule \\" _n ///
	"Consumption & `c_MtM_1989_u'	& `c_lm_1989_u'		& `c_vln_1989_u'	& `c_gini_1989_u'    &   `c_cv_1989_u'			&   `c_TB_1989_u'	&    `c_sk_1989_u'	&  `c_ku_1989_u'	\\" _n ///
	"Income      & `y1_MtM_1989_u'	& `y1_lm_1989_u'	& `y1_vln_1989_u'	& `y1_gini_1989_u'   &   `y1_cv_1989_u'			&   `y1_TB_1989_u'	&    `y1_sk_1989_u'	&  `y1_ku_1989_u'	\\" _n ///
	"\\" _n ///
	"\multicolumn{9}{l}{\textbf{[B] China, CHNS 2009 (in 2009 USD)}} \\"  _n ///
	"\\" _n ///
	"			 & Mean to Median  & Location Mean (\%)	& Variance of Logs 	& Gini Index       & Coefficient of Variation   &   90/10 Ratio    & 	Skewness    	&   Kurtosis		\\" _n ///
	"\midrule \\" _n ///
	"Consumption & `c_MtM_2009'	   	& `c_lm_2009'		& `c_vln_2009'		& `c_gini_2009'    	&   `c_cv_2009'				&   `c_TB_2009'		&    `c_sk_2009'	&  `c_ku_2009'		\\" _n ///
	"Income      & `y1_MtM_2009'	& `y1_lm_2009'		& `y1_vln_2009'		& `y1_gini_2009'    &   `y1_cv_2009'			&   `y1_TB_2009'	&    `y1_sk_2009'	&  `y1_ku_2009'		\\" _n ///
	"\\" _n ///
	"\multicolumn{9}{l}{\textbf{Rural China}} \\"  _n ///
	"\midrule \\" _n ///
	"Consumption & `c_MtM_2009_r'	& `c_lm_2009_r'		& `c_vln_2009_r'	& `c_gini_2009_r'    &   `c_cv_2009_r'			&   `c_TB_2009_r'	&    `c_sk_2009_r'	&  `c_ku_2009_r'	\\" _n ///
	"Income      & `y1_MtM_2009_r'	& `y1_lm_2009_r'	& `y1_vln_2009_r'	& `y1_gini_2009_r'   &   `y1_cv_2009_r'			&   `y1_TB_2009_r'	&    `y1_sk_2009_r'	&  `y1_ku_2009_r'	\\" _n ///
	"\\" _n ///
	"\multicolumn{9}{l}{\textbf{Urban China}} \\"  _n ///
	"\midrule \\" _n ///
	"Consumption & `c_MtM_2009_u'	& `c_lm_2009_u'		& `c_vln_2009_u'	& `c_gini_2009_u'    &   `c_cv_2009_u'			&   `c_TB_2009_u'	&    `c_sk_2009_u'	&  `c_ku_2009_u'	\\" _n ///
	"Income      & `y1_MtM_2009_u'	& `y1_lm_2009_u'	& `y1_vln_2009_u'	& `y1_gini_2009_u'   &   `y1_cv_2009_u'			&   `y1_TB_2009_u'	&    `y1_sk_2009_u'	&  `y1_ku_2009_u'	\\" _n ///
	"\\" _n ///
"\bottomrule" _n ///
"\end{tabular}"
file close _all	
