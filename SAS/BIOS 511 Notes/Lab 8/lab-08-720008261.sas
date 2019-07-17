/*****************************************************************************
* Project           : BIOS 511 Lab 8
*
* Program name      : lab-08-720008261.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-10-23
*
* Purpose           : This program is submitted for Lab 8.
*                      
*
* Revision History  : 1.0
*
* Date          Author   Ref (#)  Revision
* 2018-10-23     LZ       1      Created program for lab.
*                                  
*
*
* searchable reference phrase: *** [#] ***;
*
* Note: Standard header taken from :
*  https://www.phusewiki.org/wiki/index.php?title=Program_Header
******************************************************************************/
option mergenoby=error nodate nonumber nobyline;

ods noproctitle;

/*Initializing Libraries*/

%let path=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab Data\echo; 
libname echo "&path";

/*Create a macro variable for more efficient path names*/

%let root=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 8;

/*********************************************************************
 						SAS Code for Task # 1 / Step #1
**********************************************************************/
ods pdf file = "&root/lab-08-720008261.pdf";



title1 "Task 1 - Step 1: Number of Subjects by Treatment Group";
proc sgplot data=echo.dm;
vbar armcd;
run;

/*********************************************************************
 						SAS Code for Task # 1 / Step #2
**********************************************************************/

title1 "Task 1 - Step 2: Number of Subjects by Treatment Group";
proc sgplot data=echo.dm;
vbar armcd / fillattrs=(color=lightRed) transparency=0.5;
run;

/*********************************************************************
 						SAS Code for Task # 1 / Step #3
**********************************************************************/

title1 "Task 1 - Step 3: Number of Subjects by Treatment Group";
proc sgplot data=echo.dm;
vbar armcd / fillattrs=(color=lightRed) dataskin=pressed;
run;

/*********************************************************************
 						SAS Code for Task # 1 / Step #4
**********************************************************************/
title1 "Task 1 - Step 4: Number of Subjects by Treatment Group";
proc sgplot data=echo.dm;
vbar armcd / fillattrs=(color=lightRed) dataskin=pressed stat=percent;
xaxis label = "Treatment Group" grid;
yaxis label = "Percentage of Total Subjects Enrolled" grid;
run;

/*********************************************************************
 						SAS Code for Task # 1 / Step #5
**********************************************************************/
ods pdf nogtitle; *<destination> is something like html, pdf, etc.; 

title1 "Task 1 - Step 5: Number of Subjects by Treatment Group";
proc sgplot data=echo.dm;
vbar armcd / fillattrs=(color=lightRed) dataskin=pressed stat=percent;
xaxis label = "Treatment Group" grid;
yaxis label = "Percentage of Total Subjects Enrolled" grid;
run;

ods pdf gtitle;


/*********************************************************************
 						SAS Code for Task # 2 / Step #1
**********************************************************************/
title1 "Task 2 - Step 1: Number of Subjects by Sex and Treatment Group";
proc sgplot data=echo.DM;
vbar sex / group=armcd stat=percent;
label armcd = "Treatment Group";
keylegend / position=right;
run;

/*********************************************************************
 						SAS Code for Task # 2 / Step #2
**********************************************************************/

title1 "Task 2 - Step 2: Number of Subjects by Sex and Treatment Group";
proc sgplot data=echo.DM;
vbar sex / group =armcd groupdisplay=cluster stat=percent;
label armcd = "Treatment Group";
run;


/*********************************************************************
 						SAS Code for Task # 3
**********************************************************************/

data work.dm;
	set echo.dm;
	where COUNTRY="USA";
run;

proc transpose data=echo.vs
	out=work.vs_tr (drop=_NAME_ _LABEL_);
by usubjid;
where VISIT="Screening";
	id VSTESTCD;
	idlabel VSTEST;
	var VSSTRESN;
run;

proc sort data=work.dm;
by USUBJID;
run;

proc sort data=work.vs_tr;
by USUBJID;
run;

data work.dm_usa;
	merge work.dm (keep=USUBJID ARMCD SEX AGE in=A) work.vs_tr (in=B);
	by USUBJID;
	if (A and B);
	BMI = (WEIGHT)/(HEIGHT/100)**2;
	format BMI 6.2;
run;



/*********************************************************************
 						SAS Code for Task # 4 / Step #1
**********************************************************************/
title1 "Task 4 - Step 1: Scatter plot of Height by Body Mass Index";
proc sgplot data=dm_usa;
scatter x=height y=BMI;
xaxis label="Height (cm)";
run;

/*********************************************************************
 						SAS Code for Task # 4 / Step #2
**********************************************************************/
title1 "Task 4 - Step 2: Scatter plot of Height by Body Mass Index";
proc sgplot data=dm_usa;
scatter x=height y=BMI / markerattrs=(symbol=circleFilled color=darkBlue);
xaxis label = "Height (cm)" values=(150 to 210 by 10);
yaxis values=(5 to 35 by 5);
run;

/*********************************************************************
 						SAS Code for Task # 4 / Step #3
**********************************************************************/
proc format;
value $gend
"M"="Male"
"F"="Female";
run;


title1 "Task 4 - Step 3: Scatter plot of Height by Body Mass Index";
proc sgplot data=dm_usa;
format sex $gend.;
scatter x=height y=BMI / markerattrs=(symbol=circleFilled) group=sex;
xaxis label="Height (cm)" values=(150 to 210 by 10);
yaxis values=(5 to 35 by 5);
run; 



/*********************************************************************
 						SAS Code for Task # 5 / Step #1
**********************************************************************/
title1 "Task 5 - Step 1: Scatter plot of Height by Body Mass Index";
proc sgplot data=dm_usa;
scatter x=height y=BMI;
run;

/*********************************************************************
 						SAS Code for Task # 5 / Step #2
**********************************************************************/
ods graphics / height=4in width=4in noborder;
title1 "Task 5 - Step 2: Scatter plot of Height by Body Mass Index";
proc sgplot data=dm_usa;
scatter x=height y=BMI;
run;
ods graphics / reset = all;

/*********************************************************************
 						SAS Code for Task # 6
**********************************************************************/
proc format;
value $ trt
"ECHOMAX" = "Investigational Treatment"
"PLACEBO" = "Placebo";
run;

proc sort data=dm_usa out=dm_usa2;
by armcd;
run;

option nobyline;
title1 "Task 6: Scatter plot of Height by Body Mass Index";
title2 "Treatment Group = #byval(armcd)";
proc sgplot data=dm_usa2 noautolegend;
by armcd;
format armcd $trt.;
reg x=height y=BMI / markerattrs=(size=4 symbol=diamondFilled color=Blue)
					lineattrs=(pattern=2 thickness=2 color=darkRed);
run;
option byline;

ods pdf close;