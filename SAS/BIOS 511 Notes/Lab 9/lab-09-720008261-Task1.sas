/*****************************************************************************
* Project           : BIOS 511 Lab 9-Task 1
*
* Program name      : lab-09-720008261-Task1.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-10-30
*
* Purpose           : This program is submitted for Lab 9, Task 1.
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

proc sort data=echo.dm;
	by USUBJID;
run;

proc sort data=lab.lb;
	by USUBJID;
run;

data work.ADLB;
	merge lab.lb (in=a) echo.dm;
	by USUBJID;
run;

proc sort data=work.ADLB;
	by USUBJID LBTESTCD LBTEST VISITNUM VISIT LBDTC;
run;

*Temporary dataset with LBSEQ and LBNRIND created;

data work.ADLB2;
	set work.ADLB;
	by USUBJID;
	length LBSEQ 8 LBNRIND $5;
	label LBSEQ="Sequence Number" LBNRIND="Reference Range Indicator";
	retain LBSEQ;
if FIRST.USUBJID then LBSEQ=0;
	LBSEQ=LBSEQ+1;
if LBTEST ="Hematocrit" and SEX="M" then do;
	if LBSTRESN < 0.388 then LBNRIND = "L";
	if LBSTRESN > 0.500 then LBNRIND = "H";
	if LBSTRESN >=0.388 and LBSTRESN <=0.500 then LBNRIND = "N";
	if LBSTRESN =. then LBNRIND = "";
end;
if LBTEST ="Hematocrit" and SEX="F" then do;
	if LBSTRESN < 0.349 then LBNRIND = "L";
	if LBSTRESN > 0.445 then LBNRIND = "H";
	if LBSTRESN >=0.349 and LBSTRESN <=0.445 then LBNRIND = "N";
	if LBSTRESN =. then LBNRIND = "";
end;
if LBTEST ="Calcium" then do;
	if LBSTRESN < 2.1 then LBNRIND = "L";
	if LBSTRESN > 2.7 then LBNRIND = "H";
	if LBSTRESN >=2.1 and LBSTRESN <=2.7 then LBNRIND = "N";
	if LBSTRESN =. then LBNRIND = "";
end;
if LBTEST ="Albumin" then do;
	if LBSTRESN < 35 then LBNRIND = "L";
	if LBSTRESN > 55 then LBNRIND = "H";
	if LBSTRESN >=35 and LBSTRESN <=55 then LBNRIND = "N";
	if LBSTRESN =. then LBNRIND = "";
end;
run;


proc sort data=work.ADLB2;
	by USUBJID LBTESTCD LBDTC;
run;

*Temporary dataset with LBBLFL created;
data work.ADLB3;
	set work.ADLB2;
	by USUBJID LBTESTCD;
	length LBBLFL $1;
	label LBBLFL = "Baseline Flag";
	where input(LBDTC,yymmdd10.)<=input(rfxstdtc,yymmdd10.) and not missing(LBSTRESN);
	if last.LBTESTCD then LBBLFL="Y";
run;

*Merged back into original dataset;

data work.ADLB4;
	merge work.ADLB3 work.ADLB2;
	by USUBJID LBTESTCD LBDTC;
run;

proc sort data=work.ADLB4;
	by USUBJID LBTEST descending LBBLFL;
run;

*Creating temporary dataset with BASE, BASECAT, CHANGE, and PCT_CHANGE variables;

data work.ADLB5;
	set work.ADLB4;
	by USUBJID LBTEST descending LBBLFL;
	length BASE 8 BASECAT $1 CHANGE 8 PCT_CHANGE 8;
	label BASE="Baseline Lab Test Value" BASECAT="Baseline Reference Range Indicator" 
	CHANGE="Change from Baseline" PCT_CHANGE="Percent Change from Baseline";
	retain BASE BASECAT;
	if first.LBTEST then do;
	BASE=LBSTRESN;
	BASECAT=LBNRIND;
	end;
	CHANGE=LBSTRESN-BASE;
	PCT_CHANGE=(LBSTRESN-BASE)/BASE*100;
	format BASE 6.3 CHANGE 7.3 PCT_CHANGE 8.4;
	run;

proc sort data=work.ADLB5;
	by USUBJID LBTEST VISIT;
run;

*Create permanent ADLB dataset with variables in order specified; 
data lab.ADLB;
	retain STUDYID USUBJID AGE SEX RACE COUNTRY ARMCD ARM LBSEQ LBTESTCD LBTEST LBCAT 
	LBSTRESN LBSTRESU LBNRIND LBSTAT LBREASND LBBLFL BASE BASECAT CHANGE PCT_CHANGE
	VISITNUM VISIT LBDTC;
	set work.ADLB5;
	keep STUDYID USUBJID AGE SEX RACE COUNTRY ARMCD ARM LBSEQ LBTESTCD LBTEST LBCAT 
	LBSTRESN LBSTRESU LBNRIND LBSTAT LBREASND LBBLFL BASE BASECAT CHANGE PCT_CHANGE
	VISITNUM VISIT LBDTC;
	run;
	