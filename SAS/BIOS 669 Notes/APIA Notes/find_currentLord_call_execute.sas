/*

get house records of interest using map

one variable there will be currentLord, with a url providing the character number

use a reverse scan to pull off the currentLord character number and plug that character number in as page value here:

proc http
    url="%nrstr(https://www.anapioficeandfire.com/api/characters?page=<characternumber>&pageSize=1)"
    method="GET"
    out=books1;
run;

OK, make a macro with pagenumber and data set name as parameter, then call macro with call execcmd (stack at end)

then can merge by url (or a more elegant way) to add name (anything else?) to house information

*/
options mprint nodate mergenoby=warn varinitchk=warn;

%let jsonloc=P:\Sakai\Sakai 2019\Course units\07 Using APIs\thrones;

filename thrones temp;

* page=1 pageSize=10 is default ;
proc http
    url="%nrstr(https://www.anapioficeandfire.com/api/houses?page=1&pageSize=10)"
    method="GET"
    out=thrones;
run;


filename testmap "&jsonloc\user.map.housetest";


libname in json fileref=thrones map=testmap;

title 'The first 10 houses';
proc print data=in.houses label; run;
title;

data keep;
    set in.houses(where=(^missing(currentLord)) drop=founder);
    
    LordNum = scan(currentLord,-1,'/');
run;

proc print data=keep; title 'has currentLord value'; run; title;



proc sql noprint;
    create table values as
        select distinct LordNum as LordNums
        from keep;
        
    select cats("char", LordNum) into: LordNumDSnames separated by ' '
        from keep; 
quit;

%put &LordNumDSnames;

proc print data=values; run;

/* 
   a helpful post in writing and calling this macro: 
   https://blogs.sas.com/content/sgf/2017/08/02/call-execute-for-sas-data-driven-programming/ 
*/

%macro getchar(charnum= );

    filename chars temp;
    
    %let url=%nrstr(https://www.anapioficeandfire.com/api/characters?page=) &charnum %nrstr(&pageSize=1) ;
    %put url=&url ;

    proc http
        url="&url"
        method="GET"
        out=chars;
    run;
    
    filename testmap "&jsonloc\user.map.charactertest";


    libname in json fileref=chars map=testmap;

    proc print data=in.characters label; run;
    
    /* save this bit of data with a name incorporating the character number */
    data char&charnum;
        length LordName $30 gender $10 culture $20 playedBy1 $30 aliases1 $30;
        set in.characters(rename=(name=LordName));
    run;
    
%mend;

%getchar(charnum=362)

data _null_;
    set values;

    /* always pull charnum 1   
    arg = '%nrstr(%getchar(charnum=LordNums))';
    call execute(arg);
    */
    
    /* works! */
    arg = cats('%nrstr(%getchar(charnum=',LordNums,'))');
    call execute(arg);    
    
run;

data stacknames;
    set &LordNumDSnames;
run;

proc print data=stacknames; title 'stacknames'; run; title;


/* now add name of lord to each house */
/* url is merge variable! use SQL to combine to avoid having to sort or rename variables */

proc sql;
    create table addlord as
        select *
            from keep(rename=(url=houseURL))
                left join
                 stacknames
            on keep.currentLord = stacknames.url;
quit;

title 'The currentLord names for the houses in the first 10 that have this piece of data';
proc print data=addlord; 
run;
title;

