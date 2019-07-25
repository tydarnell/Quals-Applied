options ls=70;

proc import datafile = 'C:\Users\feizou\Desktop\Teaching\Bios663-2019\Spring2019\lecture9\ozone.csv'
 out = ozone
 dbms = CSV
 REPLACE
 ;

 /* correlation of personal and outdoor*/
proc corr data=ozone;
var personal outdoor;
run;


/*semipartial correlation of personal, 
and outdoor after adjusting for home ozone level*/
proc glm data=ozone;
model outdoor = home;
output out=out predicted=predicted 
residual=residual;
run;

proc print data=out;
run;

proc corr data=out;
  var residual personal;
run;

/*the (semipartial correlation)^2 also equals 
Semipartial Eta-Square in the type III table */
proc glm data = ozone;
model personal = home outdoor/effectsize;
run;
