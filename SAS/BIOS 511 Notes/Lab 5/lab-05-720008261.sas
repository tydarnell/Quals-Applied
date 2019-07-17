/*****************************************************************************
* Project           : BIOS 511 Lab 5
*
* Program name      : lab-05-720008261.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-09-25
*
* Purpose           : This program is submitted for Lab 5.
*                      
*
* Revision History  : 1.0
*
* Date          Author   Ref (#)  Revision
* 2018-09-25     LZ       1      Created program for lab.
*                                  
*
*
* searchable reference phrase: *** [#] ***;
*
* Note: Standard header taken from :
*  https://www.phusewiki.org/wiki/index.php?title=Program_Header
******************************************************************************/
option mergenoby=nowarn nodate nonumber nobyline;

ods noproctitle;

/*Initializing Echo library*/

%let path=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 3; 
libname echo "&path";

/*Create a macro variable for more efficient path names*/

%let root=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 5;

/*********************************************************************
 SAS Code for Task #1
*********************************************************************/
ods html file = "&root/lab-05-720008261.html" style=journal;

*Step 1;

proc format;
	value AGECAT
	LOW -<50 = "1:<50"
	50 -<65 = "2: 50 to <65"
	65 - HIGH = "3: >= 65"
	. = "4: Missing";
	run;

*Step 2;
data work.dm1;
	set echo.dm_invnam;
	format AGE AGECAT.;
	length AGECATEGORY $15;
	AGECATEGORY=put(AGE,AGECAT.);
	label AGECATEGORY="Age Category";
	run;
	
*proc contents data=work.dm1;
	*run;

*Step 3;


title1 "Task 1/Step 3: One-Way Analysis of Age Categories (Using Formatted AGE Variable)";
proc freq data=work.dm1;
	table AGE;
	label AGE="Age Category";
	run;

*Step 4;

title1 "Task 1/Step 4: One-Way Analysis of Age Categories (Using AGECATEGORY Variable)";
proc freq data=work.dm1;
	table AGECATEGORY;
	run;




/*********************************************************************
 SAS Code for Task #2
*********************************************************************/
*Step 1;

proc format;
	invalue sexn
	"M"=1
	"F"=2
	OTHER=.;
	run;
	
*Step 2 and 3;
data work.dm2;
	set work.dm1;
	sexnum=input(sex,sexn.);
	TRTSTDTN=input(rfxstdtc,yymmdd10.);
	TRTENDTN=input(rfxendtc,yymmdd10.);
	TRTDUR=((TRTENDTN-TRTSTDTN)+1)/7;
	format TRTSTDTN TRTENDTN date9.;
	run;

*proc print data= work.dm2;
*run;

*Step 4;
proc means data=work.dm2 noprint N MEAN Max Min Std;
	output out=work.trtdur_summary N=N MEAN=Mean Max=Max Min=Min Std=Std;
	var TRTDUR;
	class AGECATEGORY ARMCD; ways 1;
run;

*Step 5;
title1 "Task 2/Part 5: Summary of Treatment Duration by Treatment Group";
proc print data=work.trtdur_summary noobs split=" ";
	var ARMCD N Min Max MEAN Std;
	label ARMCD= "Treatment Group" N="Sample Size" MEAN="Mean" Max="Maximum" Min="Minimum" Std="Standard Deviation";
	format MEAN Max Min 6.2 Std 7.3;
	where ARMCD not in ("");
	run;

title1 "Task 2/Part 5: Summary of Treatment Duration by Age Category";
proc print data=work.trtdur_summary noobs split=" ";
	var AGECATEGORY N Min Max MEAN Std;
	label N="Sample Size" MEAN="Mean" Max="Maximum" Min="Minimum" Std="Standard Deviation";
	format MEAN Max Min 6.2 Std 7.3;
	where AGECATEGORY not in ("");
	run;
	
ods html close;


