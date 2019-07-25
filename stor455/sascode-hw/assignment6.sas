data college;
input hassles symptoms support;
cards;
176 73 10
379 88 50
126 118 45
193 79 40
229 127 40
153 73 39
214 93 38
164 99 37
143 81 36
27 64 36
229 99 35
144 70 35
65 86 35
45 78 34
68 106 34
89 90 34
42 77 34
203 88 33
96 111 33
118 80 33
298 111 33
158 74 32
139 82 32
49 62 32
219 93 32
112 87 31
68 88 31
75 109 31
202 102 31
64 66 31
193 100 30
201 91 29
67 63 29
62 58 28
131 80 28
88 81 27
95 62 27
717 117 27
290 96 26
277 101 26
161 109 26
171 74 25
54 86 25
153 84 25
16 80 23
156 74 23
202 102 23
260 131 20
75 78 20
172 88 20
54 74 16
525 177 16
342 75 16
217 97 15
380 107 14
185 125 11
;
run;

proc print data=college;
run;

proc reg data=college;
model symptoms=hassles support;
run; quit;

proc standard data=college out=center m=0;
var hassles support;
run;


data center;
set center;
sup_has=support*hassles;
run;

proc print data = center;
run;

/* Running the model */

proc reg data=center;
model symptoms=hassles support sup_has/covb;
run; quit;

proc means data=center;
var hassles support;
run;
