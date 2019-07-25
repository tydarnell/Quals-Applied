/* SAS Cheat Sheet for Quals V1
Code: SAS_Cheat_Sheet_v1.SAS
--> Mostly just proc options and format;
--> Includes: reading in data, proc freq, means, univariate, print, corr, 
			  ods graphics, ods output, dates, formats, arrays/counting/do loops
--> Real basic code 
Last Update: CAC  7/2/19
*/

/*********************************************
 Importing data 
*********************************************/
*BIOS511 L9 ;

*from datalines; 
*BIOS511 L1 S4;

data test;
input variable1 1-4 variable2 $ 6-21 variable3 $; * ${variable name} ${lines};
datalines;
0827 cheynna crowley yellow
;
run;

*sas7bdat infile;
*BIOS511 L1 S19;

libname test "\\Client\H$\Desktop\";
data one;
infile test.xyz;
input a b c;
run;

/*********************************************
Exporting dataset
*********************************************/
*BIOS511 L9 S31;

filename raw "\\Client\H$\Desktop\";

data temp;
set bios511.class;
file raw;
put name $1-8 age 10-12 ht 15-20;
run;

*BIOS511 L9 S39;
filename raw "\\Client\H$\Desktop\";
data _NULL_;
set bios511.class;
file raw;
put @1 name $20. @22 sex $1. @24 age 3. @28 ht 3. @ 32 wt z3.;*6 observations;
run;

/*********************************************
Creating reports 
*********************************************/
*BIOS511 L9 S45-55;


/*********************************************
DATES
*********************************************/
*BIOS511 L4 S64;
DATA one; 
SET bios511.class;** create date1 as a date constant **;
date1 = '01jul1993'd;** create date2 using a date function **;
date2 = mdy(07,01,1993);** create date3 as a date constant **;
date3 = '01jul1943'd;** find difference between dates in days and years **; 
daydiff = date1 - date3;
yeardiff = daydiff/365.25;
KEEP name date1-date3 daydiff yeardiff;
RUN;

*BIOS511 L5 S34 date format example;
data one; 
set bios511.class; 
date1 = '27sep01'd; 
date2 = date1; 
format date1 date2 date7.; 
keep date1 date2 ht; 
run; 

proc print data=one(obs=1) split='*'; 
var date1 date2 ht;
format ht 1.0 date2;
label date1 = "Today's*Date*Formatted" date2 = "Today's*Date*Unformatted"; 
title 'Date Format Example';
run;

/*********************************************
 Counting
*********************************************/
*example: BIOS511 L5 S9;
data one; 
set bios511.class; 
retain count 0 nmales 0;
count = count + 1; 
nmales = nmales + (sex='M');
keep name sex count nmales; 
run;

/*********************************************
 Creating Tables
*********************************************/

*proc tabulate;
*BIOS511 L8 ;

*BIOS511 L1 S9;
proc tabulate data=weight_club;
label StartWeight = 'Initial Weight'
		EndWeight = 'Final Weight'
			 Loss = 'Weight Loss';
class team;
var StartWeight EndWeight Loss;
table team, MEAN*(StartWeight EndWeight Loss);
run;


*BIOS511 L8 S14;
PROC TABULATE DATA=bios511.sales;
CLASS dept clerk;
VAR cost price;
TABLE clerk ALL, (dept ALL)*(cost*(N SUM) price*SUM);
TITLE2 'Crossed Class and Analysis Variables -- Wide Table';
RUN;
/*********************************************
Proc Print 
*********************************************/
*BIOS 511 L2 S19;

PROC PRINT DATA = <libref.filename> <option(s)>;
BY <DESCENDING> variable-1 <...<DESCENDING> variable-n><NOTSORTED>;
PAGEBY BY-variable;
SUMBY BY-variable;
ID variable(s) <option>;
SUM variable(s) <option>;
VAR variable(s) <option>;
RUN;

