data baseline (keep=ID Gender Age Height Weight BMI Sys_BP BaseDate Visit Treatment)
     visits   (keep=ID Date Visit Sys_BP Efficacy)
     aes      (keep=ID Visit AE Severity)
     ;

    call streaminit(396805);

    * temporary arrays to provide values of aes and their severity;
    array aelist  [5] $16 _temporary_ ('HEADACHE','ITCHING','RASH','NAUSEA','FLUSH');
    array sevlist [3] $16 _temporary_ ('MILD','MODERATE','SEVERE');
    array efflist [4] $16 _temporary_ ('NONE','POOR','MODERATE','GOOD');

    * first possible date for randomization was July 1, 2013;
    studystartdate='01JUL2013'd;

    * set needed parameters (this degree of detail not needed for this application!);
    BMImuM=26;
    BMImuF=25.5;
    BMIsigma=5.0; 

    HTmuM=1.78; * height in meters;
    HTmuF=1.63;
    HTsigmaM=.072;
    HTsigmaF=.071;

    SBPmuYM=139;
    SBPsigmaYM=22.5;   
    SBPmuOM=148;
    SBPsigmaOM=25.5;    

    SBPmuYF=148;
    SBPsigmaYF=30;     
    SBPmuOF=156;
    SBPsigmaOF=27.5;   

    * loop through each participant;
    do ID=1001 to 1300;

        * assign baseline characteristics by gender and age;

        Age = INT(45 + (65-45)*RAND('UNIFORM'));

        Visit=0;
        
        Treatment=0;

        if rand('UNIFORM')>.5 then do;
            
            Gender = 'M';

            BMI = round(RAND('NORMAL',BMImuM,BMIsigma),.01);

            Height = round(RAND('NORMAL',HTmuM,HTsigmaM),.01);

            if 45<=age<=54 then 
                Sys_BP=RAND('NORMAL',SBPmuYM,SBPsigmaYM);   *SBP really skewed right but use NORMAL for now;
            else
                sys_bp=RAND('NORMAL',SBPmuOM,SBPsigmaOM);


            if rand('UNIFORM') < .5 then
                Treatment=1;
                
        end;

        else do;

            gender = 'F';

            BMI = round(RAND('NORMAL',BMImuF,BMIsigma),.01);

            height = round(RAND('NORMAL',HTmuF,HTsigmaF),.01);

            if 45<=age<=54 then 
                sys_bp=RAND('NORMAL',SBPmuYF,SBPsigmaYF);
            else
                sys_bp=RAND('NORMAL',SBPmuOF,SBPsigmaOF);
                
            if rand('UNIFORM') < .5 then
                Treatment=1;

        end;

        Weight = ROUND(BMI*(height**2),.1);

        sys_bp = ROUND(sys_bp,.1);

        BaseDate=studystartdate + int(RAND('UNIFORM')*5);
        format basedate mmddyy10.;

        output baseline;

        * for each participant, generate number of visits;

        NVisits = RAND('TABLE',1/8,1/4,5/8);

        * loop through visits for participant;

        format Date mmddyy10.;

        do visit=1 to nvisits;
            
            Date = basedate + (visit*90);

            sys_bp = sys_bp - int(RAND('UNIFORM')*6);

            Efficacy = efflist[RAND('TABLE',.1,.1,.4,.4)];

            output visits;

            * create a max of 2 AEs for each participant (usually none);
            NAES = RAND('TABLE',.7,.25,.05)-1;

            * loop through aes;
            do i=1 to naes;
                
                Severity = sevlist[RAND('TABLE',.4,.4,.2)];

                AE = aelist[RAND('TABLE',.1,.3,.4,.05,.15)];

                output aes;

            end;    /* ends do i=1 to naes; */

        end;    /* ends do visit=1 to nvisits; */

    end;    /* ends do ID=1001 to 1300; */

run;


* check baseline variables;
title 'Check baseline variables';
proc means data=baseline n nmiss mean std min max;
    class gender;
    var age bmi height weight sys_bp;
run;
proc freq data=baseline;
    tables gender*treatment;
run;

title2 'Baseline Date';
proc tabulate data=baseline;
    class visit;
    var basedate;
    tables visit, basedate*(MIN MAX)*f=date10.;
run;

title2 'BMI';
proc sgpanel data=baseline;
    panelby gender;
    histogram bmi;
run;
title2 'Height';
proc sgpanel data=baseline;
    panelby gender;
    histogram height;
run;
title2 'Systolic Blood Pressure';
proc sgpanel data=baseline;
    panelby gender;
    histogram sys_bp;
run;

proc format;
    value agecat 45-54='Y' 55-64='O';
run;
proc means data=baseline n nmiss mean std min max;
    class gender age;
    var sys_bp;
    format age agecat.;
run;


* check aes;
title 'Check AE variables';
proc freq data=aes;
    tables visit*ae*severity / list missing;
run;


* check visit variables;
title 'Check visit variables';
proc freq data=visits;
    tables visit visit*efficacy;
run;
proc means data=visits n nmiss mean std min max;
    class visit;
    var sys_bp;
run;
proc means data=visits n nmiss mean std min max;
    class efficacy;
    var sys_bp;
run;

title2 'Visit Dates';
proc tabulate data=visits;
    class visit;
    var date;
    tables visit, date*(MIN MAX)*f=date10.;
run;




 
