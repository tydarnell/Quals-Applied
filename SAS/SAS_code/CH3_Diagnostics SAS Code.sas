*Diagnostics SAS Code;

/**************************************************************
EXAMPLE DATASET:
We have two variables and are trying to assess the relationship
between them. The first variable (X) is the number years since 
a professor has completed his or her Ph.D. and the second (Y) is 
number of publications the professor currently has published.
***************************************************************/

data phd;
input id time pubs;
cards;
1	3	18	
2	6	3	
3	3	2	
4	8	17	
5	9	11	
6	6	6	
7	16	38	
8	10	48	
9	2	9	
10	5	22	
11	5	30	
12	6	21	
13	7	10	
14	11	27	
15	18	37
;
run;

/* Diagnosics in Regression */

proc reg data=phd;
model pubs=time;
output out=model p=pred r=resid;
run; quit;

proc print data = model ;
run;
/* Lowess curves on scatterplots */

ods graphics on;
proc loess data=model;
model resid=time; /*Plotting residual by time */
run;

ods graphics on;
proc loess data=model;
model pubs=time; /*Plotting pubs by time */
run;

/* Plotting absolute residuals */

data absresid;
set model;
absresid = abs(resid); /*creating a new variable which contains the absolute value of the residuals */
run;

proc print data = absresid ;
run;
*making a scatterplot;
proc gplot data=absresid;
goptions;
symbol1 value=dot color=black;
plot absresid*pred;
run;

*putting the lowess curve on the scatterplot;
ods graphics on;
proc loess data=absresid;
model absresid=pred;
run;

/* Removing possible outlier */

*look at a scatterplot of the data;
proc gplot data=phd;
goptions;
symbol1 value=dot color=black;
plot pubs*time;
run;

*remove observation 8;
data nooutlier; set phd;
if id = 8 then delete;
run;

*run regression model without observation 8;
proc reg data=nooutlier;
model pubs=time;
run; quit;

/* Examine residuals */

proc univariate data=model normal;
var resid;
run;

/* Boxplot for residuals */

data model1;
set model;
constant = 1;
run;

title 'Boxplot of Residuals';
proc boxplot data=model1;
plot resid*constant /BOXSTYLE=SCHEMATIC;
run;

/* Normal QQ plot for residuals*/

title 'Normal Q-Q Plot for Residuals';
proc capability data=model;
qqplot resid / normal (mu=est sigma=est);
run;

/* Correlation test */

proc rank data=model out=rankedresid;
 var resid;
 ranks Rank; 
 run;

data normaldata; 
 set rankedresid;
 MSE= 117.0396; /*plug in MSE */
 n = 15; /*plug in n */
 expected = sqrt(MSE)*probit((Rank-.375)/(n+.25)); /*see pg. 111 */
 run;

proc corr data=normaldata;
 var resid expected; 
 run;

 *Plot the QQ plot;
proc gplot data=normaldata;
goptions;
symbol1 value=dot color=black;
plot resid*expected;
run;

