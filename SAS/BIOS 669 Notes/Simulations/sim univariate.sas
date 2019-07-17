* general form for simulating univariate data in a DATA step;

%LET N = 100;               * size of sample;
DATA mysample(KEEP=x);      * the x's will be the generated values;
    CALL STREAMINIT(67787); * initialize random number stream (once per DATA step);
    p = 1/2;                * set any distribution-specific parameters before loop;
    DO i = 1 TO &N;
        x = RAND("Bernoulli", p);   * call RAND for desired distribution;
        OUTPUT;
    END;
RUN;

* check generated data in some reasonable way;
title 'Continuous check';
proc means data=mysample;   
    var x;
run;
proc univariate data=mysample noprint;
    histogram x;
run;

title 'Discrete check';
proc freq data=mysample;
    tables x;
run;
proc sgplot data=mysample;
    vbar x;
run;



* simulating discrete univariate data;

%LET N = 100;               * size of sample;
DATA binomial(KEEP=x);      * the x's will be the generated values;
    CALL STREAMINIT(3021);  * initialize random number stream (once per DATA step);
    p = 1/2;                * set any distribution-specific parameters before loop;
    t = 20;
    DO i = 1 TO &N;
        x = RAND("BINOMIAL", p, t);  * call RAND for desired distribution;
        OUTPUT;
    END;
RUN;

title 'Check binomial sampling (number of successes)';
proc freq data=binomial;    
    tables x;
run;
proc sgplot data=binomial;
    vbar x;
run;
title;



%LET N = 100;                   * size of sample;
DATA die6(KEEP=x y);            * the x's will be the generated values;
    CALL STREAMINIT(55631);     * initialize random number stream;
    k=6;                        * set distrib-specific parameters before loop;
    DO i = 1 TO &N;
        x = CEIL(k * RAND('UNIFORM'));
        y = INT(k * RAND('UNIFORM'));    * for comparison;
        OUTPUT;
    END;
RUN;

title 'Check rolls of a fair six-sided die';
proc freq data=die6;
    tables x y;
run;
title;



%LET N = 100;               * size of sample;
DATA table(KEEP=x);         * the x's will be the generated values;
    CALL STREAMINIT(67787); * initialize random number stream (once per DATA step);
    DO i = 1 TO &N;
        x = RAND("TABLE", 0.1,0.7,0.2);  * specified probabilities must sum to 1;
        OUTPUT;
    END;
RUN;

title 'Check sampling from a specified table';
proc freq data=table;   
    tables x / nocum;
run;
title;



* simulating continuous univariate data;

%LET N = 100;                   * size of sample;
DATA normal(KEEP=x);            * the x's will be the generated values;
    CALL STREAMINIT(55631);     * initialize random number stream;
    mu=2;                       * set distrib-specific parameters before loop;
    sigma=1;
    DO i = 1 TO &N;
        x = RAND('NORMAL',mu,sigma);
        OUTPUT;
    END;
RUN;

title 'Check normal sample (mean of 2, std of 1)';
proc means data=normal;
    var x;
run;
proc univariate data=normal noprint;
    histogram x;
run;
title;



%LET N = 100;                   * size of sample;
DATA uniform(KEEP=x);           * the x's will be the generated values;
    CALL STREAMINIT(55631);     * initialize random number stream;
    a=5;                        
    b=10;
    DO i = 1 TO &N;
        x = a + ((b-a)*RAND('UNIFORM'));
        OUTPUT;
    END;
RUN;

title 'Check uniform distribution between 5 and 10';
proc means data=uniform;
    var x;
run;
proc univariate data=uniform noprint;
    histogram x;
run;
title;



* general form for simulating univariate data with SAS/IML;

%LET N=100;
PROC IML;
    CALL RANDSEED(89111);   * use any seed here;
    x=j(1,&n);              * allocate row vector of desired size;
    CALL RANDGEN(x, 'DistributionName', param1, param2, ...);



* Generate 50 values from a BINOMIAL distribution with probability of;
* success=1/2 and 10 attempts as well as 50 values from a NORMAL;
* distribution with mu 0 and standard deviation 2; 
 
