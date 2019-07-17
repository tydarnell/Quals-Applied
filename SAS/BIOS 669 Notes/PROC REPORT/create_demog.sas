libname data669 'P:\BIOS 613\PROC REPORT';

data data669.demog669;
    label subjid='Subject ID'
          trt   ='Treatment'
          gender='Gender'
          race  ='Race'
          age   ='Age';
    input subjid trt gender race age @@;
cards;
101 1 1 3 47 201 1 2 1 49 401 0 2 1 64 601 0 2 1 32 701 1 1 1 45
102 1 1 2 40 202 1 2 1 30 402 0 1 1 60 602 0 2 1 37 702 0 1 1 46
103 0 1 2 35 203 0 2 2 38 403 1 2 1 57 603 1 2 3 40 703 1 1 2 40
104 0 2 1 33 204 1 1 3 31 404 0 2 3 58 604 1 1 1 41 704 0 2 1 38
105 0 2 1 40 205 0 1 3 47 405 0 2 2 47 605 0 1 1 35 705 0 2 3 64
106 1 1 1 44 206 0 1 2 52 406 0 1 1 39 606 1 1 2 33 706 1 1 2 57
107 0 1 1 57 301 0 2 2 63 407 1 1 3 52 607 1 1 2 42 707 1 2 1 58
108 1 2 3 24 302 0 1 1 44 408 1 1 3 50 608 1 1 2 47 708 1 2 1 49
109 1 2 2 61 303 1 2 1 52 409 0 2 2 61 609 0 1 1 40 709 0 2 1 51
110 1 1 1 52 304 1 1 1 58 410 1 1 1 62 610 1 2 1 32 710 1 2 1 30
111 0 1 1 48 305 1 1 . 37 411 1 2 2 52 611 0 2 1 25 711 0 1 1 32
112 0 2 1 26 306 0 2 1 25 412 1 2 1 56 612 0 2 1 29 712 0 1 1 56
;

proc format;
    value trt       1='Active'
                    0='Placebo';
    value gender    1='Male'
                    2='Female';
    value race      1='White'
                    2='Black'
                    3='Other';
run;

data data669.demogtext;
    length subjid 8 longnote $98;
    input @1 subjid @5 longnote &&;
cards;
104 This participant says hi to her friend Mabel in Minnesota.
604 Watch out for ornery behavior from this participant. He bit the clinic coordinator.
;

