/*****************************************************************************
* Project           : BIOS 511 Lab 2
*
* Program name      : lab-02-720008261.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-09-04
*
* Purpose           : This program is submitted for Lab 2.
*                      
*
* Revision History  : 1.0
*
* Date          Author   Ref (#)  Revision
* 2018-09-04     LZ       1      Created program for lab.
*                                  
*
*
* searchable reference phrase: *** [#] ***;
*
* Note: Standard header taken from :
*  https://www.phusewiki.org/wiki/index.php?title=Program_Header
******************************************************************************/
option mergenoby=nowarn nodate nonumber;

ods noproctitle;

footnote "ECHO Data Extract Date: 2017-10-10";

/*Initializing Echo library*/

%let path=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab Data\echo; 
libname echo "&path";

/*Create a macro variable for more efficient path names*/

%let root=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 2;

/********************************************************************************************************
 									SAS Code for Task #1
*********************************************************************************************************/
ods pdf file = "&root/lab-02-720008261.pdf";

proc print data=echo.dm (obs=10) noobs label;
	var USUBJID RFXSTDTC AGE SEX RACE ARMCD ARM COUNTRY;
	title1 "Task1: Demographics Data for Select ECHO Trial Subjects";
run;
/********************************************************************************************************
 									SAS Code for Task #2
*********************************************************************************************************/
proc freq data = echo.dm;
	table ARM / nocum;
	title1 "Task2: Number and Percent of ECHO Trial Subjects by Treatment Group";
run;
/********************************************************************************************************
 									SAS Code for Task #3
*********************************************************************************************************/
proc freq data = echo.dm;
	table COUNTRY*ARM / norow nopercent;
	title1 "Task3: Number and Percent of ECHO Trial Subjects by Treatment Group and Country";
run;
/********************************************************************************************************
 									SAS Code for Task #4
*********************************************************************************************************/
data DM;
	set echo.DM;
	length ageCat $10;
	if not missing(age) and age<65 then ageCat = '1: <65';
	else if age >= 65 then ageCat = '2: >=65';
run;

proc freq data=DM;
	table ageCat*ARM / norow nopercent missprint;
	label ageCat = 'Age Category';
	title1 "Task4: Number and Percent of ECHO Trial Subjects by Treatment Group and Age Category";
run;
/********************************************************************************************************
 									SAS Code for Task #5
*********************************************************************************************************/
proc means data=echo.dm N NMISS MEAN Std Min Max;
	var AGE;
	title1 "Task5: Summary of Age for ECHO Trial Subjects";
run;

/********************************************************************************************************
 									SAS Code for Task #6
*********************************************************************************************************/
proc means data=echo.dm fw=5 N NMISS MEAN Std Min Max;
	var AGE;
	class ARM;
	title1 "Task6: Summary of Age for ECHO Trial Subjects by Treatment Group";
run;
/********************************************************************************************************
 									SAS Code for Task #7
*********************************************************************************************************/
ods select histogram;
proc univariate data = echo.dm;
	class ARMCD;
	var AGE;
	histogram AGE / normal odstitle=" ";
	inset mean std / format=5.2;
	title1 "Task7: Distribution of Age for ECHO Trial Subjects by Treatment Group";
run;
/********************************************************************************************************
 									SAS Code for Task #8
*********************************************************************************************************/
/*See top of program for global footnote statement!*/
ods pdf close;