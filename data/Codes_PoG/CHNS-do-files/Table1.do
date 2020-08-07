***************************************************************************************************************
* THIS FILE PRODUCES THE SUMMARY STATISTICS OF THE CHNS SAMPLE.
* CHNS 1989 - 2009
* STATA/SE 14.0
***************************************************************************************************************
clear
set mem 500m
set more off
cap log close

cd "$mypath"

use "CHNS-dta-files---final\CHNStrimmed.dta", clear

* TABLE 1: SUMMARY STATISTICS 
   gen		male  = (sex==1)		if sex~=.
   gen 		female= (sex==2)		if sex~=.
   replace 	male = male*100
   replace 	female = female*100
   gen 		educ0 = (educ==0)		if educ~=.
   gen 		educ1 = (educ==1)		if educ~=.
   gen 		educ2 = (educ==2)		if educ~=.
   replace 	educ0 = educ0*100
   replace 	educ1 = educ1*100
   replace 	educ2 = educ2*100
   gen 		liaoning 	 = (province==21) if province~=.
   gen		heilongjiang = (province==23) if province~=.
   gen		jiangsu 	 = (province==32) if province~=.
   gen		shandong	 = (province==37) if province~=.
   gen		henan		 = (province==41) if province~=.
   gen		hubei		 = (province==42) if province~=.
   gen 		hunan		 = (province==43) if province~=.
   gen 		guangxi		 = (province==45) if province~=.
   gen		guizhou		 = (province==52) if province~=.
   replace  liaoning 	 = liaoning*100
   replace  heilongjiang = heilongjiang*100
   replace  jiangsu		 = jiangsu*100
   replace  shandong 	 = shandong*100
   replace  henan		 = henan*100
   replace  hubei		 = hubei*100
   replace  hunan		 = hunan*100
   replace  guangxi		 = guangxi*100
   replace  guizhou		 = guizhou*100
   
   label var age 				"Age"
   label var male				"Male"
   label var female				"Female"
   label var educ0 				"No schooling"
   label var educ1 				"1-9th grade"
   label var educ2 				"Above 9th grade"
   label var hh_size 			"Household size"
   label var dep_ratio_weak 	"Weak DR"
   label var dep_ratio_strong	"Strong DR"
   label var liaoning			"Liaoning"
   label var heilongjiang		"Heilongjiang"
   label var jiangsu			"Jiangsu"
   label var shandong			"Shandong"
   label var henan				"Henan"
   label var hubei				"Hubei"
   label var hunan				"Hunan"
   label var guangxi			"Guangxi"
   label var guizhou			"Guizhou"
   

cap file close _all
file open ofile using "Tables\table1.tex", write replace	
file write ofile "\begin{tabular}{l p{1cm} p{1cm} p{1cm} c p{1cm} p{1cm} p{1cm}}" _n ///
	"\toprule" _n ///
	" & \multicolumn{3}{c}{1989} & & \multicolumn{3}{c}{2009} \\" _n ///
	" & Total & Rural & Urban    & & Total & Rural & Urban    \\" _n ///
	"\midrule \\" _n
	* AGE
	foreach var in age {
		local label`var': variable label `var'
		foreach t in 1989 2009 {
			qui sum `var' if year == `t'
			local mean`t'=string(r(mean),"%-10.1f")
			foreach r in 0 1  {
				qui sum `var' if year == `t' & urban == `r'
				local mean`t'_`r'=string(r(mean),"%-10.1f")
			}
		}
		file write ofile " `label`var'' & `mean1989' & `mean1989_0' & `mean1989_1' & & `mean2009' & `mean2009_0' & `mean2009_1' \\" _n
	}
	* GENDER
	file write ofile "\\ Gender of Head (\%) \\" _n 
	foreach var in male female {
		local label`var': variable label `var'
		foreach t in 1989 2009 {
			qui sum `var' if year == `t'
			local mean`t'=string(r(mean),"%-10.1f")
			foreach r in 0 1  {
				qui sum `var' if year == `t' & urban == `r'
				local mean`t'_`r'=string(r(mean),"%-10.1f")
			}
		}
		file write ofile "\hspace{.6cm} `label`var'' & `mean1989' & `mean1989_0' & `mean1989_1' & & `mean2009' & `mean2009_0' & `mean2009_1' \\" _n
	}
	* EDUCATION
	file write ofile "\\ Education of Head (\%) \\" _n
	foreach var in educ0 educ1 educ2 {
		local label`var': variable label `var'
		foreach t in 1989 2009 {
			qui sum `var' if year == `t'
			local mean`t'=string(r(mean),"%-10.1f")
			foreach r in 0 1  {
				qui sum `var' if year == `t' & urban == `r'
				local mean`t'_`r'=string(r(mean),"%-10.1f")
			}
		}
		file write ofile "\hspace{.6cm} `label`var'' & `mean1989' & `mean1989_0' & `mean1989_1' & & `mean2009' & `mean2009_0' & `mean2009_1' \\" _n
	}
	* HOUSEHOLD STRUCTURE
	file write ofile "\\ Household Structure \\" _n
	foreach var in hh_size dep_ratio_weak dep_ratio_strong {
		local label`var': variable label `var'
		foreach t in 1989 2009 {
			qui sum `var' if year == `t'
			local mean`t'=string(r(mean),"%-10.2f")
			foreach r in 0 1  {
				qui sum `var' if year == `t' & urban == `r'
				local mean`t'_`r'=string(r(mean),"%-10.2f")
			}
		}
		file write ofile "\hspace{.6cm} `label`var'' & `mean1989' & `mean1989_0' & `mean1989_1' & & `mean2009' & `mean2009_0' & `mean2009_1' \\" _n
	}
	* PROVINCE
	file write ofile "\\ Province (\%) \\" _n
	foreach var in liaoning heilongjiang jiangsu shandong henan hubei hunan guangxi guizhou  {
		local label`var': variable label `var'
		foreach t in 1989 2009 {
			qui sum `var' if year == `t'
			local mean`t'=string(r(mean),"%-10.1f")
			foreach r in 0 1  {
				qui sum `var' if year == `t' & urban == `r'
				local mean`t'_`r'=string(r(mean),"%-10.1f")
			}
		}
		file write ofile "\hspace{.6cm} `label`var'' & `mean1989' & `mean1989_0' & `mean1989_1' & & `mean2009' & `mean2009_0' & `mean2009_1' \\" _n
	}
	* NO. OF OBS
	foreach t in 1989 2009 {
		qui sum case_id if year == `t'
		local num`t'=string(r(N),"%-10.0fc")
		foreach r in 0 1  {
			qui sum case_id if year == `t' & urban == `r'
			local num`t'_`r'=string(r(N),"%-10.0fc")
		}
	}
	file write ofile "\\ No. of Observations  & `num1989' & `num1989_0' & `num1989_1' & & `num2009' & `num2009_0' & `num2009_1' \\  \\" _n  ///
"\bottomrule" _n ///
"\end{tabular}"
file close _all
