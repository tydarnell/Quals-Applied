*Logistic Regression;

/**************************************************************
EXAMPLE DATASET:
A hypothetical sample of potential graduate students were assessed on the 
following variables:

	GRE
	GPA
	ADMIT: 1= admitted to graduate schoool, 0 = not admitted
	Rank: Prestige of the undergraduate institution ranked 1 to 4
		(1 highest prestige to 4 lowest prestige)

Taken from http://www.ats.ucla.edu/stat/data/binary.csv
***************************************************************/

data logistic;
infile '\\Client\H$\Desktop\Stor455\Ch13_admit.csv' firstobs = 2 dlm =',';
input admit gre gpa rank;
run;

proc print data = logistic;
run;

proc means data=logistic;
var gre gpa;
run;

proc freq data=logistic;
tables rank admit admit*rank;
run;


*Dummy Coding Table:
------------------------------
Rank	Rank1	Rank2 	Rank3
1   	1   	0   	0
2  	    0   	1   	0
3       0   	0	    1
4	    0	    0	    0
------------------------------
;

data dummy; set logistic;
if rank = 1 then rank1 = 1; else rank1 = 0;
if rank = 2 then rank2 = 1; else rank2 = 0;
if rank = 3 then rank3 = 1; else rank3 = 0;
run;

proc logistic data=dummy descending; *descending option models admit=1 instead of admit=0;
model admit = gre gpa rank1 rank2 rank3;
run;

