***************************************************************************************************************
* THIS FILE PRODUCES TABLE 3 AND 4.
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
ssc install estout

   cd "$mypath\Structural-Model\"
  
est clear

est use "est_spec1_final.ster"
eststo  est1
est use "est_spec2_final.ster"
eststo  est2
est use "est_spec3_final.ster"
eststo  est3
est use "est_spec4_final.ster"
eststo  est4
est use "est_spec5_final.ster"
eststo  est5
est use "est_spec6_final.ster"
eststo  est6
est use "est_spec7_final.ster"
eststo  est7
est use "est_spec8_final.ster"
eststo  est8


est use "est_spec1_final_TA.ster"
eststo  est1_TA
est use "est_spec2_final_TA.ster"
eststo  est2_TA
est use "est_spec3_final_TA.ster"
eststo  est3_TA
est use "est_spec4_final_TA.ster"
eststo  est4_TA
est use "est_spec5_final_TA.ster"
eststo  est5_TA
est use "est_spec6_final_TA.ster"
eststo  est6_TA
est use "est_spec7_final_TA.ster"
eststo  est7_TA
est use "est_spec8_final_TA.ster"
eststo  est8_TA

cd "$mypath"
* TABLE OF ESTIMATES OF INCOME SHOCKS
esttab est1 est1_TA est2 est2_TA est3 est3_TA est4 est4_TA using "Tables\table3A.tex", replace ///
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
    mgroups("Disposable Income Rural" "Disposable Income Urban" "Earnings + Public Transf. Rural" "Earnings + Public Transf. Rural Urban", pattern(1 0 1 0 1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule{@span}))

* TABLE OF ESTIMATES OF INSURANCE PARAMETERS
esttab est1 est1_TA est2 est2_TA est3 est3_TA est4 est4_TA using "Tables\table4a.tex", replace ///
	booktabs nonotes nomtitles obslast label collabels(none) ///
	b(3) se(3) nostar ///
    keep(r12 r13 r14 r15 r16 r17 r18 r19 r20 r21 r22) ///
	varlabels(r13  "\hspace{.3cm} $\psi_{\zeta,pre97}$" 		r14  "\hspace{.3cm} $\psi_{\zeta,post97}$" ///
			  r15  "\hspace{.3cm} $\psi_{\varepsilon,pre97}$" 	r16  "\hspace{.3cm} $\psi_{\varepsilon,post97}$" ///
			  r12  "\hspace{.3cm}" 	///
			  r17  "\hspace{.3cm} 1991" 	r18  "\hspace{.3cm} 1993"   ///
			  r19  "\hspace{.3cm} 1997" 	r20  "\hspace{.3cm} 2000"   ///
			  r21  "\hspace{.3cm} 2004" 	r22  "\hspace{.3cm} 2006") ///
	order(r13 r14 r15 r16 r12 r17 r18 r19 r20 r21 r22) ///
	refcat(r13 "\textbf{\emph{Transmission parameters}}" ///
		   r12 "\textbf{\emph{Taste shock, $\sigma^2_{\xi}$}}" ///
		   r17 "\textbf{\emph{Measurement error in consumption, $\sigma^2_{u^c}$}}", nolabel) ///
    extracols(0) prehead(\begin{tabular}{l*{@span}{c}} \toprule) ///
    mgroups("Disposable Income Rural" "Disposable Income Urban" "Earnings + Public Transf. Rural" "Earnings + Public Transf. Rural Urban", pattern(1 0 1 0 1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule{@span}))

cd "$mypath\"







**************
*Second Four Columns
**************

cd "$mypath"
* TABLE OF ESTIMATES OF INCOME SHOCKS
esttab est5 est5_TA est6 est6_TA est7 est7_TA est8 est8_TA using "Tables\table3b.tex", replace ///
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
    mgroups("Earnings + Private Transf. Rural" "Earnings + Private Transf. Rural Urban" "Earnings Only Rural" "Earnings Only Urban", pattern(1 0 1 0 1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule{@span}))

* TABLE OF ESTIMATES OF INSURANCE PARAMETERS
esttab est5 est5_TA est6 est6_TA est7 est7_TA est8 est8_TA using "Tables\table4b.tex", replace ///
	booktabs nonotes nomtitles obslast label collabels(none) ///
	b(3) se(3) nostar ///
    keep(r12 r13 r14 r15 r16 r17 r18 r19 r20 r21 r22) ///
	varlabels(r13  "\hspace{.3cm} $\psi_{\zeta,pre97}$" 		r14  "\hspace{.3cm} $\psi_{\zeta,post97}$" ///
			  r15  "\hspace{.3cm} $\psi_{\varepsilon,pre97}$" 	r16  "\hspace{.3cm} $\psi_{\varepsilon,post97}$" ///
			  r12  "\hspace{.3cm}" 	///
			  r17  "\hspace{.3cm} 1991" 	r18  "\hspace{.3cm} 1993"   ///
			  r19  "\hspace{.3cm} 1997" 	r20  "\hspace{.3cm} 2000"   ///
			  r21  "\hspace{.3cm} 2004" 	r22  "\hspace{.3cm} 2006") ///
	order(r13 r14 r15 r16 r12 r17 r18 r19 r20 r21 r22) ///
	refcat(r13 "\textbf{\emph{Transmission parameters}}" ///
		   r12 "\textbf{\emph{Taste shock, $\sigma^2_{\xi}$}}" ///
		   r17 "\textbf{\emph{Measurement error in consumption, $\sigma^2_{u^c}$}}", nolabel) ///
    extracols(0) prehead(\begin{tabular}{l*{@span}{c}} \toprule) ///
    mgroups("Earnings + Private Transf. Rural" "Earnings + Private Transf. Rural Urban" "Earnings Only Rural" "Earnings Only Urban", pattern(1 0 1 0 1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule{@span}))

cd "$mypath\"
