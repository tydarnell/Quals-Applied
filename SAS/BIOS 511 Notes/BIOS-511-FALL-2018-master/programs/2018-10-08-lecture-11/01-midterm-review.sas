/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : 01-midterm-review.sas
*
* Author            : Matthew A. Psioda
*
* Date created      : 2018-10-08
*
* Purpose           : This program is designed to provide practice for the midterm
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

%let root     = C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511; 
%let dataPath = &root.\Lab Data\echo;
libname echo "&dataPath";


/*********** practice question #1 ********************
   What was the mean change from baseline in heart rate
   at week 32 for each of the two echo trial treatment groups?
 *****************************************************/
 proc print data = echo.vs(obs=12 where=(vstestcd='HR') drop=STUDYID VSTEST VSSTAT VSREASND) noobs; run;

*VSBLFL = Vital Sign Base Line FLag (Flag is Yes or No);

*Week 0 is the baseline (the last measurement taken before you are given the drug);
*The screening visit is typically used to determine eligibility;

proc transpose data=echo.vs out=vs2(drop=_NAME_ _LABEL_) prefix=vis_;
where vstestcd = 'HR';
by USUBJID; *One observation per USUBJID;
id VISITNUM; /*The variables that will define the new column names 
(if the values of this variable aren't valid variable names, SAS will automatically adjust them)*/
var vsstresn; /* The values of this variable will become the values in your new columns*/
run;

/*Then DATA step to calculate the mean you want. Have to merge with the echo.dm dataset to get
the treatment ARMCD.*/
/*PROC TRANSPOSE is just for rearranging
rows to columns or vice-versa. PROC MEANS will only operate on columns that already exist.*/





/*********** practice question #1 ******************************
   Of the subjects who experienced at least one adverse event, 
   what was the average duration of time from the start
   of treatment to their first post-treatment adverse event?
 ***************************************************************/
 proc print data = echo.dm(where=(usubjid='ECHO-011-005') drop=STUDYID DMDTC VIS: RFIC: SEX RACE COUNTRY AGE) noobs label; run;
 proc print data = echo.ae(where=(usubjid='ECHO-011-005') drop=STUDYID AESOC AESEV AESER) noobs label; run;
 
 /* INPUT function to convert dates in character format to numeric format
