/*  1 */ FILENAME eSUG URL "https://www.sas.com/en_ca/user-groups/alberta-usergroups/edmonton-archive.html";

/*  2 */ DATA eSUG_archive(KEEP=title author date);
/*  3 */      LENGTH Title $200 Author $100 Date $50;

/*  4 */      INFILE eSUG LENGTH=len LRECL=32767;
/*  5 */      INPUT line $VARYING32767. len;

/*  6 */      *IF FIND(line, "Matt") THEN DO;  /* equivalent */
              IF PRXMATCH("/Matt/", line) THEN DO;
/*  7 */          * PUT line= ;                /* can help during code development */
/*  8 */          title = SUBSTR(line, 4, INDEX(line,":")-4);
/*  9 */          author = SUBSTR(line, INDEX(line,":")+1, (INDEX(line,',')-INDEX(line,":")-1));
/* 10 */          date = SUBSTR(SCAN(line,-2,'<('), 1, LENGTH(SCAN(line,-2,'<('))-1);
/* 11 */          OUTPUT;
/* 12 */      END;
     
         RUN;

/* 13 */ FILENAME eSUG CLEAR;

title 'Edmonton SAS Users Group presentations by Matt';
proc print data=eSUG_archive;
run;