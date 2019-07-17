LIBNAME data669 'C:\Users\ucckjr\Documents\BIOS 613\PROC REPORT';
%LET odsdir=C:\Users\ucckjr\Documents\BIOS 613\PROC REPORT;
OPTIONS NODATE NONUMBER;
TITLE;

*** set up "hard spaces" to use for indenting in RTF file;
DATA _NULL_  ;
  CALL SYMPUT('b',LEFT(INPUT("A0",$hex2.)))  ;
RUN;
%LET c=&b&b&b;
%LET d=&c&c&c;

*** compute basic counts and percents required by table shell;
TITLE 'Basic counts and percents';
PROC FREQ DATA=data669.demog669;
    TABLES trt*race / OUTPCT OUT=racecnt MISSING;
    TABLES trt*gender / OUTPCT OUT=gendcnt MISSING;
    TABLES trt / OUT=trtcnt;
RUN;

*** see structure of output data sets - which % variable uses right denominator?;
TITLE 'FREQ output data set';
PROC PRINT DATA=racecnt; RUN;

*** store treatment group counts in macro variables for later display in column headings;
DATA _NULL_;
    SET trtcnt;
    IF trt=0 THEN CALL SYMPUT('p',PUT(count,2.));
    IF trt=1 THEN CALL SYMPUT('a',PUT(count,2.));
RUN;
%PUT p=&p a=&a ;

*** create N (%) character values requested in table shell (simplify data set BEFORE;
*** transposing);
DATA racepct;
    SET racecnt(KEEP=trt race count pct_row);
    LENGTH cp $10;
    cp=PUT(count,2.) || ' (' || PUT(pct_row,2.) || '%)';
RUN;
DATA gendpct;
    SET gendcnt(KEEP=trt gender count pct_row);
    LENGTH cp $10;
    cp=PUT(count,2.) || ' (' || PUT(pct_row,2.) || '%)';
RUN;

*** basic transposition by race or gender to get active & placebo values on same record;
*** per table shell;
PROC SORT DATA=racepct; BY race; RUN;
PROC TRANSPOSE DATA=racepct(KEEP=trt race cp) OUT=racetrn PREFIX=trt;
    BY race;
    ID trt;
    VAR cp;
RUN;

PROC SORT DATA=gendpct; BY gender; RUN;
PROC TRANSPOSE DATA=gendpct(KEEP=trt gender cp) OUT=gendtrn PREFIX=trt;
    BY gender;
    ID trt;
    VAR cp;
RUN;

*** make sure transposed tables are similar to table shell;
TITLE 'TRANSPOSE output data set';
PROC PRINT DATA=racetrn; RUN;

*** stack transposed data sets, adding an order variable and rows for headers;
*** per the table shell;
*** (is there a better way to assign order values?);
DATA racetrn2(DROP=_NAME_ RENAME=(race=variable));
    SET racetrn;
    LENGTH vartext $20;
    IF race=1 THEN DO; order=2; vartext="&c&c.White";   END;
    IF race=2 THEN DO; order=3; vartext="&c&c.Black";   END;
    IF race=3 THEN DO; order=4; vartext="&c&c.Other";   END;
    IF race=. THEN DO; order=5; vartext="&c&c.Missing"; END;
RUN;
PROC SORT DATA=racetrn2; BY order; RUN;

DATA gendtrn2(DROP=_NAME_ RENAME=(gender=variable));
    SET gendtrn;
    LENGTH vartext $20;
    IF gender=1 THEN DO; order=7; vartext="&c&c.Male";   END;
    IF gender=2 THEN DO; order=8; vartext="&c&c.Female"; END;
RUN;

* this step makes rows for headers;
DATA varheads;
    LENGTH vartext $20;
    order=1; vartext='Race';   OUTPUT;
    order=6; vartext='Gender'; OUTPUT;
RUN;

* and finally we stack, ordering by our order variable;
DATA for_report;
    SET racetrn2
        gendtrn2
        varheads;
    BY order;
RUN;

*** finally write the report;
ODS RTF FILE="&odsdir/fancy_report1.rtf" BODYTITLE STYLE=JOURNAL;
TITLE "Treatment Group Composition by Race and Gender";
PROC REPORT DATA=for_report NOWD;
    COLUMNS order vartext trt1 trt0;
    DEFINE order / ORDER NOPRINT;
    DEFINE vartext / DISPLAY ' ';
    DEFINE trt1 / DISPLAY "Active (N=&a)" RIGHT;
    DEFINE trt0 / DISPLAY "Placebo (N=&p)" RIGHT;
    COMPUTE vartext;
        IF order=1 OR order=6 THEN CALL DEFINE(_ROW_,"STYLE",
            "style=[fontweight=bold]");
    ENDCOMP;
RUN;
TITLE;
ODS RTF CLOSE;
