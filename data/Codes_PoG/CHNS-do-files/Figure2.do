***************************************************************************************************************
* THIS FILE PRODUCES FIGURE 2.
* CHNS 1989 - 2009
* STATA/SE 14.0
***************************************************************************************************************

clear
set mem 500m
set more off
cap log close

cd "$mypath"

use "CHNS-dta-files---final\CHNStrimmed.dta", clear
		   
*===============================================================	 
* FIGURE 2 IN THE PAPER
*===============================================================
***************************************
*** CHINA STATISTICAL YEARBOOK DATA ***
***************************************
* HOUSEHOLD NET INCOME PER CAPITA FROM CSYB
gen hh_netinc_pc_CSYB = .
replace hh_netinc_pc_CSYB = 1417.3	if interview_year == 1989 & urban == 1 & province == 21
replace hh_netinc_pc_CSYB = 1138	if interview_year == 1989 & urban == 1 & province == 23
replace hh_netinc_pc_CSYB = 1372	if interview_year == 1989 & urban == 1 & province == 32
replace hh_netinc_pc_CSYB = 1349.2	if interview_year == 1989 & urban == 1 & province == 37
replace hh_netinc_pc_CSYB = 1111.46	if interview_year == 1989 & urban == 1 & province == 41
replace hh_netinc_pc_CSYB = 1262.6	if interview_year == 1989 & urban == 1 & province == 42
replace hh_netinc_pc_CSYB = 1492.61 if interview_year == 1989 & urban == 1 & province == 43
replace hh_netinc_pc_CSYB = 1304	if interview_year == 1989 & urban == 1 & province == 45
replace hh_netinc_pc_CSYB = 1275.45 if interview_year == 1989 & urban == 1 & province == 52

replace hh_netinc_pc_CSYB = 1718	if interview_year == 1991 & urban == 1 & province == 21
replace hh_netinc_pc_CSYB = 1389	if interview_year == 1991 & urban == 1 & province == 23
replace hh_netinc_pc_CSYB = 1623	if interview_year == 1991 & urban == 1 & province == 32
replace hh_netinc_pc_CSYB = 1688	if interview_year == 1991 & urban == 1 & province == 37
replace hh_netinc_pc_CSYB = 1384.81	if interview_year == 1991 & urban == 1 & province == 41
replace hh_netinc_pc_CSYB = 1592.9	if interview_year == 1991 & urban == 1 & province == 42
replace hh_netinc_pc_CSYB = 1783.24 if interview_year == 1991 & urban == 1 & province == 43
replace hh_netinc_pc_CSYB = 1614	if interview_year == 1991 & urban == 1 & province == 45
replace hh_netinc_pc_CSYB = 1594	if interview_year == 1991 & urban == 1 & province == 52

replace hh_netinc_pc_CSYB = 2314	if interview_year == 1993 & urban == 1 & province == 21
replace hh_netinc_pc_CSYB = 1960	if interview_year == 1993 & urban == 1 & province == 23
replace hh_netinc_pc_CSYB = 2774	if interview_year == 1993 & urban == 1 & province == 32
replace hh_netinc_pc_CSYB = 2515.1	if interview_year == 1993 & urban == 1 & province == 37
replace hh_netinc_pc_CSYB = 1962.8	if interview_year == 1993 & urban == 1 & province == 41
replace hh_netinc_pc_CSYB = 2439	if interview_year == 1993 & urban == 1 & province == 42
replace hh_netinc_pc_CSYB = 2816.5  if interview_year == 1993 & urban == 1 & province == 43
replace hh_netinc_pc_CSYB = 2895	if interview_year == 1993 & urban == 1 & province == 45
replace hh_netinc_pc_CSYB = 2312.8  if interview_year == 1993 & urban == 1 & province == 52

replace hh_netinc_pc_CSYB = 4518.1	if interview_year == 1997 & urban == 1 & province == 21
replace hh_netinc_pc_CSYB = 4091	if interview_year == 1997 & urban == 1 & province == 23
replace hh_netinc_pc_CSYB = 5765.2	if interview_year == 1997 & urban == 1 & province == 32
replace hh_netinc_pc_CSYB = 5191	if interview_year == 1997 & urban == 1 & province == 37
replace hh_netinc_pc_CSYB = 4093.62	if interview_year == 1997 & urban == 1 & province == 41
replace hh_netinc_pc_CSYB = 4673.2	if interview_year == 1997 & urban == 1 & province == 42
replace hh_netinc_pc_CSYB = 5209.74 if interview_year == 1997 & urban == 1 & province == 43
replace hh_netinc_pc_CSYB = 5110.3	if interview_year == 1997 & urban == 1 & province == 45
replace hh_netinc_pc_CSYB = 4441.91 if interview_year == 1997 & urban == 1 & province == 52

replace hh_netinc_pc_CSYB = 5358	if interview_year == 2000 & urban == 1 & province == 21
replace hh_netinc_pc_CSYB = 4913	if interview_year == 2000 & urban == 1 & province == 23
replace hh_netinc_pc_CSYB = 6800.23	if interview_year == 2000 & urban == 1 & province == 32
replace hh_netinc_pc_CSYB = 6490	if interview_year == 2000 & urban == 1 & province == 37
replace hh_netinc_pc_CSYB = 4766.3	if interview_year == 2000 & urban == 1 & province == 41
replace hh_netinc_pc_CSYB = 5525	if interview_year == 2000 & urban == 1 & province == 42
replace hh_netinc_pc_CSYB = 6219 	if interview_year == 2000 & urban == 1 & province == 43
replace hh_netinc_pc_CSYB = 5834.43	if interview_year == 2000 & urban == 1 & province == 45
replace hh_netinc_pc_CSYB = 5122.21 if interview_year == 2000 & urban == 1 & province == 52

