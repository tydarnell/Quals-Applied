*libname bios669 'C:\Users\Kathy\Documents\669 data';
%*let odsdir=C:\Users\Kathy\Documents\output;

*libname bios669 'P:\BIOS 613\PROC REPORT';
%*let odsdir=P:\BIOS 613\PROC REPORT;

libname bios669 'P:\Sakai\Sakai 2014\Course Units\8 PROC REPORT and reporting in general';
%let odsdir=P:\Sakai\Sakai 2014\Course Units\8 PROC REPORT and reporting in general;

options nodate nonumber;

proc format;
    value trt 1='Active'
              0='Placebo';
    value gender 1='Male'
                 2='Female';
run;


ods rtf file="&odsdir\ex_group1.rtf" style=journal bodytitle;


title 'No statements or options, all numeric variables';
proc report data=bios669.demog669 nowd;
run;



title 'Using a DISPLAY variable';
proc report data=bios669.demog669 nowd;
    define subjid / display;
run;



title 'Adding an ORDER variable';
proc report data=bios669.demog669 nowd;
    define subjid / display;
    define age / order;
run;



title 'Controlling the column order';
proc report data=bios669.demog669 nowd;
    columns age subjid trt gender race;
    define subjid / display;
    define age / order;
run;



title 'Using additional order controls';
proc sort data=bios669.demog669 out=SortedBySubjid; by subjid; run;
proc report data=SortedBySubjid nowd;
    columns age subjid trt gender race;
    define subjid / display;
    define age / order;
run;
proc report data=bios669.demog669 nowd;
    columns age subjid trt gender race;
    define subjid / order;
    define age / order;
run;



title 'Computing statistics within groups';
proc report data=bios669.demog669 nowd;
    columns trt age;
    define trt / group;
    define age / analysis mean;
run;
title 'Computing statistics within groups';
proc report data=bios669.demog669 nowd;
    columns trt age;
    define trt / group format=trt.;
    define age / analysis mean format=5.2;
run;



title 'Using aliases to compute multiple statistics for a variable';
proc report data=bios669.demog669 nowd;
    *columns trt  age=agen age=agemean;
    columns trt ( 'Age' age=agen age=agemean);
    define trt / group format=trt.;
    define agen / analysis n 'N'; 
    define agemean / analysis mean format=5.2 'Mean';
run;



title 'Producing a crosstab with ACROSS and GROUP';
proc report data=bios669.demog669 nowd;
    columns gender trt;
    define trt / across format=trt.;
    define gender / group format=gender.;
run;



title 'Summarizing the entire report using RBREAK';
proc report data=bios669.demog669 nowd;
    columns gender trt;
    define trt / across format=trt. style=[just=center];
    define gender / group format=gender.;
    rbreak after / summarize style=[BACKGROUNDCOLOR=ltgray];
run;



title 'Using multiple grouping variables';
proc report data=bios669.demog669 nowd;
    columns trt gender age;
    define trt / group format=trt.;
    define gender / group format=gender.;
    define age / analysis mean format=5.2;
run;



title 'Adding summaries for groups using BREAK';
proc report data=bios669.demog669 nowd;
    columns trt gender age;
    define trt / group format=trt.;
    define gender / group format=gender.;
    define age / analysis mean format=5.2;
    break after trt / summarize;
run;



title 'Using a COMPUTED variable and a COMPUTE block';
proc report data=bios669.demog669 nowd;
    columns trt age agemonthsmean;
    define trt / group format=trt.;
    define age / analysis mean noprint;
    define agemonthsmean / computed 'Average Age in Months';
    compute agemonthsmean;
        agemonthsmean=age.mean*12;
    endcomp;
run;



title "More on using STYLE options and COMPUTE blocks";
proc report nowd data=bios669.demog669;
    columns subjid trt ('Demographics' age gender race);
    define subjid / order style(header)=[font_weight=bold];
    define trt / display style=[font_weight=bold just=center];
    define race / display;
    define age / display style=[cellwidth=1.5cm];
    compute subjid;
         if mod(subjid,2) then do;
            call define(_row_,"STYLE","STYLE=[BACKGROUND=cxDDDDDD]");
         end;
    endcomp;
    compute race;
        if race=3 then do;
            call define(_col_,"STYLE","STYLE=[FONT_WEIGHT=Bold]");
        end;
     endcomp;
run;


title "More on using STYLE options and COMPUTE blocks";
title2 "Check highlighting of subjid and gender columns";
proc report nowd data=bios669.demog669;
    columns subjid trt ('Demographics' age gender race);
    define subjid / order style(header)=[font_weight=bold] style=[background=cxDDDDDD];;
    define trt / display style=[font_weight=bold just=center];
    define race / display;
    define age / display style=[ cellwidth=1.5cm];
    compute race;
        if race=3 then do;
            call define(_col_,"STYLE","STYLE=[FONT_WEIGHT=Bold]");
        end;
     endcomp;
     compute gender;
        call define(_col_,"STYLE","STYLE=[BACKGROUND=cxDDDDDD]");
     endcomp;
run;



title "Adding a PROC PRINT-like row counter";
proc report nowd data=sashelp.class;
    column obs name;
    define obs / computed 'Obs' f=3.;
    compute before;
        obsnum=0;
    endcomp;
    compute obs;
        obsnum+1;
        obs=obsnum;
    endcomp;
run;



/* Example 12c (special note if no data for report) - see program "no data met criteria.sas" */



title 'Can PROC REPORT do percentages?';
proc report data=bios669.demog669 nowd;
    columns gender trt;
    define gender / group format=gender.;
    define trt / analysis mean format=percent7.1 'Percent in Active Group';
run;



title 'Displaying long text fields';
data addnotes;
    merge SortedBySubjid bios669.demogtext;
    by subjid;
run;

title 'Displaying long text fields';
proc report data=addnotes nowd;
    define subjid / display;
    define longnote / 'Comment';
run;


title 'Displaying long text fields with a controlled column width';
proc report data=addnotes nowd;
    define subjid / display;
    define longnote / 'Comment' style=[cellwidth=2in];
run;

ods rtf close;
