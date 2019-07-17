/* the house numbers of interest are 

Baratheon - 15      https://www.anapioficeandfire.com/api/houses/15
Greyjoy - 169
Lannister - 229
Stark - 362
Targaryen - 378
Tully - 395
Tyrell - 397

*/


/* set up info */

options mprint nodate;
%let jsonloc=P:\Sakai\Sakai 2019\Course units\07 Using APIs\thrones;



* needed macro;
%macro getchar(charnum= );

    filename chars temp;
    
    %let url=%nrstr(https://www.anapioficeandfire.com/api/characters/)&charnum.;
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
        length LordName $30 gender $10 culture $20 playedBy1 $30 aliases1 $50;
        set in.characters(rename=(name=LordName));
    run;
    
%mend;

/* sample call %getchar(charnum=362) */


%macro houselord(housename= , housenumber= );

    filename thrones temp;

    * specify house number directly;
    proc http
        url="%nrstr(https://www.anapioficeandfire.com/api/houses/)&housenumber."
        method="GET"
        out=thrones;
    run;

    filename testmap "&jsonloc.\user.map.housetest";

    libname in json fileref=thrones map=testmap;

    /* proc print data=in.houses; run; */

    data keep;
        length url $100 name $60 region $20 words $100; 
        set in.houses(where=(^missing(currentLord)) drop=founder);
        
        length FamilyName $20;
        
        FamilyName="&housename";

        LordNum = scan(currentLord,-1,'/');

        call symput("LNum",LordNum);
    run;

    %put &LNum;

    /* proc print data=keep; title 'has currentLord value'; run; title; */

    %getchar(charnum=&LNum)


    /* now add name of lord to the house */
    /* url is merge variable! use SQL to combine to avoid having to sort or rename variables */

    proc sql;
        create table addlord&housenumber as
            select *
                from keep(rename=(url=houseURL))
                    left join
                     char&LNum
                on keep.currentLord = char&LNum..url;
    quit;

    title "&housename addlord&housenumber"; 
    proc print data=addlord&housenumber; 
        var FamilyName LordName houseURL currentLord;    
    run; 
    title;

%mend;

%houselord(housename=Baratheon, housenumber=15)
%houselord(housename=Greyjoy,   housenumber=169)
%houselord(housename=Lannister, housenumber=229)
%houselord(housename=Targaryen, housenumber=378)
%houselord(housename=Tully,     housenumber=395)
%houselord(housename=Tyrell,    housenumber=397)
/* no currentLord %houselord(housename=Stark,     housenumber=362) */

data stack;
    set addlord15
        addlord169
        addlord229
        addlord378
        addlord395
        addlord397;
run;

options nodate nonumber;
ods rtf bodytitle style=journal file="&jsonloc\6houses.rtf";
proc print data=stack; title 'all six houses with their current lords'; run; 
proc report data=stack;
    columns FamilyName LordName houseURL currentLord;
    define FamilyName  / display style=[cellwidth=3 cm];
    define LordName    / display style=[cellwidth=3 cm];
    define houseURL    / display style=[cellwidth=5 cm];
    define currentLord / display style=[cellwidth=5 cm];
run;
ods rtf close;



