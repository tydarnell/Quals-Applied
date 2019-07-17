/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : 01-SGSCATTER.sas
*
* Author            : Evan Kwiatkowski
*
* Date created      : 2018-10-30
*
* Purpose           : This program is designed to provide examples
*                     of using the SGSCATTER procedure
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

proc contents data=sashelp.iris; run;

* http://support.sas.com/documentation/cdl/en/grstatproc/62603/HTML/default/viewer.htm#sgscatter-stmt.htm;

*[1] The MATRIX statement;
*Creates a scatter plot matrix;
proc sgscatter data=sashelp.iris;
 matrix petallength petalwidth;
run;

*[2] The PLOT statement;
*Creates a paneled graph that contains multiple independent scatter plots;
proc sgscatter data=sashelp.iris;
 plot petallength*petalwidth;
run;

*[3] The COMPARE statement;
* Creates a comparative panel of scatter plots with shared axes;
proc sgscatter data=sashelp.iris;
 compare x=(petallength) y=(petalwidth)/ group=species;
run;

%let dataPath = /folders/myfolders/;
libname echo "&dataPath." access=read;

proc sort data = echo.LB out = LB; 
 by usubjid; 
run;
proc sort data = echo.DM out = DM; 
 by usubjid; 
run;

data merged;
 merge LB(in=a) DM(in=b);
 by usubjid;
 if a and b;
run;

proc contents data=merged; run;

proc sgscatter data=merged;
 matrix age LBSTRESN;
run;