*example: BIOS511 L2 S21;
ODS HTML NEWFILE=PROC STYLE=DTREE;
OPTIONS NODATE NONUMBER;
PROC PRINT DATA=bios511.weight_club N NOOBS;
SUM loss;
TITLE1 H=2.0 'Listing of the Weight_Club Data Set';
TITLE2 H=0.5 'Using the N and NOOBS Options';
TITLE3 H=0.5 'Also, Using a SUM Statement But No VAR Statement';
RUN;


/*********************************************
PROC FREQ
*********************************************/
*BIOS511 L2 S 25;
PROC FREQ DATA = <libref.filename> <options> ;
BY variables ;
TABLES requests </ options> ;
WEIGHT variable </ option> ;
RUN;

*example: BIOS511 L2 S28;
ODS LISTING CLOSE;
ODS HTML NEWFILE=NONE;
PROC FREQ DATA=bios511.sales NOPRINT;
TABLES dept*clerk / OUT=no_outpct;
TABLES dept*clerk / OUT=with_outpct OUTPCT;
TITLE1 "Table underlying output data sets";
RUN;

*example: BIOS511 L2 S29;
PROC FREQ DATA=bios511.clin ;
TABLES evdnk*visit ;
TABLES evdnk*visit / MISSPRINT ;
TABLES evdnk*visit / MISSING ;
TITLE1 "Missing Data Example" ;
RUN;

*example: BIOS511 L2 S31;
ODS HTML SELECT CrossTabFreqs ;
PROC FREQ DATA=colors;
WEIGHT inputCount;
TABLES Eyecolor * Haircolor / ALL;
RUN;

*example: BIOS511 L3 S6;
proc freq data=bios511.sales;
label dept = 'Department' clerk = 'Clerk';
tables dept*clerk / plots=all;
run;
/*********************************************
PROC UNIVARIATE
*********************************************/
*BIOS511 L2 S32;

PROC UNIVARIATE DATA = <libref.filename> <options> ;
BY variables ;
CLASS variable-1 <(v-options)> <variable-2 <(v-options)>> ;
FREQ variable ;
HISTOGRAM <variables> < / options> ;
ID variables ;
INSET keyword-list </ options> ;
OUTPUT <OUT=SAS-data-set> <keyword1=names ...keywordk=names>;
VAR variables ;
WEIGHT variable ;
RUN;

*example BIOS511 L2 S36;
ODS HTML NEWFILE=PROC style=SASWEB;
PROC UNIVARIATE DATA=bios511.sales2 FREQ PLOT NORMAL ;
VAR COST ;ID CLERK ;LABEL COST='Total Cost' ;
TITLE1 'PROC UNIVARIATE with Several Options and OptionalStatements';
RUN;


*example: BIOS511 L2 S37;
proc univariate data=sales noprint;
by sex;
var cost price; /** two input variables */
output out= stats /*name of output dataset in work folder*/
		n = ncost nprice /** two output variables per stat. */
	nmiss = nmcost nmprice
	 mean = mcost mprice
	  max = maxcost maxprice;
run;

*example: BIOS511 L2 S38;
ODS GRAPHICS / HEIGHT=5in WIDTH=6in;
PROC UNIVARIATE DATA=bios511.hw4 NOPRINT;
HISTOGRAM hdl / NORMAL;
INSET N MEAN STD / format=6.2;
RUN;


/*********************************************
PROC MEANS
*********************************************/
*BIOS511 L2 S39;
PROC MEANS DATA = <libref.filename> <option(s)> <statistic-keyword(s)>;
BY <DESCENDING> variable-1 <... <DESCENDING> variable-n><NOTSORTED>;
CLASS variable(s) </ option(s)>;
FREQ variable;
ID variable(s);
OUTPUT <OUT=SAS-data-set> 
	  <output-statistic-specification(s)>
	  <id-group-specification(s)> 
	  <maximum-id-specification(s)>
	  <minimum-id-specification(s)>
	  </ option(s)> ;
TYPES request(s);
VAR variable(s) < / WEIGHT=weight-variable>;
WAYS list;
WEIGHT variable;
RUN;

