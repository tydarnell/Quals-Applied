data plastic;
input hardness hours;
cards;
  199.0   16.0
  205.0   16.0
  196.0   16.0
  200.0   16.0
  218.0   24.0
  220.0   24.0
  215.0   24.0
  223.0   24.0
  237.0   32.0
  234.0   32.0
  235.0   32.0
  230.0   32.0
  250.0   40.0
  248.0   40.0
  253.0   40.0
  246.0   40.0
  ;
  run;
proc reg data=plastic;
model hardness=hours;
output out=model p=pred r=resid;
run; quit;

proc print data = model ;
run;

data model1;
set model;
constant = 1;
run;

title 'Boxplot of Residuals';
proc boxplot data=model1;
plot resid*constant /BOXSTYLE=SCHEMATIC;
run;


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
 MSE= 10.45893; /*plug in MSE */
 n = 16; /*plug in n */
 expected = sqrt(MSE)*probit((Rank-.375)/(n+.25)); /*see pg. 111 */
 run;

proc corr data=normaldata;
 var resid expected; 
 run;

data electricity;
input X e;
cards;
   2   3.2
   3   2.9
   4  -1.7
   5  -2.0
   6  -2.3
   7  -1.2
   8  -0.9
   9   0.8
  10   0.7
  11   0.5
  ;
  run;

proc gplot data=electricity;
goptions;
symbol1 value=dot color=black;
plot e*X / vref= 0;
run;

data production;
input Y X ;
cards;
   14.28        15
    8.80         9
   12.49         7
    9.38         4
   10.89         9
   15.39        21
   13.09        11
   12.35         6
   10.66        10
    8.12         7
   12.61        12
    8.61         2
   10.99         6
    8.65         5
   11.52        10
    7.25         3
    2.63         3
    9.61         4
   20.20        20
   19.68        17
   13.46        13
   18.45        30
   18.05        21
    9.76         4
   18.27        15
   14.38        17
   13.27        13
   11.40        10
   12.32         7
   19.06        23
   10.66         7
   13.88        16
    2.53         3
   11.21         3
   13.28        10
   16.79        21
   13.04         5
   10.60         7
   19.41        26
    8.56         7
   20.87        22
    9.80         8
   15.33        14
   13.78        11
   11.77         9
   16.65        18
   12.11        10
   14.31         6
   10.38         4
   12.66        13
   15.71        13
   17.66        17
   12.94        13
   12.14         8
    7.11         2
   21.97        33
    9.02         3
    8.90         4
   15.75        25
   11.80        12
   12.52        14
   12.45         6
   18.35        24
   10.81         8
   11.86        12
    9.00         4
    8.54         4
   17.11        14
   17.50        16
   10.74         6
   16.57        16
   16.46        15
   17.24        22
   15.03        12
   14.65        10
    8.66         8
   20.70        21
    8.27         9
   11.99         8
   11.01         6
   13.72         7
   11.15         7
   18.80        18
   21.94        23
   22.35        27
    9.49         8
   11.43         8
   12.84        14
   10.64         5
   14.95        14
   13.29        10
   19.25        16
    7.78         8
   11.37         6
   15.86        18
    6.69         6
   13.34        17
   12.13        10
   14.62         8
    7.63         6
    0.51         0
   10.41         8
   11.91         6
   18.88        21
   11.15         9
    9.23         6
   10.65        10
   13.53        11
   16.37        12
   11.45         9
   15.78        15
   ;
   run;

proc gplot data=production;
goptions;
symbol1 value=dot color=black;
plot Y*X;
run;

proc reg data=production;
model Y=X;
run; quit;

data trans; set production;
sqrtx = sqrt(X);

proc print data = trans;
run;

proc reg data = trans;
model Y=sqrtx;
run; quit;
