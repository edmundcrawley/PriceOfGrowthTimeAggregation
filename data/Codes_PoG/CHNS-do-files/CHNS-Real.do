/* The deflator is from the income measure constructed by CHNS.	The cost in urban areas in Liaoning urban in 2009 is set equal
to 100 and all other costs are calculated relative to it. */											
											
/*Rural Deflators*/											
gen	deflator_all	=.									
replace	deflator_all	=	36.97	if	interview_year==	1989	&	province==	21	&	urban == 0
replace	deflator_all	=	34.15	if	interview_year==	1989	&	province==	32	&	urban == 0
replace	deflator_all	=	36.45	if	interview_year==	1989	&	province==	37	&	urban == 0
replace	deflator_all	=	34.24	if	interview_year==	1989	&	province==	41	&	urban == 0
replace	deflator_all	=	33.22	if	interview_year==	1989	&	province==	42	&	urban == 0
replace	deflator_all	=	34.49	if	interview_year==	1989	&	province==	43	&	urban == 0
replace	deflator_all	=	36.91	if	interview_year==	1989	&	province==	45	&	urban == 0
replace	deflator_all	=	32.72	if	interview_year==	1989	&	province==	52	&	urban == 0
												
replace	deflator_all	=	39.83	if	interview_year==	1991	&	province==	21	&	urban == 0
replace	deflator_all	=	35.43	if	interview_year==	1991	&	province==	32	&	urban == 0
replace	deflator_all	=	38.51	if	interview_year==	1991	&	province==	37	&	urban == 0
replace	deflator_all	=	34.07	if	interview_year==	1991	&	province==	41	&	urban == 0
replace	deflator_all	=	35.38	if	interview_year==	1991	&	province==	42	&	urban == 0
replace	deflator_all	=	35.42	if	interview_year==	1991	&	province==	43	&	urban == 0
replace	deflator_all	=	38.74	if	interview_year==	1991	&	province==	45	&	urban == 0
replace	deflator_all	=	34.65	if	interview_year==	1991	&	province==	52	&	urban == 0
												
replace	deflator_all	=	45.37	if	interview_year==	1993	&	province==	21	&	urban == 0
replace	deflator_all	=	42.89	if	interview_year==	1993	&	province==	32	&	urban == 0
replace	deflator_all	=	43.96	if	interview_year==	1993	&	province==	37	&	urban == 0
replace	deflator_all	=	38.3	if	interview_year==	1993	&	province==	41	&	urban == 0
replace	deflator_all	=	43.56	if	interview_year==	1993	&	province==	42	&	urban == 0
replace	deflator_all	=	43.95	if	interview_year==	1993	&	province==	43	&	urban == 0
replace	deflator_all	=	47.93	if	interview_year==	1993	&	province==	45	&	urban == 0
replace	deflator_all	=	42.91	if	interview_year==	1993	&	province==	52	&	urban == 0
												
replace	deflator_all	=	75.51	if	interview_year==	1997	&	province==	23	&	urban == 0
replace	deflator_all	=	65.74	if	interview_year==	1997	&	province==	32	&	urban == 0
replace	deflator_all	=	70.4	if	interview_year==	1997	&	province==	37	&	urban == 0
replace	deflator_all	=	63.38	if	interview_year==	1997	&	province==	41	&	urban == 0
replace	deflator_all	=	72.46	if	interview_year==	1997	&	province==	42	&	urban == 0
replace	deflator_all	=	73.16	if	interview_year==	1997	&	province==	43	&	urban == 0
replace	deflator_all	=	77.86	if	interview_year==	1997	&	province==	45	&	urban == 0
replace	deflator_all	=	73.73	if	interview_year==	1997	&	province==	52	&	urban == 0
												
replace	deflator_all	=	67.11	if	interview_year==	2000	&	province==	21	&	urban == 0
replace	deflator_all	=	70.47	if	interview_year==	2000	&	province==	23	&	urban == 0
replace	deflator_all	=	64.36	if	interview_year==	2000	&	province==	32	&	urban == 0
replace	deflator_all	=	68.24	if	interview_year==	2000	&	province==	37	&	urban == 0
replace	deflator_all	=	59.28	if	interview_year==	2000	&	province==	41	&	urban == 0
replace	deflator_all	=	69.25	if	interview_year==	2000	&	province==	42	&	urban == 0
replace	deflator_all	=	75.3	if	interview_year==	2000	&	province==	43	&	urban == 0
replace	deflator_all	=	73.64	if	interview_year==	2000	&	province==	45	&	urban == 0
replace	deflator_all	=	73.36	if	interview_year==	2000	&	province==	52	&	urban == 0
												
