/*****************************************************************************
* Project           : BIOS 511 Lab 3
*
* Program name      : lab-03-720008261.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-09-11
*
* Purpose           : This program is submitted for Lab 3.
*                      
*
* Revision History  : 1.0
*
* Date          Author   Ref (#)  Revision
* 2018-09-11     LZ       1      Created program for lab.
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

%let root=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 3;

/*********************************************************************
 SAS Code for Task # 1
*********************************************************************/
ods html file = "&root/lab-03-720008261.html" style=Listing;
*Step 1; 

data work.dm_task1;
	set echo.dm_invnam;
	length AGECAT $5;
	if not missing(age) and age<65 then ageCat = '<65';
	else if age >= 65 then ageCat = '>=65';
	
	if age=. then ageCatn=99;
	else ageCatn = 1 + (AGE>=65);
	run;

*Step 2;
/*proc freq data=dm_task1;
	table age*agecatn*ageCat/list missing nocum nopercent;
	run;*/
	
proc format;
	value $ ARMCD
		"ECHOMAX" = "Intervention"
		"PLACEBO" = "Placebo";	
	run;
	
*Step 3;

title1 "Task 1/Step 4: Two-Way Frequency Analysis of Treatment Group by Age Category";
ods select CrossTabFreqs ChiSq;
proc freq data=dm_task1;
	table AGECAT*ARMCD/CHISQ norow nopercent;
	label AGECAT="Age Category" ARMCD="Treatment Group";
	format ARMCD $ARMCD.;
	run;



/*********************************************************************
 SAS Code for Task # 2
*********************************************************************/
*Step 1;
proc sort data=echo.dm_invnam
	out=Investigators1(keep=COUNTRY SITEID INVNAM) nodupkey;
	by SITEID INVNAM;
	run;

*Step 2;
data Investigators2;
	set Investigators1;
	length FIRSTNAME $30 LASTNAME $30 COUNTRY_LONG $10;
	label FIRSTNAME = "Investigator First Name" LASTNAME="Investigator Last Name" COUNTRY_LONG="Country Name";
	lastName=propcase(scan(INVNAM,1,','));
	firstname=propcase(strip(scan(INVNAM,-1,' ')));
	if COUNTRY="USA" then do; COUNTRY_ORDER=1; COUNTRY_LONG="USA"; end;
	else if COUNTRY="MEX" then do; COUNTRY_ORDER=2; COUNTRY_LONG="Mexico"; end;
	else if COUNTRY="CAN" then do; COUNTRY_ORDER=3; COUNTRY_LONG="Canada"; end;

	run;
	
*Step 3;
proc sort data = Investigators2;
	by COUNTRY_ORDER COUNTRY_LONG;
	run;

*Step 4;
title1 "Task 2/Step 4: Listing of ECHO Trial Investigators";
title2 "Country= #byval(COUNTRY_LONG)";
proc print data=INVESTIGATORS2 noobs label;
	by COUNTRY_ORDER COUNTRY_LONG;
	var SITEID LASTNAME FIRSTNAME;
run;

/*********************************************************************
 SAS Code for Task # 3
*********************************************************************/
*Step 1;
data work.dm_task3;
	set echo.dm_invnam;
	COMMA_SPOT=INDEX(INVNAM,",");
	length FIRSTNAME $30 LASTNAME $30 ICDAY $5 ICMONTH $5 ICYEAR $5 RFICDTC3 $20 RFICDTC4 $20 RFICDTC5 $20 RACECAT $30;
	LASTNAME=propcase(substr(INVNAM,1,COMMA_SPOT-1));
	FIRSTNAME=propcase(substr(INVNAM,COMMA_SPOT+2));
	ICYEAR=scan(RFICDTC,1,'-');
	ICMONTH=scan(RFICDTC,2,'-');
	ICDAY=scan(RFICDTC,3,'-');
	RFICDTC3=trim(ICYEAR)||'-'||trim(ICMONTH)||'-'||trim(ICDAY);
	RFICDTC4=CATS(ICYEAR,'-',ICMONTH,'-',ICDAY);
	RFICDTC5=CATX('-',ICYEAR,ICMONTH,ICDAY);
	
	/*Code for explicit assignment using conditional statements*/
	/*If RACE='WHITE' THEN RACECAT='White';
	Else if RACE="BLACK OR AFRICAN AMERICAN" THEN RACECAT="Black or African American";
	Else RACECAT="Other";*/
	
	If RACE in ('WHITE',"BLACK OR AFRICAN AMERICAN") THEN RACECAT=TRANWRD(PROPCASE(RACE),"Or", "or");
	Else RACECAT="Other";
	drop COMMA_SPOT;
	run;

title1 "Task 3/Step 2: Print Out of Derived Variables for Site 011";
proc print data=work.dm_task3(obs=10) noobs;
	where siteid='011';
	var INVNAM LASTNAME FIRSTNAME RFICDTC ICYEAR ICMONTH ICDAY RFICDTC3 RFICDTC4 RFICDTC5 RACE RACECAT;
	run;

ods html close;