replace hh_netinc_pc_CSYB = 8008	if interview_year == 2004 & urban == 1 & province == 21
replace hh_netinc_pc_CSYB = 7471	if interview_year == 2004 & urban == 1 & province == 23
replace hh_netinc_pc_CSYB = 10482	if interview_year == 2004 & urban == 1 & province == 32
replace hh_netinc_pc_CSYB = 9438	if interview_year == 2004 & urban == 1 & province == 37
replace hh_netinc_pc_CSYB = 7704.9 	if interview_year == 2004 & urban == 1 & province == 41
replace hh_netinc_pc_CSYB = 8023	if interview_year == 2004 & urban == 1 & province == 42
replace hh_netinc_pc_CSYB = 8617.5  if interview_year == 2004 & urban == 1 & province == 43
replace hh_netinc_pc_CSYB = 8690	if interview_year == 2004 & urban == 1 & province == 45
replace hh_netinc_pc_CSYB = 7322.1  if interview_year == 2004 & urban == 1 & province == 52

replace hh_netinc_pc_CSYB = 10370		if interview_year == 2006 & urban == 1 & province == 21
replace hh_netinc_pc_CSYB = 9182.31		if interview_year == 2006 & urban == 1 & province == 23
replace hh_netinc_pc_CSYB = 14084.3		if interview_year == 2006 & urban == 1 & province == 32
replace hh_netinc_pc_CSYB = 12192.24	if interview_year == 2006 & urban == 1 & province == 37
replace hh_netinc_pc_CSYB = 9810.3		if interview_year == 2006 & urban == 1 & province == 41
replace hh_netinc_pc_CSYB = 9803		if interview_year == 2006 & urban == 1 & province == 42
replace hh_netinc_pc_CSYB = 10505	 	if interview_year == 2006 & urban == 1 & province == 43
replace hh_netinc_pc_CSYB = 9899		if interview_year == 2006 & urban == 1 & province == 45
replace hh_netinc_pc_CSYB = 9117	 	if interview_year == 2006 & urban == 1 & province == 52

replace hh_netinc_pc_CSYB = 15761.4		if interview_year == 2009 & urban == 1 & province == 21
replace hh_netinc_pc_CSYB = 12566		if interview_year == 2009 & urban == 1 & province == 23
replace hh_netinc_pc_CSYB = 20552		if interview_year == 2009 & urban == 1 & province == 32
replace hh_netinc_pc_CSYB = 17811.04	if interview_year == 2009 & urban == 1 & province == 37
replace hh_netinc_pc_CSYB = 14372		if interview_year == 2009 & urban == 1 & province == 41
replace hh_netinc_pc_CSYB = 14367.5		if interview_year == 2009 & urban == 1 & province == 42
replace hh_netinc_pc_CSYB = 15084.31	if interview_year == 2009 & urban == 1 & province == 43
replace hh_netinc_pc_CSYB = 15451.5		if interview_year == 2009 & urban == 1 & province == 45
replace hh_netinc_pc_CSYB = 12863 		if interview_year == 2009 & urban == 1 & province == 52

replace hh_netinc_pc_CSYB = 740.22	if interview_year == 1989 & urban == 0 & province == 21
replace hh_netinc_pc_CSYB = 535.19	if interview_year == 1989 & urban == 0 & province == 23
replace hh_netinc_pc_CSYB = 876		if interview_year == 1989 & urban == 0 & province == 32
replace hh_netinc_pc_CSYB = 631		if interview_year == 1989 & urban == 0 & province == 37
replace hh_netinc_pc_CSYB = 457.1	if interview_year == 1989 & urban == 0 & province == 41
replace hh_netinc_pc_CSYB = 571.84	if interview_year == 1989 & urban == 0 & province == 42
replace hh_netinc_pc_CSYB = 558.34	if interview_year == 1989 & urban == 0 & province == 43
replace hh_netinc_pc_CSYB = 483.04	if interview_year == 1989 & urban == 0 & province == 45
replace hh_netinc_pc_CSYB = 430.34  if interview_year == 1989 & urban == 0 & province == 52

replace hh_netinc_pc_CSYB = 897		if interview_year == 1991 & urban == 0 & province == 21
replace hh_netinc_pc_CSYB = 735		if interview_year == 1991 & urban == 0 & province == 23
replace hh_netinc_pc_CSYB = 921		if interview_year == 1991 & urban == 0 & province == 32
replace hh_netinc_pc_CSYB = 764.04	if interview_year == 1991 & urban == 0 & province == 37
replace hh_netinc_pc_CSYB = 539.3	if interview_year == 1991 & urban == 0 & province == 41
replace hh_netinc_pc_CSYB = 626.92	if interview_year == 1991 & urban == 0 & province == 42
replace hh_netinc_pc_CSYB = 688.91	if interview_year == 1991 & urban == 0 & province == 43
replace hh_netinc_pc_CSYB = 658		if interview_year == 1991 & urban == 0 & province == 45
replace hh_netinc_pc_CSYB = 466  	if interview_year == 1991 & urban == 0 & province == 52

