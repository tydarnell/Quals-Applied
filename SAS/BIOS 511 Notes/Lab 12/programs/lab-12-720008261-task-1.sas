/*****************************************************************************
* Project           : BIOS 511 Lab 12, Task 1
*
* Program name      : lab-12-720008261-task-1.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-11-20
*
* Purpose           : This program is submitted for Lab 12, Task 1
*                      
*
* Revision History  : 1.0
*
* Date          Author   Ref (#)  Revision
* 2018-11-20     LZ       1      Created program for lab.
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

*Initializing Libraries;

%let path=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab Data/echo; 
libname echo "&path";

%let road=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 12; 
libname test "&road";

%let way= &road./data;
libname out "&way";

*Format for AGECAT;
proc format;
	value AGECAT
		LOW - <45 = "<45"
		45-<55 = "45-55"
		55 - HIGH = ">=55"
		. = " ";
run;

*Creating AGECAT;
data work.dm1;
	set echo.dm (keep=USUBJID ARMCD ARM AGE COUNTRY);
	length AGECAT $5;
	AGECAT=put(AGE,AGECAT.);
	label AGECAT="Age Category";
	
run;

data work.dm1;
	retain USUBJID ARMCD ARM AGE AGECAT COUNTRY;
	set work.dm1;
run;


*Finding PCMAX (by array, for practice);
data work.pc1;
	set echo.pc;
	by USUBJID;
	length PCMAX 8;
	if substr(PCSTRESC,1,1)="<" then do;
		PCSTRESN=input(substr(PCSTRESC,2),best8.);
	end;
	retain PC_1-PC_11;
	array PC {*} PC_1-PC_11;
	if first.usubjid then do;
		do i=1 to dim(PC);
			PC[i]=.;
		end;
	end;
	do i = 1 to dim(PC);
		if PCSEQ=i then do;
			PC[i]=PCSTRESN;
		end;
	end;
	PCMAX=0;
	maxind=0;
	do i = 1 to dim(PC);
		if PC{i}>PCMAX then do;
			PCMAX=PC{i};
			maxind=i;
		end;
	end;
	if last.usubjid;
		keep USUBJID PCMAX;
	label PCMAX="Maximum Plasma Concentration";
run;

*Finding SYSBP_Change;
data vs_x_SYSBP;
	set echo.vs;
	by USUBJID;
	where VISITNUM in (-1, 1) and VSTESTCD = "SYSBP";
	retain SUM COUNT;
	if first.usubjid then do;
		SUM=0;
		COUNT=0;
	end;
	SUM=VSSTRESN+SUM;
	COUNT=COUNT+1;
	SYSBP_X=SUM/COUNT;
	if last.usubjid;
	keep USUBJID SYSBP_X;
run;

data vs_y_SYSBP;
	set echo.vs;
	by USUBJID;
	where VISITNUM in (2,3,4,5) and VSTESTCD = "SYSBP";
	retain SUM COUNT;
	if first.usubjid then do;
		SUM=0;
		COUNT=0;
	end;
	SUM=VSSTRESN+SUM;
	COUNT=COUNT+1;
	SYSBP_Y=SUM/COUNT;
	if last.usubjid;
	keep USUBJID SYSBP_Y;
run;

data vs_SYSBP_change;
	length SYSBP_CHANGE 8;
	merge vs_X_SYSBP vs_y_SYSBP;
	by USUBJID;
	SYSBP_CHANGE=SYSBP_Y-SYSBP_X;
	label SYSBP_CHANGE="Change in Systolic Blood Pressure";
	keep USUBJID SYSBP_CHANGE;
run;

*Finding DIABP_Change;
data vs_x_DIABP;
	set echo.vs;
	by USUBJID;
	where VISITNUM in (-1, 1) and VSTESTCD = "DIABP";
	retain SUM COUNT;
	if first.usubjid then do;
		SUM=0;
		COUNT=0;
	end;
	SUM=VSSTRESN+SUM;
	COUNT=COUNT+1;
	DIABP_X=SUM/COUNT;
	if last.usubjid;
	keep USUBJID DIABP_X;
run;

data vs_y_DIABP;
	set echo.vs;
	by USUBJID;
	where VISITNUM in (2,3,4,5) and VSTESTCD = "DIABP";
	retain SUM COUNT;
	if first.usubjid then do;
		SUM=0;
		COUNT=0;
	end;
	SUM=VSSTRESN+SUM;
	COUNT=COUNT+1;
	DIABP_Y=SUM/COUNT;
	if last.usubjid;
	keep USUBJID DIABP_Y;
run;

data vs_DIABP_change;
	length DIABP_CHANGE 8;
	merge vs_X_DIABP vs_y_DIABP;
	by USUBJID;
	DIABP_CHANGE=DIABP_Y-DIABP_X;
	label DIABP_CHANGE="Change in Diastolic Blood Pressure";
	keep USUBJID DIABP_CHANGE;
run;

*Finding HR_Change;
data vs_x_HR;
	set echo.vs;
	by USUBJID;
	where VISITNUM in (-1, 1) and VSTESTCD = "HR";
	retain SUM COUNT;
	if first.usubjid then do;
		SUM=0;
		COUNT=0;
	end;
	SUM=VSSTRESN+SUM;
	COUNT=COUNT+1;
	HR_X=SUM/COUNT;
	if last.usubjid;
	keep USUBJID HR_X;
run;

data vs_y_HR;
	set echo.vs;
	by USUBJID;
	where VISITNUM in (2,3,4,5) and VSTESTCD = "HR";
	retain SUM COUNT;
	if first.usubjid then do;
		SUM=0;
		COUNT=0;
	end;
	SUM=VSSTRESN+SUM;
	COUNT=COUNT+1;
	HR_Y=SUM/COUNT;
	if last.usubjid;
	keep USUBJID HR_Y;
run;

data vs_HR_change;
	length HR_CHANGE 8;
	merge vs_X_HR vs_y_HR;
	by USUBJID;
	HR_CHANGE=HR_Y-HR_X;
	label HR_CHANGE="Change in Heart Rate";
	keep USUBJID HR_CHANGE;
run;

*Finding WGT_Change;
data vs_x_WGT;
	set echo.vs;
	by USUBJID;
	where VISITNUM in (-1, 1) and VSTESTCD = "WEIGHT";
	retain SUM COUNT;
	if first.usubjid then do;
		SUM=0;
		COUNT=0;
	end;
	SUM=VSSTRESN+SUM;
	COUNT=COUNT+1;
	WGT_X=SUM/COUNT;
	if last.usubjid;
	keep USUBJID WGT_X;
run;

data vs_y_WGT;
	set echo.vs;
	by USUBJID;
	where VISITNUM in (2,3,4,5) and VSTESTCD = "WEIGHT";
	retain SUM COUNT;
	if first.usubjid then do;
		SUM=0;
		COUNT=0;
	end;
	SUM=VSSTRESN+SUM;
	COUNT=COUNT+1;
	WGT_Y=SUM/COUNT;
	if last.usubjid;
	keep USUBJID WGT_Y;
run;

data vs_WGT_change;
	length WGT_CHANGE 8;
	merge vs_X_WGT vs_y_WGT;
	by USUBJID;
	WGT_CHANGE=WGT_Y-WGT_X;
	label WGT_CHANGE="Change in Weight";
	keep USUBJID WGT_CHANGE;
run;

*Merge datasets containing changes in vital signs;
data vitals_change;
	merge vs_DIABP_change vs_SYSBP_change vs_HR_change vs_WGT_change;
	by USUBJID;
run;

*Merge all datasets;

data ADSL;
	merge work.dm1 work.pc1 vitals_change;
	by USUBJID;
run;

data out.ADSL;
	set ADSL;
run;






		
	
	
