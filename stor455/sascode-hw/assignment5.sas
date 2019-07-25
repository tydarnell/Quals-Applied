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

proc corr data=brand;
var liking moisture sweetness;
run;

proc sgscatter data=brand;
matrix liking moisture sweetness;
run;

proc reg data=brand;
model liking = moisture sweetness;
run; quit;

data pvalue;
Fobs = 129.08;
ndf = 2;
ddf = 13;
prob = 1-probf(fobs,ndf,ddf);
run;
 
 proc print data=pvalue;
 run;

data temp; 
if _n_=1 then moisture=5;
if _n_=1 then sweetness=4;
output; 
set brand;
run;

proc reg data=temp;
model liking= moisture sweetness/clm alpha=.01;
run; quit;

proc reg data=temp noprint;
model liking=moisture sweetness/alpha=.01;
output out=accu lcl=lower ucl=upper p=pred stdi=stdi;
run; quit;

proc print data=accu;
run;
