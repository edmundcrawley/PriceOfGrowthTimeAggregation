***************************************************************************************************************
* THIS FILE PRODUCES THE TABLES IN APPENDIX D.
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

est use "est_inc_Rural.ster"
eststo  est1
est use "est_inc_Urban.ster"
eststo  est2

* TABLE OF ESTIMATES OF INCOME SHOCKS
esttab est1 est2 using "Tables\table_incomeprocess.tex", replace ///
	booktabs nonotes nomtitles obslast label collabels(none) ///
	b(3) se(3) nostar ///
    keep(r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12) ///
	varlabels(r1  "\hspace{.3cm} 1992-3" 	r2  "\hspace{.3cm} 1994-7" ///
			  r3  "\hspace{.3cm} 1998-2000" r4  "\hspace{.3cm} 2001-4" ///
			  r5  "\hspace{.3cm} 2005-6" 	///
			  r6  "\hspace{.3cm} 1991" 		r7  "\hspace{.3cm} 1993"   ///
			  r8  "\hspace{.3cm} 1997" 		r9  "\hspace{.3cm} 2000"   ///
			  r10 "\hspace{.3cm} 2004" 		r11 "\hspace{.3cm} 2006"   ///
			  r12 " ")  ///
	order(r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12) ///
	refcat(r1 "\textbf{\emph{Permanent shocks $\sigma^2_{\zeta_t}$}}" ///
		   r6 "\textbf{\emph{Transitory shocks $\sigma^2_{\varepsilon_t}$}}"  ///
		   r12 "\textbf{\emph{Persistence parameter $\rho$}}", nolabel) ///
    extracols(0) prehead(\begin{tabular}{l*{@span}{c}} \toprule) ///
    mgroups("Rural" "Urban", pattern(1 1) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule{@span}))
	
cd "$mypath\"
