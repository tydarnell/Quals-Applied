filename aq1 temp;

proc http
    url="%nrstr(https://api.openaq.org/v1/measurements?country=CA&city=BRITISH COLUMBIA&location=Vancouver Airport)"
    method="GET"
    out=aq1;
run;

libname aq json fileref=aq1;





%let jsonloc=P:\Sakai\Sakai 2019\Course units\07 Using APIs\air quality;

filename aq1 temp;

proc http
    url="%nrstr(https://api.openaq.org/v1/measurements)"
    method="GET"
    out=aq1;
run;

libname in json fileref=aq1 map="&jsonloc\measurements.user.map" automap=create;






%let jsonloc=P:\Sakai\Sakai 2019\Course units\07 Using APIs\air quality;

filename aq1 temp;

proc http
    url="%nrstr(https://api.openaq.org/v1/measurements?country=CA&city=BRITISH COLUMBIA&location=Vancouver Airport&limit=10000)"
    method="GET"
    out=aq1;
run;

filename measmap "&jsonloc\measurements.user_meas.map";

libname in json fileref=aq1 map=measmap;

proc print data=in.meas label; run; 







* Interestingly, this plotting code fails with an integer divide by zero message;

proc sgplot data=in.meas(where=(parameter='pm25'));
    scatter x=ordinal_date y=value;
run; 

* But this two-step equivalent code succeeds and produced the plot below using data retrieved on 2/19/2019;

data pm25;
    set in.meas(where=(parameter='pm25'));
run;

proc sgplot data=pm25;
    scatter x=ordinal_date y=value;
run;




data pm25_noon_dates;
    set pm25;
    
    label value='PM 25'
          DateOnly='Date';
          
    if substr(local,12,2)='12';
    
    DateTimeAll=input(local,ymddttM15.);
    
    DateOnly=datepart(datetimeall);
    
    format dateonly date9.;
run;

proc sgplot data=pm25_noon_dates;
    scatter x=dateonly y=value;
run;
