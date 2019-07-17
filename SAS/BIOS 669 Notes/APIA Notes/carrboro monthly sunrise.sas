options mprint ;


/* develop algorithm and test code for January first */

filename carrbor1 temp;

proc http
    url="%nrstr(https://api.sunrise-sunset.org/json?lat=35.9101&lng=-79.0753&date=2019-01-01)"
    method="GET"
    out=carrbor1;
run;

libname sunrise json fileref=carrbor1;

title "Carrboro - results";
proc print data=sunrise.results;
run;


data january;
    set sunrise.results(keep=sunrise);
    
    /* test with 11 AM type value (should give 6 ish result) - yes, this works 
    sunrise="11:58:00 AM";
    */
        
    /* test with 1 PM type value (should give 8 ish result) - yes, this works! 
    sunrise="01:15:00 PM";
    */
       
    /* definitely works with 12 PM type value (-> 7 result - 12 PM was real value on 1/1/2019) */

    * the API returns all values as strings;
    * start by pulling off the pieces useful to us: the time, the hour, and whether AM or PM; 
    sunrise_time_part=substr(sunrise,1,9);
    sunrise_hour= input(substr(sunrise,1,2),best2.);   
    ampm=substr(sunrise,10);
   
    * now convert the time to a SAS time value (seconds since midnight);
    sunrise_time = input(sunrise_time_part, time9.);
    
    * but that time value might not be correct depending on whether time returned by the API was tagged AM or PM;
    * converting to military time (0 - 24 with no AM or PM) is our safest bet);
    * military time examples:  0-1 military is midnight to 1 AM, 12-13 military is noon to 1 PM;
    * so if the API time is PM and between 1:00 and 11:59, we need to add 12 hours to get to military time;
    * since SAS times are in seconds, we need to add 12 hours worth of seconds, which is 12*60*60;
    if ampm='PM' and 1<=sunrise_hour<12 then 
        sunrise_time_military = sunrise_time + 12*60*60;
    else sunrise_time_military= sunrise_time;
        
    * OK, once we have the API-provided time in military form, we simply need to subtract 5 hours to get EST;
    sunrise_time_est=sunrise_time_military - 5*60*60;
    
    format sunrise_time_est time9.;
run;

title 'January';
proc print data=january;
run;



/* OK, now develop macro to call for each month */

%macro whichmonth(m= ,name=);

filename carrb&m temp;

proc http
    url="%nrstr(https://api.sunrise-sunset.org/json?lat=35.9101&lng=-79.0753&date=2019-)&m.%nrstr(-01)"
    method="GET"
    out=carrb&m;
run;

libname sunrise json fileref=carrb&m;

title "Carrboro - &name raw results";
proc print data=sunrise.results;
run;

data &name;
    set sunrise.results(keep=sunrise);
    
    length month $10;
    month="&name";

    sunrise_time_part=substr(sunrise,1,9);
    sunrise_hour= input(substr(sunrise,1,2),best2.);    
    ampm=substr(sunrise,10);
    
    sunrise_time = input(sunrise_time_part, time9.);
    
    
    if ampm='PM' and 1<=sunrise_hour<12 then 
        sunrise_time_military = sunrise_time + 12*60*60;
    else sunrise_time_military= sunrise_time;
        
    
    sunrise_time_est=sunrise_time_military - 5*60*60;
    
    format sunrise_time_est time9.;
run;

title "&name";
proc print data=&name;
run;

%mend;


%whichmonth(m=01,name=January)
%whichmonth(m=02,name=February)
%whichmonth(m=03,name=March)
%whichmonth(m=04,name=April)
%whichmonth(m=05,name=May)
%whichmonth(m=06,name=June)
%whichmonth(m=07,name=July)
%whichmonth(m=08,name=August)
%whichmonth(m=09,name=September)
%whichmonth(m=10,name=October)
%whichmonth(m=11,name=November)
%whichmonth(m=12,name=December)



data stack;
    set 
        January  (keep=month sunrise_time_est)
        February (keep=month sunrise_time_est)
        March    (keep=month sunrise_time_est)
        April    (keep=month sunrise_time_est)
        May      (keep=month sunrise_time_est)     
        June     (keep=month sunrise_time_est)  
        July     (keep=month sunrise_time_est)
        August   (keep=month sunrise_time_est)
        September(keep=month sunrise_time_est)
        October  (keep=month sunrise_time_est)
        November (keep=month sunrise_time_est)     
        December (keep=month sunrise_time_est) 
        ;
run;



options nocenter nodate;

title 'First day of the month sunrise times, Carrboro, 2019'; 
proc print data=stack noobs label; 
    label month='Month'
          sunrise_time_est='Sunrise time (EST)';
run; 
title;
