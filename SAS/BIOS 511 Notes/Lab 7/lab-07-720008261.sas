/*****************************************************************************
* Project           : BIOS 511 Lab 7
*
* Program name      : lab-07-720008261.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-10-16
*
* Purpose           : This program is submitted for Lab 7.
*                      
*
* Revision History  : 1.0
*
* Date          Author   Ref (#)  Revision
* 2018-10-16     LZ       1      Created program for lab.
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

%let path=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 7; 
libname echo "&path";

%let route=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab Data\echo;
libname data "&route";

/*********************************************************************
 SAS Code for Task # 1
*********************************************************************/
data work.genotype;
	infile "&path.\echo_genotype.dat" dlm="," firstobs=2;
	length USUBJID $30 SITE 5 SUBJECT 5 GENOTYPE $5 REASON $30;
	input SITE SUBJECT GENOTYPE REASON;
	USUBJID=CATX('-',"ECHO",put(SITE,Z3.),put(SUBJECT,Z3.));
run;




/*********************************************************************
 SAS Code for Task # 2
*********************************************************************/
data work.vs;
	set data.vs;
where VSTESTCD in ("DIABP" "SYSBP") and (VSBLFL="Y" or VISIT="Week 32");
run;

proc sort data=work.vs;
by USUBJID;
run;

proc sort data=work.genotype;
by USUBJID;
run;

proc sort data=data.dm;
by USUBJID;
run;

*Check for missing blood pressure values;
data work.vs2;
	set work.vs;
where VSSTRESN in (.);
run;



proc transpose data=work.vs
	out = work.bp_transpose (drop=_NAME_ _LABEL_ RENAME= (COL1=WEEK0_DBP COL2=WEEK32_DBP COL3=WEEK0_SBP COL4=WEEK32_SBP));
	by USUBJID;
	var VSSTRESN;
run;

data work.bp_transpose2;
	set work.bp_transpose;
	change_dbp=WEEK32_DBP-WEEK0_DBP;
	change_sbp=WEEK32_SBP-WEEK0_SBP;
run;

data work.genotype2;
	format USUBJID SEX GENOTYPE REASON CHANGE_DBP CHANGE_SBP;
	merge work.genotype (in=a keep = USUBJID GENOTYPE REASON) data.dm (in=b keep=USUBJID SEX) work.bp_transpose2 (in=c keep=USUBJID change_dbp change_sbp);
	by USUBJID;
	if (a=1 and b=1 and c=1);
run;




/*********************************************************************
 SAS Code for Task # 3
*********************************************************************/
proc means data=work.genotype2 n maxdec=2 mean stddev median min max nway;
	title "Summary of Change from Baseline in Systolic and Diastolic Blood Pressure by Genotype";
	class Genotype/missing;
	output out=work.results(drop=_freq_ _type_) n=n mean=dbp sbp;
	label change_sbp="Systolic Blood Pressure Difference (0 Weeks - 32 Weeks)" change_dbp="Diastolic Blood Pressure Difference (0 Weeks - 32 Weeks)";
run;




/*********************************************************************
 SAS Code for Task # 4
*********************************************************************/
proc export data=work.genotype2
file="&path./ECHO_GENOTYPE.xlsx"
DBMS=xlsx REPLACE;
Sheet="ECHO";

run;


/*********************************************************************
 SAS Code for Task # 5
*********************************************************************/

data _null_;
	set work.results;
	if GENOTYPE in ("") then do;
		GENOTYPE = "U";
	end;
	file "&path./ECHO_GENOTYPE.csv" dlm =",";
	if _n_ eq 1 then
	put @1 "Genotype,n,dbp,sbp";
	put (_all_) (+0);
run;
	