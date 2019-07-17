/* creating a demographics summary table */

/********************************************************************
    The outline of this code is taken from Example 5.3 of Jack
    Shostak's SAS Programming in the Pharmaceutical Industry:  
    Creating a Typical Summary of Demographics
 ********************************************************************/

/********************************************************************

    In our table I will use BIOS 511's LRC120 data set, using
    treatment variable Trt, continuous variable Age,
    and categorical variable Smoke.
    
 ********************************************************************/
 
*libname bios511 'C:\BIOS 613 data\BIOS511';
libname bios511 'P:\Sakai\Sakai 2016\Data\BIOS511';
%*let odsdir=P:\BIOS 613\PROC REPORT;
%*let odsdir=C:\Users\ucckjr\Documents\BIOS 613\PROC REPORT;
%let odsdir=P:\Sakai\Sakai 2016\Course units\04 PROC REPORT and reporting in general;

*** set up "hard spaces" to use for indenting in RTF file;
DATA _NULL_  ;
  CALL SYMPUT('b',LEFT(INPUT("A0",$hex2.)))  ;
RUN;
%LET c=&b&b&b;
%LET d=&c&c&c;


data demog1;
    set bios511.lrc120;
    
    label Age   = 'Age'
          Smoke = 'Smoking Status';

run; 

**** CREATE FORMATS NEEDED FOR TABLE ROWS.; 
proc format;
   value smoke 
      0 = "&c&c.Non-smoker"
      1 = "&c&c.Smoker";
run; 


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 0 = PLACEBO, 1 = DRUG,
**** AND 2 = OVERALL.;
data demog2;
   set demog1;
   output;
   trt = 2;
   output;
run;


**** AGE STATISTICS PROGRAMMING ********************************;
**** GET P VALUE FROM NON-PARAMETRIC COMPARISON OF AGE MEANS.;
proc npar1way 
   data = demog2
   wilcoxon 
   noprint;
      where trt in (0,1);
      class trt;
      var age;
      output out = pvalue wilcoxon;
run;

proc sort 
   data = demog2;
      by trt;
run;
 
***** GET AGE DESCRIPTIVE STATISTICS N, MEAN, STD, MIN, AND MAX.;
proc means 
   data = demog2 noprint;
      by trt;

      var age;
      output out = age1 
             n = _n mean = _mean std = _std min = _min 
             max = _max;
run;

**** FORMAT AGE DESCRIPTIVE STATISTICS FOR THE TABLE.;
data age2;
   set age1;

   format n mean std min max $14.;
   drop _n _mean _std _min _max;

   n = put(_n,3.);
   mean = put(_mean,7.1);
   std = put(_std,8.2);
   min = put(_min,7.1);
   max = put(_max,7.1);
run;

**** TRANSPOSE AGE DESCRIPTIVE STATISTICS INTO COLUMNS.;
proc transpose 
   data = age2 
   out = age3 
   prefix = col;
      var n mean std min max;
      id trt;
run; 
 
**** CREATE AGE FIRST ROW FOR THE TABLE.;
data label1;
   set pvalue(keep = p2_wil rename = (p2_wil = pvalue));
   length label $ 85;
   label = "Age (years)";
run;
 
**** APPEND AGE DESCRIPTIVE STATISTICS TO AGE P VALUE ROW AND 
**** CREATE AGE DESCRIPTIVE STATISTIC ROW LABELS.; 
data age4;
   length label $ 85 col0 col1 col2 $ 25 ;
   set label1 age3;

   keep label col0 col1 col2 pvalue ;
   if _n_ > 1 then 
      select;
         when(_NAME_ = 'n')    label = "&c&c.N";
         when(_NAME_ = 'mean') label = "&c&c.Mean";
         when(_NAME_ = 'std')  label = "&c&c.Standard Deviation";
         when(_NAME_ = 'min')  label = "&c&c.Minimum";
         when(_NAME_ = 'max')  label = "&c&c.Maximum";
         otherwise;
      end;
run;
**** END OF AGE STATISTICS PROGRAMMING *************************;

 
**** SMOKING STATISTICS PROGRAMMING *****************************;
**** GET SIMPLE FREQUENCY COUNTS FOR GENDER.;
proc freq 
   data = demog2 
   noprint;
      where trt ne .; 
      tables trt * smoke / missing outpct out = smoke1;
run;
 
**** FORMAT Smoke N(%) AS DESIRED.;
data smoke2;
   set smoke1;
      where smoke ne .;
      length value $25;
      value = put(count,4.) || ' (' || put(pct_row,5.1)||'%)';