*example: BIOS511 L2 S43;
PROC MEANS DATA=bios511.sales2 MAXDEC=2 N MEAN MAX MISSING;
CLASS sex ;
TITLE1 color=red 'PROC MEANS: 'color=blue 'CLASS Sex with the MAXDEC Option' ;
RUN;


*example: BIOS511 L2 S44;
PROC MEANS DATA=sales NOPRINT;
BY sex;
WHERE not missing(sex);
VAR cost price;
OUTPUT OUT=summary N=cost_N price_n MEAN= cost_mean price_mean;
*OUTPUT OUT=summary N= MEAN= / AUTONAME;
RUN;

/*********************************************
PROC CORR
*********************************************/
*example: BIOS511 L3 S7;
proc corr data = bios511.cars2011 plots=all; 
var citympg hwympg basemsrp curbweight; 
run;

/*********************************************
PROC GLM
*********************************************/


*example: BIOS511 L3 S9;
proc glm data=bios511.baseball plots=all; 
class league; 
model cr_runs=league ; 
run;

/*********************************************
PROC SGPLOT
*********************************************/
*BIOS511 L3 S20;
PROC SGPLOT data=<libref.filename> <option(s)>;
STYLEATTRS </option(s)>; 
VBAR category-variable </option(s)>;
XAXIS <option(s)>;
YAXIS <option(s)>; 
KEYLEGEND <"name-1" ... "name-n"> </option(s)>;
RUN;

*example: BIOS511 L3 S22;
proc sgplot data=bios511.sales; 
vbar dept /response=price stat=mean fillattrs=(color=orange);
yaxis label ='Average Price' values=(0 to 700 by 50) grid;
xaxis label = 'Department'; 
title 'Average Item Price by Department in January'; 
run;

*example: BIOS511 L3 S23;
proc sgplot data=bios511.sales; 
vbar clerk / group=dept groupdisplay=cluster response=price stat=mean ;
yaxis label ='Average Price' values=(0 to 700 by 50) grid;
xaxis label = 'Department'; 
title 'Average Item Price for Clerk by Department in January';
run;

*example: BIOS511 L3 S24;
proc sgplot data=bios511.cars2011 noautolegend; 
histogram curbweight; 
density curbweight / type=normal lineattrs=(color=black thickness=2 pattern=2); 
inset 'Source: Consumer Reports' / position=topright;
run;

*example: BIOS511 L3 S29;
proc sgplot data=bios511.ufo2;
series x=sightdate y=howmany/ group=color markers lineattrs=(pattern=1) 
							  markerattrs=(symbol=circlefilled size=6);
run;

/*********************************************
PROC SGPANEL
*********************************************/
*BIOS511 L3A S1 Basic Syntax;
PROC SGPANEL data = <libref.filename> <option(s)>;
PANELBY variable(s) </option(s)>;
STYLEATTRS </option(s)>;
VBAR category-variable </option(s)>;
COLAXIS <option(s)>;
ROWAXIS <option(s)>; 
KEYLEGEND <"name-1" ... "name-n"> </option(s)>; 
RUN;

*example: BIOS511 L3A S3 Comparative Histogram and Kernel Density Plot;
proc sgpanel data=bios511.baseball noautolegend;
panelby league division;
histogram c_home;
density cr_home / type=kernel;
label league="League" division="Division"; 
run;

*example: BIOS511 L3A S5 Use of GROUP= option with SGPANEL;
proc sgpanel data=bios511.prostate; 
panelby Treatment / rows=2 columns=2; 
styleattrs datacontrastcolors=(blue red);
where CVDHistory>-10 and age >-10 and TumorSize > -10;
reg x=age y=TumorSize / group = CVDHistory markerattrs=(symbol=circleFilled size=5);
colaxis grid; rowaxis grid;
label CVDHistory="CVD History" TumorSize="Tumor Size"; 
run;


/*********************************************
PROC SGSCATTER
*********************************************/

*example: BIOS511 L3 S6 Use of MATRIX Statement in PROC SGSCATTER;
options nolabel; 
ods graphics / height=6in width=6in; 
proc sgscatter data=bios511.cars2011;
matrix citympg hwympg basemsrp curbweight / ellipse diagonal=(histogram kernel) 
												 markerattrs=(color=green);
