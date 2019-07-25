
data beers;
input id gender weight beers PM;
cards;
1	2	132	5	6
2	2	128	2	9.25
3	2	110	9	4.75
4	1	192	8	7.5
5	1	172	3	9.75
6	2	250	7	6.5
7	2	125	3	7
8	1	175	5	8.75
9	2	175	3	6
10	1	275	5	8.5
11	2	130	4	8.5
12	1	168	6	7.75
13	2	128	5	8.25
14	1	246	7	7.75
15	1	164	1	9.5
16	1	175	4	9
;
run;

/* Displaying the data */

ods rtf file='C:\Users\rshutton\Desktop\SAS\beersprint.rtf';
proc print data=beers;
run;
ods rtf close;


/* Computing means */

proc means data=beers;
var beers PM;
run;

/* Sorting the data */
/* The 'by' statement specifies variables which are used to break the dataset into groups for the 
	procedure */
/* Using data from the working directory */

proc sort data=beers;
by gender;
run;

/* Take yet another look at data - it should be sorted by gender */

proc print data=beers;
run;

/* Computing means by gender */
/* The output command puts the mean data in a seperate data file */
/* 'out = ' saves a name for the means dataset */
/* 'mean = ' gives a label for the requested mean data by gender */

proc means data=beers;
by gender;
var beers PM;
output out = meandata mean = beersmean PMmean;
run;

/* Looking at the data... */

proc print data=meandata;
run;

/* Plotting beermean x gender */

proc gplot data=meandata;
goptions;
symbol1 value=dot color=black interpol=join;
plot beersmean*gender;
run;

/* Obtaining descriptive statistics, plots, and histogram of beers and PM */

goptions reset=all;
proc univariate data=beers plot ;
 var beers PM;
 histogram/normal(color=black);
run;

/* Histogram */
/* 'endpoint =' tells SAS what value range to use and by what unit increment */

proc univariate data=beers; 
var beers;
title 'Histogram of Beers';
histogram / normal(color=black) endpoints = 1 to 10 by 3;
run;

/* Obtaining frequency tables */

proc freq data=beers;
tables weight beers PM;
run;

/* Getting grouped frequencies - categorizing data */
/* 'value' puts a label to your categories */
/* The left side of the = are the numerical values you want to categorize, the right side of the = 
	are the labels */

proc format;
value cat
0-3 = '0-3'
3.01-6 = '3.01-6'
6.01-9 = '6.01-9';
run;

/* Get grouped frequencies */
/* Applying the previously defined categories to the variable */
/* Note the addition of the 'format' statement and the color of the value label */

proc freq data=beers;
tables beers;
format beers cat.;
run;

/* Creating a new variable */

data new; set beers;
gender1 = gender - 1;
run;

proc print data=new;
run;

/* Scatterplot of PM versus Beers */
/* Create axis definitions */
/* 'axis order =' tells SAS what value range to use and by what unit increment */

goptions reset=all;
proc gplot data=beers;
axis1 label=("PM");
axis2 order=0 to 10 by 1 label=("Beers");
title 'Scatterplot of 2 continuous variables';
plot PM*beers / haxis=axis2 vaxis = axis1;
symbol1 value=dot color=steel;
run;
quit;

/* Boxplot */
/* proc boxplot can't actually plot 1 variable */
/* Have to trick it by plotting it against a constant */
/* First, creating the constant */
/* By using the same 'data' and 'set' names - we just add on the constant variable */

data beers;
set beers;
constant = 1;
run;

proc print data=beers;
run;

/* Now creating the boxplot */ 

title 'Boxplot of PM';
proc boxplot data=beers;
plot PM*constant /BOXSTYLE=SCHEMATIC;
run;

/* Normal QQ plot for PM*/

title 'Normal Q-Q Plot for PM';
proc capability data=beers;
qqplot PM / normal (mu=est sigma=est);
run;


/* Z-Scores */

/* We have a mean of 8.5 with a standard deviation of 2.15. 
1)  What is the cumulative proportion of area below a raw score of 9? 
2)  What is the cumulative proportion of area above a raw score of 9? */

/* First, lets calculate the z-score */

data zscore;
zscore = (9-8.5)/2.15;
run;

proc print data=zscore; run;

/* 1)  What is the cumulative proportion of area below a raw score of 9?  */

data zscore_below; set zscore;
belowprb = probnorm(zscore);
run;

proc print data=zscore_below; run;

/* 2)  What is the cumulative proportion of area above a raw score of 9? */

data zscore_above; set zscore;
aboveprb = 1 - probnorm(zscore);
run;

proc print data=zscore_above; run;

/* Now, let's do everything in one datastep */

data zscore_one;
zscore = (9-8.5)/2.15;
belowprb = probnorm(zscore);
aboveprb = 1- probnorm(zscore);
run;

proc print data=zscore_one; run;

/* Using the same example as above, what if we knew that the cumulative area ABOVE a 
particular score is .12 - how can we get the z-score? */
/* We know that the cumulative probability below then would be .88 (1-.12). So we can use 
this with the probit command */

data get_zscore;
zout = probit(.88); run;

proc print data=get_zscore; run;

/* Example: Assume a normally distributed population of math test scores with µ = 75 and s = 7.
What is the probability of randomly selecting someone who scored either above 84 
or between 60 and 65 */

/* Get the z-scores (first three lines) */
/* Then get areas above 84 and below 65 and 60 (lines 4-6) */
/* Since we want area between 60 and 65, we have to subtract below60 from below65 (line 7) */
/* Then, we add the two areas together (line 8)*/

data math;
 zs84 = (84-75)/7;
 zs65 = (65-75)/7;
 zs60 = (60-75)/7;
 above84 = 1 - probnorm(zs84);
 below65 = probnorm(zs65);
 below60 = probnorm(zs60);
 area60to65 = below65 - below60;
 areasum = area60to65 + above84;
run;

proc print data=math; run;

data confidence;
/*95% CI */
upper95 =600+probit(.975)*(126/sqrt(30));
lower95 =600-probit(.975)*(126/sqrt(30));
/*or can use this syntax */
upper195 =600+probit(.975)*(126/sqrt(30));
lower195 =600+probit(.025)*(126/sqrt(30));
/* 99% CI */
upper99 = 600+probit(.995)*(126/sqrt(30));
lower99 = 600-probit(.995)*(126/sqrt(30));
/* or can use this syntax */
upper199 = 600+probit(.995)*(126/sqrt(30));
lower199 = 600+probit(.005)*(126/sqrt(30));
run;

proc print data=confidence; run;


