title; footnote; options nodate nonumber;
%let odsdir=P:\BIOS 613\PROC REPORT;

ODS RTF STYLE=JOURNAL BODYTITLE FILE="&odsdir.\NoDataMetCriteria.rtf";

*** the basic desired report;
proc report nowd data=sashelp.class;
    columns name age;
run;

*** to illustrate our point, create a table with 0 obs but ;
*** the same basic structure as the data set to be reported on;
proc sql noprint;
    create table work.class
        like sashelp.class;
quit;

*** by default, we simply get no output when reporting on this 0 obs data set;
proc report nowd data=work.class;
    columns name age;
run;

*** instead, we would like the report to automatically tell us ;
*** if it has been run on a data set with 0 observations;

*** use PROC SQL to count the observations in the data set;
proc sql ;
    select * from work.class;
%put &sqlobs;

*** store that count in an OBS variable;
data blank;
    obs=&sqlobs;
run;

***  add that OBS variable to our report data set;
data classR;
    set class(in=in1) blank;
    if in1 then obs=_N_;
run;

*** now run our report on the augmented report data set, using OBS as a not printed order variable;
*** if OBS is 0, the compute block prints a message;
options missing=' ';
proc report nowd data=classR;
    columns obs name age;
    define obs / order noprint;

    compute before obs;
        if obs=0 then do;
            text1=" ************* No data met the criteria for this display ************* ";
            line @1 text1 $;
        end;
    endcomp;
run;

*** run parallel code showing that the special message is NOT printed;
*** if our report data set DOES have observations;
proc sql ;
    select * from sashelp.class;
%put &sqlobs;

data blank;
    obs=&sqlobs;
run;

data classR;
    set sashelp.class(in=in1) blank;
    if in1 then obs=_N_;
run;


options missing=' ';
proc report nowd data=classR;
    columns obs name age;
    define obs / order noprint;

    compute before obs;
        if obs=0 then do;
            text1=" ************* No data met the criteria for this display ************* ";
            line @1 text1 $;
        end;
    endcomp;
run;

ODS RTF CLOSE;