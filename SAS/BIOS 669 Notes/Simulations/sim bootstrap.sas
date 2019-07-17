* choose a species;
proc means data=sashelp.fish n nmiss mean std min max;
	class species;
	var weight;
run;

* make and check out bream data set;
DATA bream(KEEP=Weight);
	SET sashelp.fish(WHERE=(lowcase(species)="bream" AND ^MISSING(weight)));
run;
PROC MEANS DATA=bream NOLABELS N MEAN STD SKEWNESS KURTOSIS;
	VAR weight;
RUN;
PROC UNIVARIATE NOPRINT DATA=bream;
	HISTOGRAM weight;
RUN;

/* 0. Specify sample sizes (using macro variables is a good practice) */
%LET m=5000;	/* m=number of samples */

/* 1. Resample with PROC SURVEYSELECT */
PROC SURVEYSELECT DATA=bream NOPRINT SEED=2162
	OUT=BootSS(RENAME=(Replicate=SampleID))
	METHOD=URS SAMPRATE=1
	REPS=&m OUTHITS;
RUN;

/* 2. Compute statistics for each sample */
PROC MEANS DATA=BootSS NOPRINT;
	BY SampleID;
	VAR Weight;
	OUTPUT OUT=OutStats SKEW=Skewness KURT=Kurtosis;
RUN;

/* 3. Analyze the samples */
TITLE 'Descriptive Statistics for Bootstrap Distribution';
PROC MEANS DATA=OutStats N MEAN STD P5 MEDIAN P95;
	VAR Skewness Kurtosis;
RUN;
PROC UNIVARIATE DATA=OutStats NOPRINT;
	HISTOGRAM Skewness;
	HISTOGRAM Kurtosis;
RUN;
TITLE;

/* Omitting OUTHITS - how #1 and #2 code changes */
/* 1. Resample with PROC SURVEYSELECT */
PROC SURVEYSELECT DATA=bream NOPRINT SEED=2162
	OUT=BootSS(RENAME=(Replicate=SampleID))
	METHOD=URS SAMPRATE=1
	REPS=&m;
RUN;

/* 2. Compute statistics for each sample */
PROC MEANS DATA=BootSS NOPRINT;
	BY SampleID;
	VAR Weight;
	FREQ NumberHits;
	OUTPUT OUT=OutStats SKEW=Skewness KURT=Kurtosis;
RUN;