replace	deflator_all	=	73.16	if	interview_year==	2004	&	province==	21	&	urban == 0
replace	deflator_all	=	74.95	if	interview_year==	2004	&	province==	23	&	urban == 0
replace	deflator_all	=	69.29	if	interview_year==	2004	&	province==	32	&	urban == 0
replace	deflator_all	=	74.11	if	interview_year==	2004	&	province==	37	&	urban == 0
replace	deflator_all	=	64.18	if	interview_year==	2004	&	province==	41	&	urban == 0
replace	deflator_all	=	74.66	if	interview_year==	2004	&	province==	42	&	urban == 0
replace	deflator_all	=	81.78	if	interview_year==	2004	&	province==	43	&	urban == 0
replace	deflator_all	=	77.39	if	interview_year==	2004	&	province==	45	&	urban == 0
replace	deflator_all	=	79.1	if	interview_year==	2004	&	province==	52	&	urban == 0
												
replace	deflator_all	=	77.3	if	interview_year==	2006	&	province==	21	&	urban == 0
replace	deflator_all	=	78.51	if	interview_year==	2006	&	province==	23	&	urban == 0
replace	deflator_all	=	72.16	if	interview_year==	2006	&	province==	32	&	urban == 0
replace	deflator_all	=	76.65	if	interview_year==	2006	&	province==	37	&	urban == 0
replace	deflator_all	=	66.51	if	interview_year==	2006	&	province==	41	&	urban == 0
replace	deflator_all	=	78.59	if	interview_year==	2006	&	province==	42	&	urban == 0
replace	deflator_all	=	85.08	if	interview_year==	2006	&	province==	43	&	urban == 0
replace	deflator_all	=	79.34	if	interview_year==	2006	&	province==	45	&	urban == 0
replace	deflator_all	=	82.38	if	interview_year==	2006	&	province==	52	&	urban == 0
												
replace	deflator_all	=	87.58	if	interview_year==	2009	&	province==	21	&	urban == 0
replace	deflator_all	=	89.81	if	interview_year==	2009	&	province==	23	&	urban == 0
replace	deflator_all	=	79.51	if	interview_year==	2009	&	province==	32	&	urban == 0
replace	deflator_all	=	85.74	if	interview_year==	2009	&	province==	37	&	urban == 0
replace	deflator_all	=	76		if	interview_year==	2009	&	province==	41	&	urban == 0
replace	deflator_all	=	88.71	if	interview_year==	2009	&	province==	42	&	urban == 0
replace	deflator_all	=	97.2	if	interview_year==	2009	&	province==	43	&	urban == 0
replace	deflator_all	=	89.71	if	interview_year==	2009	&	province==	45	&	urban == 0
replace	deflator_all	=	95.35	if	interview_year==	2009	&	province==	52	&	urban == 0
												
/* Urban Deflators*/												
replace	deflator_all	=	40.3	if	interview_year==	1989	&	province==	21	&	urban == 1
replace	deflator_all	=	40.64	if	interview_year==	1989	&	province==	32	&	urban == 1
replace	deflator_all	=	40.82	if	interview_year==	1989	&	province==	37	&	urban == 1
replace	deflator_all	=	38.35	if	interview_year==	1989	&	province==	41	&	urban == 1
replace	deflator_all	=	37.87	if	interview_year==	1989	&	province==	42	&	urban == 1
replace	deflator_all	=	38.98	if	interview_year==	1989	&	province==	43	&	urban == 1
replace	deflator_all	=	43.92	if	interview_year==	1989	&	province==	45	&	urban == 1
replace	deflator_all	=	39.59	if	interview_year==	1989	&	province==	52	&	urban == 1
												
replace	deflator_all	=	43.04	if	interview_year==	1991	&	province==	21	&	urban == 1
replace	deflator_all	=	44.95	if	interview_year==	1991	&	province==	32	&	urban == 1
replace	deflator_all	=	44		if	interview_year==	1991	&	province==	37	&	urban == 1
replace	deflator_all	=	40.19	if	interview_year==	1991	&	province==	41	&	urban == 1
replace	deflator_all	=	40.91	if	interview_year==	1991	&	province==	42	&	urban == 1
replace	deflator_all	=	40.37	if	interview_year==	1991	&	province==	43	&	urban == 1
replace	deflator_all	=	43.85	if	interview_year==	1991	&	province==	45	&	urban == 1
replace	deflator_all	=	41.1	if	interview_year==	1991	&	province==	52	&	urban == 1
												
replace	deflator_all	=	53.99	if	interview_year==	1993	&	province==	21	&	urban == 1
replace	deflator_all	=	57.2	if	interview_year==	1993	&	province==	32	&	urban == 1
replace	deflator_all	=	54.51	if	interview_year==	1993	&	province==	37	&	urban == 1
replace	deflator_all	=	47.78	if	interview_year==	1993	&	province==	41	&	urban == 1
replace	deflator_all	=	52.69	if	interview_year==	1993	&	province==	42	&	urban == 1
replace	deflator_all	=	52.79	if	interview_year==	1993	&	province==	43	&	urban == 1
replace	deflator_all	=	57.41	if	interview_year==	1993	&	province==	45	&	urban == 1
replace	deflator_all	=	51.5	if	interview_year==	1993	&	province==	52	&	urban == 1
												