replace hh_netinc_pc_CSYB = 1161	if interview_year == 1993 & urban == 0 & province == 21
replace hh_netinc_pc_CSYB = 1028	if interview_year == 1993 & urban == 0 & province == 23
replace hh_netinc_pc_CSYB = 1267	if interview_year == 1993 & urban == 0 & province == 32
replace hh_netinc_pc_CSYB = 953		if interview_year == 1993 & urban == 0 & province == 37
replace hh_netinc_pc_CSYB = 695.9	if interview_year == 1993 & urban == 0 & province == 41
replace hh_netinc_pc_CSYB = 783.2	if interview_year == 1993 & urban == 0 & province == 42
replace hh_netinc_pc_CSYB = 851.87	if interview_year == 1993 & urban == 0 & province == 43
replace hh_netinc_pc_CSYB = 892.07	if interview_year == 1993 & urban == 0 & province == 45
replace hh_netinc_pc_CSYB = 580  	if interview_year == 1993 & urban == 0 & province == 52

replace hh_netinc_pc_CSYB = 2302	if interview_year == 1997 & urban == 0 & province == 21
replace hh_netinc_pc_CSYB = 2308	if interview_year == 1997 & urban == 0 & province == 23
replace hh_netinc_pc_CSYB = 3270	if interview_year == 1997 & urban == 0 & province == 32
replace hh_netinc_pc_CSYB = 2292.12	if interview_year == 1997 & urban == 0 & province == 37
replace hh_netinc_pc_CSYB = 1733.9	if interview_year == 1997 & urban == 0 & province == 41
replace hh_netinc_pc_CSYB = 2102.2	if interview_year == 1997 & urban == 0 & province == 42
replace hh_netinc_pc_CSYB = 2037.06	if interview_year == 1997 & urban == 0 & province == 43
replace hh_netinc_pc_CSYB = 1875.28	if interview_year == 1997 & urban == 0 & province == 45
replace hh_netinc_pc_CSYB = 1299  	if interview_year == 1997 & urban == 0 & province == 52

replace hh_netinc_pc_CSYB = 2356	if interview_year == 2000 & urban == 0 & province == 21
replace hh_netinc_pc_CSYB = 2148.22	if interview_year == 2000 & urban == 0 & province == 23
replace hh_netinc_pc_CSYB = 3595.09	if interview_year == 2000 & urban == 0 & province == 32
replace hh_netinc_pc_CSYB = 2659.2	if interview_year == 2000 & urban == 0 & province == 37
replace hh_netinc_pc_CSYB = 1985.82	if interview_year == 2000 & urban == 0 & province == 41
replace hh_netinc_pc_CSYB = 2268.59	if interview_year == 2000 & urban == 0 & province == 42
replace hh_netinc_pc_CSYB = 2197.16	if interview_year == 2000 & urban == 0 & province == 43
replace hh_netinc_pc_CSYB = 1865	if interview_year == 2000 & urban == 0 & province == 45
replace hh_netinc_pc_CSYB = 1374.16 if interview_year == 2000 & urban == 0 & province == 52

replace hh_netinc_pc_CSYB = 3307.1	if interview_year == 2004 & urban == 0 & province == 21
replace hh_netinc_pc_CSYB = 3005.2	if interview_year == 2004 & urban == 0 & province == 23
replace hh_netinc_pc_CSYB = 4754	if interview_year == 2004 & urban == 0 & province == 32
replace hh_netinc_pc_CSYB = 3507.4	if interview_year == 2004 & urban == 0 & province == 37
replace hh_netinc_pc_CSYB = 2553.2	if interview_year == 2004 & urban == 0 & province == 41
replace hh_netinc_pc_CSYB = 2890.01	if interview_year == 2004 & urban == 0 & province == 42
replace hh_netinc_pc_CSYB = 2837.8	if interview_year == 2004 & urban == 0 & province == 43
replace hh_netinc_pc_CSYB = 2305.2	if interview_year == 2004 & urban == 0 & province == 45
replace hh_netinc_pc_CSYB = 1722    if interview_year == 2004 & urban == 0 & province == 52

replace hh_netinc_pc_CSYB = 4090.4	if interview_year == 2006 & urban == 0 & province == 21
replace hh_netinc_pc_CSYB = 3552.4	if interview_year == 2006 & urban == 0 & province == 23
replace hh_netinc_pc_CSYB = 5813.2	if interview_year == 2006 & urban == 0 & province == 32
replace hh_netinc_pc_CSYB = 4368.3	if interview_year == 2006 & urban == 0 & province == 37
replace hh_netinc_pc_CSYB = 3261.03	if interview_year == 2006 & urban == 0 & province == 41
replace hh_netinc_pc_CSYB = 3419.4	if interview_year == 2006 & urban == 0 & province == 42
replace hh_netinc_pc_CSYB = 3389.81	if interview_year == 2006 & urban == 0 & province == 43
replace hh_netinc_pc_CSYB = 2771	if interview_year == 2006 & urban == 0 & province == 45
replace hh_netinc_pc_CSYB = 1985    if interview_year == 2006 & urban == 0 & province == 52

