libname demog 'P:\Sakai\Sakai 2016\Data\demog';



* simple random sample without replacement;
proc surveyselect data=mets.dema_669 method=srs n=50 out=sample seed=58291;
run;

* stratified random sample without replacement, same number in each stratum;
proc sort data=mets.dema_669 out=dema;
    by dema2;  * gender;
run;
proc surveyselect data=dema method=srs n=25 out=sample2 seed=901132;
    strata dema2;
run;




data demog;
    set demog.demog669;
    call streaminit(55818);
    sorter = rand('UNIFORM');
run;

proc sort data=demog;
    by sorter;
run;

data for_distribution;
    FakeID = put(_N_,z4.);
    set demog;
    * drop subjid sorter;
run;

proc print data=for_distribution(obs=10);
run;





data sim_dates;

    array m m1-m12 (1:12);
    array p p1-p28 (1:28);
    array q q1-q30 (1:30);
    array r r1-r31 (1:31);
    array y y1-y6  (2010:2015);

    seed = 449961;

    do i = 1 to 25;

        * this call will replace m1 with the randomly selected item from m1-m12;
        * use that selection to set month;
        call ranperk(seed, 1, of m1-m12);
        month = m1;

        * based on what month was selected, select a day from the appropriate range;
        if m1=2 then do;
            call ranperk(seed, 1, of p1-p28);
            day = p1;
        end;
        else if m1 in (4, 6, 9, 11) then do;
            call ranperk(seed, 1, of q1-q30);
            day = q1;
        end;
        else if m1 in (1, 3, 5, 7, 8, 10, 12) then do;
            call ranperk(seed, 1, of r1-r31);
            day = r1;
        end;

        * finally, select year;
        call ranperk(seed, 1, of y1-y6);
        year = y1;

        * construct date of birth variable from the current selections and output the record;
        DOB = mdy(month,day,year);
        output;
    end;
    
    label DOB='Date of birth';
    format DOB date9.;
    keep DOB;
run;

title 'Randomly-constructed dates';
proc print data=sim_dates;
run;
title;

   
   
   

ods output summary=ODSStatsUni;
proc means data=simuni;
    by sampleid;
    var x;
run;



/* this code will not run but is intended to serve as a syntax example 

ods select CrazyEstimates;
proc crazy data=all_reps;
    model Resp = cov1 cov2 cov3;
    ods output CrazyEstimates(match_all=list)=out;
    by X;
run;

data allout;
    set &list;
run;

*/
