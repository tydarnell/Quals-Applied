%let jsonloc=P:\Sakai\Sakai 2019\Course units\07 Using APIs\thrones;

filename hous1 temp;

proc http
    url="%nrstr(https://www.anapioficeandfire.com/api/houses)"
    method="GET"
    out=hous1;
run;

libname in json fileref=hous1 map="&jsonloc\houses.user.map" automap=create;

