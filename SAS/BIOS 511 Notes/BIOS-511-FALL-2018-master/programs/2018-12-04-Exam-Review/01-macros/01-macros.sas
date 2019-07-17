/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : 01-macros.sas
*
* Author            : Matthew A. Psioda
*
* Date created      : 2018-12-04
*
* Purpose           : This program demonstrates using a macro;
*
* Revision History  :
*
* Date          Author   Ref (#)  Revision
* 
*
*
* searchable reference phrase: *** [#] ***;
******************************************************************************/
option mergenoby=nowarn nodate nonumber nobyline;
ods noproctitle;
title;
footnote;

%let root      = C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511; 
%let dataPath  = &root./Lab Data/echo;                                    
%let outPath   = &root./BIOS-511-FALL-2018-master/programs/2018-12-04-exam-review/03-transposing-data;        

libname echo "&dataPath";                                             


** How do I write a macro that perfoms linear regression of the dependent variable Y (separately) 
   on indepdent variables with prefix XXX in a dataset;


  /** linear regression template code:

	 ods select none;
     ods output ParameterEstimates = ParmEst;
     proc reg data = <input dataset> plots=(none);
      model <dependent variable> = <independent variable> / clb; 
     run;
     quit;
     ods select all;

  **/


** code is used to simulate a dataset;
data reg_dat;
 call streaminit(123);

 subject = .;

 format Y X_COVA X_COVB X_COVC X_EXPOSURE 7.3;
 Y = .;
 array x[4] X_COVA X_COVB X_COVC X_EXPOSURE;
 array b[4] _temporary_ (0 1 2 2);

 do subject = 1 to 20;
 	 y = 0;
	 do j = 1 to dim(x);
	  x[j] = rand('normal');
	  y    = y + x[j]*b[j];
	 end;
     y    = y + rand('normal',0,5);
     output;
 end;
 drop j;
run;


** example linear regression code;
 ods select none;
 ods output ParameterEstimates = ParmEst; *One way to make a dataset out of your data manipulations;
 *ParameterEstimates is the name of an ODS object produced by PROC REG (you have to look it up if you
don't know the name);
 proc reg data = reg_dat plots=(none);
  model y = X_EXPOSURE / clb; 
 run;
 quit;
 ods select all;
 
 title "Single-Variable Regression Estimates";
 proc print data = parmEst;
  where upcase(variable)  ='X_EXPOSURE';
 run;


/*
  What do I need to do:
   [1] Get a list of independent variables
   [2] Count the number of independent variables
   [3] Perform linear regression with each independent variable
   [4] Append the results to a dataset that stores all estimates
       from the regressions by the end
   [5] Print out the regression estimates
*/

*User specifies a list of variables, and you do linear regression with each of those variables as the 
independent;
*countw() function to count the number of words (specify what the delimiter is);
*%sysfunc() allows you to use DATA step functions in macros - replace variables with macro variables,
and remove quotation marks;


%macro linRegA(ds=,Dvar=,covList=);
	%let numVar=%sysfunc(countw(&covList.,|)); /*No quotes needed for space characters when used with macros.
	If you used "|", both "" and | will be treated as space characters.*/
	%put &=numVar.; /*Prints numVar=value of numVar*/
    %do i=1 %to &numVar.;
    	%let cov=%scan(&covList.,&i.,|);
    	%put &=cov.;
    	ods select none;
     	ods output ParameterEstimates = ParmEst&i.;
     	proc reg data = &ds. plots=(none);
      	model &Dvar. = &cov. / clb; 
     	run;
     	quit; /*You really don't need both. Convention is to just use quit; (for similar reasons as 
     	PROC SQL). Having both won't screw you over though. */
     	ods select all;
    %end;
    
    /*After DO Loop complete*/
   
   data results;
   		set 
   		%do i=1 %to &numVar.;
   			ParmEst&i. 
   		%end; /* We want something like: set ParmEst1 ParmEst2 ParmEst3; Only want the semicolon 
   		after the last dataset; */
   		; /*Semicolon that ends the SET statement*/
   		where upcase(variable) ^= "INTERCEPT";
	run;
	
	proc print data=results;
	run;
%mend;
%linRegA(ds=work.reg_dat,Dvar=Y,covList=X_COVA|X_COVB|X_COVC);


*User specifies a prefix, and you do linear regression with each of the variables beginning with that prefix 
as the independent;

%macro linRegB(ds=,Dvar=,covPrefix=);

    proc contents data=&ds. out=contents noprint;
    run;
    
    data contents;
    set contents end=eof;
    where (upcase(substr(name,1,length("&covPrefix.")))=upcase("&covPrefix."));
    /*See Codebook lab. One way to start is to use PROC CONTENTS to get a dataset where each row corresponds
    to one of the variables in the dataset.*/
   call symput("mv"||strip(put(_n_,best.)),strip(name));
   if eof=1 then
   call symput("numVar",strip(put(_n_,best.)));
  	run;
  	
  	%do i=1 %to &numVar.;
    	%let cov=&&mv&i; /*Double && usage here*/
    	%put &=cov.;
    	ods select none;
     	ods output ParameterEstimates = ParmEst&i.;
     	proc reg data = &ds. plots=(none);
      	model &Dvar. = &cov. / clb; 
     	run;
     	quit; /*You really don't need both. Convention is to just use quit; (for similar reasons as 
     	PROC SQL). Having both won't screw you over though. */
     	ods select all;
    %end;
    
    /*After DO Loop complete*/
   
   data results;
   		set 
   		%do i=1 %to &numVar.;
   			ParmEst&i. 
   		%end; /* We want something like: set ParmEst1 ParmEst2 ParmEst3; Only want the semicolon 
   		after the last dataset; */
   		; /*Semicolon that ends the SET statement*/
   		where upcase(variable) ^= "INTERCEPT";
	run;
	
	proc print data=results;
	run;
  	
  	
   	
%mend;
%linRegB(ds=work.reg_dat,Dvar=Y,covPrefix=X_);

