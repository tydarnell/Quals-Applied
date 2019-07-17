/* data scraped from https://www.plugincars.com/cars */

filename in 'P:\Sakai\Sakai 2019\Course units\08 Web scraping\evinfo.txt';
data readin;
    infile in length=len lrecl=2000;
    input line $varying1000. len;

    * prepare to insert line 169 with price info for Honda Clarity Electric;
    nobs1 = _n_;
    nobs=nobs1;
    if nobs1>=169 then nobs=nobs1+1;
run;
data fix;
    nobs=169;
    line='TBD';
run;
data all;
    set readin fix;
    by nobs;
run;

* keep only rows with car name, ev type, car type, miles per charge, fuel types, and price;
data keep;
    set all;
    if mod(nobs,10) in (4,5,6,7,8,9);
run;

* generate indexes to help with organized transposition into one row per car;
data generate_type;
    do car=1 to 47;
        do j=1 to 6;
            output;
        end;
    end;
run;

* add indexes to main data - yikes, merge with no BY! but rows match one-to-one I AM SURE;
data addtype;
    merge generate_type keep;
    drop nobs1;
run;

* now collapse to one row per car;
data collapse;
    set addtype;
    by car;

    length car_name $40 ev_type $20 car_type $20 miles $20 fuel $30 coststr $20;

    retain car_name ev_type car_type miles fuel coststr;

    if first.car then do;
        car_name=' '; ev_type=' '; car_type=' '; miles=' '; fuel=' '; coststr=' ';
    end;

    if j=1 then car_name=line;
    if j=2 then ev_type =line;
    if j=3 then car_type=line;
    if j=4 then miles   =line;
    if j=5 then fuel    =line;
    if j=6 then coststr =line;

    if last.car then output;

    keep car car_name ev_type car_type miles fuel coststr;
run;

* make needed numeric variables from strings;
data fixup;
    set collapse;

    n_miles = input(scan(miles,1),best.);

    if coststr='TBD' then cost=.;
    else cost = input(coststr,dollar10.);
    format cost dollar10.;
run;

title 'Of cars of interest, which have high gas-free mileage and a relatively low price?';
proc sgplot data=fixup;
    where fuel='(electric + gasoline)' and ^missing(cost) and car_type ^in ('Luxury','Coupe');
    label cost='Cost'
          n_miles='Miles on electric charge'
          car_type='Type of car';
    scatter x=n_miles y=cost / group=car_type 
                               markerattrs=(symbol=CircleFilled)
                               datalabel=car_name ;
run;
title;
