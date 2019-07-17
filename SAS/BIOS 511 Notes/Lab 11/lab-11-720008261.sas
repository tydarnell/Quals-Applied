/*****************************************************************************
* Project           : BIOS 511 Lab 11
*
* Program name      : lab-11-720008261.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-11-13
*
* Purpose           : This program is submitted for Lab 11
*                      
*
* Revision History  : 1.0
*
* Date          Author   Ref (#)  Revision
* 2018-11-13     LZ       1      Created program for lab.
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

/*Create macro variables as per lab instructions*/

%let outputPath=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 11;
%let task2FName=lab-11-720008261-Task-2-output;
%let task3FName=lab-11-720008261-Task-3-output;

/*********************************************************************
 						SAS Code for Task # 1
**********************************************************************/
proc sort data=echo.vs;
	by USUBJID;
run;

proc sort data=echo.dm;
	by USUBJID;
run;

data work.vs;
	merge echo.dm (keep= USUBJID ARMCD) echo.vs;
	by USUBJID;
run;

/*********************************************************************
 						SAS Code for Task # 2
**********************************************************************/
%macro tst(testcd=);

data &testcd.;
	set vs end=last; /*The END option creates a temporary variable called LAST whose value is 1 when the DATA step is processing the last 
	observation, and it is 0 at all other times. In this macro, we use the LAST variable so that we can do something with the final observation.
	See the discussion of the last=1 conditional DO block.*/

	/*This gives some flexibility to the user and implements some defensive programming. All the values of the variable VSTESTCD in the data are
	in all-caps. Using the %upcase function here allows you to match the condition specified by the WHERE statement here 
	without the user having to type in the value of testcd in all-caps (and allows it to work even if they don't).*/
	where vstestcd="%upcase(&testcd.)";
		vstest=tranwrd(vstest,"Blood Pressure","BP");
			/*If this last=1 statement (indicating the last observation out of the ones selected for by the WHERE statement) was not here,
			you would get the same values for the macro variables LAB and UNIT. This is because SAS would read each observation and
			perform the actions dictated by the CALL SYMPUT routine, and thus each observation would overwrite the value of LAB and
			UNIT from the previous observation. So, LAB and UNIT would have the value corresponding to the last observation.
			The last=1 conditional DO block just checks the last observation out of the ones selected for by the WHERE statement, which
			is much more computationally efficient than having to check each observation.*/
			if last=1 then do;
				/*Creates the LAB macro variable and assigns it the value of VSTEST with the trailing and leading white spaces removed.
				The value of VSTEST depends on the type of vital sign specified by the user using the value of TESTCD. If the user inputs DIABP
				or SYSBP, then the value of VSTEST would have the words "Blood Pressure" replaced with "BP". If the user input DIABP, then 
				LAB would have the value 'Diastolic BP'.*/ 
				call symput('lab',strip(vstest));
				/*Creates the UNIT macro variable and assigns it the value of VSSTRESU with the trailing and leading white spaces removed.
				The value of VSSTRESU depends on the type of vital sign specified by the user using the value of TESTCD. If the user input DIABP,
				then UNIT would have the value 'mmHg'.*/
				call symput('unit',strip(vsstresu));
	end;
		drop vstestcd vstest vsstresu vsseq
			vsblfl vsstat vsreasnd studyid;
	/*Since all the observations will now be from the same type of vitals measurement, the VSSTRESN variable is renamed to the name of 
	type of vitals test.*/
	rename vsstresn = &testcd.;
run;

/*This writes the value of the LAB macro variable and the UNIT macro variable to the SAS log.
This could be useful for debugging because you can check on the SAS log if your macro variable has the value you expect when the code executes.*/
%put LAB = &lab. UNIT=&unit.;

data &testcd.;
	set &testcd.;
		/*This gives the macro variable TESTCD a descriptive label describing the type of test and the units that vital sign is
		measured in. This label would be available for viewing (because it is attached to a variable in the dataset) when PROC CONTENTS
		is run on the dataset.*/
		label &testcd. = "&lab. (&unit.)";
run;

%mend;

