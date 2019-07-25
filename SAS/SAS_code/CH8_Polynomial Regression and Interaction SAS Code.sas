*Interactions Among Continuous Variables SAS Code;

/* More on Quadratic Regression:
http://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_reg_sect004.htm
/*

/*******************************************************
EXAMPLE DATASET:  This data set contains 3 variables, books, 
attend, and grade and has 40 students. Books represents the 
number of books read by students on a statistics course, 
attend represents the number of lectures they attended, and 
grade represents their final grade on the course. 
********************************************************/

data books;
input books attend grade;
cards;
0	9	45
1	15	57
0	10	45
2	16	51
6	10	65
4	20	88
1	11	44
4	20	87
3	15	89
0	15	59
2	8	66
1	13	65
4	18	56
1	10	47
0	8	66
1	10	41
3	16	56
0	11	37
1	19	45
4	12	58
7	11	47
0	19	64
2	15	97
3	15	55
1	20	51
0	6	61
3	15	69
3	19	79
2	14	71
2	13	62
3	17	87
2	20	54
2	11	43
3	20	92
5	20	83
4	20	94
3	9	60
1	8	56
2	16	88
0	10	62
;
run;

proc print data=books;
run;

/* Centering IVs */

proc standard data=books out=center m=0;
var books attend;
run;

proc print data=center;
run;

/* Creating interaction variable */

data center;
set center;
bk_att_c=books*attend;
run;

/* Running the model
we want it in the order of:
non-moderator, moderator, interaction term*/

proc reg data=center;
model grade=books attend bk_att_c/covb;
run; quit;

/* Simple slopes
The slope of grade regressed on books
varies at different levels of attend.  

grade_hat = b0 + b1*books + b2*attend + b3*books*attend
    = (b0 + b2*attend)+ (b1 + b3*attend)books
    = (61.86 + 1.53*attend) + (3.27 + .72*attend)books

This slope (b1 + b3*attend) is called the
simple slope.  

To get a better sense of where the slopes differ, we can pick
values of age that are low, medium, and high.

Suggestion: 1 SD below mean, at the mean, and 1 SD above mean of attend */

proc means data=center;
var books attend;
run;

/* SD(attend) = 4.28
y_hat = (61.86 + 1.53*attend) + (3.27 + .72*attend)books

e.g..: Plug in value for age that is 1 SD above mean (remember that attend is centered):
y_hat = (61.86 + 1.53*4.28) + (3.27 + .72*4.28)books
y_hat = 68.41 + 6.35*books

Therefore, at higher levels of classes attended, the slope of grades regressed on books is
positive. Is this slope significant? What about at lower and average levels of classes 
attended?  
