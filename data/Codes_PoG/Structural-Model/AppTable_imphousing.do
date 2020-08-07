***************************************************************************************************************
* THIS FILE PRODUCES THE TABLES IN APPENDIX F.2.
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

  cd "$mypath\Structural-Model\"
  
est clear

est use "est_imp4_final.ster"
eststo  est1
est use "est_spec2_final.ster"
eststo  est2


* TABLE OF ESTIMATES OF INCOME SHOCKS AND INSURANCE PARAMETERS
esttab est2 est1 using "Tables\table_imphousing.tex", replace ///
	booktabs nonotes nomtitles obslast label collabels(none) ///
	b(3) se(3) nostar ///
    keep(r12 r13 r14 r15 r16) ///
	varlabels(r13  "\hspace{.3cm} $\psi_{\zeta,pre97}$" 		r14  "\hspace{.3cm} $\psi_{\zeta,post97}$" ///
			  r15  "\hspace{.3cm} $\psi_{\varepsilon,pre97}$" 	r16  "\hspace{.3cm} $\psi_{\varepsilon,post97}$" ///
			  r12  "\hspace{.3cm}") ///
	order(r13 r14 r15 r16 r12) ///
	refcat(r13 "\textbf{\emph{Transmission parameters}}" ///
		   r12 "\textbf{\emph{Taste shock, $\sigma^2_{\xi}$}}", nolabel) ///
    extracols(0) prehead(\begin{tabular}{l*{@span}{c}} \toprule) ///
    mgroups("Benchmark" "Benchmark + Imputed Housing Service", pattern(1 1) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule{@span}))

cd "$mypath\"
