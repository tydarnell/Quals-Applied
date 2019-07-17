/*****************************************************************************
* Project           : BIOS 511 Lab 6
*
* Program name      : lab-06-720008261.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-10-02
*
* Purpose           : This program is submitted for Lab 5.
*                      
*
* Revision History  : 1.0
*
* Date          Author   Ref (#)  Revision
* 2018-10-02     LZ       1      Created program for lab.
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

/*Initializing Echo library*/

%let path=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 6; 
libname echo "&path";

/*Create a macro variable for more efficient path names*/

%let root=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 6;

/*********************************************************************
 SAS Code for Task # 1
*********************************************************************/
proc print data=echo.vs;
where USUBJID="ECHO-011-011";
run;



/*********************************************************************
 SAS Code for Task # 2
*********************************************************************/
*Approach 1;
data work.DIABP;
set echo.vs;
where VSTESTCD="DIABP";
rename VSSTRESN=DIABP;
drop VSTEST;
run;

proc sort data=work.DIABP;
by USUBJID;
run;

data work.SYSBP;
set echo.vs;
where VSTESTCD="SYSBP";
rename VSSTRESN=SYSBP;
drop VSTEST;
run;

proc sort data=work.SYSBP;
by USUBJID;
run;

data work.BP1;
merge work.SYSBP work.DIABP;
by USUBJID;
keep USUBJID VISITNUM VISIT SYSBP DIABP;
run;

data work.bp1;
format USUBJID SYSBP DIABP VISITNUM VISIT;
set work.bp1;
run;


*Approach 2;
proc sort data=echo.vs out=work.vs;
by USUBJID VISITNUM VISIT VSTESTCD;
where VSTESTCD in ("SYSBP" "DIABP");
run;

data bp2;
set work.vs;
by USUBJID VISITNUM VISIT VSTESTCD;
retain SYSBP DIABP; 
if FIRST.VISITNUM=1 then do;
SYSBP= .;
DIABP= .;
end; 
if vstestcd='SYSBP' then SYSBP=VSSTRESN;
if vstestcd='DIABP' then DIABP=VSSTRESN;
if LAST.VISITNUM=1;
keep USUBJID VISITNUM VISIT SYSBP DIABP;
run;

/*Every time you get to a new visit, blank out the blood pressure measurements.
If this wasn't there, and a measurement was missing, SAS would put the last assigned value in (because 
it was retained.) This is what the conditional do block does.*/


*Approach 3;
proc sort data=echo.vs out=VS;
by USUBJID VISITNUM VISIT VSTESTCD;
run;

proc transpose data=VS
out=BPS(drop=_NAME_ _LABEL_);
by USUBJID VISITNUM VISIT;
where VSTESTCD in ("SYSBP" "DIABP");
id vstestcd;
idlabel vstest;
var vsstresn;
run;


/*********************************************************************
 SAS Code for Task # 3
*********************************************************************/
data work.vs;
set echo.vs;
where vstestcd in ("SYSBP" "DIABP");
run;

proc sort data=work.vs;
by USUBJID VISITNUM VISIT VSTESTCD;
run;

data echo.BP4;
set work.vs;
by USUBJID VISITNUM VISIT VSTESTCD;
retain DBP_SCR DBP_WK00 DBP_WK08 DBP_WK16 DBP_WK24 DBP_WK32
	   SBP_SCR SBP_WK00 SBP_WK08 SBP_WK16 SBP_WK24 SBP_WK32;
array bp[2,6] DBP_SCR DBP_WK00 DBP_WK08 DBP_WK16 DBP_WK24 DBP_WK32
	          SBP_SCR SBP_WK00 SBP_WK08 SBP_WK16 SBP_WK24 SBP_WK32;

if first.usubjid then do;
	do r=1 to 2;
	do c=1 to 6;
	bp[r,c]=.;
	end;
	end;
end;
if vstestcd="DIABP" then array_row=1;
else if vstestcd="SYSBP" then array_row=2;

if visitnum=-1 then array_col=1;
else if visitnum=1 then array_col=2;
else if visitnum=2 then array_col=3;
else if visitnum=3 then array_col=4;
else if visitnum=4 then array_col=5;
else if visitnum=5 then array_col=6;
bp[array_row,array_col]=vsstresn;
if last.usubjid;
keep usubjid dbp: sbp:;
run;

/*********************************************************************
 SAS Code for Task # 4
*********************************************************************/
data work.bp5;
set echo.vs;
where vstestcd in ("SYSBP" "DIABP");
length ClinVisit $20.;
*Writing variable name for ClinVisit using SAS string functions;
ClinVisit=CATS(substr(scan(VSTEST,1,""),1,1),"",substr(scan(VSTEST,2,""),1,1),"",substr(scan(VSTEST,3,""),1,1),
"_","",compress(UPCASE(substr(VISIT,1,4)),"E"),"",
compress(tranwrd(substr(VISIT,length(VISIT)-1,2)," ","0"),"ng"));

*Writing variable name for ClinVisit using two do blocks;
/*if vstestcd="DIABP" then do;
	if visitnum=-1 then ClinVisit="DBP_SCR";
	else if visitnum=1 then ClinVisit="DBP_WK00";
	else if visitnum=2 then ClinVisit="DBP_WK08";
	else if visitnum=3 then ClinVisit="DBP_WK16";
	else if visitnum=4 then ClinVisit="DBP_WK24";
	else if visitnum=5 then ClinVisit="DBP_WK32";
end;

if vstestcd="SYSBP" then do;
	if visitnum=-1 then ClinVisit="SBP_SCR";
	else if visitnum=1 then ClinVisit="SBP_WK00";
	else if visitnum=2 then ClinVisit="SBP_WK08";
	else if visitnum=3 then ClinVisit="SBP_WK16";
	else if visitnum=4 then ClinVisit="SBP_WK24";
	else if visitnum=5 then ClinVisit="SBP_WK32";
end;*/
run;

proc sort data=work.bp5 out=work.bp5;
by USUBJID;
run;

proc transpose data = work.bp5 
out=echo.bp5(drop=_NAME_ _LABEL_);
	by usubjid;
	id ClinVisit;
	var vsstresn;
run;