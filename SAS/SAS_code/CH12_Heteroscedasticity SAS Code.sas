/* SAS example for Weighted Least Squares */
/* We use the blood pressure data in Table 11.1 of the book */

data bp;
input age dbp;
cards;
  27   73
  21   66
  22   63
  24   75
  25   71
  23   70
  20   65
  20   70
  29   79
  24   72
  25   68
  28   67
  26   79
  38   91
  32   76
  33   69
  31   66
  34   73
  37   78
  38   87
  33   76
  35   79
  30   73
  31   80
  37   68
  39   75
  46   89
  49  101
  40   70
  42   72
  43   80
  46   83
  43   75
  44   71
  46   80
  47   96
  45   92
  49   80
  48   70
  40   90
  42   85
  55   76
  54   71
  57   99
  52   86
  53   79
  56   92
  52   85
  50   71
  59   90
  50   91
  52  100
  58   80
  57  109
;
run;

/* Regressing the response, dbp, against the predictor, age */

/* The plots show some definite nonconstant error variance */

proc reg data=bp;
model dbp=age;
output out=model p=pred r=resid;
plot dbp*age;
run; quit;

/* split age to do the Brown-Forsythe test */

proc sort data = model;
by pred;
run;

proc print data = model;
run;

/* split the top and bottom predicted values */

data split_age;
set model;
if _n_ <= 27 then age1 = 1;
else age1 = 0;
run;

proc print data = split_age;
run;

/* preforming the Brown-Forsythe test */

proc glm data=split_age;
class age1;
model dbp=age1;
means age1 / hovtest=bf;
run;

/* Plot of absolute residuals against age shows that  */

data absresid;
set model;
absresid = abs(resid); /*creating a new variable which contains the absolute value of the residuals */
run;

*making a scatterplot;
proc gplot data=absresid;
goptions;
symbol1 value=dot color=black;
plot absresid*pred;
run;

/* absolute residuals may increase linearly with age. */ 

/* Regressing the absolute residuals against the predictor, age */
/* This second regression is done on the data set temp */

proc reg data = absresid;
model absresid = age;
output out = model2 p = s_hat ;
run; quit;

/* Defining the weights using the fitted values from this second regression: */

data model2;
set model2;
w = 1/(s_hat**2);
run;

proc print data=model2;
run;

/* Using the WEIGHT option in PROC REG to get the WLS estimates: */

proc reg data = model2;
weight w;
model dbp = age;
*output out=temp r=resid;
run; quit;