replace hh_netinc_pc_CSYB = 5958	if interview_year == 2009 & urban == 0 & province == 21
replace hh_netinc_pc_CSYB = 5206.76	if interview_year == 2009 & urban == 0 & province == 23
replace hh_netinc_pc_CSYB = 8003.54	if interview_year == 2009 & urban == 0 & province == 32
replace hh_netinc_pc_CSYB = 6118.77	if interview_year == 2009 & urban == 0 & province == 37
replace hh_netinc_pc_CSYB = 4806.95	if interview_year == 2009 & urban == 0 & province == 41
replace hh_netinc_pc_CSYB = 5035.26	if interview_year == 2009 & urban == 0 & province == 42
replace hh_netinc_pc_CSYB = 4909.04	if interview_year == 2009 & urban == 0 & province == 43
replace hh_netinc_pc_CSYB = 3980.44	if interview_year == 2009 & urban == 0 & province == 45
replace hh_netinc_pc_CSYB = 3005.41 if interview_year == 2009 & urban == 0 & province == 52

* HOUSEHOLD FOOD EXPENDITURE PER CAPITA FROM CSYB
gen exp_food_pc_CSYB = .					
replace exp_food_pc_CSYB = 	692.66	if year ==	1989	&     province == 21	&     urban == 1
replace exp_food_pc_CSYB = 	829.16	if year ==	1991	&     province == 21	&     urban == 1
replace exp_food_pc_CSYB = 	997.33	if year ==	1993	&     province == 21	&     urban == 1
replace exp_food_pc_CSYB = 	1787.94	if year ==	1997	&     province == 21	&     urban == 1
replace exp_food_pc_CSYB = 	1772.14	if year ==	2000	&     province == 21	&     urban == 1
replace exp_food_pc_CSYB = 	2644	if year ==	2004	&     province == 21	&     urban == 1
replace exp_food_pc_CSYB = 	3102.13	if year ==	2006	&     province == 21	&     urban == 1
replace exp_food_pc_CSYB = 	4680.9	if year ==	2009	&     province == 21	&     urban == 1

replace exp_food_pc_CSYB = 	518		if year ==	1989	&     province == 23	&     urban == 1
replace exp_food_pc_CSYB = 	621.6	if year ==	1991	&     province == 23	&     urban == 1
replace exp_food_pc_CSYB = 	816.21	if year ==	1993	&     province == 23	&     urban == 1
replace exp_food_pc_CSYB = 	1474.15	if year ==	1997	&     province == 23	&     urban == 1
replace exp_food_pc_CSYB = 	1469.5	if year ==	2000	&     province == 23	&     urban == 1
replace exp_food_pc_CSYB = 	1972.4	if year ==	2004	&     province == 23	&     urban == 1
replace exp_food_pc_CSYB = 	2215.7	if year ==	2006	&     province == 23	&     urban == 1
replace exp_food_pc_CSYB = 	3397.41	if year ==	2009	&     province == 23	&     urban == 1

replace exp_food_pc_CSYB = 	701		if year ==	1989	&     province == 32	&     urban == 1
replace exp_food_pc_CSYB = 	852		if year ==	1991	&     province == 32	&     urban == 1
replace exp_food_pc_CSYB = 	1141.36	if year ==	1993	&     province == 32	&     urban == 1
replace exp_food_pc_CSYB = 	2161.18	if year ==	1997	&     province == 32	&     urban == 1
replace exp_food_pc_CSYB = 	2190	if year ==	2000	&     province == 32	&     urban == 1
replace exp_food_pc_CSYB = 	2932	if year ==	2004	&     province == 32	&     urban == 1
replace exp_food_pc_CSYB = 	3463	if year ==	2006	&     province == 32	&     urban == 1
replace exp_food_pc_CSYB = 	4773.7	if year ==	2009	&     province == 32	&     urban == 1

replace exp_food_pc_CSYB = 	602.52	if year ==	1989	&     province == 37	&     urban == 1
replace exp_food_pc_CSYB = 	733.08	if year ==	1991	&     province == 37	&     urban == 1
replace exp_food_pc_CSYB = 	895.8	if year ==	1993	&     province == 37	&     urban == 1
replace exp_food_pc_CSYB = 	1654.94	if year ==	1997	&     province == 37	&     urban == 1
replace exp_food_pc_CSYB = 	1744.09	if year ==	2000	&     province == 37	&     urban == 1
replace exp_food_pc_CSYB = 	2310.7	if year ==	2004	&     province == 37	&     urban == 1
replace exp_food_pc_CSYB = 	2711.7	if year ==	2006	&     province == 37	&     urban == 1
replace exp_food_pc_CSYB = 	3954.34	if year ==	2009	&     province == 37	&     urban == 1

replace exp_food_pc_CSYB = 	533.19	if year ==	1989	&     province == 41	&     urban == 1
replace exp_food_pc_CSYB = 	644.26	if year ==	1991	&     province == 41	&     urban == 1
replace exp_food_pc_CSYB = 	798.78	if year ==	1993	&     province == 41	&     urban == 1
replace exp_food_pc_CSYB = 	1506.25	if year ==	1997	&     province == 41	&     urban == 1
replace exp_food_pc_CSYB = 	1386.76	if year ==	2000	&     province == 41	&     urban == 1
replace exp_food_pc_CSYB = 	1855.44	if year ==	2004	&     province == 41	&     urban == 1
replace exp_food_pc_CSYB = 	2215.32	if year ==	2006	&     province == 41	&     urban == 1
replace exp_food_pc_CSYB = 	3272.8	if year ==	2009	&     province == 41	&     urban == 1

