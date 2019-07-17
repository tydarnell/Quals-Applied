/*****************************************************************************
* Project           : BIOS 511 Course
*
* Program name      : 02-basic-joins.sas
*
* Author            : Matthew A. Psioda
*
* Date created      : 2018-11-28
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

ods html newfile=proc;



** a simple inner join to produce a dataset;
*Everything between proc SQL and quit is one SAS statement;
proc SQL noprint;
 create table work.ae1 as /*Can read or write permanent or temporary datasets.
 The CREATE clause is not necessary, but we are doing it here to create another dataset.
 Without this, SAS will dump the results to the Output window. Work.AE1 is the dataset we are creating.*/
 select dm.usubjid,dm.age,dm.armcd,dm.sex,dm.country,dm.race,ae.* /* The * is a wildcard character.
 Here we are selecting for all the variables in the AE dataset.*/
 from  echo.dm, echo.ae
 where dm.usubjid=ae.usubjid
 order by usubjid,aestdtc,aeendtc;
quit;
proc print data = work.ae1(obs=20); run;








** a simple inner join to produce a dataset (modified);
proc SQL noprint;
 create table work.ae2 as
 select dm.usubjid,dm.age,dm.armcd,dm.sex,dm.country,dm.race,ae.aeterm,ae.aedecod,ae.aesoc,ae.aestdtc,ae.aeendtc
 from  echo.dm, echo.ae
 where dm.usubjid=ae.usubjid
 order by usubjid,aestdtc,aeendtc;
quit;
proc print data = work.ae2(obs=20); run;

*Listing out all the variables you want to to select, but this is tedious. Note that we don't have to put
ae.usubjid in the SELECT clause to use it in the WHERE statement. The SELECT clause determines what variables we
want to keep in our final output.





** a simple inner join to produce a dataset (modified);
proc SQL noprint;
 create table work.ae3(drop=u) as
 select dm.usubjid,dm.age,dm.armcd,dm.sex,dm.country,dm.race,ae.*
 from  echo.dm,
       echo.ae(rename=(usubjid=u))
 where dm.usubjid=ae.u
 order by usubjid,aestdtc,aeendtc;
quit;
proc print data = work.ae3(obs=20); run;

*You could also include some SAS code. Use the RENAME option to rename USUBJID from AE to U, and then drop it
from Work.AE3. The WHERE clause is like a key for joins in the tidyverse in R.







** a simple left join to produce a dataset ;
proc SQL noprint;
 create table work.ae4 as
 select dm.usubjid,dm.age,dm.armcd,dm.sex,dm.country,dm.race,ae.aeterm,ae.aedecod,ae.aesoc,ae.aestdtc,ae.aeendtc
 from  echo.dm left join echo.ae on dm.usubjid=ae.usubjid
 order by usubjid,aestdtc,aeendtc;
quit;
proc print data = work.ae4(obs=20); run;
