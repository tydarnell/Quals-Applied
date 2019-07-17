/*****************************************************************************
* Project           : BIOS 511 Lab 1
*
* Program name      : lab-01-720008261.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-08-28
*
* Purpose           : This program is submitted for Lab 1.
*                      
*
* Revision History  : 1.0
*
* Date          Author   Ref (#)  Revision
* 2018-08-28     LZ       1      Created program for lab.
*                                  
*
*
* searchable reference phrase: *** [#] ***;
*
* Note: Standard header taken from :
*  https://www.phusewiki.org/wiki/index.php?title=Program_Header
******************************************************************************/
ods noproctitle;

/*Initializing Orion library*/

%let path=C:/Users/linra/ecprg193; 
libname orion "&path";


/********************************************************************************************************
 									SAS Code for Section #2
*********************************************************************************************************/
proc print data=orion.employee_payroll (obs=10);
	title 'First 10 Observations of Employee Payroll Data Set';
	run;

proc univariate data=orion.employee_payroll;
	var salary;
	title 'Descriptive Statistics for Salary';
	run;

/**********************************************************************************************************
 									SAS Code for Section #4
***********************************************************************************************************/
ods trace on;
proc print data=orion.employee_payroll (obs=10);
	title 'First 10 Observations of Employee Payroll Data Set';
	run;

proc univariate data=orion.employee_payroll;
	var salary;
	title 'Descriptive Statistics for Salary';
	run;
ods trace off;

/**********************************************************************************************************
 									SAS Code for Section #9
***********************************************************************************************************/
ods pdf file = 'C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 1\Lab 01 Output/freq9.pdf';
	proc freq data = orion.customer;
		tables country gender country*gender;
		title 'Frequency Distributions and Cross-tabluations';
		run;
ods pdf close;

/**********************************************************************************************************
 									SAS Code for Section #10
***********************************************************************************************************/
ods rtf file = 'C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 1\Lab 01 Output/freq10.rtf';
proc freq data = orion.customer;
	tables country gender country*gender;
	title 'Frequency Distributions and Cross-tabulations';
	run;
ods rtf close;

ods rtf file = 'C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 1\Lab 01 Output/freq10_bodytitle.rtf' bodytitle;
proc freq data = orion.customer;
	tables country gender country*gender;
	title 'Frequency Distributions and Cross-tabulations';
	run;
ods rtf close;

/**********************************************************************************************************
 									SAS Code for Section #11
***********************************************************************************************************/
ods html file = 'C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 1\Lab 01 Output/freq11.html';
proc freq data = orion.customer;
	tables country gender country*gender;
	title 'Frequency Distributions and Cross-tabulations';
	run;
ods html close;

/**********************************************************************************************************
 									SAS Code for Section #13
***********************************************************************************************************/
ods pdf file = 'C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 1\Lab 01 Output/select_exclude13.pdf';

title "Moments and Extreme Observations";
ods select moments extremeobs;
proc univariate data=orion.employee_payroll;
	var salary;
run;

title "Basic Measures, Tests for Location, and Quantitles";
ods exclude moments extremeobs;
proc univariate data=orion.employee_payroll;
	var salary;
run;

title "All Univariate Procedure Output";
proc univariate data=orion.employee_payroll;
	var salary;
run;

/*ODS SELECT and EXCLUDE statements are "consumed" by a proc statement, so each one only stays in effect
for one proc statement.*/
ods pdf close;

/**********************************************************************************************************
 									SAS Code for Section #15
***********************************************************************************************************/
ods pdf file = 'C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 1\Lab 01 Output/ods_output_15.pdf';

ods pdf select quantiles;
ods output quantiles = salary_quant;
proc univariate data = orion.employee_payroll;
	var salary;
run;

title "Quantiles for Salary Variable";
proc print data = salary_quant; 
run;

ods pdf close;
/**********************************************************************************************************
 									SAS Code for Section #17
***********************************************************************************************************/
ods pdf file = 'C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 1\Lab 01 Output/fav_style17.pdf' style=journal;
proc freq data=orion.customer;
	tables country gender country*gender;
	title 'Frequency Distributions and Cross-tabulations';
run;
ods pdf close;
/**********************************************************************************************************
 									SAS Code for Section #18
***********************************************************************************************************/
ods pdf file = 'C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 1\Lab 01 Output/start_page18.pdf' 
				style=journal
				startpage=no;

title1 'Descriptive Statistics for Price Variable';
proc means data=orion.employee_payroll;
	class employee_gender;
	var salary;
run;

ods pdf startpage=now;

ods select extremeobs;
proc univariate data=orion.employee_payroll;
	var salary;
run;

ods pdf close;
title;
/**********************************************************************************************************
 									SAS Code for Section #19
***********************************************************************************************************/
ods pdf file = 'C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 1\Lab 01 Output/contents19.pdf'
				style=minimal
				startpage=no;

ods pdf select variables;
proc contents data=orion.employee_payroll;
run;

ods pdf select variables;
proc contents data=orion.employee_addresses;
run;

ods pdf select variables;
proc contents data=orion.employee_donations;
run;

ods pdf close;