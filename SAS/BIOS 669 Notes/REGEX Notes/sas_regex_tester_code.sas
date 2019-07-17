*libname mets    'P:\Sakai\Sakai 2018\Data\METS';
*libname airline 'P:\Sakai\Sakai 2018\Data\Airline';

%let regex = T(UR|RU)NIP\s*GREEN;

data checkRegEx;
    *set mets.omra_669;
    set airline.frequentflyers;
    retain testRegEx;
    if _N_=1 then do;
        *testRegEx = prxparse("/HUNT/");
        testRegEx = prxparse("/&regex/");
        if missing(testRegEx)then do;
            putlog 'ERROR: regex is malformed';
            stop;
        end;
    end;
    
    *if prxmatch(testRegEx, strip(omra1));
    if prxmatch(testRegEx, strip(address));
run;

title "Address matches &regex";
proc print data=checkRegEx;
    * var omra1;
    var address;
run;
title;