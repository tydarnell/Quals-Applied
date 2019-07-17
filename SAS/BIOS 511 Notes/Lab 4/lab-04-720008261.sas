/*****************************************************************************
* Project           : BIOS 511 Lab 4
*
* Program name      : lab-04-720008261.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-09-18
*
* Purpose           : This program is submitted for Lab 4.
*                      
*
* Revision History  : 1.0
*
* Date          Author   Ref (#)  Revision
* 2018-09-18     LZ       1      Created program for lab.
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

%let path=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab Data\echo; 
libname echo "&path";

/*Create a macro variable for more efficient path names*/

%let root=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 4;

/********************************************************************************************************
 									SAS Code for Task #1
*********************************************************************************************************/
ods html file = "&root/lab-04-720008261.html" style=journal;

ods select Position;
proc contents data=echo.ae VARNUM;
title1 "Task 1: Variables in the AE Dataset";
run;


/********************************************************************************************************
 									SAS Code for Task #2
*********************************************************************************************************/
**Sort Echo DM dataset;

proc sort data=echo.dm out=work.dm_sorted;
	by USUBJID;
run;

proc print data=work.dm_sorted(obs=5) noobs;
title1 "Task 2/Part 1: First 5 Observations in DM Dataset";
run;

**Sort Echo AE dataset;

proc sort data=echo.ae out=work.ae_sorted;
	by USUBJID;
run;

proc print data=work.ae_sorted(obs=5) noobs;
title1 "Task 2/Part 1: First 5 Observations in AE Dataset";
run;


/********************************************************************************************************
 									SAS Code for Task #3
*********************************************************************************************************/
data work.AE2;
merge work.DM_sorted(keep=usubjid armcd sex race country rfxstdtc rfxendtc)
	  work.AE_sorted;
by usubjid;
	if (aeterm>"");
	drop studyid;
run;

proc print data=work.AE2(obs=15) noobs;
title1 "Task 3/Part 1: First 15 Observations in AE2 Dataset";
run;

data work.AEDM;
merge work.DM_sorted(keep=usubjid armcd sex race country rfxstdtc rfxendtc)
	  work.AE_sorted;
by usubjid;
	/*if (aeterm>"");
	drop studyid;*/
run;

proc print data=work.AEDM(obs=15) noobs;
title1 "Task 3/Part 2: First 15 Observations in AEDM Dataset";
run;

/********************************************************************************************************
 									SAS Code for Task #4
*********************************************************************************************************/
data work.teae;
	set work.ae2;
	length AESTYR $4 AESTMN $2 AESTDY $2;
	AESTYR=scan(AESTDTC,1,'-');
	AESTMN=scan(AESTDTC,2,'-');
	AESTDY=scan(AESTDTC,3,'-');
	if AESTDY="" then AESTDY='28';
	AESTDTI=MDY(AESTMN,AESTDY,AESTYR);
	TRTSYR=scan(RFXSTDTC,1,'-');
	TRTSMN=scan(RFXSTDTC,2,'-');
	TRTSDY=scan(RFXSTDTC,3,'-');
	if TRTSDY="" then TRTSDY='28';
	TRTSTDTN=MDY(TRTSMN,TRTSDY,TRTSYR);
	format AESTDTI TRTSTDTN date9.;
	if AESTDTI-TRTSTDTN>=0 then TEAEFN=1;
	else TEAEFN=0;
	drop AESTYR AESTMN AESTDY TRTSYR TRTSMN TRTSDY;
	label AESTDTI="Imputed AE Onset Date (Numeric)" TRTSTDTN="Treatment Start Date (Numeric)";
run;

	
/********************************************************************************************************
 									SAS Code for Task #5
*********************************************************************************************************/
proc print data=work.teae noobs label;
	where TEAEFN=1 AND count(AESTDTC,'-')<2 AND count(AESOC,'Infections and infestations','i')=1;	 
var USUBJID AETERM AEDECOD AESTDTC AESTDTI TRTSTDTN;
title1 "Task 5: Listing of Treatment-Emergent Adverse Events with Date Imputation and System Organ Class = Infections and Infestations";
run;

ods html close;