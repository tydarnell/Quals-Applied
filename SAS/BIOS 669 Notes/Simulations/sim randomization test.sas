*libname bios511 'C:\Users\Kathy\Documents\BIOS511\DATA';
libname bios511 'P:\Sakai\Sakai 2014\Data\BIOS511';

data preem;
    set bios511.preemies(keep=sex ga);
run;

proc univariate noprint data=preem;
    histogram ga;
run;

proc sgplot data=preem;
    vbox ga / category=sex;
run;

proc glm data=preem;
    class sex;
    model ga=sex;
run; quit;


/* rand_gen and rand_anl macros from Cassell paper */
%macro rand_gen(
    indata=_last_,
    outdata=outrand,
    depvar=Y,
    numreps=1000,
    seed=0);

/* get size of input data set into macro variable &numrecs */
proc sql noprint;
    select count(*) into :numrecs from &indata;
quit;

/* generate &numreps random numbers for each record, so
   records can be randomly sorted within each replicate */
data __temp_1;
    set &indata;
    call streaminit(&seed);
    do replicate=1 to &numreps;
        rand_dep = RAND('UNIFORM');
        output;
    end;
run;

proc sort data=__temp_1;
    by replicate rand_dep;
run;

/* Now append the new re-orderings to the original data set.
   Label the original as Replicate=0, so the &RAND_ANL macro
   will be able to pick out the correct p-value.  Then use
   the ordering of __counter within each replicate to 
   write the original values of &depvar, thus creating a
   randomization of the dependent variables in every 
   replicate. */
data &outdata;
    array deplist{ &numrecs } _temporary_;
    set &indata(in=in_orig)
        __temp_1(drop=rand_dep);

    if in_orig then do;
        replicate=0;
        deplist(_n_)=&depvar;
    end;
    else &depvar = deplist{ 1 + mod(_n_,&numrecs) };
run;

%mend rand_gen;

%macro rand_anl(
    randdata=outrand,
    where=,
    testprob=probf,
    testlabel=F test,);

data _null_;
    retain pvalue numsig numtot 0;
    set &randdata end=endofile;

    %if "&where" ne ""
        %then where &where %str(;);
    if replicate=0 then pvalue=&testprob;
    else do;
        numtot+1;
        numsig + ( &testprob < pvalue );
    end;

    if endofile then do;
        ratio=numsig/numtot;
        put numsig= numtot= ;
        put "Randomization test for &testlabel"
        %if "&where" ne "" %then " where &where";
          " has significance level of "
          ratio 6.4;
    end;
run;

%mend rand_anl;


/* calling these macros for our example */
options mprint;
%rand_gen(indata=preem, outdata=outrand, depvar=ga, numreps=100, seed=6644)

ods listing close;
ods html close;
ods output overallanova=glmanova1;
proc glm data=outrand;
    by replicate;
    class sex;
    model ga=sex;
run; quit;
ods output close;
ods listing;
ods html;

%rand_anl(randdata=glmanova1, 
          where= %str(source='Model'),
          testprob=probF,
          testlabel=Model F test ) 


/* to check that replicates are truly complete reshuffles, could run this code after %rand_gen call */
proc freq data=outrand;
    tables replicate*sex / list missing;
run;
proc means data=outrand;
    class replicate;
    var ga;
run;
