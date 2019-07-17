/*****************************************************************************
* Project           : BIOS 511 Lab 13
*
* Program name      : lab-13-720008261.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-11-27
*
* Purpose           : This program is submitted for Lab 13
*                      
*
* Revision History  : 1.0
*
* Date          Author   Ref (#)  Revision
* 2018-11-27     LZ       1      Created program for lab.
*                                  
*
*
* searchable reference phrase: *** [#] ***;
*
* Note: Standard header taken from :
*  https://www.phusewiki.org/wiki/index.php?title=Program_Header
******************************************************************************/
option mergenoby=error nodate nonumber nobyline mprint symbolgen mlogic;

ods noproctitle;

%let root=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511;
%let dataPath= &root./Lab 13/data;
%let outputPath=&root./Lab 13/output;
%let labdat=&root./Lab Data/echo;

libname echo "&labdat.";

libname out "&outputPath.";

/*********************************************************************
 						SAS Code for Task # 1
**********************************************************************/

data ranges;
	infile "&dataPath./qc_dates.csv" dlm="," firstobs=4;
	informat Start_Date End_Date date9.;
	input COUNTRY $ Site_Number Start_Date End_Date QC_Period;
	format Start_Date End_Date ddmmyy10.;
run;	

proc sort data=ranges;
	by Site_Number;
run;

proc print data=ranges;
run;


data _null_;
	set ranges;
	by Site_Number;
	retain Count 0;
	if first.Site_Number then do;
	COUNT=COUNT+1;
	call symput("SITE"||strip(put(COUNT,best.)),strip(put(Site_Number,best.)));
	end;
	call symput("NUMSITES",strip(put(COUNT,best.)));
run;
	
%put &=NUMSITES;

data work.dm;
	set echo.dm;
	Site_Number=input(substr(scan(USUBJID,2,"-"),2,2),2.);
run;

proc sort data=dm;
	by Site_Number;
run;

data ranges2;
	set work.ranges;
	by Site_Number;
	retain Start_Date2 End_Date2 QC_Period2;
	array mod {*} Start_Date2 End_Date2 QC_Period2;
	if QC_Period=1 then do;
		do i=1 to dim(mod);
			mod[1]=Start_Date;
			mod[2]=End_Date;
			mod[3]=QC_Period;
		end;
	end;
	format Start_Date2 End_Date2 ddmmyy10.;
	if last.site_number;
	drop i;
run;
	
proc contents data=dm;
run;

data subjects;
	merge work.dm work.ranges2;
	by Site_Number;
	Consent_Date=input(RFICDTC,yymmdd10.);
run;

proc contents data=subjects;
run;

data subjects;
	set subjects;
	where (Consent_Date>=Start_Date and Consent_Date<=End_Date) or (Consent_Date>=Start_Date2 and Consent_Date<=End_Date2);
run;

