*Simple Linear Regression SAS Code;

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

/* Creating a scatterplot with a regression line */

goptions reset=all;
title 'Scatterplot of Publications and Years Since Ph.D.';
proc gplot data=phd;
plot pubs*time / vaxis=axis2 haxis=axis1;
symbol1 value=dot color=black interpol=rl;
axis1 label=('Years Since Ph.D.');
axis2 label=('Number of Publications');
run;
quit;

/* Running the regression */

proc reg data=phd;
model pubs=time; 
run;
quit;

/* Regression with standardized coefficients */

proc reg data=phd;
model pubs=time / stb; 
run;
quit;

/* How to output predicted values and residuals */

proc reg data=phd;
model pubs=time;
output out = model p=pred r=resid;
*plot pubs*time;
run;
quit;

proc print data=model;
var pred resid;
run;

/*
Examine relationships among X,Y,Y_hat,e 
1) What is the correlation between X and Y_hat?
2) What is the correlation between X and e? 
3) What is the correlation between Y_hat and Y? 
4) What is the correlation between X and Y?  */

proc corr data=model;
var time pubs pred resid;
run;
