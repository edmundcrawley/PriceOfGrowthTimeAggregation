***************************************************************************************************************
* THIS IS THE MASTER FILE.
* CHNS 1989 - 2009
* STATA/SE 14.0
***************************************************************************************************************
clear
clear matrix
clear mata
set mem 500m
set maxvar 32760
set more off

*****************************************************************
* INSERT THE DIRECTORY PATH HERE
	
	global mypath "G:\Edmund\time-aggregation\Papers\ThePriceOfGrowth\data\Codes_PoG\"
	
	*global mypath "G:\Research\TimeAggRahul\Papers\ThePriceOfGrowth\data\Codes_PoG\"
	
	
	global mymatlab "C:\rsma\MATLAB\R2019a\bin\matlab.exe" 
******************************************************************

 cd "$mypath"
 

******************************************************
** 			Sample Selection and Trimming			**
******************************************************
* TRIMMING THE LEVEL OF INCOME AND CONSUMPTION
do "CHNS-do-files\cr-CHNStrimmed"

* IMPUTATION OF CONSUMPTION
do "CHIP-do-files\Datacompare-Urban.do"			// Appendix F: Table F-3 to Table F-5
do "CHIP-do-files\CHIPimputation.do"
do "CHIP-do-files\CHNSimputation.do"

* FORMING ESTIMATION SAMPLES
do "CHNS-do-files\cr-CHNSbootpanel"

******************************************************
** 			Estimation and Bootstrapping		    **
******************************************************
* MAIN RESULT FOR THE RURAL SAMPLE (INCLUDING WELFARE CALCULATIONS, TABLE 3, 4, 5)
do "Structural-Model\CHNSbootstrap_welfare_rural.do"

* MAIN RESULT FOR THE URBAN SAMPLE (INCLUDING WELFARE CALCULATIONS, TABLE 3, 4, 5)
do "Structural-Model\CHNSbootstrap_welfare_urban.do"

* RESULTS FOR ALTERNATIVE INCOME AND CONSUMPTION MEASURES (TABLE 3, 4, APPENDIX F.1, APPENDIX G)
do "Structural-Model\CHNSbootstrap.do"

* RESULTS FOR IMPUTED CONSUMPTION MEASURES (APPENDIX F.2, F.3)
do "Structural-Model\CHNSbootstrap_imp.do"

* RESULTS FOR FAST- AND SLOW-GROWING COMMUNITIES AND ALTERNATIVE SAMPLE SPLITS (APPENDIX H, I)
do "Structural-Model\CHNSbootstrap_extra.do"

* RESULTS FOR THE INCOME PROCESS ONLY (APPENDIX D)
do "Structural-Model\CHNSincomeprocess.do"
do "Structural-Model\CHNSbootstrap_incomeprocess_rural.do"
do "Structural-Model\CHNSbootstrap_incomeprocess_urban.do"

***************************************************
**			Tables and Figures
***************************************************
do "CHNS-do-files\Table1.do"									// Table 1
do "CHNS-do-files\Table2.do"									// Table 2 (have to re run)
do "Structural-Model\Maintables.do"							// Table 3 and 4 (have to re run)
*do "Structural-Model\Maintables_welfare_time.do"			// Table 5 (have to re run)
do "CHNS-do-files\Figure1.do"									// Figure 1
do "CHNS-do-files\Figure2.do"									// Figure 2
do "CHNS-do-files\Figure3.do"									// Figure 3
do "CHNS-do-files\Figure4.do"									// Figure 4

do "CHNS-do-files\AppTable-Trimming.do"						// Appendix B: Sample Selection and Trimming, Table B-1
do "CHNS-do-files\AppTable-IncomePartition.do"				// Appendix C: Further Cross-Sectional Facts, Table C-1 to Table C-3
do "CHNS-do-files\AppTable-IncomePartitionDetail.do"		// Appendix C: Further Cross-Sectional Facts, Table C-4 to Table C-11
do "CHNS-do-files\AppTable-Ineqmeasures.do"					// Appendix C: Further Cross-Sectional Facts, Table C-12
do "CHNS-do-files\AppTable-vTrans.do"						// Appendix C: Further Cross-Sectional Facts, Figure C-1
do "CHNS-do-files\AppTable-Gini.do"							// Appendix C: Further Cross-Sectional Facts, Figure C-2
do "CHNS-do-files\AppTable-ChinaUS.do"						// Appendix C: Further Cross-Sectional Facts, Figure C-3
do "Structural-Model\AppTable_incomeprocess.do"				// Appendix D: Estimating Income Process Alone, Table D-1 (have to re run)
do "Structural-Model\AppTable_altc.do"						// Appendix F.1: Alternative Consumption Measures from the CHNS, Table F-1
do "Structural-Model\AppTable_imphousing.do"				// Appendix F.2: Adding Imputed Housing Service from the CHNS, Table F-2
do "Structural-Model\AppTable_imputation.do"				// Appendix F.3: Imputed Consumption Measures, Table F-6
do "Structural-Model\AppTable_inkind.do"					// Appendix G: Removal of In-Kind Public Transfers, Tables G-1 and G-2 
do "Structural-Model\AppTable_community.do"					// Appendix H: Further Evidence from Cross-sections, Table H-1
do "Structural-Model\AppTable_extra.do"						// Appendix I: Hukou Status and State Employment, Table I-1

