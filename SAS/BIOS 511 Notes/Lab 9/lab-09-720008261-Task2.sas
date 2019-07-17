/*****************************************************************************
* Project           : BIOS 511 Lab 9-Task2
*
* Program name      : lab-09-720008261-Task2.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-10-30
*
* Purpose           : This program is submitted for Lab 9, Task 2.
*                      
*
* Revision History  : 1.0
*
* Date          Author   Ref (#)  Revision
* 2018-10-30     LZ       1      Created program for lab.
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

%let root=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 9;
libname lab "&root";

/******************************************************************************
						Supporting Code for Mean and 95% CI
******************************************************************************/
*Country = "A" will plot information for all countries;
data input;
	set lab.ADLB;
	output;
	country="A";
	output;
run;

*Creating a VISIT_2 variable to combine all timepoints to be plotted into one variable;
data input2;
	set input;
	where (VISIT in ("Week 16","Week 32") or LBBLFL in ("Y"));
	if LBBLFL="Y" then VISIT_2="Baseline";
	else VISIT_2=VISIT;
run;
	

proc means data=input2 noprint nway alpha=0.05;
	class LBTEST ARMCD COUNTRY VISIT_2;
	var PCT_CHANGE;
	output out = summary(drop=_TYPE_ _FREQ_) n=n mean=mean stddev=sd lclm=lower_cl_mean uclm=upper_cl_mean;
run;

proc format;
 value $countryfmt
  "A" = "Overall"
  "CAN" = "Canada"
  "MEX" = "Mexico"
  "USA" = "United States";
run;


ods pdf file = "&root/lab-09-720008261-output.pdf";

ods graphics / height=4.5 in width=8 in;

*Albumin graph;
title1 "Plot of Percent Change in Albumin by Treatment Group";
title2 "Mean +/- 95% Confidence Interval";
proc sgpanel data=summary;
	where LBTEST="Albumin";
	format COUNTRY $countryfmt.;
	panelby COUNTRY / columns=4 rows=1;
	highlow x=visit_2 low=lower_cl_mean high=upper_cl_mean / group=armcd highcap=serif lowcap=serif groupdisplay=cluster clusterwidth=0.2;
	series x=visit_2 y=mean / group=armcd groupdisplay=cluster clusterwidth=0.2 markers 
	markerattrs=(symbol=circleFilled size=10) lineattrs=(thickness=1);
	rowaxis label = "Percent Change from Baseline";
  	colaxis label = 'Visit Name' type=discrete;
  	colaxistable n / class=armcd;
run;

*Calcium graph;
title1 "Plot of Percent Change in Calcium by Treatment Group";
title2 "Mean +/- 95% Confidence Interval";
proc sgpanel data=summary;
	where LBTEST="Calcium";
	format COUNTRY $countryfmt.;
	panelby COUNTRY / columns=4 rows=1;
	highlow x=visit_2 low=lower_cl_mean high=upper_cl_mean / group=armcd highcap=serif lowcap=serif groupdisplay=cluster clusterwidth=0.2;
	series x=visit_2 y=mean / group=armcd groupdisplay=cluster clusterwidth=0.2 markers 
	markerattrs=(symbol=circleFilled size=10) lineattrs=(thickness=1);
	rowaxis label = "Percent Change from Baseline";
  	colaxis label = 'Visit Name' type=discrete;
  	colaxistable n / class=armcd;
run;

*Hematocrit graph;
title1 "Plot of Percent Change in Hematocrit by Treatment Group";
title2 "Mean +/- 95% Confidence Interval";
proc sgpanel data=summary;
	where LBTEST="Hematocrit";
	format COUNTRY $countryfmt.;
	panelby COUNTRY / columns=4 rows=1;
	highlow x=visit_2 low=lower_cl_mean high=upper_cl_mean / group=armcd highcap=serif lowcap=serif groupdisplay=cluster clusterwidth=0.2;
	series x=visit_2 y=mean / group=armcd groupdisplay=cluster clusterwidth=0.2 markers 
	markerattrs=(symbol=circleFilled size=10) lineattrs=(thickness=1);
	rowaxis label = "Percent Change from Baseline";
  	colaxis label = 'Visit Name' type=discrete;
  	colaxistable n / class=armcd;
run;

ods pdf close;

