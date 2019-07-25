data phd;
input case time pubs cits salary female age; 
cards;
1 3 18 50 51876 1 34
2 6 3 26 54511 1 28
3 3 2 50 53425 1 31
4 8 17 34 61863 0 38
5 9 11 41 52926 1 39
6 6 6 37 47034 0 30
7 16 38 48 66432 0 52
8 10 48 56 61100 0 45
9 2 9 19 41934 0 40
10 5 22 29 47454 0 37
11 5 30 28 49832 1 44
12 6 21 31 47047 0 49
13 7 10 25 39115 1 32
14 11 27 40 59677 0 44 
15 18 37 61 61458 0 59
16 6 8 32 54528 0 29
17 9 13 36 60327 1 34
18 7 6 69 56600 0 32
19 7 12 47 52542 1 44
20 3 29 29 50455 1 54
21 7 29 35 51647 1 33
22 5 7 35 62895 0 51 
23 7 6 18 53740 0 29
24 13 69 90 75822 0 61
25 5 11 60 56596 0 33
26 8 9 30 55682 1 38
27 8 20 27 62091 1 41
28 7 41 35 42162 1 57
29 2 3 14 52646 1 39
30 13 27 56 74199 0 50
31 5 14 50 50729 0 59
32 3 23 25 70011 0 31
33 1 1 35 37939 0 41
34 3 7 1 39652 0 30
35 9 19 69 68987 0 54
36 3 11 69 55579 0 49
37 9 31 27 54671 0 41
38 3 9 50 57704 0 55
39 4 12 32 44045 1 48
40 10 32 33 51122 0 49
41 1 26 45 47082 0 57
42 11 12 54 60009 0 43
43 5 9 47 58632 0 68
44 1 6 29 38340 0 39
45 21 39 69 71219 0 59
46 7 16 47 53712 1 56
47 5 12 43 54782 1 51
48 16 50 55 83503 0 49
49 5 18 33 47212 0 36
50 4 16 28 52840 1 45
51 5 5 42 53650 0 52
52 11 20 24 50931 0 37
53 16 50 31 66784 1 42
54 3 6 27 49751 1 39
55 4 19 83 74343 1 60
56 4 11 49 57710 1 41
57 5 13 14 52676 0 29
58 6 3 36 41195 1 49
59 4 8 34 45662 1 44
60 8 11 70 47606 1 59
61 3 25 27 44301 1 41
62 4 4 28 58582 1 38
;
run;

/* Sequence A: Hierarchical Regression Analysis */
/* Model 1 includes only X1 (time), Model 2 adds X2 (salary), Model 3 adds X3 (cits), and Model 4 adds X4 (age) */
proc reg data = phd;
model pubs = time /clb;
  model1: test time = 0; /* This is requesting an F-test of this model compared 
  								   to one without time. In this case, the F-test should be the same 
  								   as the overall F-test */
  						 /* "model1" is just giving a name to the test that I'm requesting */
model pubs = time salary / clb;
  model2: test salary=0;
model pubs = time salary cits / CLB;
  model3: TEST cits=0;
model pubs = time salary cits age / CLB;
  model4: TEST age=0;
run; quit;

/* Sequence B: Hierarchical Regression Analysis */
/* Model 1 includes only X1 (time) and X2 (salary), while Model 2 adds X3 (cits) and X4 (age) */
proc reg data = phd;
model pubs = time salary / clb;
  model1: test time=0, salary=0; /* same as overall F test */
model pubs = time salary cits age / clb;
  model2: test cits=0, age=0;
run; quit;
