proc print data = iqs
run;
data iqs;
input iq ;
cards;

134   
131   
126  
132   
138   
106
120   
135   
106   
113   
145   
126
129   
114  
123   
121   
116   
129
146   
119   
132   
132  
125  
123
136    
85   
121
124   
130   
144
 91   
101   
146
130   
131   
115
;
run;

proc print data = iqs;
run;

goptions reset=all;
proc univariate data=iqs ;
 var iq;
run;

data iqs;
set iqs;
constant = 1;
run;

proc boxplot data=iqs;
plot iq*constant /BOXSTYLE=SCHEMATIC;
run;


proc capability data=iqs;
qqplot iq / normal (mu=est sigma=est);
run;

proc univariate data=iqs; 
var iq;
histogram / normal(color=black);
run;

data zscore_heart;
zscore = (53-76)/5;
belowprb = probnorm(zscore);
run;

proc print data=zscore_heart; run;

data heart;
 zs80 = (80-76)/5;
 zs69 = (69-76)/5;
 zs73 = (73-76)/5;
 zs77 = (77-76)/5;
 above80 = 1 - probnorm(zs80);
 below69 = probnorm(zs69);
 below73 = probnorm(zs73);
 below77 = probnorm(zs77);
 area73to77 = below77 - below73;
 areasum = area73to77 + above80 + below69;
run;

proc print data=heart; run;
