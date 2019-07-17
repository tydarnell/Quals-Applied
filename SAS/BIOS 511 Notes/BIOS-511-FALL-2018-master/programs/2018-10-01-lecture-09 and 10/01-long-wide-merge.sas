/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : 01-long-wide-merge.sas
*
* Author            : Matthew A. Psioda
*
* Date created      : 2018-10-01
*
* Purpose           : This program is design to teach students about
*                     merging data sets and transforming data sets
*                     from long to wide format;
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

%let root     = C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\BIOS-511-FALL-2018-master; 
%let dataPath = &root.\programs\2018-10-01-lecture-09;
libname lecture "&dataPath";

%let path=C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab Data\echo; 
libname echo "&path";

** Task #1: Merge on treatment group information (ARMCD) from the DM dataset;
** [1] The new dataset (WORK.VS2) should only have observations matching those in the WORK.VS dataset.
       That is, we should not keep observations from DM that have no match in the WORK.VS dataset.;

/* Question: Conceptually... what do we need to do to achieve this goal?
  [1] Identify variables that allow matching observations (USUBJID)
  [2] Make sure both datasets are sorted by those variables (could be more than one)
  [3] Write a DATA step that merges the two sources AND keeps the observations you want in the newly created
  dataset
*/

/*proc print data=lecture.vs;
run;*/

*Don't take for granted your data is sorted;
proc sort data = lecture.VS out = work.VS;
 by usubjid;
run;

proc sort data = echo.dm(keep=usubjid armcd) out = dm;
 by usubjid;
run;

data work.VS2;
 merge work.VS(in=A) work.dm(in=B);
 by usubjid;
 *putlog " BEFORE " _all_;
 if(A=1 and B=1);
 *putlog " AFTER " _all_;
run;



** Task #2: Construct a dataset (WORK.HR[x]) that has all HR values on a single observation for each subject. 
**   [1] The variables in this dataset should be named: usubjid armcd SCR WK00 WK08 WK16 WK24 WK32 (or something similar);

/********************************************************************************/
/* Strategy #1 -> Make a dataset of results for each visit and merge them all together. */

		data SCR WK00 WK08 WK16 WK24 WK32;
		 set work.VS2;

		       if upcase(VISIT) = 'SCREENING' then output SCR;
		  else if upcase(VISIT) = 'WEEK 0'    then output WK00;
		  else if upcase(VISIT) = 'WEEK 8'    then output WK08;
		  else if upcase(VISIT) = 'WEEK 16'   then output WK16;
		  else if upcase(VISIT) = 'WEEK 24'   then output WK24;
		  else if upcase(VISIT) = 'WEEK 32'   then output WK32;

		  keep usubjid armcd vsstresn;
		run;

		** code to print out all the datasets;
        proc print data = work.SCR;  run;
		proc print data = work.WK00; run;
        proc print data = work.WK08; run;
		proc print data = work.WK16; run;
		proc print data = work.WK24; run;
		proc print data = work.WK32; run;

		data work.HRa;
		 merge SCR(rename=(VSSTRESN=SCR)) 
		 WK00(rename=(VSSTRESN=WK00)) 
		 WK08(rename=(VSSTRESN=WK08))
		 WK16(rename=(VSSTRESN=WK16))
		 WK24(rename=(VSSTRESN=WK24))
		 WK32(rename=(VSSTRESN=WK32));
		 by usubjid;
		run;

		/*This DATA step simply changes the order in which the variables are stored in the dataset.
		The FORMAT statement we use must come before the SET statement to change the way/order
		SAS will encounter the data. This FORMAT statement will also eliminate any formats on the variables, 
		but we don't have any right now. In addition, we can also create and format new variables that
		don't exist in the initial dataset. We can also do the same thing using a LENGTH statement that 
		keeps the length of each variable the same as it currently is (basically, we can use any statement
		that defines an attribute for a variable and orders the variables, but FORMAT and LENGTH
		are the easiest.)*/
		data HRa;
		format usubjid /*test*/ armcd scr wk:;
		set HRa;
		*test="CHECK";
		run;

		proc print data = work.HRa; 
		var usubjid armcd scr wk:; 
		run;
/********************************************************************************/
/* Strategy #2 -> Use an ARRAY /w RETAIN and conditional OUTPUTs statements in a single data step */

		data work.HRb;
		 set work.VS2;
		 by usubjid; *Needed to get first.usubjid and last.usubjid;

		 retain SCR WK00 WK08 WK16 WK24 WK32;
/*As data are processed by SAS, you can only access one observation at a time, more-or-less.
SAS processes row-by-row. It is nearly impossible to pull a later observation and put it on an earlier row.
Instead, we pull observations down (from earlier rows to later rows.) 
The RETAIN statement is critical because we need SAS to keep observations from earlier rows 
(to pull down to later rows) until we tell SAS to change them otherwise.*/

		 array hr[6] SCR WK00 WK08 WK16 WK24 WK32; ** note this array CREATES variables that do not exist;
		
		if first.usubjid=1 then do i = 1 to 6;
		hr[i]=.;
		end;
/*Defensive programming to prevent data from one subject from being pulled down to another subject 
(if there was missing data, for example).*/
		
		 ** what does this code do?;
		 if visitnum = -1 then arrayID = 1;
		 else                  arrayID = visitnum + 1;

		 hr[arrayID] = vsstresn;

		 ** why is this conditional output statement necessary;
		 if last.usubjid then output; *Could also do if last.usubjid=1;
/*We can identify the last time we see a subject id (which, in this case, should be the row that contains
all the blood pressure measurements for each meeting) and tell SAS to drop the other rows (which contain
partially-filled, redundant data).*/

		 keep usubjid armcd SCR WK00 WK08 WK16 WK24 WK32;
		run;
/********************************************************************************/
/* Strategy #3 -> Use PROC TRANSPOSE (always nice when it can be used) */


		proc transpose data = work.VS2 out = work.HRc;
		 by usubjid;     ** defines the observations in the new data set;
		 id visit;       ** defines the columns in the new data set;
		 var vsstresn;   ** defines the values of the variables (columns) in the new data set;
		run;
/********************************************************************************/

































/*data work.VS "C:\Users\psioda\Documents\GitHub\BIOS-511-FALL-2018\programs\2018-10-01-lecture-09\data\vs";*/
/* set echo.VS;*/
/*  where usubjid in ('ECHO-011-001' 'ECHO-011-002');*/
/*  where also vstestcd in ('HR');*/
/**/
/*  if usubjid = 'ECHO-011-002' and visitnum = 4 then delete;*/
/**/
/*  keep usubjid vstest: vsstresn vsstresu visit:; */
/*run; */
/*proc sort; by visitnum; run;*/
/*proc print noobs ; run;*/

/********************************************************************************/
