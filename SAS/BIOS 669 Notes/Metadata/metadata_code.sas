*libname bios511 'C:\Users\Kathy\Dropbox\BIOS511\DATA';
*libname bios511 'P:\Sakai\Sakai 2014\Data\BIOS511';
libname bios511 'C:\BIOS 613 data\BIOS511';
*libname mets    'P:\Sakai\Sakai 2014\Data\METS';
libname mets    'C:\BIOS 613 data\METS';





* basic use of variable metadata functions;
DATA cars;
    SET bios511.cars2011;
    reltype=VTYPE(reliability);
    PUT reltype= ;
    STOP;   * try with and without this;
RUN;



%macro applycondfmt;
DATA cars;
    SET bios511.cars2011;
    reltype=VTYPE(reliability);
    CALL SYMPUTX("mreltype",reltype);
    STOP;
RUN;
PROC PRINT DATA=bios511.cars2011(OBS=8);
    VAR make model reliability;
    %IF &mreltype=N %THEN
        FORMAT reliability WORDS30.;;
RUN;
%mend;
options mprint;
%applycondfmt



* an application;
DATA cars;
    SET bios511.cars2011;
    CurbWeightKG=CurbWeight/2.2046;
    LENGTH newlabel $256;
    newlabel=TRANWRD(VLABEL(CurbWeight),"pounds","kilograms");
    LABEL CurbWeightKG=newlabel;  * does not work! ;
RUN; 

DATA cars;
    SET bios511.cars2011;
    CurbWeightKG=CurbWeight/2.2046;
    LENGTH newlabel $256;
    newlabel=TRANWRD(VLABEL(CurbWeight),"pounds","kilograms");
    CALL SYMPUTX("CWKGlabel",newlabel);
    DROP newlabel;
RUN; 
DATA cars2;
    SET cars;
    LABEL CurbWeightKG="&CWKGlabel";
RUN;
PROC PRINT DATA=cars2(OBS=7) LABEL;
    VAR Make Model CurbWeight CurbWeightKG;
RUN;

/* more efficient - use PROC DATASETS to change the variable label in the existing data set */
/* rather than creating a whole new data set just to change a variable label                */
PROC DATASETS LIB=work;
    MODIFY cars;
        LABEL CurbWeightKG="&CWKGlabel";
RUN; QUIT;





* checking for the existence of a data set;
DATA _null_;
    rc = EXIST("sashelp.class");
    PUT rc= ;
    STOP;
RUN;



%macro doit(ds=);
    %IF %SYSFUNC(EXIST(&ds))=1 %THEN %DO; 
        PROC PRINT DATA=&ds;
        RUN;
    %END;

    %ELSE %DO;
        DATA _null_;
            FILE PRINT;
            PUT "Data set &ds does not exist.";
        RUN;
    %END;
%mend;

* options mprint mlogic symbolgen;
%doit(ds=sashelp.class)
%doit(ds=class)




* using file i/o functions that require opening/closing a data set;
DATA _null_;
    dsid=OPEN('sashelp.class');
    dsid2=OPEN('sashelp.air');

    DSLib=ATTRC(dsid,'LIB');
    DSName=ATTRC(dsid,'MEM');
    name=DSNAME(dsid);
    NumObs=ATTRN(dsid,'NOBS');

    PUT DSLib= DSNAME= name= NumObs= ;

    rc=CLOSE(dsid);
    rc=CLOSE(dsid2);
RUN;






* a nice application is transferring a data set label from;
* one data set to another (not automatically done);
DATA _null_;
    dsid=OPEN('bios511.cars2011');
    LENGTH dslabel $256;
    dslabel=ATTRC(dsid,'LABEL');
    rc = CLOSE(dsid);
    CALL SYMPUTX("dslabel",dslabel);
RUN;

DATA cars(LABEL="&dslabel");
    SET bios511.cars2011;
RUN;