replace exp_food_pc_CSYB = 	607		if year ==	1989	&     province == 42	&     urban == 1
replace exp_food_pc_CSYB = 	717.4	if year ==	1991	&     province == 42	&     urban == 1
replace exp_food_pc_CSYB = 	941.54	if year ==	1993	&     province == 42	&     urban == 1
replace exp_food_pc_CSYB = 	1773.6	if year ==	1997	&     province == 42	&     urban == 1
replace exp_food_pc_CSYB = 	1779.4	if year ==	2000	&     province == 42	&     urban == 1
replace exp_food_pc_CSYB = 	2516.2	if year ==	2004	&     province == 42	&     urban == 1
replace exp_food_pc_CSYB = 	2868.4	if year ==	2006	&     province == 42	&     urban == 1
replace exp_food_pc_CSYB = 	4160.51	if year ==	2009	&     province == 42	&     urban == 1

replace exp_food_pc_CSYB = 	678.28	if year ==	1989	&     province == 43	&     urban == 1
replace exp_food_pc_CSYB = 	772.07	if year ==	1991	&     province == 43	&     urban == 1
replace exp_food_pc_CSYB = 	1049.4	if year ==	1993	&     province == 43	&     urban == 1
replace exp_food_pc_CSYB = 	1972.77	if year ==	1997	&     province == 43	&     urban == 1
replace exp_food_pc_CSYB = 	1943.68	if year ==	2000	&     province == 43	&     urban == 1
replace exp_food_pc_CSYB = 	2479.6	if year ==	2004	&     province == 43	&     urban == 1
replace exp_food_pc_CSYB = 	2850.94	if year ==	2006	&     province == 43	&     urban == 1
replace exp_food_pc_CSYB = 	4174.6	if year ==	2009	&     province == 43	&     urban == 1

replace exp_food_pc_CSYB = 	768.11	if year ==	1989	&     province == 45	&     urban == 1
replace exp_food_pc_CSYB = 	875		if year ==	1991	&     province == 45	&     urban == 1
replace exp_food_pc_CSYB = 	1236.2	if year ==	1993	&     province == 45	&     urban == 1
replace exp_food_pc_CSYB = 	2112.76	if year ==	1997	&     province == 45	&     urban == 1
replace exp_food_pc_CSYB = 	1936.1	if year ==	2000	&     province == 45	&     urban == 1
replace exp_food_pc_CSYB = 	2727.1	if year ==	2004	&     province == 45	&     urban == 1
replace exp_food_pc_CSYB = 	2857.4	if year ==	2006	&     province == 45	&     urban == 1
replace exp_food_pc_CSYB = 	4129.6	if year ==	2009	&     province == 45	&     urban == 1

replace exp_food_pc_CSYB = 	640.2	if year ==	1989	&     province == 52	&     urban == 1
replace exp_food_pc_CSYB = 	750.81	if year ==	1991	&     province == 52	&     urban == 1
replace exp_food_pc_CSYB = 	1021.42	if year ==	1993	&     province == 52	&     urban == 1
replace exp_food_pc_CSYB = 	1819.9	if year ==	1997	&     province == 52	&     urban == 1
replace exp_food_pc_CSYB = 	1847.63	if year ==	2000	&     province == 52	&     urban == 1
replace exp_food_pc_CSYB = 	2260.5	if year ==	2004	&     province == 52	&     urban == 1
replace exp_food_pc_CSYB = 	2649.02	if year ==	2006	&     province == 52	&     urban == 1
replace exp_food_pc_CSYB = 	3755.61	if year ==	2009	&     province == 52	&     urban == 1

replace exp_food_pc_CSYB = 	325.2	if year ==	1989	&     province == 21	&     urban == 0
replace exp_food_pc_CSYB = 	397.2	if year ==	1991	&     province == 21	&     urban == 0
replace exp_food_pc_CSYB = 	518.5	if year ==	1993	&     province == 21	&     urban == 0
replace exp_food_pc_CSYB = 	992.07	if year ==	1997	&     province == 21	&     urban == 0
replace exp_food_pc_CSYB = 	815.7	if year ==	2000	&     province == 21	&     urban == 0
replace exp_food_pc_CSYB = 	962		if year ==	2004	&     province == 21	&     urban == 0
replace exp_food_pc_CSYB = 	1162.53	if year ==	2006	&     province == 21	&     urban == 0
replace exp_food_pc_CSYB = 	1563.33	if year ==	2009	&     province == 21	&     urban == 0

replace exp_food_pc_CSYB = 	265.1	if year ==	1989	&     province == 23	&     urban == 0
replace exp_food_pc_CSYB = 	356.8	if year ==	1991	&     province == 23	&     urban == 0
replace exp_food_pc_CSYB = 	458.6	if year ==	1993	&     province == 23	&     urban == 0
replace exp_food_pc_CSYB = 	848.9	if year ==	1997	&     province == 23	&     urban == 0
replace exp_food_pc_CSYB = 	682.8	if year ==	2000	&     province == 23	&     urban == 0
replace exp_food_pc_CSYB = 	750.6	if year ==	2004	&     province == 23	&     urban == 0
replace exp_food_pc_CSYB = 	923.7	if year ==	2006	&     province == 23	&     urban == 0
replace exp_food_pc_CSYB = 	1331.1	if year ==	2009	&     province == 23	&     urban == 0

