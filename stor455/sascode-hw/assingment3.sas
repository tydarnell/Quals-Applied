data copier ;
input minutes copiers ;
cards; 
   20     2
   60     4
   46     3
   41     2
   12     1
  137    10
   68     5
   89     5
    4     1
   32     2
  144     9
  156    10
   93     6
   36     3
   72     4
  100     8
  105     7
  131     8
  127    10
   57     4
   66     5
  101     7
  109     7
   74     5
  134     9
  112     7
   18     2
   73     5
  111     7
   96     6
  123     8
   90     5
   20     2
   28     2
    3     1
   57     4
   86     5
  132     9
  112     7
   27     1
  131     9
   34     2
   27     2
   61     4
   77     5
   ;
   run;




proc reg data=copier;
model minutes=copiers/clb alpha = .1 ; 
run;
quit;



data pvalue;
tobs = 31.123 ;
df = 43;
prob = 2*(1-probt(tobs, df));
run;
 
proc print data = pvalue;
 run;

proc reg data=copier;
model minutes=copiers/clm alpha=.1;
run; quit;

data temp; 
if _n_ = 1 then copiers = 6;
output; 
set copier;
run;

proc print data=temp;
run;

proc reg data = temp;
model minutes=copiers/ clm alpha=.1; 
output out=stabil lclm=lower uclm=upper p=yhat stdp=stdp; 
run; quit; 

ods rtf file='\\Client\C$\Users\tdarnell\Desktop\Stor455\a2.rtf';

proc print data = stabil; 
run;

ods rtf close;

proc reg data=temp noprint;
model minutes=copiers/alpha=.1;
output out=accu lcl=lower ucl=upper p=pred stdi=stdi;
run; quit;

proc print data=accu;
run;

data pvalue1;
Fobs = 968.66;
ndf = 1;
ddf = 43;
prob = 1-probf(fobs,ndf,ddf);
run;

proc print data = pvalue1;
run;