* finding the type of a variable in the open data set;
DATA _null_;
    dsid=OPEN('sashelp.class');
    SexType=VARTYPE(dsid,VARNUM(dsid,'sex'));
    PUT sextype= ;
    CALL SYMPUTX('sexvartype',sextype);
    rc = CLOSE(dsid);
RUN;
%PUT &sexvartype;







* CEXIST function to see whether a certain user-defined format exists;
DATA _null_;
    rc = CEXIST('WORK.FORMATS.AGEGRP.FORMAT');
    PUT rc= ;
    CALL SYMPUTX("isAgeGrpformat",rc);
RUN;
%put &isAgeGrpformat;

   







 
    
/* how many observations are in my data set? five ways */

DATA count1;
    SET sashelp.class END=eof;
    RETAIN nobs 0;
    nobs=nobs+1;
    IF eof THEN CALL SYMPUTX("nobs1",nobs);
RUN;
%PUT &nobs1;
/* This method does not work if the data set has 0 observations */



DATA count2;
    IF 0 THEN SET sashelp.class NOBS=nobs;
    CALL SYMPUTX("nobs2",nobs);
    STOP;
RUN;
%PUT &nobs2;
/* 
    "IF 0 THEN" in the above is needed to make this method work in cases
   where the data set has 0 observations.
*/


DATA _null_;
    dsid=OPEN("sashelp.class");
    nobs=ATTRN(dsid,'NOBS');
    CALL SYMPUTX("nobs3",nobs);
    rc = CLOSE(dsid);
RUN;
%PUT &nobs3;


* Clear out nobs3 macro variable before next bit of code. ;
* Not absolutely necessary but in case the code below fails, ;
* I want to make sure that the value from above doesn't carry over and fool me. ;
%let nobs3= ;

%macro countnobs(ds= );
    DATA _null_;
        %IF %SYSFUNC(EXIST(&ds))=1 %THEN %DO;
            dsid=OPEN("&ds");
            nobs=ATTRN(dsid,'NOBS');
            CALL SYMPUTX("nobs3",nobs);
            rc = CLOSE(dsid);
        %END;
    RUN;
    %PUT &nobs3;
%mend;
%countnobs(ds=sashelp.class)




PROC SQL NOPRINT;
    CREATE TABLE class AS SELECT * FROM sashelp.class;
%PUT &sqlobs;

PROC SQL;
    SELECT * FROM sashelp.class;
%PUT &sqlobs;
QUIT;

PROC SQL NOPRINT;
    SELECT * FROM sashelp.class;
%PUT &sqlobs;   /* incorrectly returns a 1! - combination of NOPRINT and SELECT w/o CREATE TABLE */
QUIT;




PROC SQL NOPRINT;
    SELECT COUNT(*) INTO :nobs4 FROM sashelp.class;
QUIT;
%put &nobs4;

    


* more on sysfunc;
data _null_;
    rc = EXIST('sashelp.class'); put rc= ;
    rc = %SYSFUNC(EXIST(sashelp.class)); put rc= ;
run;


footnote "Job run on %sysfunc(TODAY(),worddate18.)";
proc print data=sashelp.class; run;


* sysfunc with another type of metadata - about your SAS session (options settings);
%let oldlinesize=%sysfunc(getoption(linesize));
%put &oldlinesize;
options linesize=64;
proc print data=bios511.cars2011(obs=10);
run;
options linesize=&oldlinesize;


%let missingSetting=%sysfunc(getoption(missing));
options missing=' ';
title 'Note that no dots appear for missing numeric values in this listing';
proc print data=bios511.cars2011(obs=10);
run;
options missing=&missingSetting;



* using %SYSFUNC to call character functions outside of a DATA step;

%macro indx(letter=);
    %if %sysfunc(index(%sysfunc(upcase(Kathy Roggenkamp)),&letter))>0 %then 
          %put Name contains the character &letter;
    %else %put Name does not contain the character &letter;
%mend;

%indx(letter=A)
%indx(letter=B)
%indx(letter=a)







* dictionary tables;
footnote;
title 'SASHELP.VMEMBER (like DICTIONARY.TABLES)';
proc contents data=sashelp.vmember varnum; run;

