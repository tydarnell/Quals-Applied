*SLR Inference SAS Code;

/**************************************************************
EXAMPLE DATASET:
We have two variables and are trying to assess the relationship
between them. The first variable (X) is the number years since 
a professor has completed his or her Ph.D. and the second (Y) is 
number of publications the professor currently has published.
***************************************************************/

data phd;
input time pubs;
cards;
3	18	
6	3	
3	2	
8	17	
9	11	
6	6	
16	38	
10	48	
2	9	
5	22	
5	30	
6	21	
7	10	
11	27	
18	37
;
run;

/* Inferences in SLR 

clb = confidence limits for parameter estimates (slope and intercept) */

proc reg data=phd;
model pubs=time/clb alpha=.05;
run; quit;

/* find the two-tailed p-value */

 data pvalue;
 tobs = 3.139;
 df = 13;
 prob = 2*(1-probt(tobs, df));
 run;
 
 proc print data = pvalue;
 run;
/* Inferences about predicted scores on pubs
CI for the mean (predicted pubs score) for each level of time that is observed
STABILITY across repeated samples 

clm = confidence limits for the mean of each observation */

proc reg data=phd;
model pubs=time/clm alpha=.05;
run; quit;

/* What if you want a CI for a time level that is not observed? */

data temp; 
if _n_ = 1 then time=5;
output; 
set phd;
run;

proc print data=temp;
run;

/* stdp = standard error of the mean predicted value
   lclm and uclm create confidence interval endpoints */
   
proc reg data = temp;
model pubs = time/ clm alpha=.05; 
output out=stabil lclm=lower uclm=upper p=yhat stdp=stdp; 
run; quit; 

proc print data = stabil; 
run;

/*  Prediction intervals for each level of time that is observed
ACCURACY; 

cli = confidence limits for individual predicted values
*/

proc reg data=phd;
model pubs=time/cli alpha=.05;
run; quit;

/* Prediction interval for a level not observed */

data temp; 
if _n_=1 then time=5;
output; 
set phd;
run;

/* stdi = standard error of the individual predicted value
   lcl and ucl create prediction interval endpoints */

proc reg data=temp noprint;
model pubs=time/alpha=.05;
output out=accu lcl=lower ucl=upper p=pred stdi=stdi;
run; quit;

proc print data=accu;
run;

/* Graphing bands */

proc reg data=phd noprint;
model pubs=time;
output out=band stdp=stdp stdi=stdi p=pred;
run; quit;

proc print data=band;
run;

/* t_cv = 2.16, alpha = .05 on how many df? */

data band1;
set band;
tcv = tinv(.975, 13);
lbound_p = pred - tcv*stdp;
ubound_p = pred + tcv*stdp;
lbound_i = pred - tcv*stdi;
ubound_i = pred + tcv*stdi;
run;

proc print data=band1;
run;

proc sort data=band1;
by time;
run;

goptions reset=all;
proc gplot data=band1;
plot (ubound_i lbound_i ubound_p lbound_p)*time pubs*time/regeqn overlay haxis=axis2;
axis2 order=2 to 18;
symbol1 v=none i=join c=blue;
symbol2 v=none i=join c=blue;
symbol3 v=none i=join c=red;
symbol4 v=none i=join c=red;
symbol5 v=none i=rl c=green;
run;quit;




