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
option mergenoby=error nodate nonumber;

*Nobyline option not included to get an informative title before each new BY group;

ods noproctitle;

%let root=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 13;
%let dataPath= &root./data;
%let outputPath=&root./output;
%let path=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511;
%let labdat=&path./Lab Data/echo;

libname echo "&labdat.";

libname out "&outputPath.";

/*********************************************************************
 						      SAS Code
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



*It is not necessary to put the COUNTRY condition in the WHERE statement 
since both datasets only contain observations from Canada, USA, or Mexico, anyway.
However, I added the condition for technical completeness.;

proc sql noprint;
	create table work.subjects(drop=u) as
	select dm.*, ranges.*
	from echo.dm, work.ranges(rename=(country=u))
	where ranges.site_number=input(substr(scan(dm.USUBJID,2,"-"),2,2),2.) AND 
	(input(dm.RFICDTC,yymmdd10.) >= ranges.Start_Date AND input(dm.RFICDTC,yymmdd10.) <= ranges.End_Date) AND
	dm.country=ranges.u
	order by USUBJID, Site_Number;
quit;

*Creating GEN_REPORT macro;
%macro GEN_REPORT;
  %do j = 1 %to &NUMSITES.;
	data work.temp;
		set work.subjects;
		where site_number=&&SITE&J;
		call SYMPUT("SITE",strip("0"||strip(&&SITE&J)));
		call SYMPUT("COUNTRY",strip(COUNTRY));
	run;
   
   proc sql noprint;
		create table work.temp2(drop=Sub_ID) as
		select temp.USUBJID, temp.SITE_NUMBER, temp.COUNTRY, vs.*
		from work.temp, echo.vs(rename=(USUBJID=Sub_ID))
		where temp.USUBJID=vs.Sub_ID
		order by USUBJID, VISITNUM, VISIT;
   quit;
   
   proc transpose data=work.temp2
		out=work.temp3(drop=_NAME_ _LABEL_ VISITNUM);
		by USUBJID VISITNUM VISIT;
			id vstestcd;
			idlabel vstest;
			var vsstresn;
	run;
	

*Reorder variables for a (in my opinion) more natural viewing order. Changed value of USUBJID to
just have the three digit subject ID (for bylines). Also changed variable label for USUBJID
 for bylines.;
  
  	data work.temp3;
		retain USUBJID VISIT SYSBP DIABP HR HEIGHT WEIGHT;
		set work.temp3;
		label USUBJID = "Subject Number";
		USUBJID = scan(USUBJID,3,"-");
	run;
	
	ods pdf file="&outputPath./&COUNTRY._&SITE._VITAL_SIGNS.pdf" startpage=no style=journal;
		title bold "Site &SITE. Vital Sign Data for Select Subjects";
		proc print data=work.temp3 noobs split="*";
			by USUBJID;
			label VISIT="Visit*Name"
				  SYSBP="Systolic Blood*Pressure (mmHg)"
				  DIABP="Diastolic Blood*Pressure (mmHg)"
				  HR="Heart Rate*(Beats/Min)"
				  HEIGHT="Height (cm)"
				  WEIGHT="Weight (kg)";
		
		run;
	ods pdf close;
  
  %end;
%mend;

%GEN_REPORT;
