/*****************************************************************************
* Project           : BIOS 511 Lab 12, Codebook macro
*
* Program name      : codebook-720008261.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-11-20
*
* Purpose           : This program is submitted for Lab 12, Codebook Macro Creation
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


%macro codebook(lib=, ds=, maxVal=10);


** Running PROC CONTENTS on dataset of choice to then create macro variables in a DATA step;
proc contents data = &lib..&ds. out = contents noprint varnum; run;

proc sort data=contents;
	by varnum;
run;

data _null_;
 set contents end=last;
 
 *put _n_ last; *_n_ temporary variable created by SAS to indicate the number of the observation - mostly for visualization;
  
 
 length typec $4;
 if type = 1 then typec = 'Num'; *type, name, label, etc. are variables in the contents dataset that you create and typec you create yourself;
 else             typec = 'Char';
 
 call symput('var'||strip(put(_n_,best.)), strip(name));
 call symput('label'||strip(put(_n_,best.)), strip(label));
 call symput('type'||strip(put(_n_,best.)), strip(typec));
 if last = 1;
	call symput('numVars', strip(put(_n_,best.)));

run;


 
%do i = 1 %to &numVars.;  
      
%if %upcase(&&type&i) = CHAR  %then %do;
 title "Frequency Analysis of Variable = &&var&i (&&label&i)";
 
 proc freq data = &lib..&ds. noprint order=freq;
  table &&var&i / nocum out=counts;
  run;
*Done for alternate step if the number of observations is greater than the set maxVal;  
 data _null_;
 	set counts end=last;
 	if last = 1;
		call symput('numObs',strip(put(_n_,best.)));
 run;
 
 %if &numObs.>&maxVal. %then %do;
 	title "&maxVal. Most Frequent Values of Variable &&var&i (&&label&i)";
 %end;
 
 proc print data=counts(obs=&maxVal.) noobs label;
 	label &&var&i=Value;
 run;
 
 %end;
 
 %else %if %upcase(&&type&i)=NUM %then %do;
 
  proc means data = &lib..&ds. noprint n nmiss mean std median min max;
   var &&var&i;
   output out=means(drop=_TYPE_ _FREQ_) n=NumVar nmiss=NumMiss
   mean=Mean std=STD median=Median min=Minimum max=Maximum;
  run;

  
 title "Analysis of Variable = &&var&i (&&label&i)";
*Done to get column labels and number formatting consistent with solution;
 proc print data=means noobs split='/';
 	label NumVar="Number of/Non-Missing/Values"
 		  NumMiss="Number of/Missing/Values"
 		  Mean="Mean"
 		  STD="Standard/Deviation"
 		  Median="Median"
 		  Minimum="Minimum"
 		  Maximum="Maximum";
 	run;
 %end;
%end;
   

%mend;
