run;

proc sort
   data = smoke2;
      by smoke;
run;
 
**** TRANSPOSE THE SMOKE SUMMARY STATISTICS.;
proc transpose 
   data = smoke2 
   out = smoke3(drop = _name_) 
   prefix = col;
      by smoke;
      var value;
      id trt;
run;
 
**** PERFORM CHI-SQUARE ON SMOKE COMPARING ACTIVE VS PLACEBO.;
proc freq 
   data = demog2 
   noprint;
      where smoke ne . and trt not in (.,2);
      table smoke * trt / chisq;
      output out = pvalue pchi;
run;

**** CREATE SMOKE FIRST ROW FOR THE TABLE.;
data label2;
   set pvalue(keep = p_pchi rename = (p_pchi = pvalue));
   length label $ 85;
   label = "Smoking Status";
run;

**** APPEND SMOKE DESCRIPTIVE STATISTICS TO SMOKE P VALUE ROW
**** AND CREATE SMOKE DESCRIPTIVE STATISTIC ROW LABELS.; 
data smoke4;
   length label $ 85 col0 col1 col2 $ 25 ;
   set label2 smoke3;

   keep label col0 col1 col2 pvalue ;
   if _n_ > 1 then 
        label= put(smoke,smoke.);
run;
**** END OF SMOKE STATISTICS PROGRAMMING **********************;

 

**** CONCATENATE AGE AND SMOKE STATISTICS AND CREATE
**** GROUPING GROUP VARIABLE FOR LINE SKIPPING IN PROC REPORT.;
**** (Unfortunately, this way of line skipping does not work in ODS destinations.);
data forreport;
   set age4(in = in1)
       smoke4(in = in2)
       ;

       group = sum(in1 * 1, in2 * 2);
run;


**** DEFINE THREE MACRO VARIABLES &N0, &N1, AND &NT THAT ARE USED 
**** IN THE COLUMN HEADERS FOR "PLACEBO," "ACTIVE" AND "OVERALL" 
**** THERAPY GROUPS.;
data _null_;
   set demog1 end = eof;

   **** CREATE COUNTER FOR N0 = PLACEBO, N1 = ACTIVE.;
   if trt = 0 then
      n0 + 1;
   else if trt = 1 then
      n1 + 1;

   **** CREATE OVERALL COUNTER NT.; 
   nt + 1;
  
   **** CREATE MACRO VARIABLES &N0, &N1, AND &NT.;
   if eof then
      do;     
         call symput("n0",compress('(N='||put(n0,4.) || ')'));
         call symput("n1",compress('(N='||put(n1,4.) || ')'));
         call symput("nt",compress('(N='||put(nt,4.) || ')'));
      end;
run;
%put first:  &n0 &n1 &nt;


**** alternative N calculation technique;
proc sql noprint;
    select n(trt) into :c0 - :c1
    from demog1
    group by trt ;
quit;
%let ct=%eval(&c0+&c1);


**** a different SQL N calculation technique;
proc sql noprint;
    select count(*) into :c0 from demog1 where trt=0;
    select count(*) into :c1 from demog1 where trt=1;
quit;
%let ct=%eval(&c0+&c1);


data _null_;
     call symput("n0",compress('(N='||put(&c0,4.) || ')'));
     call symput("n1",compress('(N='||put(&c1,4.) || ')'));
     call symput("nt",compress('(N='||put(&ct,4.) || ')'));
run;
%put second: &n0 &n1 &nt;


**** We need MISSING=' ' for this table, but save previous MISSING setting;
**** so that we can return SAS to that state after producing our table;
%let missingSetting = %sysfunc(getoption(MISSING));
options missing=' ';

ods rtf file="&odsdir./fancy2.rtf" bodytitle style=journal;
proc report
   data = forreport
   nowindows
   split = "|";

   columns group label col1 col0 col2 pvalue;

   define group   /order order = internal noprint;
   define label   /display " ";
   define col0    /display center "Placebo|&n0";
   define col1    /display center "Active|&n1";
   define col2    /display center "Overall|&nt";
   define pvalue  /display center " |P-value*" 
                   f = pvalue6.4;

   break after group / skip;  /* does not work with ODS destinations */

   title1 "Table 1: Demographics";
 
   footnote1 "* P-values:  Age = Wilcoxon rank-sum, Smoking Status "  
             "= Pearson's chi-square              ";

run;
ods rtf close;

options MISSING=&missingSetting;
