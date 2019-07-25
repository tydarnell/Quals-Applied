data ati;
input verbal vis_mem training;
cards;
6.81	53.06	0
2.98	62.45	0
-3.14	44.96	0
-7.2	38.72	0
20.03	66.72	0
16.96	39.27	0
5.78	48.37	0
-6.33	43.83	0
9.19	58.14	0
-7.13	65	0
-11.3	44.13	0
-4.41	38.74	0
-5.78	49.1	0
5.5	41.92	0
-18.78	41.23	0
14.48	43.68	0
-0.77	64.19	0
-8.38	44.29	0
-5.02	57.45	0
-11.53	40.49	0
-17.04	47.02	0
-10.02	42.41	0
7.83	55.76	0
2.24	56.92	0
-7.29	51.05	0
-4.94	46	0
-12.47	35.63	0
-1.84	59.52	0
-13.26	43.68	0
11.08	51.3	0
6.9	46.54	0
8.09	52.17	0
-11.28	32.7	0
-6.67	41.58	0
-11.1	28.89	0
6.81	33.72	0
16.42	68.39	0
7.53	57.22	0
-4.06	53.87	0
20.55	68.6	0
15.52	57.71	0
1.08	62.98	0
-7.42	40.28	0
-4.39	59.84	0
1.82	64.15	0
1.1	53.97	0
-11.97	40.41	0
7.5	53.32	0
9.66	52.85	0
7.65	55.77	0
-6.25	41.92	1
6.24	38.12	1
3.58	36.57	1
-14.69	45.39	1
-22.25	48.64	1
1.12	39.12	1
1.97	42.82	1
1.41	44.73	1
8	43.56	1
5.46	42.04	1
6.01	37.85	1
-12.43	44.51	1
3.31	33.72	1
-1.21	43.09	1
-2.34	32.69	1
20.06	31.14	1
7.87	36.52	1
2.26	45.13	1
9.68	33.59	1
5.2	33.89	1
6.86	36.05	1
-17.68	47	1
-13.4	39.27	1
-4.79	34.38	1
3.69	37.52	1
18.06	37.53	1
-1	31.01	1
-8.06	53.46	1
5.67	36.62	1
-14.74	42.05	1
-15.17	41.66	1
-5.03	40.8	1
4.14	38.88	1
-7.55	37.91	1
12.56	38.7	1
-5.33	40.21	1
-0.12	36.96	1
12.45	39.17	1
11.05	36.53	1
-11.6	45.26	1
-13.37	45.76	1
-16.88	47.75	1
5.75	36.49	1
17.49	44.76	1
-1.8	47.74	1
4.76	32.25	1
-7.15	44.51	1
0.34	38.42	1
11.61	40.1	1
6.27	36.24	1
;
run;
ods rtf file='\\Client\C$\Users\tdarnell\Desktop\Stor455\atiprint.rtf';

proc format;
value cat
20.01-40 = '20-40'
40.01-60 = '40-60'
60.01-80 = '60-80';
run;

proc freq data=ati;
tables vis_mem;
format vis_mem cat.;
run;

goptions reset=all;
proc univariate data=ati ;
 var vis_mem;
run;

data new; set ati;
vis_mem1 = (vis_mem - 45)/ 9.33 ;
run;

proc univariate data=new ;
 var vis_mem1;
run;

proc means data=ati;
by training;
var vis_mem;
output out = meandata mean = vis_memmean;
run;

proc gplot data=meandata;
goptions;
symbol1 value=dot color=black interpol=join;
plot vis_memmean*training;
run;

goptions reset=all;
proc gplot data=ati;
axis1 label=("vis_mem");
axis2 label=("verbal");
title 'Scatterplot of vis_mem vs verbal';
plot vis_mem*verbal / haxis=axis2 vaxis = axis1;
symbol1 value=dot color=steel;
run;
quit;


ods rtf close;