replace exp_food_pc_CSYB = 	407		if year ==	1989	&     province == 32	&     urban == 0
replace exp_food_pc_CSYB = 	493		if year ==	1991	&     province == 32	&     urban == 0
replace exp_food_pc_CSYB = 	532		if year ==	1993	&     province == 32	&     urban == 0
replace exp_food_pc_CSYB = 	1217	if year ==	1997	&     province == 32	&     urban == 0
replace exp_food_pc_CSYB = 	1018	if year ==	2000	&     province == 32	&     urban == 0
replace exp_food_pc_CSYB = 	1341	if year ==	2004	&     province == 32	&     urban == 0
replace exp_food_pc_CSYB = 	1729	if year ==	2006	&     province == 32	&     urban == 0
replace exp_food_pc_CSYB = 	2275.28	if year ==	2009	&     province == 32	&     urban == 0

replace exp_food_pc_CSYB = 	255.26	if year ==	1989	&     province == 37	&     urban == 0
replace exp_food_pc_CSYB = 	327.56	if year ==	1991	&     province == 37	&     urban == 0
replace exp_food_pc_CSYB = 	415.6	if year ==	1993	&     province == 37	&     urban == 0
replace exp_food_pc_CSYB = 	871.73	if year ==	1997	&     province == 37	&     urban == 0
replace exp_food_pc_CSYB = 	781.88	if year ==	2000	&     province == 37	&     urban == 0
replace exp_food_pc_CSYB = 	1000.13	if year ==	2004	&     province == 37	&     urban == 0
replace exp_food_pc_CSYB = 	1191.32	if year ==	2006	&     province == 37	&     urban == 0
replace exp_food_pc_CSYB = 	1618.66	if year ==	2009	&     province == 37	&     urban == 0

replace exp_food_pc_CSYB = 	199.99	if year ==	1989	&     province == 41	&     urban == 0
replace exp_food_pc_CSYB = 	242.83	if year ==	1991	&     province == 41	&     urban == 0
replace exp_food_pc_CSYB = 	334.52	if year ==	1993	&     province == 41	&     urban == 0
replace exp_food_pc_CSYB = 	693.09	if year ==	1997	&     province == 41	&     urban == 0
replace exp_food_pc_CSYB = 	654.13	if year ==	2000	&     province == 41	&     urban == 0
replace exp_food_pc_CSYB = 	808.27	if year ==	2004	&     province == 41	&     urban == 0
replace exp_food_pc_CSYB = 	911.484	if year ==	2006	&     province == 41	&     urban == 0
replace exp_food_pc_CSYB = 	1220.36	if year ==	2009	&     province == 41	&     urban == 0

replace exp_food_pc_CSYB = 	321.72	if year ==	1989	&     province == 42	&     urban == 0
replace exp_food_pc_CSYB = 	369.18	if year ==	1991	&     province == 42	&     urban == 0
replace exp_food_pc_CSYB = 	446.62	if year ==	1993	&     province == 42	&     urban == 0
replace exp_food_pc_CSYB = 	928.54	if year ==	1997	&     province == 42	&     urban == 0
replace exp_food_pc_CSYB = 	827.25	if year ==	2000	&     province == 42	&     urban == 0
replace exp_food_pc_CSYB = 	1076.35	if year ==	2004	&     province == 42	&     urban == 0
replace exp_food_pc_CSYB = 	1278.8	if year ==	2006	&     province == 42	&     urban == 0
replace exp_food_pc_CSYB = 	1668.35	if year ==	2009	&     province == 42	&     urban == 0

replace exp_food_pc_CSYB = 	290.35	if year ==	1989	&     province == 43	&     urban == 0
replace exp_food_pc_CSYB = 	412.63	if year ==	1991	&     province == 43	&     urban == 0
replace exp_food_pc_CSYB = 	498.95	if year ==	1993	&     province == 43	&     urban == 0
replace exp_food_pc_CSYB = 	1078	if year ==	1997	&     province == 43	&     urban == 0
replace exp_food_pc_CSYB = 	1053.37	if year ==	2000	&     province == 43	&     urban == 0
replace exp_food_pc_CSYB = 	1338.65	if year ==	2004	&     province == 43	&     urban == 0
replace exp_food_pc_CSYB = 	1463.33	if year ==	2006	&     province == 43	&     urban == 0
replace exp_food_pc_CSYB = 	1967.54	if year ==	2009	&     province == 43	&     urban == 0

replace exp_food_pc_CSYB = 	244.2	if year ==	1989	&     province == 45	&     urban == 0
replace exp_food_pc_CSYB = 	360.09	if year ==	1991	&     province == 45	&     urban == 0
replace exp_food_pc_CSYB = 	453.52	if year ==	1993	&     province == 45	&     urban == 0
replace exp_food_pc_CSYB = 	799.89	if year ==	1997	&     province == 45	&     urban == 0
replace exp_food_pc_CSYB = 	824.97	if year ==	2000	&     province == 45	&     urban == 0
replace exp_food_pc_CSYB = 	1047.58	if year ==	2004	&     province == 45	&     urban == 0
replace exp_food_pc_CSYB = 	1196.07	if year ==	2006	&     province == 45	&     urban == 0
replace exp_food_pc_CSYB = 	1572.82	if year ==	2009	&     province == 45	&     urban == 0

