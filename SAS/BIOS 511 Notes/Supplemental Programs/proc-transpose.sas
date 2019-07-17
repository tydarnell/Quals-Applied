

** code to create a temporary dataset;
data Long;
 infile datalines dlm = " ";
 input  COL1 $ COL2 $ COL3 $ COL4;
 datalines;
A 1 X 1
A 1 Y 2
A 2 X 3
A 2 Y 4
B 1 X 5
B 1 Y 6
B 2 X 7
B 2 Y 8
C 1 X 9
C 1 Y 10
C 2 X 11
C 2 Y 12
;
run;

/* Desired Tranposition:  Complete Transposition -- note COL4 values are converted to character */
proc transpose data = Long out = Wide prefix=row; 
 var COL1-COL4;
run; 
proc print data = Wide; run;

/* Desired Tranposition: 
    [1] One row per value of COL1 & COL2 --> BY Statement 
    [2] New column names based on values of COL3 --> ID Statement
    [3] New column values based on values of COL4 --> VAR Statement
*/
proc transpose data = Long out = partialTransposeA prefix=C3_; 
 by COL1 COL2;
 id COL3;
 var COL4;
run; 
proc print data = partialTransposeA; run;


/* Desired Tranposition: 
    [1] One row per value of COL1 --> BY Statement 
    [2] New column names based on values of COL2 & COL3 --> ID Statement
    [3] New column values based on values of COL4 --> VAR Statement
*/
proc transpose data = Long out = partialTransposeB prefix=C23_; 
 by COL1 ;
 id COL2 COL3;
 var COL4;
run; 
proc print data = partialTransposeB; run;

/* Desired Tranposition:  Reversed Complete Transposition */
proc transpose data = Wide out = Long_NEW; 
 var ROW1-ROW12;
run; 
proc print data = Long_NEW; run;


/* Desired Tranposition:  Reversed partialTransposeA -- extra parsing needed to recreate COL3 exactly*/
proc transpose data = partialTransposeA out = Long_NEWA;
 by COL1 COL2 ;
 var C3_X C3_Y;
run; 
proc print data = Long_NEWA; run;

/* Desired Tranposition:  Reversed partialTransposeB -- extra parsing needed to recreate COL2 & COL3 exactly*/
proc transpose data = partialTransposeB out = Long_NEWB;
 by COL1  ;
 var C23_1X C23_1Y C23_2X C23_2Y;
run; 
proc print data = Long_NEWB; run;