run;
options label;

*example: BIOS511 L3 S7 Use of COMPARE Statement in PROC SGSCATTER;
options nolabel; 
ods graphics / height=4in width=6in; 
proc sgscatter data=bios511.cars2011; 
where lowcase(country) in ("japan","germany") and hwympg<60; 
compare y=hwympg x=(basemsrp curbweight seating) / loess jitter group=country; 
run; 
options label;
/*********************************************
PROC FORMAT
*********************************************/
*BIOS511 L9 S20;

*example:BIOS511 L3A S11;
proc format; 
value sm 0='Non-smoker' 
		 1='Smoker'; 
value ex 0='Does not exercise' 
		 1='Exercises'; 
run;

*BIOS511 L5 S28;
DATA class2; 
SET classlib.class; 
FORMAT sex $hex2. age roman6. ht words15. wt e8.;
RUN;

*BIOS511 L5 S27;
TITLE1 “With Formats”;
PROC PRINT DATA=bios511.sales(obs=2); 
FORMAT cost price dollar9.2; 
RUN;


*BIOS511 L5 S40;
PROC FORMAT; 
VALUE prfmt 0<-100 = ‘Low’ 
		  100<-500 = ‘Medium’ 
		 500<-<700 = ‘High’ 
		  700-high = ‘Very High’ 
		     LOW-0 = ‘Invalid’ 
			 Other = ‘Missing’; 
VALUE $rfmt ‘MON’,’TUE’,’WED’,’SUN’ = ‘No R’ 
     			  ‘THR’,’FRI’,’SAT’ = ‘R’ 
							  other = ‘Invalid’; 
RUN;


/*********************************************
DO LOOPS i.e.
X=0 ; 
DO I = 1 to 7 by 2;
X = X + I; END;
*********************************************/
*BIOS511 L5 S54
Compute the final balance resulting from depositing a given amount (CAPITAL)
for a given number of years (TERM) at a given rate of interest (RATE). 
Assume interest is compounded yearly.;
DATA work.compound; 
SET work.money; 
DO year=1 TO term BY 1; 
interest = capital * rate; 
capital = capital + interest;
END; 
DROP year interest; 
RUN;

*BIOS511 L5 S59 
Create a dataset without input data;

data one; 
do var1 = 1 to 8 by 2, 10, 40, 50;
var2 = sqrt(var1); 
output; *output statement important;
end; 
run;

*example BIOS511 L5 S63;
DATA double; 
SET compound; 
total = capital; term = 0; 
DO WHILE(total < (capital*2)); 
total = total + (total*rate);
term = term + 1; 
END; 
RUN;

/*********************************************
ARRAYS
-> Transposing
*********************************************/
*BIOS511 L5 S71;
*example: Convert the homework scores HW1-HW3 from a 10-point scale to a 100-point scale.;
DATA newhw; 
SET oldhw; 
DROP i;
ARRAY homework{3} hw1 hw2 hw3; 
DO I = 1 TO 3; homework{i} = homework{i} * 10; 
END; 
RUN;



/*********************************************
ODS Styles and Outputs
*********************************************/
*BIOS511 L2 S12;

*HTML;
ODS HTML FILE="weight_club.html" STYLE=sasweb; 
*other common style options include: ANALYSIS, MEADOW, DTREE, JOURNAL2;
PROC PRINT DATA=weight_club;
WHERE team = 'yellow';
TITLE 'The Yellow Team';
RUN;
ODS HTML CLOSE;

*PDF;
ODS PDF FILE="weight_club.pdf" STYLE=journal;
PROC PRINT DATA=weight_club;
WHERE team = 'yellow';
TITLE 'The Yellow Team';
RUN;
ODS PDF CLOSE;

*RTF;
ODS RTF FILE="weight_club.rtf" STYLE=ANALYSIS;
PROC PRINT DATA=weight_club;
WHERE team = 'yellow';
TITLE 'The Yellow Team';
RUN;
ODS RTF CLOSE;