replace exp_food_pc_CSYB = 	282.92	if year ==	1989	&     province == 52	&     urban == 0
replace exp_food_pc_CSYB = 	286.6	if year ==	1991	&     province == 52	&     urban == 0
replace exp_food_pc_CSYB = 	390.45	if year ==	1993	&     province == 52	&     urban == 0
replace exp_food_pc_CSYB = 	742.16	if year ==	1997	&     province == 52	&     urban == 0
replace exp_food_pc_CSYB = 	687.32	if year ==	2000	&     province == 52	&     urban == 0
replace exp_food_pc_CSYB = 	754.39	if year ==	2004	&     province == 52	&     urban == 0
replace exp_food_pc_CSYB = 	838.42	if year ==	2006	&     province == 52	&     urban == 0
replace exp_food_pc_CSYB = 	1093.94	if year ==	2009	&     province == 52	&     urban == 0

*******************************************************************
* Transform the nominal values to the real values
quietly do "CHNS-do-files\CHNS-Real"
foreach var of varlist hh_netinc_pc_CSYB exp_food_pc_CSYB   {
		  quietly gen     `var'_real = `var'/deflator_all*100
 	      quietly replace `var'   = `var'_real
		  drop    `var'_real
		  quietly replace `var'   = `var'/6.83		// in USD
 }
 drop deflator_all
*********************************************************************

* AVERAGE FOOD EXPENDITURE BY URBAN STATUS AND YEAR
bys interview urban: egen m_hh_disinc_pc_CSYB= mean(hh_netinc_pc_CSYB)
bys interview urban: egen m_hh_food_pc_CSYB  = mean(exp_food_pc_CSYB)

*****************************************
*** CHINA HEALTH AND NUTRITION SURVEY ***
*****************************************
* COMPUTING THE MEAN INCOME AND CONSUMPTION PER CAPITA FROM CHNS
	* trim top 1% of the hh size by urban status and by year
	foreach year in 1989 1991 1993 1997 2000 2004 2006 2009  {
		forvalues urb = 0/1   {
			qui xtile p_hh_size_`urb'_`year' = hh_size if interview == `year' & urban == `urb', nq(100)
			replace hh_size =. if p_hh_size_`urb'_`year' == 100
		}
	}
	drop p_hh_size_*

	* HOUSEHOLD DISPOSABLE INCOME PER CAPITA FROM CHNS
	gen  minus_2 = -sub_coupon
	gen  minus_3 = -foodgift
	egen income 	= rsum(income1 minus_2 minus_3)  if income1~=.  // minus_2 = -sub_coupon and minus_3 = -foodgift to be consistent with the income def in CSYB
	gen  income_pc 	= income/hh_size 				 if income1~=. & hh_size ~=.
	bys interview_year urban: egen m_hh_disinc_pc_CHNS = mean(income_pc)

	* HOUSEHOLD FOOD EXPENDITURE PER CAPITA FROM CHNS
	cap drop food_exp
	egen food_exp = rsum(cdiet minus_2 minus_3)		if cdiet~=.
	gen hh_food_pc_CHNS = food_exp/hh_size
	bys interview urban: egen m_hh_food_pc_CHNS = mean(hh_food_pc_CHNS)

keep interview_year urban m_hh_disinc_pc_CSYB m_hh_disinc_pc_CHNS m_hh_food_pc_CSYB m_hh_food_pc_CHNS
duplicates drop	
	
*****************************
*** PENN WORLD TABLE DATA ***
*****************************
 * GDP PER CAPITA
 gen 	 m_income_pwt80_1=.
 replace m_income_pwt80_1=1369.603 if interview_year==1989
 replace m_income_pwt80_1=1509.074 if interview_year==1991
 replace m_income_pwt80_1=1918.451 if interview_year==1993
 replace m_income_pwt80_1=2778.176 if interview_year==1997
 replace m_income_pwt80_1=3409.736 if interview_year==2000
 replace m_income_pwt80_1=4760.820 if interview_year==2004
 replace m_income_pwt80_1=5907.746 if interview_year==2006
 replace m_income_pwt80_1=7950.976 if interview_year==2009	

 *********************
 *** MAKING GRAPHS ***
 *********************
table interview_year urban, c(mean m_hh_food_pc_CHNS   mean m_hh_food_pc_CSYB)
table interview_year urban, c(mean m_hh_disinc_pc_CHNS mean m_hh_disinc_pc_CSYB)
	
foreach var in hh_disinc_pc_CSYB hh_disinc_pc_CHNS hh_food_pc_CSYB hh_food_pc_CHNS income_pwt80_1 {   // normalize the value in 1989 to 1
	bys urban (interview_year): gen `var'0 = m_`var'/m_`var'[1]
	}
table interview_year urban, c(mean hh_disinc_pc_CSYB0 mean hh_disinc_pc_CHNS0)
table interview_year urban, c(mean hh_food_pc_CSYB0 mean hh_food_pc_CHNS0)

* HH Disposable income per capita: CHNS vs CSYB
twoway  (scatter income_pwt80_10 	interview_year, sort(interview_year) connect(l) lcolor(black) lwidth(thick) lpattern(shortdash) msymbol(none) mcolor(dkgreen)) ///
		(scatter hh_disinc_pc_CSYB0 interview_year if urban == 0, sort(interview_year) connect(l) lcolor(cyan) lwidth(thick) lpattern(dash) msymbol(O) mcolor(cyan)) ///
		(scatter hh_disinc_pc_CHNS0 interview_year if urban == 0, sort(interview_year) mcolor(blue) msymbol(D))  ///
	   , ylabel(1(1)6, labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1mono) xlabel(1989(2)2009) xtitle("",size(medium)) title("Rural HH Disposable Income per Capita: CHNS vs CSYB",size(medium)) legend(nobox symxsize(3) region(lstyle(none)) size(medium) pos(12) row(1) region(fcolor(none)) order(1 "PWT" 2 "CSYB" 3 "CHNS"))
	graph save   "CHNS-Figures/CHNS-CSYB-hh-dispinc-mean-rural.gph", replace
   *graph export "CHNS Figures/CHNS-CSYB-hh-dispinc-mean-rural.eps", replace