%LET N=50;
PROC IML;
    CALL RANDSEED(28712);   * use any seed here;
    bin=j(1,&n);        * allocate row vectors of desired size;
    norm=j(1,&n);
    p=1/2; t=10; mu=0; std=2;   * set parameters;

    CALL RANDGEN(bin,'BINOMIAL',p,t);   * generate and print values;
    CALL RANDGEN(norm,'NORMAL',mu,std);
    PRINT bin;
    PRINT norm;

    * check sample from normal distrib with mean 0, standard deviation 2;
    *RESET PRINT;
    RESET NOPRINT;
    mean_norm = norm[,:];
    PRINT 'NORM mean' mean_norm;

    norm_cent = norm-mean_norm;
    norm_ss = norm_cent[,##];
    std_norm=SQRT(norm_ss/(NCOL(norm)-1));
    PRINT 'NORM standard deviation' std_norm;

    * check sample from binomial distribution (p=1/2, 10 tries);
    RESET PRINT;
    cats=UNIQUE(bin);           * makes row vector of bin’s unique vals;
    cats_c=CHAR(cats,2);        * converts these values to character;
                                * so can be used as row headings;
    counts=J(NCOL(cats),1,0);   * make row vector of 0's of size needed;
    RESET PRINT;
    DO i=1 TO NCOL(cats);       * operate loop for each unique bin value;
        idx=LOC(bin=cats[i]);   * LOC returns all indices;
                                * satisfying the condition;
        counts[i]=NCOL(idx);    * count number of cols returned by LOC;
    END;

    PRINT counts[ROWNAME=cats_c];
QUIT;



* simulating a coin toss - relative frequency of heads as # of tosses increases;
* with thanks to Bailer, Statistical Programming in SAS (p. 241);

DATA cointoss;
    RETAIN num_heads 0;
    CALL STREAMINIT(440289);
    DO itoss=1 TO 1000;
        outcome=RAND('BERNOULLI',0.50);
        num_heads=num_heads + (outcome=1);
        probability_heads=num_heads/itoss;
        OUTPUT;
    END;
RUN;

title 'Coin toss simulation with regular SAS';
PROC SGPLOT DATA=cointoss;
    SERIES X=itoss Y=probability_heads /
           LINEATTRS=(THICKNESS=2);
    YAXIS LABEL="Estimated Pr(HEADS)" 
          VALUES=(0.25 TO 0.60 BY 0.05);
    XAXIS LABEL="Number of simulated data points" 
          VALUES=(0 TO 1000 BY 50);
    REFLINE 0.50 / AXIS=Y;
RUN;



* now do a similar coin toss simulation with PROC IML;

/* my original poor, inefficient code (does not start by creating matrices of appropriate dimensions) */
/*
proc iml;
    call randseed(440289);
    *call randseed(1234);
    reset noprint;
    do i=1 to 1000;
        outcome=j(1,1);
        call randgen(outcome,"BERNOULLI",0.50);
        outcomes=outcomes//outcome;
        numheads=sum(outcomes);
        numheadscum=numheadscum//numheads;
        is=is//i;
    end;
    probability_heads=numheadscum/is;

    create PropHeadsIML var {numheadscum is outcomes probability_heads};
    append;
    close PropHeadsIML;
quit;

title 'Coin toss simulation with PROC IML';
proc sgplot data=PropHeadsIML;
    series x=is y=probability_heads / lineattrs=(thickness=2);
    yaxis label="Estimated Pr(HEADS)" values=(0.25 to 0.60 by 0.05);
    xaxis label="Number of simulated data points" values=(0 to 1000 by 50);
    refline 0.50 / axis=y;
run;
*/

* much improved code;

/* make sure code works for 10 coin flips */
%let n=10;
proc iml;
    call randseed(440289);

    * flip all coins and generate row of outcomes;
    outcomes = j(1,&n);  /* j(&n,1) for column */
    call randgen(outcomes,'BERNOULLI',0.50);
    print outcomes;

    * produce cumulative row;
    cum = j(1,&n);
    do i=1 to &n; 
        if i=1 then cum[1,i] = outcomes[1,i] ;
        else cum[i] = cum[1,i-1] + outcomes[1,i] ;
    end;
    print cum;

    * compute proportion heads;
    prop = j(1,&n);
    do i=1 to &n;
        prop[i] = cum[i] / i;
    end;
    print prop;

    * concatenate all, transposing into columns and preceeding with a column counter;
    all = (1:&n)` || outcomes` || cum` || prop`;
    print all;
quit;


/* now run for all 1000 tosses, output to SAS data set, and plot */
%let n=1000;
proc iml;
    call randseed(440289);

    * flip all coins and generate row of outcomes;
    outcomes = j(1,&n);  /* j(&n,1) for column */
    call randgen(outcomes,'BERNOULLI',0.50);
    *print outcomes;

    * produce cumulative row;
    cum = j(1,&n);
    do i=1 to &n; 
        if i=1 then cum[1,i] = outcomes[1,i] ;
        else cum[i] = cum[1,i-1] + outcomes[1,i] ;
    end;
    *print cum;

    * compute proportion heads;
    prop = j(1,&n);
    do i=1 to &n;
        prop[i] = cum[i] / i;
    end;
    *print prop;

    * concatenate all, transposing into columns and preceeding with a column counter;
    all = (1:&n)` || outcomes` || cum` || prop`;
    * print all;
    
    create PropHeadsIML var {is outcomes numheadscum probability_heads};
    append from all;
    close PropHeadsIML;
quit;

title 'Coin toss simulation with PROC IML';
proc sgplot data=PropHeadsIML;
    series x=is y=probability_heads / lineattrs=(thickness=2);
    yaxis label="Estimated Pr(HEADS)" values=(0.25 to 0.60 by 0.05);
    xaxis label="Number of simulated data points" values=(0 to 1000 by 50);
    refline 0.50 / axis=y;
run;
