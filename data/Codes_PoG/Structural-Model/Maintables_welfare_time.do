***************************************************************************************************************
* THIS FILE PRODUCES TABLE 5.
* CHNS 1989 - 2009
* STATA/SE 14.0
* CREATED BY YU ZHENG
***************************************************************************************************************clear
clear matrix
clear mata
set mem 500m
set maxvar 32760
set more off

   cd "$mypath\Structural-Model\"
 

*************************************************
* RURAL SAMPLE
*************************************************
est clear
est use "est_spec1_final.ster"
eststo est1

* RURAL, PRE-PERIOD
	* POINT ESTIMATES
	local omega_G_1a = string(`=_b[r31]*100',"%10.2f")
	local omega_R_1a = string(`=_b[r32]*100',"%10.2f")
	local omega_I_1a = string(`=_b[r33]*100',"%10.2f")
	local omega_T_1a = string(`=_b[r34]*100',"%10.2f")

	local omega_G_2a = string(`=_b[r47]*100',"%10.2f")
	local omega_R_2a = string(`=_b[r48]*100',"%10.2f")
	local omega_I_2a = string(`=_b[r49]*100',"%10.2f")
	local omega_T_2a = string(`=_b[r50]*100',"%10.2f")
	
	* 95% CONFIDENCE INTERVALS
	matrix ci95 = e(ci_percentile)
	local omega_R_1a_lb = string(`=ci95[1,32]*100',"%10.2f")
	local omega_R_1a_ub = string(`=ci95[2,32]*100',"%10.2f")
	local omega_I_1a_lb = string(`=ci95[1,33]*100',"%10.2f")
	local omega_I_1a_ub = string(`=ci95[2,33]*100',"%10.2f")
	local omega_T_1a_lb = string(`=ci95[1,34]*100',"%10.2f")
	local omega_T_1a_ub = string(`=ci95[2,34]*100',"%10.2f")
	
	local omega_R_2a_lb = string(`=ci95[1,48]*100',"%10.2f")
	local omega_R_2a_ub = string(`=ci95[2,48]*100',"%10.2f")
	local omega_I_2a_lb = string(`=ci95[1,49]*100',"%10.2f")
	local omega_I_2a_ub = string(`=ci95[2,49]*100',"%10.2f")
	local omega_T_2a_lb = string(`=ci95[1,50]*100',"%10.2f")
	local omega_T_2a_ub = string(`=ci95[2,50]*100',"%10.2f")
	
* RURAL, POST-PERIOD
	* POINT ESTIMATES
	local omega_G_1b = string(`=_b[r35]*100',"%10.2f")
	local omega_R_1b = string(`=_b[r36]*100',"%10.2f")
	local omega_I_1b = string(`=_b[r37]*100',"%10.2f")
	local omega_T_1b = string(`=_b[r38]*100',"%10.2f")

	local omega_G_2b = string(`=_b[r51]*100',"%10.2f")
	local omega_R_2b = string(`=_b[r52]*100',"%10.2f")
	local omega_I_2b = string(`=_b[r53]*100',"%10.2f")
	local omega_T_2b = string(`=_b[r54]*100',"%10.2f")
	
	* 95% CONFIDENCE INTERVALS
	matrix ci95 = e(ci_percentile)
	local omega_R_1b_lb = string(`=ci95[1,36]*100',"%10.2f")
	local omega_R_1b_ub = string(`=ci95[2,36]*100',"%10.2f")
	local omega_I_1b_lb = string(`=ci95[1,37]*100',"%10.2f")
	local omega_I_1b_ub = string(`=ci95[2,37]*100',"%10.2f")
	local omega_T_1b_lb = string(`=ci95[1,38]*100',"%10.2f")
	local omega_T_1b_ub = string(`=ci95[2,38]*100',"%10.2f")
	
	local omega_R_2b_lb = string(`=ci95[1,52]*100',"%10.2f")
	local omega_R_2b_ub = string(`=ci95[2,52]*100',"%10.2f")
	local omega_I_2b_lb = string(`=ci95[1,53]*100',"%10.2f")
	local omega_I_2b_ub = string(`=ci95[2,53]*100',"%10.2f")
	local omega_T_2b_lb = string(`=ci95[1,54]*100',"%10.2f")
	local omega_T_2b_ub = string(`=ci95[2,54]*100',"%10.2f")
	
  
*************************************************
* URBAN SAMPLE
*************************************************
eststo clear
est use "est_spec2_final.ster"
eststo est2

* URBAN, PRE-PERIOD
	* POINT ESTIMATES
	local omega_G_3a = string(`=_b[r31]*100',"%10.2f")
	local omega_R_3a = string(`=_b[r32]*100',"%10.2f")
	local omega_I_3a = string(`=_b[r33]*100',"%10.2f")
	local omega_T_3a = string(`=_b[r34]*100',"%10.2f")

	local omega_G_4a = string(`=_b[r47]*100',"%10.2f")
	local omega_R_4a = string(`=_b[r48]*100',"%10.2f")
	local omega_I_4a = string(`=_b[r49]*100',"%10.2f")
	local omega_T_4a = string(`=_b[r50]*100',"%10.2f")
	
	* 95% CONFIDENCE INTERVALS
	matrix ci95 = e(ci_percentile)
	local omega_R_3a_lb = string(`=ci95[1,32]*100',"%10.2f")
	local omega_R_3a_ub = string(`=ci95[2,32]*100',"%10.2f")
	local omega_I_3a_lb = string(`=ci95[1,33]*100',"%10.2f")
	local omega_I_3a_ub = string(`=ci95[2,33]*100',"%10.2f")
	local omega_T_3a_lb = string(`=ci95[1,34]*100',"%10.2f")
	local omega_T_3a_ub = string(`=ci95[2,34]*100',"%10.2f")
	
	local omega_R_4a_lb = string(`=ci95[1,48]*100',"%10.2f")
	local omega_R_4a_ub = string(`=ci95[2,48]*100',"%10.2f")
	local omega_I_4a_lb = string(`=ci95[1,49]*100',"%10.2f")
	local omega_I_4a_ub = string(`=ci95[2,49]*100',"%10.2f")
	local omega_T_4a_lb = string(`=ci95[1,50]*100',"%10.2f")
	local omega_T_4a_ub = string(`=ci95[2,50]*100',"%10.2f")

* URBAN, POST-PERIOD
	* POINT ESTIMATES
	local omega_G_3b = string(`=_b[r35]*100',"%10.2f")
	local omega_R_3b = string(`=_b[r36]*100',"%10.2f")
	local omega_I_3b = string(`=_b[r37]*100',"%10.2f")
	local omega_T_3b = string(`=_b[r38]*100',"%10.2f")

	local omega_G_4b = string(`=_b[r51]*100',"%10.2f")
	local omega_R_4b = string(`=_b[r52]*100',"%10.2f")
	local omega_I_4b = string(`=_b[r53]*100',"%10.2f")
	local omega_T_4b = string(`=_b[r54]*100',"%10.2f")
	
	* 95% CONFIDENCE INTERVALS
	matrix ci95 = e(ci_percentile)
	local omega_R_3b_lb = string(`=ci95[1,36]*100',"%10.2f")
	local omega_R_3b_ub = string(`=ci95[2,36]*100',"%10.2f")
	local omega_I_3b_lb = string(`=ci95[1,37]*100',"%10.2f")
	local omega_I_3b_ub = string(`=ci95[2,37]*100',"%10.2f")
	local omega_T_3b_lb = string(`=ci95[1,38]*100',"%10.2f")
	local omega_T_3b_ub = string(`=ci95[2,38]*100',"%10.2f")
	
	local omega_R_4b_lb = string(`=ci95[1,52]*100',"%10.2f")
	local omega_R_4b_ub = string(`=ci95[2,52]*100',"%10.2f")
	local omega_I_4b_lb = string(`=ci95[1,53]*100',"%10.2f")
	local omega_I_4b_ub = string(`=ci95[2,53]*100',"%10.2f")
	local omega_T_4b_lb = string(`=ci95[1,54]*100',"%10.2f")
	local omega_T_4b_ub = string(`=ci95[2,54]*100',"%10.2f")	
	
cap file close _all
file open ofile using "Tables\table_welfare_pre.tex", write replace
file write ofile "\begin{tabular}{lccccc}" _n ///
"\toprule" _n ///
"Welfare gain 		& \multicolumn{2}{c}{Rural} & & \multicolumn{2}{c}{Urban} \\" _n ///
"					& $\eta=2$	& $\eta=4$	& & $\eta=2$	& $\eta=4$    \\" _n ///
"\midrule" _n ///
"\hspace{.3cm} Growth effect    & `omega_G_1a'\% 								 & `omega_G_2a'\% 								  & & `omega_G_3a'\%									 &  `omega_G_4a'\% 		\\" _n ///
"\hspace{.3cm} \footnotesize{$\{\textcolor{red}{\gamma^{post}},\sigma^{pre},\psi^{pre}\}$} & & & & & \\" _n ///
"\hspace{.3cm} Risk effect	    & `omega_R_1a'\% 								 & `omega_R_2a'\%								  & & `omega_R_3a'\%									 &  `omega_R_4a'\%		\\" _n ///
"\hspace{.3cm} \footnotesize{$\{\textcolor{red}{\gamma^{post}},\textcolor{red}{\sigma^{post}},\psi^{pre}\}$} & \footnotesize{[`omega_R_1a_lb' `omega_R_1a_ub']} & \footnotesize{[`omega_R_2a_lb' `omega_R_2a_ub']} & & \footnotesize{[`omega_R_3a_lb' `omega_R_3a_ub']} & \footnotesize{[`omega_R_4a_lb' `omega_R_4a_ub']} \\" _n ///
"\hspace{.3cm} Insurance effect & `omega_I_1a'\% 								 & `omega_I_2a'\% 								  & &  `omega_I_3a'\%								 &  `omega_I_4a'\%		\\" _n ///
"\hspace{.3cm} \footnotesize{$\{\textcolor{red}{\gamma^{post}},\textcolor{red}{\sigma^{post}},\textcolor{red}{\psi^{post}}\}$}	& \footnotesize{[`omega_I_1a_lb' `omega_I_1a_ub']} & \footnotesize{[`omega_I_2a_lb' `omega_I_2a_ub']} & & \footnotesize{[`omega_I_3a_lb' `omega_I_3a_ub']} & \footnotesize{[`omega_I_4a_lb' `omega_I_4a_ub']} \\" _n ///
"Total effect					& `omega_T_1a'\% 								 & `omega_T_2a'\% 								  & &  `omega_T_3a'\%								 &  `omega_T_4a'\%		\\" _n ///
"								& \footnotesize{[`omega_T_1a_lb' `omega_T_1a_ub']} & \footnotesize{[`omega_T_2a_lb' `omega_T_2a_ub']} & & \footnotesize{[`omega_T_3a_lb' `omega_T_3a_ub']} & \footnotesize{[`omega_T_4a_lb' `omega_T_4a_ub']} \\" _n ///
"\bottomrule" _n ///
"\end{tabular}"
file close _all


cap file close _all
file open ofile using "Tables\table_welfare_post.tex", write replace
file write ofile "\begin{tabular}{lccccc}" _n ///
"\toprule" _n ///
"Welfare gain 		& \multicolumn{2}{c}{Rural} & & \multicolumn{2}{c}{Urban} \\" _n ///
"					& $\eta=2$	& $\eta=4$	& & $\eta=2$	& $\eta=4$    \\" _n ///
"\midrule" _n ///
"\hspace{.3cm} Growth effect    & `omega_G_1b'\% 								 & `omega_G_2b'\% 								  & & `omega_G_3b'\%									 &  `omega_G_4b'\% 		\\" _n ///
"\hspace{.3cm} \footnotesize{$\{\textcolor{red}{\gamma^{pre}},\sigma^{post},\psi^{post}\}$} & & & & & \\" _n ///
"\hspace{.3cm} Risk effect	    & `omega_R_1b'\% 								 & `omega_R_2b'\%								  & & `omega_R_3b'\%									 &  `omega_R_4b'\%		\\" _n ///
"\hspace{.3cm} \footnotesize{$\{\textcolor{red}{\gamma^{pre}},\textcolor{red}{\sigma^{pre}},\psi^{post}\}$} & \footnotesize{[`omega_R_1b_lb' `omega_R_1b_ub']} & \footnotesize{[`omega_R_2b_lb' `omega_R_2b_ub']} & & \footnotesize{[`omega_R_3b_lb' `omega_R_3b_ub']} & \footnotesize{[`omega_R_4b_lb' `omega_R_4b_ub']} \\" _n ///
"\hspace{.3cm} Insurance effect & `omega_I_1b'\% 								 & `omega_I_2b'\% 								  & &  `omega_I_3b'\%								 &  `omega_I_4b'\%		\\" _n ///
"\hspace{.3cm} \footnotesize{$\{\textcolor{red}{\gamma^{pre}},\textcolor{red}{\sigma^{pre}},\textcolor{red}{\psi^{pre}}\}$}	& \footnotesize{[`omega_I_1b_lb' `omega_I_1b_ub']} & \footnotesize{[`omega_I_2b_lb' `omega_I_2b_ub']} & & \footnotesize{[`omega_I_3b_lb' `omega_I_3b_ub']} & \footnotesize{[`omega_I_4b_lb' `omega_I_4b_ub']} \\" _n ///
"Total effect					& `omega_T_1b'\% 								 & `omega_T_2b'\% 								  & &  `omega_T_3b'\%								 &  `omega_T_4b'\%		\\" _n ///
"								& \footnotesize{[`omega_T_1b_lb' `omega_T_1b_ub']} & \footnotesize{[`omega_T_2b_lb' `omega_T_2b_ub']} & & \footnotesize{[`omega_T_3b_lb' `omega_T_3b_ub']} & \footnotesize{[`omega_T_4b_lb' `omega_T_4b_ub']} \\" _n ///
"\bottomrule" _n ///
"\end{tabular}"
file close _all

cd "$mypath\"
