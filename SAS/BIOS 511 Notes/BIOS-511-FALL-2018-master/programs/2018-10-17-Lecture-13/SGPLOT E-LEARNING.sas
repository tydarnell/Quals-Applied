/*****************************************************************************
* Project           : BIOS 511 Getting Started with SGPLOT E-Learning
*
* Program name      : SGPLOT E-LEARNING.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-10-17
*
* Purpose           : This program is for practicing the code in the e-learning.
*                      
*
* Revision History  : 1.0
*
* Date          Author   Ref (#)  Revision
* 2018-10-17    LZ       1      Created program.
*                                  
*
*
* searchable reference phrase: *** [#] ***;
*
* Note: Standard header taken from :
*  https://www.phusewiki.org/wiki/index.php?title=Program_Header
******************************************************************************/
option mergenoby=error nodate nonumber nobyline;

ods noproctitle;

/******************************************************************************
 							Part 1, Scatter Plot
*******************************************************************************/
title "Weight by Height";
proc sgplot data=sashelp.class;
	scatter x=height y=weight;
run;

title "Weight by Height by Gender";
proc sgplot data=sashelp.class;
	scatter x=height y=weight/group=sex;
run;

title "Weight by Height by Gender";
proc sgplot data=sashelp.class;
	styleattrs datasymbols=(circlefilled trianglefilled)
	datacontrastcolors=(olive maroon);
	scatter x=height y=weight/group=sex filledoutlinedmarkers
		markerattrs=(size=12) markerfillattrs=(color=white)
		markeroutlineattrs=(thickness=2);
	keylegend/location=inside position=bottomright;
run;
/*
 
Doesn't seem to run. WARNING: Apparent symbolic reference FILEM not resolved. The system cannot find this file. ERROR: Variable LABEL not found.


title "Weight by Height by Gender";
proc sgplot data=sashelp.class noborder noautolegend;
	symbolimage name=male image="&fileM";
	symbolimage name=female image="&fileF";
	styleattrs datasymbols=(male female);
	scatter x=height y=weight/group=sex markerattrs=(size=20)
		datalabel=label datalabelpos=bottom;
	xaxis offsetmin=0.05 offsetmax=0.05 display=(noline noticks) grid;
	yaxis offsetmin=0.05 offsetmax=0.05 display=(noline noticks) grid;
run;
*/


/******************************************************************************
 							Part 2, VBAR
*******************************************************************************/

title "Counts by Type";
proc sgplot data=sashelp.cars;
	vbar type;
run;

title "Mileage by Type";
proc sgplot data=sashelp.cars;
	vbar type/response=mpg_city stat=mean
		barwidth=0.6 fillattrs=graphdata2;
	xaxis display=(nolabel);
run;

title "Mileage by Type";
proc sgplot data=sashelp.cars;
  vbar type / response=mpg_city stat=mean 
  	barwidth=0.6 fillattrs=graphdata4 limits=both 
    baselineattrs=(thickness=0);
  xaxis display=(nolabel);
run;

/*&softgreen doesn't work. Removing the & does not work either.

title "Mileage by Type";
proc sgplot data=sashelp.cars noborder;
	format mpg_city 4.1;
	vbar type/response=mpg_city stat=mean
		datalabel dataskin=matte baselineattrs=(thickness=0) 
		fillattrs=(color=&softgreen);
	xaxis display=(nolabel noline noticks);
	yaxis display=(noline noticks) grid;
run;
*/

title "Sales by Type and Quarter for 1994";
proc sgplot data=sashelp.prdsale(where=(year=1994)) noborder;
  format actual dollar8.0;
  vbar product / response=actual stat=sum 
           group=quarter seglabel datalabel 
          baselineattrs=(thickness=0) 
          outlineattrs=(color=cx3f3f3f);
  xaxis display=(nolabel noline noticks);
  yaxis display=(noline noticks) grid;
run;

title "Sales by Type and Year";
proc sgplot data=sashelp.prdsale noborder;
	vbar product /response=actual
		group=year groupdisplay=cluster
		dataskin=pressed
		baselineattrs=(thickness=0);
	xaxis display=(nolabel noline noticks);
	yaxis display=(noline) grid;
run;

title "Sales by Type and Year";
proc sgplot data=sashelp.prdsale noborder;
  styleattrs datacolors=(gold olive);
  vbar product / response=actual  
           group=year groupdisplay=cluster
          dataskin=pressed baselineattrs=(thickness=0) 
          filltype=gradient datalabel;
  xaxis display=(nolabel noline noticks);
  yaxis display=(noline) grid;
run;

/* &softgreen as written in the blog does not work. */
title "Sales by Type, Year and Quarter";
proc sgpanel data=sashelp.prdsale;
	styleattrs datacolors=(gold olive green silver);
	panelby product/onepanel rows=1 noborder layout=columnlattice
		noheaderborder novarname colheaderpos=bottom;
	vbar year/response=actual stat=sum group=quarter barwidth=1
		dataskin=pressed baselineattrs=(thickness=0) filltype=gradient;
	colaxis display=(nolabel noline noticks) valueattrs=(size=7);
	rowaxis display=(noline nolabel noticks) grid;
run;

title "Mileage by Type";
proc sgplot data=sashelp.cars noborder;
  styleattrs datacolors=(olive gold);
  vbar type / response=mpg_city stat=mean 
           dataskin=pressed baselineattrs=(thickness=0) ;
  vbar type / response=mpg_highway stat=mean 
          dataskin=pressed baselineattrs=(thickness=0) 
         barwidth=0.5;
  xaxis display=(nolabel noline noticks);
  yaxis display=(noline) grid;
run;

title "Mileage by Type";
proc sgplot data=sashelp.cars noborder;
  styleattrs datacolors=(brown olive);
  vbar type / response=mpg_highway stat=mean 
           dataskin=pressed barwidth=0.6 
           baselineattrs=(thickness=0) 
           discreteoffset=-0.1;
  vbar type / response=mpg_city stat=mean 
          dataskin=pressed barwidth=0.6 
          baselineattrs=(thickness=0)
          discreteoffset= 0.1;
  xaxis display=(nolabel noline noticks);
  yaxis display=(noline) grid;
run;

/******************************************************************************
 							Part 2, VBOX
*******************************************************************************/
title "Distribution of Cholesterol";
proc sgplot data=sashelp.heart;
	vbox cholesterol;
run;

title "Distribution of Cholesterol by Death Cause";
proc sgplot data=sashelp.heart;
	vbox cholesterol/category=deathcause;
	xaxis display=(nolabel);
run;

title "Distribution of Cholesterol by Death Cause";
proc sgplot data=sashelp.heart;
	vbox cholesterol/category=deathcause
		connect=mean fillattrs=graphdata3
		dataskin=gloss;
	xaxis display=(noline nolabel noticks);
	yaxis display=(noline nolabel noticks) grid;
run;

title "Distribution of Cholesterol by Death Cause";
proc sgplot data=sashelp.heart noborder;
	vbox cholesterol/category=deathcause
		group=sex clusterwidth=0.5
		boxwidth=0.8 meanattrs=(size=5)
		outlierattrs=(size=5);
	xaxis display=(noline nolabel noticks);
	yaxis display=(noline nolabel noticks) grid;
run;

title "Distribution of Cholesterol by Death Cause";
proc sgplot data=sashelp.heart noborder;
  vbox cholesterol / category=deathcause 
            boxwidth=0.2 meanattrs=(size=6) 
            notches capshape=none;
  xaxis display=(noline nolabel noticks);
  yaxis display=(noline noticks nolabel) grid;
run;
