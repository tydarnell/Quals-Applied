/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : 03-macro-variables.sas
*
* Author            : Matthew A. Psioda
*
* Date created      : 2018-11-26
*
* Purpose           : This program is designed to teach students about proc SQL;
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

%let root      = C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511; ** define the ROOT macro variable;
%let dataPath  = &root./Lab Data/echo;                                    ** use TEXT SUBSTITUTION to define the DATAPATH macro variable;
%let outPath   = &root./BIOS-511-FALL-2018-master\programs\2018-11-28-Lecture-20; ** use TEXT SUBSTITUTION to define the OUTPATH macro variable;
libname echo "&dataPath";                                             ** use TEXT SUBSTITUION to define the ECHO libref;



** creating macro variable using SQL;
proc SQL noprint;
 select strip(put(max(age),best.)) into :maxAge from echo.dm;
quit;
%put &=maxAge;
 
** creating macro variable using SQL;
proc SQL noprint;
    select        distinct scan(usubjid,2,'-')   into :siteList separated by '|' from echo.dm;
	select count( distinct scan(usubjid,2,'-') ) into :siteNum                   from echo.dm;
quit;
%put &=siteNum.;
%put &=siteList.;


** a simple print macro;
%macro prt(obs=5);
 %do j = 1 %to &siteNum.;
   data temp;
    set echo.dm;
	where scan(usubjid,2,'-') = "%scan(&siteList.,&j,|)";
   run;

   title "ECHO.DM data for Site %scan(&siteList.,&j,|) -- First &obs. Subjects";
   proc print data = temp(obs=&obs.) noobs; run;
 %end;
%mend;
%prt;
