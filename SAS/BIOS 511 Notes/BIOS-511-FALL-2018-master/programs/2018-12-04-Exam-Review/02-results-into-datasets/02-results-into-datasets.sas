/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : 02-results-into-datasets.sas
*
* Author            : Matthew A. Psioda
*
* Date created      : 2018-12-04
*
* Purpose           : This program demonstrates converting results into SAS datasets;
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 
*
*
* searchable reference phrase: *** [#] ***;
******************************************************************************/
option mergenoby=error nodate nonumber nobyline;
ods noproctitle;
title;
footnote;

%let root      = C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511; 
%let dataPath  = &root./Lab Data/echo;                                    
%let outPath   = &root./BIOS-511-FALL-2018-master/programs/2018-12-04-exam-review/02-results-into-datasets;        

libname echo "&dataPath";       



/*
	PROC FREQ 
		[1] Use the OUT option (in the TABLE statement);
		[2] Use ODS statement to direct output object to a dataset;

	PROC MEANS/UNIVARIATE 
		[1] Use the OUTPUT statement;
		[2] Use ODS statement to direct output object to a dataset;
		
		The ODS statement is more general and applicable to any SAS procedure that creates output.
		
	A lot of the other SAS procedures (ex: PROC REG) have their own syntax to produce datasets from their output.
*/




/*ods html close;*/
/*ods html newfile=none;*/

** Example 1 ****************************************************;
title "Example 1";
proc freq data = echo.DM;
 table country*armcd;
run;

** Example 2 ****************************************************;
title "Example 2";
ods select none; /*Excludes objects from the output. This is what you put to not print any of the other results 
out to the Results window. If you use the ODS output method, you cannot use the "noprint" option for the PROC
statement (since "noprint" prevents the objects from being created in the first place.)
*/
ods output CrossTabFreqs = DS1 ChiSq = CST; /* This syntax is not specific to any procedure. It is part of the 
ODS suite. If you don't know the name of the objects (like CrossTabFreqs or ChiSq), you can Google the name of
objects produced by SAS procedures or use ODS TRACE */
proc freq data = echo.DM;
 table country*armcd / chisq; /* The chisq option created another object that can be put into its own dataset.*/
run;

ods select all;
proc print data = DS1; run;
proc print data = CST; run;

** Example 3 ****************************************************;
title "Example 3";
proc freq data = echo.DM noprint; /* Using the built-in OUT = option in PROC FREQ, you can use the noprint option.
*/
 table country*armcd / out = DS2 outpct; /* "outpct" is an option that increases the amount of information 
 produced in the output dataset. There are others that you will have to look up in the documentation.*/
run;
proc print data = DS2; run;

/* Generally, the built-in dataset output option produces something more user-friendly, but it also generally
gives just a subset of the total information. Sometimes, you will need to use ODS output to get the information
you need (or need to manipulate in a DATA step.) */


** Example 4 ****************************************************;
title "Example 4";
proc means data = echo.DM;
 class country armcd;
 var age;
run;

** Example 5 ****************************************************;
title "Example 5";
ods select none;
ods output Summary = DS1;
proc means data = echo.DM;
 class country armcd;
 var age;
run;
ods select all;
proc print data = DS1; run;

** Example 6 ****************************************************;
title "Example 6";
ods select none;
ods output BasicMeasures = DS2;
proc univariate data = echo.DM;
 class country armcd;
 var age;
run;
ods select all;
proc print data = DS2; run;



data temp;
 set echo.DM;
  dur = input(rfxendtc,yymmdd10.)-input(rfxstdtc,yymmdd10.)+1;
run;



** Example 7 ****************************************************;
/*Examples below with the OUTPUT statement also more-or-less apply to PROC UNIVARIATE. */


title "Example 7";
proc means data = temp noprint /*nway*/; /* nway option is important/useful. Since our CLASS variables
are COUNTRY and ARMCD, having nway on just gives us the output for the different combinations of COUNTRY values
and ARMCD values (without it, for example, we get each value of COUNTRY by itself and each value of ARMCD by
itself.) */
 class country armcd;
 var age dur;
 output out = DS3 n(dur)=dur mean=mean_age mean_dur std=std_age atd_dur;
/* n, mean, and std are the summary statistics you computed. You are then assigning the calculated value
to a variable. Since we have two VAR variables (age and dur), there are values of n, mean, and std calculated
for each VAR variable. With n(dur) = dur, we are saying that we only want the number of non-missing values for 
the dur variable stored in a variable called "dur" in our new dataset. For the mean, we want the means of the two
VAR variables stored in mean_age and mean_dur (we name them in this order because that is how we ordered
them in the VAR statement). Same with the std. The order they are assigned from the summary statistics is the
same as the order of the variables in the VAR statement. */ 
 
run;
proc print data = DS3; run;

** Example 8 ****************************************************;
title "Example 8";
proc means data = temp noprint;
 class country armcd;
 var age dur;
 output out = DS4 n(dur)= mean= / autoname; /* SAS will create generally intuitive variable names for you.
 However, PROC UNIVARIATE does not have the autoname option. */
run;
proc print data = DS4; run;

** Example 9 ****************************************************;
title "Example 9";
proc means data = temp noprint;
 class country armcd;
 var age dur;
 output out = DS5; /* Didn't specify which statistics you wanted in the output or the names of the variables 
 you wanted the statistics put into. Output dataset is in long format instead of wide format. */
run;
proc print data = DS5; run;
