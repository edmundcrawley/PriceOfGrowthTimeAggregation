***************************************************************************************************************
* THIS FILE PRODUCES THE TABLES IN APPENDIX G.
* CHNS 1989 - 2009
* STATA/SE 14.0
* CREATED BY YU ZHENG
***************************************************************************************************************
clear
clear matrix
clear mata
set mem 500m
set maxvar 32760
set more off

 cd "$mypath\Structural-Model"
 
est clear

est use "est_spec9_final.ster"
eststo  est1
est use "est_spec10_final.ster"
eststo  est2


* TABLE OF ESTIMATES OF INCOME SHOCKS AND INSURANCE PARAMETERS
esttab est1 est2 using "Tables\table_inkind.tex", replace ///
	booktabs nonotes nomtitles obslast label collabels(none) ///
	b(3) se(3) nostar ///
    keep(r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15 r16) ///
	varlabels(r1  "\hspace{.3cm} 1992-3" 	r2  "\hspace{.3cm} 1994-7" ///
			  r3  "\hspace{.3cm} 1998-2000" r4  "\hspace{.3cm} 2001-4" ///
			  r5  "\hspace{.3cm} 2005-6" 	///
			  r6  "\hspace{.3cm} 1991" 		r7  "\hspace{.3cm} 1993"   ///
			  r8  "\hspace{.3cm} 1997" 		r9  "\hspace{.3cm} 2000"   ///
			  r10 "\hspace{.3cm} 2004" 		r11 "\hspace{.3cm} 2006" ///
			  r13  "\hspace{.3cm} $\psi_{\zeta,pre97}$" 		r14  "\hspace{.3cm} $\psi_{\zeta,post97}$" ///
			  r15  "\hspace{.3cm} $\psi_{\varepsilon,pre97}$" 	r16  "\hspace{.3cm} $\psi_{\varepsilon,post97}$" ///
			  r12  "\hspace{.3cm}") ///
	order(r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r13 r14 r15 r16 r12) ///
	refcat(r1 "\textbf{\emph{Permanent shocks $\sigma^2_{\zeta_t}$}}" ///
		   r6 "\textbf{\emph{Transitory shocks $\sigma^2_{\varepsilon_t}$}}" ///
		   r13 "\textbf{\emph{Transmission parameters}}" ///
		   r12 "\textbf{\emph{Taste shock, $\sigma^2_{\xi}$}}", nolabel) ///
    extracols(0) prehead(\begin{tabular}{l*{@span}{c}} \toprule) ///
    mgroups("Rural" "Urban", pattern(1 1) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule{@span}))

	
* COMPUTE THE CORRELATION TABLE
 use "$mypath\CHNS-dta-files---final\CHNStrimmed.dta", clear
 
	keep if urban == 1  // KEEP THE URBAN SAMPLE
	**********************************************
	* CONSTRUCT ADULT-EQUIVALENT MEASURES
	**********************************************
	* Compute equivalence scales
		gen equiv_KP       =  (numi_geq_15 +  .7*numi_lt_15)^(.7) /* These are the NAS scales used by Krueger and Perri ReStud who cite . If you read that reference you will find they refer to page 59 in "Measuring Poverty, A New Approach" published by the National Academy of Sciencies (NAS) scales. "																							It is Also used by Heathcote, Storesletten, and Violante JPE (Consumption Insurance and Labor Supply) */	
		gen numi_15_60 = numi_geq_15-numi_gt_60
		gen equiv_ad   = numi_geq_15
		gen equiv_ad2  = numi_15_60

	* Compute adult-equivalent income
		gen c_KP = consumption1 /equiv_KP
		gen tpub_ad2 	= transfR_pub /equiv_ad2
		gen y_ad2 = income0 / equiv_ad2
		
	* Compute the logs
		gen logc = ln(c_KP)
		gen logt = ln(tpub_ad2)
		gen logy = ln(y_ad2)
	* Compute the residuals
		gen Rlogc =.
		gen Rlogy =.
		local  xwave =  1
		while `xwave' < 9{
			qui regress   logy i.sex i.age i.educ i.province i.minority	      if wave==`xwave'
			qui predict  Rlogywave`xwave' 				if wave==`xwave', resid					   						
			replace  Rlogy=  Rlogywave`xwave'       if wave==`xwave'
			drop     Rlogywave`xwave'
			
			qui regress   logc i.sex i.age i.educ i.province i.minority	      if wave==`xwave'
			qui predict  Rlogcwave`xwave' 				if wave==`xwave', resid					   						
			replace  Rlogc=  Rlogcwave`xwave'       if wave==`xwave'
			drop     Rlogcwave`xwave'
			
			local xwave = `xwave'+ 1
		}
	* MAKE TABLE
	cap file close _all
	file open ofile using "Tables\table_corr_inkind.tex", write replace	
	file write ofile "\begin{tabular}{l c c}" _n ///
		"\toprule" _n ///
		"Wave & Corr. log public transf.   & Corr. log public transf. \\" _n ///
		" 	  & and log residual earnings  & and log residual consumption    \\" _n ///
		"\\" _n
		foreach t in 1989 1991 1993 1997 2000 2004 2006 2009	{
			corr logt Rlogy if year == `t'
			local corr_ty = string(r(rho),"%10.4f")
			
			corr logt Rlogc if year == `t'
			local corr_tc = string(r(rho),"%10.4f")

			local time = strofreal(`t')
			file write ofile " `time' & `corr_ty' & `corr_tc'  \\" _n 
 		}
	file write ofile "\bottomrule" _n ///
	"\end{tabular}"
	file close _all
			
cd "$mypath\"
