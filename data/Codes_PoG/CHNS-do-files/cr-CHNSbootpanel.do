***************************************************************************************************************
* THIS FILE CONSTRUCTS A PANEL OF LOG INCOME AND CONSUMPTION AS INPUTS TO THE BOOTSTRAPPING ROUTINE.
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

 cd "$mypath"
  
  capture log close
  log using "CHNS-log\CHNSbootpanel", replace
  
		use "CHNS-dta-files---final\CHNSimp.dta", clear
		rename year interview_year
		drop dataset year_cp lq
		gen  dataimp = 1
		
		* GENERATE IMPUTED CONSUMPTION
		gen consumption3 = exp(lx1_imp)
		gen consumption4 = exp(lx2_imp)
		gen consumption5 = exp(lx3_imp)
		
		label var consumption3 "imputed nondurable consumption (narrow definition)"
		label var consumption4 "imputed nondurable consumption (loose definition)"
		label var consumption5 "imputed consumption"
		drop lx*_imp
		merge 1:1 case_id interview_year using "CHNS-dta-files---final\CHNStrimmed.dta"
		assert _merge==3 | _merge==2
		keep if _merge==3 | _merge==2
		drop _merge
		
		
		**********************************************
		* CONSTRUCT ADULT-EQUIVALENT MEASURES
		**********************************************
		* Compute equivalence scales
			gen equiv_KP       =  (numi_geq_15 +  .7*numi_lt_15)^(.7) /* These are the NAS scales used by Krueger and Perri ReStud who cite . If you read that reference you will find they refer to page 59 in "Measuring Poverty, A New Approach" published by the National Academy of Sciencies (NAS) scales. "																							It is Also used by Heathcote, Storesletten, and Violante JPE (Consumption Insurance and Labor Supply) */	
			gen numi_15_60 = numi_geq_15-numi_gt_60
			gen equiv_ad   = numi_geq_15
			gen equiv_ad2  = numi_15_60

		* Compute adult-equivalent income
			gen consumption0_KP = consumption0 /equiv_KP
			gen consumption1_KP = consumption1 /equiv_KP
			gen consumption2_KP = consumption2 /equiv_KP
			gen consumption3_KP = consumption3 /equiv_KP
			gen consumption4_KP = consumption4 /equiv_KP
			gen consumption5_KP = consumption5 /equiv_KP
			gen consumption6_KP = consumption6 /equiv_KP
			gen consumption7_KP = consumption7 /equiv_KP
			gen consumption8_KP = consumption8 /equiv_KP
			
			gen income0_ad2 = income0 /equiv_ad2
			gen income1_ad2 = income1 /equiv_ad2
			gen income2_ad2 = income2 /equiv_ad2
			gen income3_ad2 = income3 /equiv_ad2
			gen income4_ad2 = income4 /equiv_ad2
			
		keep	income0 			income1     		income2     		income3				income4 			///
				income0_ad2 		income1_ad2 		income2_ad2 		income3_ad2 		income4_ad2 		///
				consumption0		consumption1 		consumption2 		consumption3 		consumption4 		consumption5     	///
				consumption0_KP		consumption1_KP 	consumption2_KP 	consumption3_KP 	consumption4_KP 	consumption5_KP     ///
				consumption6		consumption7		consumption8		///
				consumption6_KP		consumption7_KP		consumption8_KP		///
				hh_size 			equiv_KP 			equiv_ad2 			dep_ratio_weak 		numi_lt_15 			numi_geq_15 		///
				age 				case_id 			relation2head 		cohort 				wave 				interview_year 		///
				reside 				educ 				province 			commid 				birthplace 			sex 				///
				ethnicity 			hukou 				cadre_hh 			minority 			marital_status 		pri_occu 			///
				pri_posi 			pri_type 			stable 				house_value 		house_area
	 
		foreach var in 	income0 			income1     		income2     		income3				income4				///
						income0_ad2 		income1_ad2 		income2_ad2 		income3_ad2			income4_ad2			///
						consumption0		consumption1     	consumption2		consumption6		consumption7		consumption8		///
						consumption0_KP		consumption1_KP  	consumption2_KP		consumption6_KP		consumption7_KP		consumption8_KP   	{
				gen `var'_Urban = `var' if reside==0
				gen `var'_Rural = `var' if reside==1
				drop `var'
		}
		foreach var in  consumption3		consumption4		consumption5			///
						consumption3_KP		consumption4_KP		consumption5_KP		 	{
				rename `var' `var'_Urban 	// IMPUTATION IS DONE ONLY FOR URBAN HOUSEHOLDS (FOR THE MEASURE THAT INCLUDES IMPUTED HOUSING RENTS, ONLY URBAN IS RELIABLE)
		}		
		sort wave
		
		foreach var in 	income0_Rural 				income1_Rural     		income2_Rural     			income3_Rural				income4_Rural				///
						income0_ad2_Rural 			income1_ad2_Rural 		income2_ad2_Rural 			income3_ad2_Rural			income4_ad2_Rural			///
						consumption0_Rural			consumption1_Rural     	consumption2_Rural			consumption6_Rural			consumption7_Rural			///
						consumption0_KP_Rural		consumption1_KP_Rural  	consumption2_KP_Rural		consumption6_KP_Rural		consumption7_KP_Rural		///
						income0_Urban 				income1_Urban     		income2_Urban     			income3_Urban				income4_Urban				///
						income0_ad2_Urban 			income1_ad2_Urban 		income2_ad2_Urban 			income3_ad2_Urban			income4_ad2_Urban			///
						consumption0_Urban			consumption1_Urban     	consumption2_Urban			consumption3_Urban			consumption4_Urban			///
						consumption0_KP_Urban		consumption1_KP_Urban  	consumption2_KP_Urban		consumption3_KP_Urban		consumption4_KP_Urban		///
						consumption5_Urban			consumption6_Urban		consumption7_Urban			consumption8_Urban			///
						consumption5_KP_Urban		consumption6_KP_Urban	consumption7_KP_Urban		consumption8_KP_Urban		{
				
				gen ln`var'=ln(`var')
				
		}
		
		
		***************************************************************
		* SAVE DTA FILES THAT WILL BE CALLED BY THE BOOTSTRAP ROUTINE
		***************************************************************
		* TO BE SAVED IN THE "STRUCTURAL MODEL\BASELINE DATA\"
		
			// RURAL: BASELINE: DISPOSABLE INCOME + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS
				preserve
				keep wave interview_year case_id lnincome1_ad2_Rural lnconsumption1_KP_Rural sex educ province minority cohort
				drop if missing(lnincome1_ad2_Rural) & missing(lnconsumption1_KP_Rural)
				
				rename lnincome1_ad2_Rural 		logy
				rename lnconsumption1_KP_Rural  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec1.dta", replace
				restore
				
			// URBAN: BASELINE: DISPOSABLE INCOME + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS
				preserve
				keep wave interview_year case_id lnincome1_ad2_Urban lnconsumption1_KP_Urban sex educ province minority cohort
				drop if missing(lnincome1_ad2_Urban) & missing(lnconsumption1_KP_Urban)
				
				rename lnincome1_ad2_Urban 		logy
				rename lnconsumption1_KP_Urban  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec2.dta", replace
				restore
				
			// RURAL: EARNINGS AND PUCLIC TRANSFERS + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS
				preserve
				keep wave interview_year case_id lnincome3_ad2_Rural lnconsumption1_KP_Rural sex educ province minority cohort
				drop if missing(lnincome3_ad2_Rural) & missing(lnconsumption1_KP_Rural)
				
				rename lnincome3_ad2_Rural 		logy
				rename lnconsumption1_KP_Rural  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec3.dta", replace
				restore
				
			// URBAN: EARNINGS AND PUCLIC TRANSFERS + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS
				preserve
				keep wave interview_year case_id lnincome3_ad2_Urban lnconsumption1_KP_Urban sex educ province minority cohort
				drop if missing(lnincome3_ad2_Urban) & missing(lnconsumption1_KP_Urban)
				
				rename lnincome3_ad2_Urban 		logy
				rename lnconsumption1_KP_Urban  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec4.dta", replace
				restore
				
			// RURAL: EARNINGS AND PRIVATE TRANSFERS + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS
				preserve
				keep wave interview_year case_id lnincome2_ad2_Rural lnconsumption1_KP_Rural sex educ province minority cohort
				drop if missing(lnincome2_ad2_Rural) & missing(lnconsumption1_KP_Rural)
				
				rename lnincome2_ad2_Rural 		logy
				rename lnconsumption1_KP_Rural  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec5.dta", replace
				restore
				
			// URBAN: EARNINGS AND PRIVATE TRANSFERS + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS
				preserve
				keep wave interview_year case_id lnincome2_ad2_Urban lnconsumption1_KP_Urban sex educ province minority cohort
				drop if missing(lnincome2_ad2_Urban) & missing(lnconsumption1_KP_Urban)
				
				rename lnincome2_ad2_Urban 		logy
				rename lnconsumption1_KP_Urban  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec6.dta", replace
				restore
				
			// RURAL: EARNINGS + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS
				preserve
				keep wave interview_year case_id lnincome0_ad2_Rural lnconsumption1_KP_Rural sex educ province minority cohort
				drop if missing(lnincome0_ad2_Rural) & missing(lnconsumption1_KP_Rural)
				
				rename lnincome0_ad2_Rural 		logy
				rename lnconsumption1_KP_Rural  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec7.dta", replace
				restore
				
			// URBAN: EARNINGS + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS
				preserve
				keep wave interview_year case_id lnincome0_ad2_Urban lnconsumption1_KP_Urban sex educ province minority cohort
				drop if missing(lnincome0_ad2_Urban) & missing(lnconsumption1_KP_Urban)
				
				rename lnincome0_ad2_Urban 		logy
				rename lnconsumption1_KP_Urban  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec8.dta", replace
				restore
				
			// RURAL: EARNINGS AND CASH PUBLIC TRANSFERS + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS MINUS IN-KIND SUBSIDIES
				preserve
				keep wave interview_year case_id lnincome4_ad2_Rural lnconsumption2_KP_Rural sex educ province minority cohort
				drop if missing(lnincome4_ad2_Rural) & missing(lnconsumption2_KP_Rural)
				
				rename lnincome4_ad2_Rural 		logy
				rename lnconsumption2_KP_Rural  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec9.dta", replace
				restore
				
			// URBAN: EARNINGS AND CASH PUBLIC TRANSFERS + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS MINUS IN-KIND SUBSIDIES
				preserve
				keep wave interview_year case_id lnincome4_ad2_Urban lnconsumption2_KP_Urban sex educ province minority cohort
				drop if missing(lnincome4_ad2_Urban) & missing(lnconsumption2_KP_Urban)
				
				rename lnincome4_ad2_Urban 		logy
				rename lnconsumption2_KP_Urban  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec10.dta", replace
				restore
				
			// RURAL: DISPOSABLE INCOME + FOOD CONSUMPTION IN CHNS
				preserve
				keep wave interview_year case_id lnincome1_ad2_Rural lnconsumption0_KP_Rural sex educ province minority cohort
				drop if missing(lnincome1_ad2_Rural) & missing(lnconsumption0_KP_Rural)
				
				rename lnincome1_ad2_Rural 		logy
				rename lnconsumption0_KP_Rural  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec11.dta", replace
				restore
				
			// URBAN: DISPOSABLE INCOME + FOOD CONSUMPTION IN CHNS
				preserve
				keep wave interview_year case_id lnincome1_ad2_Urban lnconsumption0_KP_Urban sex educ province minority cohort
				drop if missing(lnincome1_ad2_Urban) & missing(lnconsumption0_KP_Urban)
				
				rename lnincome1_ad2_Urban 		logy
				rename lnconsumption0_KP_Urban  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec12.dta", replace
				restore
			
			// RURAL: DISPOSABLE INCOME + FOOD AND UTILITY CONSUMPTION IN CHNS
				preserve
				keep wave interview_year case_id lnincome1_ad2_Rural lnconsumption6_KP_Rural sex educ province minority cohort
				drop if missing(lnincome1_ad2_Rural) & missing(lnconsumption6_KP_Rural)
				
				rename lnincome1_ad2_Rural 		logy
				rename lnconsumption6_KP_Rural  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec13.dta", replace
				restore
			
			// URBAN: DISPOSABLE INCOME + FOOD AND UTILITY CONSUMPTION IN CHNS 
				preserve
				keep wave interview_year case_id lnincome1_ad2_Urban lnconsumption6_KP_Urban sex educ province minority cohort
				drop if missing(lnincome1_ad2_Urban) & missing(lnconsumption6_KP_Urban)
				
				rename lnincome1_ad2_Urban 		logy
				rename lnconsumption6_KP_Urban  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec14.dta", replace
				restore
			
			// RURAL: DISPOSABLE INCOME + FOOD, UTILITY AND HEALTH CONSUMPTION IN CHNS
				preserve
				keep wave interview_year case_id lnincome1_ad2_Rural lnconsumption7_KP_Rural sex educ province minority cohort
				drop if missing(lnincome1_ad2_Rural) & missing(lnconsumption7_KP_Rural)
				
				rename lnincome1_ad2_Rural 		logy
				rename lnconsumption7_KP_Rural  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec15.dta", replace
				restore
			
			// URBAN: DISPOSABLE INCOME + FOOD, UTILITY AND HEALTH CONSUMPTION IN CHNS
				preserve
				keep wave interview_year case_id lnincome1_ad2_Urban lnconsumption7_KP_Urban sex educ province minority cohort
				drop if missing(lnincome1_ad2_Urban) & missing(lnconsumption7_KP_Urban)
				
				rename lnincome1_ad2_Urban 		logy
				rename lnconsumption7_KP_Urban  logc
				
				saveold  "Structural-Model\Baseline_Data\dydc_spec16.dta", replace
				restore
		
		
		* TO BE SAVED IN THE "STRUCTURAL MODEL\EXTRA DATA\"
			// RURAL HUKOU: DISPOSBLE INCOME + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS MINUS IN-KIND SUBSIDIES
				gen 	lnincome1_ad2 		= lnincome1_ad2_Rural
				replace lnincome1_ad2 		= lnincome1_ad2_Urban 		if lnincome1_ad2==.
				gen		lnconsumption1_KP 	= lnconsumption1_KP_Rural
				replace lnconsumption1_KP	= lnconsumption1_KP_Urban	if lnconsumption1_KP==.
				
				bys case_id (interview): egen max_hukou = max(hukou)
				bys case_id (interview): egen min_hukou = min(hukou)
				gen hukou_constant = (max_hukou==min_hukou)
				
				preserve
				keep if hukou == 1 & hukou_constant == 1
				keep wave interview_year case_id lnincome1_ad2 lnconsumption1_KP sex educ province minority cohort
				drop if missing(lnincome1_ad2) & missing(lnconsumption1_KP)
					
				rename lnincome1_ad2 		logy
				rename lnconsumption1_KP  	logc
					
				saveold  "Structural-Model\Extra_Data\dydc_spec1.dta", replace
				restore
				
			// URBAN HUKOU: DISPOSBLE INCOME + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS MINUS IN-KIND SUBSIDIES
				preserve
				keep if hukou == 0 & hukou_constant == 1
				keep wave interview_year case_id lnincome1_ad2 lnconsumption1_KP sex educ province minority cohort
				drop if missing(lnincome1_ad2) & missing(lnconsumption1_KP)
					
				rename lnincome1_ad2 		logy
				rename lnconsumption1_KP  	logc
					
				saveold  "Structural-Model\Extra_Data\dydc_spec2.dta", replace
				restore
				
				drop hukou_constant max_hukou min_hukou
			
			// NON-FARM SOE WORKERS IN PRE-1997 PERIOD: DISPOSBLE INCOME + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS MINUS IN-KIND SUBSIDIES
				gen 	state = 1 if (pri_type == 1 | pri_type == 3)
				replace state = 0 if (pri_type == 2 | pri_type == 5 | pri_type == 6 | pri_type == 7)
				bys case_id (interview_year): egen minstate = min(state)
				bys case_id (interview_year): egen maxstate = max(state)
				gen allstate = (minstate==1)
				gen nvrstate = (maxstate==0)
				gen swtstate = (minstate<maxstate & minstate==0 & maxstate==1)
				bys case_id (interview_year): egen minyear = min(interview_year)
				gen tagobs = (minyear<=1997 & minyear~=.)
				
				preserve
				keep if allstate == 1 & tagobs == 1
				keep wave interview_year case_id lnincome1_ad2 lnconsumption1_KP sex educ province minority cohort
				drop if missing(lnincome1_ad2) & missing(lnconsumption1_KP)
					
				rename lnincome1_ad2 		logy
				rename lnconsumption1_KP  	logc
					
				saveold  "Structural-Model\Extra_Data\dydc_spec3.dta", replace
				restore
				
				preserve
				keep if swtstate == 1 & tagobs == 1
				keep wave interview_year case_id lnincome1_ad2 lnconsumption1_KP sex educ province minority cohort
				drop if missing(lnincome1_ad2) & missing(lnconsumption1_KP)
					
				rename lnincome1_ad2 		logy
				rename lnconsumption1_KP  	logc
					
				saveold  "Structural-Model\Extra_Data\dydc_spec4.dta", replace
				restore
				
				preserve
				keep if nvrstate == 1 & tagobs == 1
				keep wave interview_year case_id lnincome1_ad2 lnconsumption1_KP sex educ province minority cohort
				drop if missing(lnincome1_ad2) & missing(lnconsumption1_KP)
					
				rename lnincome1_ad2 		logy
				rename lnconsumption1_KP  	logc
					
				saveold  "Structural-Model\Extra_Data\dydc_spec5.dta", replace
				restore
				
				drop allstate nvrstate swtstate state minstate maxstate tagobs minyear
			
			
			// FAST-GROWING RURAL COMMUNITIES: DISPOSABLE INCOME + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS
				preserve
				keep if reside == 1
				keep interview_year case_id commid income1_ad2_Rural
				bys interview_year commid (case_id): egen m_com_income = mean(income1_ad2_Rural)
				keep interview_year commid m_com_income
				duplicates drop
				bys commid (interview_year): gen d_year = interview_year - interview_year[_n-1]
				bys commid (interview_year): gen ratio_income = m_com_income/m_com_income[_n-1]
				bys commid (interview_year): gen annualgrowth = ratio_income^(1/d_year)-1
				bys commid (interview_year): egen avg_growth = mean(annualgrowth)
				keep commid avg_growth
				duplicates drop
				sum avg_growth, d
				gen 	fastgrowth = 1 if avg_growth > r(p50) & avg_growth~=.
				replace fastgrowth = 0 if avg_growth <= r(p50) & avg_growth~=.
				keep commid fastgrowth
				sort commid
				saveold "CHNS-dta-files---final\CHNSfastgrowth_Rural.dta", replace
				restore
				
				preserve
				keep if reside == 1
				merge m:1 commid using "CHNS-dta-files---final\CHNSfastgrowth_Rural.dta", update
				assert _merge == 3
				drop _merge
				keep if fastgrowth == 1
				keep wave interview_year case_id lnincome1_ad2_Rural lnconsumption1_KP_Rural sex educ province minority cohort
				drop if missing(lnincome1_ad2_Rural) & missing(lnconsumption1_KP_Rural)
				
				rename lnincome1_ad2_Rural 		logy
				rename lnconsumption1_KP_Rural  logc
				
				saveold  "Structural-Model\Extra_Data\dydc_spec6.dta", replace
				restore	
			
			// SLOW-GROWING RURAL COMMUNITIES: DISPOSABLE INCOME + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS
				preserve
				keep if reside == 1
				merge m:1 commid using "CHNS-dta-files---final\CHNSfastgrowth_Rural.dta", update
				assert _merge == 3
				drop _merge
				keep if fastgrowth == 0
				keep wave interview_year case_id lnincome1_ad2_Rural lnconsumption1_KP_Rural sex educ province minority cohort
				drop if missing(lnincome1_ad2_Rural) & missing(lnconsumption1_KP_Rural)
				
				rename lnincome1_ad2_Rural 		logy
				rename lnconsumption1_KP_Rural  logc
				
				saveold  "Structural-Model\Extra_Data\dydc_spec7.dta", replace
				restore
				erase "CHNS-dta-files---final\CHNSfastgrowth_Rural.dta"
			
		
		* TO BE SAVED IN THE "STRUCTURAL MODEL\IMPUTED DATA\"
			// URBAN: DISPOSABLE INCOME + ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS, FOR OBS WHOSE IMPUTED CONSUMPTION IS NONMISSING
				preserve
				keep if lnincome1_ad2_Urban~=. | lnconsumption3_KP_Urban~=.
				keep wave interview_year case_id lnincome1_ad2_Urban lnconsumption1_KP_Urban sex educ province minority cohort
				drop if missing(lnincome1_ad2_Urban) & missing(lnconsumption1_KP_Urban)
				
				rename lnincome1_ad2_Urban 		 logy
				rename lnconsumption1_KP_Urban  logc

				tsset case_id interview_year
				
				saveold  "Structural-Model\Imputed_Data\dydc_imp0.dta", replace
				restore
				
			// URBAN: DISPOSABLE INCOME + IMPUTED NONDURABLE CONSUMPTION (NARROW DEFINITION)
				preserve
				keep wave interview_year case_id lnincome1_ad2_Urban lnconsumption3_KP_Urban sex educ province minority cohort
				drop if missing(lnincome1_ad2_Urban) & missing(lnconsumption3_KP_Urban)
				
				rename lnincome1_ad2_Urban 		 logy
				rename lnconsumption3_KP_Urban  logc
				
				tsset case_id interview_year
				
				saveold  "Structural-Model\Imputed_Data\dydc_imp1.dta", replace
				restore
				
			// URBAN: DISPOSABLE INCOME + IMPUTED NONDURABLE CONSUMPTION (WIDE DEFINITION)
				preserve
				keep wave interview_year case_id lnincome1_ad2_Urban lnconsumption4_KP_Urban sex educ province minority cohort
				drop if missing(lnincome1_ad2_Urban) & missing(lnconsumption4_KP_Urban)
				
				rename lnincome1_ad2_Urban 		logy
				rename lnconsumption4_KP_Urban  logc

				tsset case_id interview_year
				
				saveold  "Structural-Model\Imputed_Data\dydc_imp2.dta", replace
				restore
				
			// URBAN: DISPOSABLE INCOME + IMPUTED CONSUMPTION
				preserve
				keep wave interview_year case_id lnincome1_ad2_Urban lnconsumption5_KP_Urban sex educ province minority cohort
				drop if missing(lnincome1_ad2_Urban) & missing(lnconsumption5_KP_Urban)
				
				rename lnincome1_ad2_Urban 		logy
				rename lnconsumption5_KP_Urban  logc

				tsset case_id interview_year
				
				saveold  "Structural-Model\Imputed_Data\dydc_imp3.dta", replace
				restore
				
			// URBAN: DISPOSABLE INCOME +  ALL CONSUMPTION CONSISTENTLY SURVEYED IN CHNS AND IMPUTED HOUSING SERVICE
				preserve
				keep wave interview_year case_id lnincome1_ad2_Urban lnconsumption8_KP_Urban sex educ province minority cohort
				drop if missing(lnincome1_ad2_Urban) & missing(lnconsumption8_KP_Urban)
				
				rename lnincome1_ad2_Urban 		logy
				rename lnconsumption8_KP_Urban  logc

				tsset case_id interview_year
				
				saveold  "Structural-Model\Imputed_Data\dydc_imp4.dta", replace
				restore
		
log close
