libname final "C:\Users\tydar\OneDrive\Documents\Bios662\Final" ;

data total;
input diabcase race_aa _total_;
cards;
0 1 1750
1 1 400
0 0 7350
1 0 750
;
run;

proc surveymeans data=Final.final2018q2 total= total;
var il6;
strata diabcase race_aa;
run;
