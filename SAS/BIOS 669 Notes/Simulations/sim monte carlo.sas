/* 0. Specify sample sizes (using macro variables is a good practice) */
%LET N=10;      /* N=size of each sample */
%LET m=1000;    /* m=number of samples */

/* 1. Simulate data with the DATA step */
DATA SimUni;
    CALL STREAMINIT(172635);

    DO SampleID=1 TO &m;
        DO i=1 TO &N;
            x=RAND('UNIFORM');  /* change this for your application */
            OUTPUT;
        END;
    END;
RUN;

/* 2. Compute statistics for each sample */
PROC MEANS DATA=SimUni NOPRINT;
    BY SampleID;
    VAR x;
    OUTPUT OUT=OutStatsUni MEAN=SampleMean;
RUN;

/* 3. Analyze the samples -> approximate sampling distribution of statistic (ASD) */
TITLE 'Sample distribution of Mean generated from UNIFORM distribution';
PROC MEANS DATA=OutStatsUni N MEAN STD P5 MEDIAN P95;
    VAR SampleMean;
RUN;
PROC UNIVARIATE DATA=OutStatsUni NOPRINT;
    HISTOGRAM SampleMean / NORMAL;
RUN;
TITLE;

/* Tip:  if you don't know a distribution a priori, you can */
/*       request a non-parametric look at the distribution  */
/*       using a KERNEL smooth                              */
/* In this case, the distribution looks very normal.        */
PROC SGPLOT DATA=OutStatsUni;   
    HISTOGRAM SampleMean;
    DENSITY SampleMean / TYPE=KERNEL LEGENDLABEL="Mean";
RUN;


/* What is the probability that the mean of a new sample of 10 points */
/* from the UNIFORM distribution will have a mean < 0.4?              */
DATA TestNewSamp;
    SET OutStatsUni;
    SmallishMean = (SampleMean < 0.4);
RUN;

TITLE 'Probability of Mean < 0.4';
PROC FREQ DATA=TestNewSamp;
    TABLES SmallishMean / NOCUM;
RUN;
TITLE;


/* Use IML to find the sampling distribution of the mean */
%LET N=10;      /* N=size of each sample */
%LET m=1000;    /* m=number of samples */
PROC IML;
    CALL RANDSEED(172635);
    x = J(&m,&N);   /* many samples (rows), each of size N */
    CALL RANDGEN(x,"UNIFORM");  /* 1. Simulate data                  */
    s = x[,:];                  /* 2. Compute statistic for each row */
    Mean = MEAN(s);             /* 3. Analyze the distribution       */
    StdDev = STD(s);
    CALL QNTL(q,s,{0.05 0.95});
    PRINT Mean StdDev (q`) [COLNAME={"5th Pctl" "95th Pctl"}];

    /* compute proportion of statistics less than 0.4 */
    /* (works because (s < 0.4) is either 0 or 1)     */
    Prob = MEAN(s < 0.4);
    PRINT Prob[FORMAT=PERCENT7.2];
quit;
    
