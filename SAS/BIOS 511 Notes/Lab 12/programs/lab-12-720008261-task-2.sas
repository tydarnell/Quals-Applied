/*****************************************************************************
* Project           : BIOS 511 Lab 12, Task 2
*
* Program name      : lab-12-720008261-task-2.sas
*
* Author            : Linran Zhou (LZ)
*
* Date created      : 2018-11-27
*
* Purpose           : This program is submitted for Lab 12, Task 2
*                      
*
* Revision History  : 1.0
*
* Date          Author   Ref (#)  Revision
* 2018-11-27     LZ       1      Created program for lab.
*                                  
*
*
* searchable reference phrase: *** [#] ***;
*
* Note: Standard header taken from :
*  https://www.phusewiki.org/wiki/index.php?title=Program_Header
******************************************************************************/
%let root= C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab 12;
%let echoDat= C:\Users\linra\Documents\UNC Masters Degree\Fall 2018\BIOS 511\Lab Data\echo;
%let analysisDat= &root.\data;
%let outputPath= &root.\output;
%let macroPath= &root.\macros;



libname echo "&echoDat."	access=read;
libname out "&analysisDat."	access=read;

ods noptitle; option nonumber nodate;

%include "&macroPath./codebook-720008261.sas";

ods pdf file="&outputPath./ADSL_Codebook.pdf" style=sasweb;
	%codebook(lib=out,ds=adsl,maxVal=15);
ods pdf close;

ods pdf file="&outputPath./DM_Codebook.pdf" style=sasweb;
	%codebook(lib=echo,ds=dm);
ods pdf close;