data kidney;
input clearance concentration age weight;
cards; 
  132.0   0.71   38.0   71.0
   53.0   1.48   78.0   69.0
   50.0   2.21   69.0   85.0
   82.0   1.43   70.0  100.0
  110.0   0.68   45.0   59.0
  100.0   0.76   65.0   73.0
   68.0   1.12   76.0   63.0
   92.0   0.92   61.0   81.0
   60.0   1.55   68.0   74.0
   94.0   0.94   64.0   87.0
  105.0   1.00   66.0   79.0
   98.0   1.07   49.0   93.0
  112.0   0.70   43.0   60.0
  125.0   0.71   42.0   70.0
  108.0   1.00   66.0   83.0
   30.0   2.52   78.0   70.0
  111.0   1.13   35.0   73.0
  130.0   1.12   34.0   85.0
   94.0   1.38   35.0   68.0
  130.0   1.12   16.0   65.0
   59.0   0.97   54.0   53.0
   38.0   1.61   73.0   50.0
   65.0   1.58   66.0   74.0
   85.0   1.40   31.0   67.0
  140.0   0.68   32.0   80.0
   80.0   1.20   21.0   67.0
   43.0   2.10   73.0   72.0
   75.0   1.36   78.0   67.0
   41.0   1.50   58.0   60.0
  120.0   0.82   62.0  107.0
   52.0   1.53   70.0   75.0
   73.0   1.58   63.0   62.0
   57.0   1.37   68.0   52.0
;
run;

/* All-Possible-Regressions Procedures */

proc reg data = kidney;
model clearance = concentration age weight/ selection = rsquare adjrsq aic sbc;
run;

/* Forward selection */

proc stepwise data=kidney;
model clearance = concentration age weight / forward slentry=.1;
run;

/* Backward elimination */

proc stepwise data=kidney;
model clearance = concentration age weight / backward slstay=.15;
run;

data computer;
input cents responses;
cards;
   77.0   16.0
   70.0   14.0
   85.0   22.0
   50.0   10.0
   62.0   14.0
   70.0   17.0
   55.0   10.0
   63.0   13.0
   88.0   19.0
   57.0   12.0
   81.0   18.0
   51.0   11.0
;
run;

proc reg data = computer;
model cents = responses;
output out=compr p=pred r=resid;
run; quit;

*making a scatterplot of resid against responses;
proc gplot data=compr;
goptions;
symbol1 value=dot color=black;
plot resid*responses;
run;
/* split age to do the Brown-Forsythe test */

proc sort data = compr;
by pred;
run;

proc print data = compr;
run;

/* split the top and bottom predicted values */

data split_responses;
set compr;
if _n_ <= 6 then responses1 = 1;
else responses1 = 0;
run;

proc print data = split_responses;
run;

/* preforming the Brown-Forsythe test */

proc glm data=split_responses;
class responses1;
model cents = responses1;
means responses1 / hovtest=bf;
run;

/* Plot of absolute residuals against age shows that  */

data absresid;
set compr;
absresid = abs(resid); /*creating a new variable which contains the absolute value of the residuals */
run;

*making a scatterplot;
proc gplot data=absresid;
goptions;
symbol1 value=dot color=black;
plot absresid*responses;
run;

proc reg data = absresid;
model absresid = responses;
output out = model2 p = s_hat ;
plot absresid*responses;
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
model cents= responses;
*output out=temp r=resid;
run; quit;
