data runners;
input oxygen male runtime runpul age restpul weight smoke drink;
cards;
44.609	1	11.37	178	60	62	71.47	1	0
54.297	0	11.65	156	44	45	96.84	2	1
49.874	0	9.22	178	38	55	79.02	2	2
45.681	0	10.95	176	55	70	75.98	2	1
39.442	1	14.08	174	59	63	64.42	0	0
50.541	1	8.13	168	44	45	88.03	2	3
44.754	0	11.12	176	45	51	79.45	1	2
51.855	0	11.33	166	54	50	87.12	0	3
46.774	1	11.25	162	48	48	71.63	0	1
39.407	1	13.63	174	57	58	65.37	0	0
45.441	0	9.63	164	32	48	78.32	1	1
45.118	0	12.08	172	51	48	77.25	2	0
45.79	1	9.47	186	51	59	73.71	2	1
48.673	1	9.4		186	49	56	76.32	2	2
47.467	1	12.5	170	52	53	72.78	0	3
45.313	0	11.07	185	40	62	75.07	0	0
59.571	0	8.17	166	42	40	98.15	1	3
44.811	0	11.63	176	47	58	77.45	0	2
49.091	1	10.85	162	43	64	71.19	1	1
37.388	1	14.03	186	55	56	62.66	0	0
47.273	0	10.6	162	47	47	79.15	1	2
49.156	0	8.95	180	49	44	81.42	1	3
46.672	0	10	162	51	48	77.91	0	0
50.388	1	10.08	168	49	67	88.37	2	3
46.08	1	11.17	156	54	62	79.38	1	2
54.625	1	7.92	146	50	48	95.87	2	3
50.545	1	9.93	148	47	49	86.08	1	1
47.92	1	11.5	170	49	52	71.24	1	2
;
run;

proc print data=runners;
run;

proc means data=runners;
class smoke;
var runtime;
run;


/* 
Dummy Coding Table:
D1 - 1 if Quit Smoking
D2 - 1 if Current Smoker
-------------------
Category   D1  D2  
Current    0   1   
Quit       1   0   
Never      0   0   
-------------------
*/

data smoker;
set runners;
if smoke = 1 then D1 = 1;
else D1=0;
if smoke = 0 then D2 = 1;
else D2=0;
run;

proc print data=smoker;
run;

proc standard data=smoker out=centered m=0;
var age;
run;

proc print data = centered;
run;

proc reg data=centered;
model runtime = age D1 D2;
run; quit;

/* Interactions */


/* Computing the interaction */

data centered;
set centered;
D3 = age*D1;
D4 = age*D2;
run;

proc print data = centered;
run;

/* Step 3:  Add the interactions (D3 and D4) */

proc reg data=centered;
model runtime= age D1 D2 D3 D4;
run; quit;

proc means data=centered;
class smoke;
var age;   /* note the range of age for each group for plotting */
run;

data probe;
set centered;
B0=9.93363; /*intercept */
B1=.07408; /* slope for age */
B2=.53153; /* slope for D1 */
B3=1.75508; /* slope for D2 */
B4=-.00019; /* slope of age*D1 */
B5=.09732; /* slope of age*D2 */
Current=(B0 + B2) + (B1 + B5)*age;
Quit=(B0 + B3) + (B1 + B4)*age;
Never=B0 + B1*age;
run;

proc print data=probe;
run;

/* Plot the simple equations */

goptions reset=all;
symbol1 value=dot color=steel i=join;
symbol2 value=dot color=orange i=join;
symbol3 value=dot color=red i=join;	
legend label=('Smoker status') value=('Never' 'Quit' 'Current') frame;
axis1 label=(angle=-90 rotate=90 'Run Time');
axis2 label=('Age');
title 'Plotting Equations for Groups';
proc gplot data=probe;
plot Never*age Quit*age Current*age/overlay vaxis=axis1 haxis=axis2 legend=legend;
run;
quit;

/* new regression model */

proc standard data=smoker out=new m=0;
var weight;
run;

proc print data=new;
run;

proc reg data=new;
model restpul = weight D1 D2;
run; quit;

data new;
set centered;
D3 = weight*D1;
D4 = weight*D2;
run;

proc print data=new;
run;

proc reg data=new;
model restpul= weight D1 D2 D3 D4;
run; quit;

data newprobe;
set new;
B0=96.92977; /*intercept */
B1=-.50489; /* slope for weight */
B2=12.66186; /* slope for D1 */
B3=-16.65909; /* slope for D2 */
B4=-.22002; /* slope of weight*D1 */
B5=.15887; /* slope of weight*D2 */
Current=(B0 + B2) + (B1 + B5)*weight;
Quit=(B0 + B3) + (B1 + B4)*weight;
Never=B0 + B1*weight;
run;

proc print data=newprobe;
run;

goptions reset=all;
symbol1 value=dot color=steel i=join;
symbol2 value=dot color=orange i=join;
symbol3 value=dot color=red i=join;	
legend label=('Smoker status') value=('Never' 'Quit' 'Current') frame;
axis1 label=(angle=-90 rotate=90 'Resting Pulse');
axis2 label=('Weight');
title 'Plotting Equations for Groups';
proc gplot data=newprobe;
plot Never*weight Quit*weight Current*weight/overlay vaxis=axis1 haxis=axis2 legend=legend;
run;
quit;