/*The macro selects all observations from our WORK.VS dataset where the vital sign test code is the same as the user input value (so, it
selects all observations that were obtained from a particular type of vital sign measurement) and puts these in a new dataset that is named
the value of the TESTCD macro variable (given by the user input.) Several variables (like VSTESTCD, VSTEST, STUDYID, etc.) are dropped from this
new dataset.
It also creates two macro variables, LAB (based on the name of the test, or VSTEST), and UNIT (based on the unit of measurement for the test, or
VSSTRESU), and uses these macro variables to create a descriptive label for the TESTCD macro variable (the name of this macro variable is the 
user input value, but all in upper-case.) The name of the VSSTRESN variable is changed to match the value of TESTCD. The values of the two macro
variables LAB and UNIT created in this macro are also written out to the SAS log.*/
%tst(testcd=diabp);
%tst(testcd=sysbp);
%tst(testcd=hr);

data vs_horiz;
	merge diabp sysbp hr;
	by usubjid visitnum visit;
run;
	
/*The .. are necessary after the reference to the TASK1FNAME macro variable because the first period is used in the macro call, and the second
period is used for the file extension.*/
ods pdf file = "&outputPath./&task2FName..pdf" style=journal;
ods graphics / height = 7.25in width=7in;
	title1 "Scatter Plot Matrix for Diastolic BP, Systolic BP, and Heart Rate";
	title2 "Visit = Week 32";
	proc sgscatter data=vs_horiz;
		where visitnum=5;
		matrix diabp sysbp hr / diagonal=(histogram) group = armcd;
	run;
ods graphics / reset=all;
ods pdf close;



/*********************************************************************
 						SAS Code for Task # 3
**********************************************************************/
%macro scatMat(testcdList=,visitnum=,grp=);
/*%SYSFUNC is necessary to execute SAS DATA step functions. In this case, %COUNTW doesn't exist, so you have
to use %SYSFUNC to use the SAS DATA step function COUNTW.*/
%*Note that arguments are NOT quoted as they would be when using the DATA step function COUNTW;
	%let testnum=%sysfunc(countw(&testcdList.,|));

%*Loop over the number of tests to include;
	%do i=1 %to &testNum;

/*%SCAN selects for words (testcd names) entered into testcdList. This function scans through the value
entered into &testcdList and picks the word whose indexed number matches the value of i. Since the words
in testcdList are entered using "|" as separation, the %scan function using "|" as its third argument to
indicate the separator.*/
%*Note that arguments are NOT quoted as they would be when using the DATA step function SCAN;
	%let testcd=%scan(&testcdList.,&i,|);

	data &testcd.;
		set vs end=last;
		where vstestcd = "%upcase(&testcd.)";
	
		vstest = tranwrd(vstest,'Blood Pressure','BP');
	
		if last=1 then do;
			call symput('lab',strip(vstest));
			call symput('unit',strip(vsstresu));
		end;
	
		drop vstestcd vstest vsstresu vsseq
			vsblfl vsstat vsreasnd studyid;
		rename vsstresn = &testcd.;
	run;

	data &testcd.; set &testcd.;
		label &testcd. = "&lab. (&unit.)";
	run;

/*These DO blocks create the vs_horiz dataset to contain/merge the observations from each WORK.&testcd. dataset.
The first iteration is different because it sets the first group of observations into the new dataset, so that
later groups of observations (from another value of &testcd.) can be merged into the dataset. In addition, if the
macro were called again with a different list of vstestcd names (without clearing the work directory first), 
having the different first iteration will allow you to clear and replace the existing data so that you don't merge the 
observations from your new execution of the macro with observations from the old execution.*/
	%if &i = 1 %then %do;
		data vs_horiz;
			set &testcd.;
			by usubjid visitnum visit;
		run;
	%end;
	%else %do;
		data vs_horiz;
			merge vs_horiz &testcd.;
			by usubjid visitnum visit;
		run;
	%end;

%end;

ods graphics / height=7in width=7in;
proc sgscatter data=vs_horiz;
	where visitnum=&visitnum.;
	matrix %sysfunc(tranwrd(&testcdList.,|,))/
		   %if &grp^= %then %do; group=&grp. %end;
		   diagonal=(histogram);
	run;
%mend;

ods pdf file="&outputPath./&task3FName..pdf" style=journal;
ods graphics / height=7.25in width=7in;
	title1 "Scatter Plot Matrix for Diastolic BP, Systolic BP, and Weight";
	title2 "Visit = Week 0";
	%scatMat(testcdList=DIABP|SYSBP|WEIGHT,visitnum=1);
ods pdf close;