title 'SASHELP.VMEMBER (like DICTIONARY.TABLES) - First 10 observations';
proc print data=sashelp.vmember(obs=10); run;

title 'SASHELP.VCOLUMN (like DICTIONARY.COLUMNS)';
proc contents data=sashelp.vcolumn varnum; run;

title 'SASHELP.VCOLUMN (like DICTIONARY.COLUMNS) - First 10 observations';
proc print data=sashelp.vcolumn(obs=10); 
    var libname memname memtype name type length npos varnum label format;
run;



proc sql;
    describe table dictionary.columns;
    describe table mets.dema_669;
quit;




title 'CARS2011 variables from sashelp.vcolumn';
proc print data=sashelp.vcolumn;
    where libname='BIOS511' and memname='CARS2011';
run;

title 'CARS2011 variables from dictionary.columns';
proc sql;
    select * from dictionary.columns
        where libname='BIOS511' and memname='CARS2011';
quit;
title;





* dictionary table applications;

* make a macro variable list of all variables in a data set;
proc sql noprint;
    select name into :varlist separated by ' '
        from dictionary.columns
        where libname='BIOS511' and memname='CARS2011';
quit;
%put &varlist;




* make a customized list of all character variables in a data set;
proc sql noprint;
    select name into :charlist separated by ' '
        from dictionary.columns
        where libname='BIOS511' and memname='CARS2011' and 
              type='char' and upcase(name)^='MODEL';
quit;
%put &charlist;





* make a list of all date variables in a data set;
proc sql noprint;
    select name into :datelist separated by ' '
        from dictionary.columns
        where libname='METS' and memname='SAEA_669' and 
              type='num' and 
              (index(format,'DATE')>0 or index(format,'MMDDYY')>0);
quit;
%put &datelist;






* make a copy of a data set with the variables in alphabetical order;
proc sql noprint;
    select name into :alphalist separated by ','
        from dictionary.columns
        where libname='BIOS511' and memname='CARS2011'
        order by name;

    create table alphacars as
        select &alphalist
        from bios511.cars2011;
quit;

title 'First 8 obs of copy of cars2011 with variables in alphabetic order';
proc print data=alphacars(obs=8); run;
    




* print first 5 obs of each data set in WORK library;
%macro print5;
    proc sql noprint;
        select memname into :dsns separated by ' '
            from dictionary.tables
            where libname="WORK";
    quit;

    %put &sqlobs data sets in WORK are &dsns;

    %if &sqlobs=0 %then %do;
        %put No data sets!;
        %goto bottom;
    %end;

    %let i=1;
    %do %until (%scan(&dsns,&i)= );
        %let dsn = %scan(&dsns,&i);

        proc print data=work.&dsn(obs=5);
            title "First 5 observations of &dsn";
        run;

        %let i = %eval(&i+1);
    %end;

    %bottom: ;
%mend;

%print5





* putting a data set label into a title;
%macro printit(libname=, memname=);
proc sql noprint;
    select memlabel into :label 
        from dictionary.tables
        where libname="&libname" and
              memname="&memname" and
              memtype in ('DATA','VIEW');
quit;

proc print data=&libname..&memname;
    title "Data set &libname..&memname - &label";
run;
%mend printit;

%printit(libname=BIOS511, memname=CARS2011)




* reconstruct the LENGTH statement for a data set;
%macro makelen(libname=,dsn=);

    %let libname=%upcase(&libname);
    %let dsn=%upcase(&dsn);

    proc format;
        value $typ 'char'='$'
                   other =' ';
    run;

    proc sql noprint;
        select catx(' ',name,put(type,$typ1.),put(length,5.))
            into :lenvar separated by ' '
            from dictionary.columns
            where libname="&libname" and memname="&dsn"
            ;
    quit;

    %put LENGTH statement for &libname..&dsn is &lenvar;

%mend makelen;

%makelen(libname=bios511,dsn=cars2011)
        
