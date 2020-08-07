***************************************************************************************************************
* THIS FILE PRODUCES THE TABLES IN APPENDIX F.3.
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

est use "est_imp0_final.ster"
eststo  est0
est use "est_imp2_final.ster"
eststo  est2
est use "est_imp3_final.ster"
eststo  est3

* TABLE OF ESTIMATES OF INCOME SHOCKS
esttab est0 est2 est3 using "Tables\table_imp1.tex", replace ///
	booktabs nonotes nomtitles obslast label collabels(none) ///
	b(3) se(3) nostar ///
    keep(r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11) ///
	varlabels(r1  "\hspace{.3cm} 1992-3" 	r2  "\hspace{.3cm} 1994-7" ///
			  r3  "\hspace{.3cm} 1998-2000" r4  "\hspace{.3cm} 2001-4" ///
			  r5  "\hspace{.3cm} 2005-6" 	///
			  r6  "\hspace{.3cm} 1991" 		r7  "\hspace{.3cm} 1993"   ///
			  r8  "\hspace{.3cm} 1997" 		r9  "\hspace{.3cm} 2000"   ///
			  r10 "\hspace{.3cm} 2004" 		r11 "\hspace{.3cm} 2006") ///
	order(r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11) ///
	refcat(r1 "\textbf{\emph{Permanent shocks $\sigma^2_{\zeta_t}$}}" ///
		   r6 "\textbf{\emph{Transitory shocks $\sigma^2_{\varepsilon_t}$}}", nolabel) ///
    extracols(0) prehead(\begin{tabular}{l*{@span}{c}} \toprule) ///
    mgroups("CHNS" "Nondurable" "Total", pattern(1 1 1) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule{@span}))

* TABLE OF ESTIMATES OF INSURANCE PARAMETERS
esttab est0 est2 est3 using "Tables\table_imp2.tex", replace ///
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
    mgroups("CHNS" "Nondurable" "Total", pattern(1 1 1) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule{@span}))

cd "$mypath\"