replace	deflator_all	=	90.38	if	interview_year==	1997	&	province==	23	&	urban == 1
replace	deflator_all	=	93.47	if	interview_year==	1997	&	province==	32	&	urban == 1
replace	deflator_all	=	91.05	if	interview_year==	1997	&	province==	37	&	urban == 1
replace	deflator_all	=	79.8	if	interview_year==	1997	&	province==	41	&	urban == 1
replace	deflator_all	=	90.86	if	interview_year==	1997	&	province==	42	&	urban == 1
replace	deflator_all	=	85.92	if	interview_year==	1997	&	province==	43	&	urban == 1
replace	deflator_all	=	90.26	if	interview_year==	1997	&	province==	45	&	urban == 1
replace	deflator_all	=	85.86	if	interview_year==	1997	&	province==	52	&	urban == 1
												
replace	deflator_all	=	87.45	if	interview_year==	2000	&	province==	21	&	urban == 1
replace	deflator_all	=	87.31	if	interview_year==	2000	&	province==	23	&	urban == 1
replace	deflator_all	=	92.16	if	interview_year==	2000	&	province==	32	&	urban == 1
replace	deflator_all	=	91.87	if	interview_year==	2000	&	province==	37	&	urban == 1
replace	deflator_all	=	74.78	if	interview_year==	2000	&	province==	41	&	urban == 1
replace	deflator_all	=	86.46	if	interview_year==	2000	&	province==	42	&	urban == 1
replace	deflator_all	=	87.12	if	interview_year==	2000	&	province==	43	&	urban == 1
replace	deflator_all	=	85.19	if	interview_year==	2000	&	province==	45	&	urban == 1
replace	deflator_all	=	84.66	if	interview_year==	2000	&	province==	52	&	urban == 1
												
replace	deflator_all	=	89.88	if	interview_year==	2004	&	province==	21	&	urban == 1
replace	deflator_all	=	91.17	if	interview_year==	2004	&	province==	23	&	urban == 1
replace	deflator_all	=	94.98	if	interview_year==	2004	&	province==	32	&	urban == 1
replace	deflator_all	=	94.9	if	interview_year==	2004	&	province==	37	&	urban == 1
replace	deflator_all	=	80.56	if	interview_year==	2004	&	province==	41	&	urban == 1
replace	deflator_all	=	92.33	if	interview_year==	2004	&	province==	42	&	urban == 1
replace	deflator_all	=	90.59	if	interview_year==	2004	&	province==	43	&	urban == 1
replace	deflator_all	=	89.64	if	interview_year==	2004	&	province==	45	&	urban == 1
replace	deflator_all	=	89.54	if	interview_year==	2004	&	province==	52	&	urban == 1
												
replace	deflator_all	=	91.6	if	interview_year==	2006	&	province==	21	&	urban == 1
replace	deflator_all	=	93.56	if	interview_year==	2006	&	province==	23	&	urban == 1
replace	deflator_all	=	98.43	if	interview_year==	2006	&	province==	32	&	urban == 1
replace	deflator_all	=	96.9	if	interview_year==	2006	&	province==	37	&	urban == 1
replace	deflator_all	=	83.24	if	interview_year==	2006	&	province==	41	&	urban == 1
replace	deflator_all	=	96.15	if	interview_year==	2006	&	province==	42	&	urban == 1
replace	deflator_all	=	93.97	if	interview_year==	2006	&	province==	43	&	urban == 1
replace	deflator_all	=	93.81	if	interview_year==	2006	&	province==	45	&	urban == 1
replace	deflator_all	=	91.52	if	interview_year==	2006	&	province==	52	&	urban == 1
												
replace	deflator_all	=	100		if	interview_year==	2009	&	province==	21	&	urban == 1
replace	deflator_all	=	103.28	if	interview_year==	2009	&	province==	23	&	urban == 1
replace	deflator_all	=	107.35	if	interview_year==	2009	&	province==	32	&	urban == 1
replace	deflator_all	=	105.3	if	interview_year==	2009	&	province==	37	&	urban == 1
replace	deflator_all	=	92.34	if	interview_year==	2009	&	province==	41	&	urban == 1
replace	deflator_all	=	105.43	if	interview_year==	2009	&	province==	42	&	urban == 1
replace	deflator_all	=	104.17	if	interview_year==	2009	&	province==	43	&	urban == 1
replace	deflator_all	=	104.43	if	interview_year==	2009	&	province==	45	&	urban == 1
replace	deflator_all	=	102.25	if	interview_year==	2009	&	province==	52	&	urban == 1