twoway  (scatter income_pwt80_10 	interview_year, sort(interview_year) connect(l) lcolor(black) lwidth(thick) lpattern(shortdash) msymbol(none) mcolor(none)) ///
		(scatter hh_disinc_pc_CSYB0 interview_year if urban == 1, sort(interview_year) connect(l) lcolor(cyan) lwidth(thick) lpattern(dash) msymbol(O) mcolor(cyan)) ///
		(scatter hh_disinc_pc_CHNS0 interview_year if urban == 1, sort(interview_year) mcolor(blue) msymbol(D))   ///
	   , ylabel(1(1)6, labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1mono) xlabel(1989(2)2009) xtitle("",size(medium)) title("Urban HH Disposable Income per Capita: CHNS vs CSYB",size(medium)) legend(nobox symxsize(3) region(lstyle(none)) size(medium) pos(12) row(1) region(fcolor(none)) order(1 "PWT" 2 "CSYB" 3 "CHNS"))
	graph save   "CHNS-Figures/CHNS-CSYB-hh-dispinc-mean-urban.gph", replace
   *graph export "CHNS Figures/CHNS-CSYB-hh-dispinc-mean-urban.eps", replace
	graph combine "CHNS-Figures/CHNS-CSYB-hh-dispinc-mean-rural.gph" "CHNS-Figures/CHNS-CSYB-hh-dispinc-mean-urban.gph", col(2) scheme(s1mono)
graph save   "CHNS-Figures/CHNS-CSYB-hh-dispinc-mean.gph", replace

* HH Food consumption per capita: CHNS vs CSYB
twoway (scatter hh_food_pc_CSYB0 interview_year if urban == 0, sort(interview_year) connect(l) lcolor(cyan) lwidth(thick) lpattern(dash) msymbol(O) mcolor(cyan))		///
	   (scatter hh_food_pc_CHNS0 interview_year if urban == 0, sort(interview_year) mcolor(blue) msymbol(D))	///
	   , ylabel(1(.5)3, labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1mono) xlabel(1989(2)2009) xtitle("",size(medium)) title("Rural HH Food Expenditure per Capita: CHNS vs CSYB",size(medium)) legend(nobox symxsize(3) region(lstyle(none)) size(medium) pos(12) row(1) region(fcolor(none)) order(1 "CSYB" 2 "CHNS"))
	graph save   "CHNS-Figures/CHNS-CSYB-hh-food-mean-rural.gph", replace
   *graph export "CHNS Figures/CHNS-CSYB-hh-food-mean-rural.eps", replace
twoway (scatter hh_food_pc_CSYB0 interview_year if urban == 1, sort(interview_year) connect(l) lcolor(cyan) lwidth(thick) lpattern(dash) msymbol(O) mcolor(cyan))		///
	   (scatter hh_food_pc_CHNS0 interview_year if urban == 1, sort(interview_year) mcolor(blue) msymbol(D))	///
	   , ylabel(1(.5)3, labsize(medium)) xlabel(,labsize(medium) angle(vertical)) scheme(s1mono) xlabel(1989(2)2009) xtitle("",size(medium)) title("Urban HH Food Expenditure per Capita: CHNS vs CSYB",size(medium)) legend(nobox symxsize(3) region(lstyle(none)) size(medium) pos(12) row(1) region(fcolor(none)) order(1 "CSYB" 2 "CHNS"))
	graph save   "CHNS-Figures/CHNS-CSYB-hh-food-mean-urban.gph", replace
   *graph export "CHNS Figures/CHNS-CSYB-hh-food-mean-urban.eps", replace
graph combine "CHNS-Figures/CHNS-CSYB-hh-food-mean-rural.gph" "CHNS-Figures/CHNS-CSYB-hh-food-mean-urban.gph", col(2) scheme(s1mono)
graph save "CHNS-Figures/CHNS-CSYB-hh-food-mean.gph", replace

graph combine "CHNS-Figures/CHNS-CSYB-hh-dispinc-mean.gph" "CHNS-Figures/CHNS-CSYB-hh-food-mean.gph", col(1) scheme(s1mono)
graph save "CHNS-Figures/CHNS-CSYB-dispinc-food-mean.gph", replace
graph export "CHNS-Figures/Figure2.png", width(1400) height(1000) replace
graph export "CHNS-Figures/Figure2.eps", replace


erase "CHNS-Figures/CHNS-CSYB-hh-dispinc-mean-rural.gph"
erase "CHNS-Figures/CHNS-CSYB-hh-dispinc-mean-urban.gph"
erase "CHNS-Figures/CHNS-CSYB-hh-dispinc-mean.gph"
erase "CHNS-Figures/CHNS-CSYB-hh-food-mean-rural.gph"
erase "CHNS-Figures/CHNS-CSYB-hh-food-mean-urban.gph"
erase "CHNS-Figures/CHNS-CSYB-hh-food-mean.gph"
erase "CHNS-Figures/CHNS-CSYB-dispinc-food-mean.gph"
