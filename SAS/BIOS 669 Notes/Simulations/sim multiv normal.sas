libname bios511 'P:\Sakai\Sakai 2015\Data\BIOS511';

ods graphics on;
title 'Starting data set';
proc corr data=bios511.candy cov outp=outcov plots=matrix(histogram);
    where servings=1;
    var calories carbohydrate sugars;
run;

* use IML to generate data with this same covariance structure;
%let n=1000;
proc iml;

    use outcov;
    read all var {calories carbohydrate sugars} where(_type_='MEAN') into means;
    read all var {calories carbohydrate sugars} where(_type_='COV')  into covmat;
    print means covmat;
          
    call randseed(5883);
    x = RandNormal(&n, means, covmat);
    
    SampleMean=mean(x);
    SampleCov=cov(x);
    
    c={"calories" "carbohydrate" "sugars"};
    print (x[1:5,]) [label="First 5 Obs: MV Normal"][colname=c];
    print SampleMean[colname=c];
    print SampleCov[colname=c rowname=c];

    create MVN from x[colname=c];
    append from x;
    close MVN;
quit;

title 'Data simulated with PROC IML (RandNormal function)';
proc corr data=MVN cov plots(maxpoints=NONE)=matrix(histogram);
    var calories carbohydrate sugars;
run;

* use PROC SIMNORMAL to do the same;
proc simnormal data=outcov out=simnorm seed=5883 numreal=1000;
    var calories carbohydrate sugars;
run;

title 'Data simulated with PROC SIMNORMAL';
proc corr data=simnorm cov plots(maxpoints=NONE)=matrix(histogram);
    var calories carbohydrate sugars;
run;






