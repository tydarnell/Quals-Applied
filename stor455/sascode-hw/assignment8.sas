data brand;
input liking moisture sweetness;
cards;
   64.0    4.0    2.0
   73.0    4.0    4.0
   61.0    4.0    2.0
   76.0    4.0    4.0
   72.0    6.0    2.0
   80.0    6.0    4.0
   71.0    6.0    2.0
   83.0    6.0    4.0
   83.0    8.0    2.0
   89.0    8.0    4.0
   86.0    8.0    2.0
   93.0    8.0    4.0
   88.0   10.0    2.0
   95.0   10.0    4.0
   94.0   10.0    2.0
  100.0   10.0    4.0
;
run;

proc reg data=brand;
model liking = moisture sweetness/partial;
run; quit;

/* Added resid plot for moisture */
proc reg data = brand;
model liking = sweetness;
output out=residy r=residy;
run; quit;

proc reg data=brand;
model moisture=sweetness;
output out=residm r=residm;
run;quit;

data resid; merge residy residm;
run;

proc print data = resid;
run;

proc gplot data=resid;
plot residy*residm;
run;

proc reg data=resid;
model residy=residm;
run;

/* Added resid plot for sweetness */
proc reg data = brand;
model liking = moisture;
output out=residy2 r=residy2;
run; quit;

proc reg data=brand;
model sweetness=moisture;
output out=resids r=resids;
run;quit;

data resid2; merge residy2 resids;
run;

proc print data = resid2;
run;

proc gplot data=resid2;
plot residy2*resids;
run;

proc reg data=resid2;
model residy2=resids;
run;
/* Outlier detection for the model predicting liking from moisture and sweetness;
Run the model in proc reg, use 'influence' options, output influence statistics 
into data set using output delivery system (ods) */
proc reg data=brand;
model liking = moisture sweetness/influence;
ods output OutputStatistics=diag; /* dataset diag has diagnostic stats */
run;

proc print data=diag;
run;

/* 	Rstudent = standardized residuals (discrepancy)
	Hat Diagonal = h (leverage) 

/* Using cut-off values to identify extreme values of h (leverage)

2p/n = 2(3)/16 = .375 */

proc print data=diag;
  var HatDiagonal;
  where HatDiagonal > .375;
run;

proc print data=diag;
  var HatDiagonal;
  where HatDiagonal > .2;
run;
/* Using an index plot to identify extreme values of h (leverage) */

goptions reset=all;
symbol1 value=dot color=steel;
title 'Index Plot for H'; 
proc gplot data=diag;
plot HatDiagonal*Observation/href=1 to 16 by 1 haxis=axis1 ;
run; quit;

/* Get critical t values */

data crit;
n = 16; /* plug in n from data */
alpha = .1; /* set alpha value */
p = 3; /* determine number of parameters */
crit = tinv(1-alpha/(2*n), n-p-1);
run;

proc print data=crit;
run;

proc print data=diag;
var Rstudent;
where abs(Rstudent) > 3.30778;
run;

/* Influence */

/* Index plot for DFFITS */

goptions reset=all;
symbol1 value=dot color=steel;
title 'Index Plot for DFFITS'; 
proc gplot data=diag;
plot DFfits*Observation/href=1 to 16 by 1 haxis=axis1 chref=red cframe=ligr;
run; quit;

/* To get Cook's d: */

proc reg data=brand;
model liking = moisture sweetness;
output out=diag1 cookd=cookd;
run;

proc print data = diag1;
run;

/* Index plot for Cook's d: */

data diagcookd; merge diag diag1;
run;

proc print data = diagcookd;
run;

goptions reset=all;
symbol1 value=dot color=steel;
title 'Index Plot for Cooks D'; 
proc gplot data=diagcookd;
plot cookd*Observation/href=1 to 16 by 1 haxis=axis1 chref=red cframe=ligr;
run; quit;
	
/* Index plot for DFBETAS */

goptions reset=all;
symbol1 value=dot color=steel;
symbol2 value=dot color=orange;
title 'Index Plot for DFBETA - MOISTURE(steel) and SWEETNESS(orange)';
proc gplot data=diag;
plot DFB_moisture*Observation DFB_sweetness*Observation/overlay href=1 to 16 by 1 haxis=axis1 chref=red cframe=ligr;
run; quit;
