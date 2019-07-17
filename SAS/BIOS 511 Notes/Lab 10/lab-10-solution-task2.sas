/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : lab-10-solution-task2.sas
*
* Author            : Matthew A. Psioda
*
* Date created      : 2018-11-06
*
* Purpose           : This program serves as a solution for lab 10 task2;
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 
*
*
* searchable reference phrase: *** [#] ***;
******************************************************************************/
%let root        = C:\Users\psioda\Documents\GitHub\BIOS-511-FALL-2018;
%let dataPath    = &root.\data\echo;
%let rawDataPath = P:\Teaching\BIOS-511-FALL-2018\2018-11-06-lab-10-solution;

option nonumber nodate;
ods noptitle;
ods _all_ close;

libname echo "&dataPath."         access=read;
libname lab10 "&rawDataPath."     access=read;

/***********************************************************************************
                                           Task 2;
 ***********************************************************************************/

data PC;
 set echo.PC;
  if find(pcstresc,'<','i') then pcstresn = input(compress(pcstresc,'< '),best.);
run; proc sort data = PC; by usubjid; run;

proc sort data = echo.dm out = dm(keep=usubjid armcd sex);
 by usubjid;
run;

data PC2;
 merge PC(in=a) DM(in=b);
 by usubjid;
 if a;

 label hours = 'Hours Post-Dose';
 hours = input(scan(pctpt,1,' '),best.);
run;

proc format;
 value $ sex
  "M" = "Male"
  "F" = "Female";
 value $ sumstat
  'ss1' = 'N (# missing)'
  'ss2' = 'Mean (Std. Dev.)'
  'ss3' = 'Median'
  'ss4' = 'Q1 - Q3';
run;

data input_means;
 set PC2;
  length group $20;
  group = put(sex,$sex.);
  output;

   group = 'Overall';
   output;
run;
  

proc means data = input_means noprint nway;
 class group hours;
 format hours 6.2;
 var pcstresn;
 output out = summary1 nmiss=n0 n=n1 mean=mn std=sd median=md q1=q1 q3=q3;
run;


data summary2;
 set summary1;
  ss1 = put(n1,3. )||' ('||strip(put(n0,3.))||')';
  ss2 = put(mn,6.2)||' ('||strip(put(sd,7.3))||')';
  ss3 = put(md,6.2);
  ss4 = put(q1,6.2)||' - '||put(q3,6.2);
run;

proc transpose data = summary2 out = summary3;
 by group hours;
 var ss1 ss2 ss3 ss4;
run; proc sort; by hours _name_; run;

proc transpose data = summary3 out = summary4;
 by hours _name_;
 id group;
 var col1;
run;

data summary5;
 set summary4;
  Statistic = put(_name_,$sumstat.);
run;

ods pdf file="&rawDataPath.\lab-10-solution-task2.pdf" style=journal;

title1 "Descriptive Summary of PK Concentrations by Gender";
proc report data = summary5;
 column (hours statistic female male overall);

 define hours / group;
 define statistic / display style={just=left};

 compute before hours;
  line @1 " ";
 endcomp;
run;


ods pdf close;

