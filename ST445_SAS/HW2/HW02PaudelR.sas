
*Include an OPTIONS statement that includes FMTSEARCH = (InputDS);
options number pageno=1 FMTSEARCH= (InputDS) nodate;

*Create the InputDS libref and Raw Data fileref with using relative paths.;
x "cd L:\st445\data";
libname InputDS ".";
filename RawData ".";

*Rabin SAS Directory in HW2 folder;
x "cd S:\Documents\HW2";
libname HW2 ".";

*Read in the Baseball.dat file from our shared library on the L drive.;
data HW2.Baseball;
  attrib  FName    label     = 'First Name' 
          LName    label     = 'Last Name'                         
          Team     label     = 'Team at the end of 1986' 
          nAtBat   label     = '# Of At Bats in 1986'
          nHits    label     = '# Of Hits in 1986' 
          nHome    label     = '# Of Home Runs in 1986' 
          nRuns    label     = '# Of Runs in 1986' 
          nRBI     label     = '# Of RBIs in 1986'
          nBB      label     = '# Of Walks in 1986' 
          YrMajor  label     = '# Of Years in the Major Leagues' 
          CrAtBat  label     = '# Of At Bats in Career' 
          CrHits   label     = '# Of Hits in Career' 
          CrHome   label     = '# Of Home Runs in Career' 
          CrRuns   label     = '# Of Runs in Career' 
          CrRbi    label     = '# Of RBIs in career'
          CrBB     label     = '# Of Walks in Career' 
          League   label     = 'League at the end of 1986' 
          Division label     = 'Division at the end of 1986' 
          Position label     = 'Position(s) Played' 
          nOuts    label     = '# Of Put Outs in 1986' 
          nAssts   label     = '# Of Assists in 1986' 
          nError   label     = '# Of Errors in 1986' 
          Salary   label     = 'Salary (Thousands of Dollars)' 
; 
  infile  RawData ("Baseball.dat")  dlm = '092c'X firstobs =14;
  length  LName $11     FName $ 9      Team $ 13      League $8       Division $4       Position $3;
  input   LName $       FName          Team           nAtBat  51-53   nHits    54-57    nHome 58-61 
          nRuns  62-65  nRBI   66-69   nBB    70-73   YrMajor 74-77   CrAtBat  78-82    CrHits 83-86 
          CrHome 87-90  CrRuns 91-94   CrRbi  95-98   CrBB    99-102  League            Division 
          Position      nOuts  133-136 nAssts 137-140 nError  143-144 Salary;
  format  Salary  dollar10.3;
run;

*Set RTF includes results;
ods rtf file = "HW2 Paudel Baseball Report.rtf" style = Sapphire;
ods listing close;
ods noproctitle;

*Use select position to see the variable names and labels.;
title 'Variable-Level Metadata (Descriptor) Information';
ods select position;
proc contents data=HW2.Baseball varnum;
run;
title;

*Define custom format to the Salary variable.;
title 'Salary Format Details';
proc format fmtlib;
  Value Salary (fuzz = 0) .         =  'Missing'
                          0         =  'None'
                          0<-190    =  'First Quartile'
                          190<-425  =  'Second Quartile'
                          425<-750  =  'Third Quartile'
                          750<-2460 =  'Fourth Quartile'
                          other     =  'Unclassified'
;
run;
title;

*Set PDF includes output distinations;
ods pdf file = "HW2 Paudel Baseball Report.pdf" style = Journal;

*PROC Mean Result and Using MISSING option.;
title "Five Number Summaries of Selected Batting Statistics";
title2 h=10pt "Grouped by League (1986), Division (1986),and Salary Category (1987)";
proc means data=HW2.Baseball min P25 P50 P75 max maxdec=2 nolabels;
  class League Division Salary/ Missing ;
  var nHits nhome nRuns nRBI nBB;
  format Salary Salary. ;
run;
title;
title2;

*PROC freq Result and Using MISSING option.;
title "Breakdown of Players by Position and Position by Salary";
proc freq data=HW2.Baseball  ;
  tables position position*Salary/Missing;
  format Salary Salary.;
run;
title;

*Sort the data needed for next step.;
proc sort data=HW2.Baseball;
  by league division team decending salary ;
run;

*Produce needed information After sorting and try to match provided report.;
title "Listing of Selected 1986 Players";
footnote j= left h=8pt "Included: Players with Salaries of at least $1,000,000 or who played for the Chicago Cubs";
proc print data=HW2.Baseball noobs label;
  where (salary >=1000 or (team = "Chicago" & league ~= "American")) & salary ne .;
  id Lname Fname Position;
  var league division team salary nHits nHome nRuns nRBI NBB ;
  format salary       dollar11.3 
         nHits        comma10. 
         nRuns        comma9. 
         nRBI         comma9. 
         NBB          comma9.
;
  sum salary nHits nHome nRuns nRBI NBB ;
run;
title;
footnote;

*Close PDF and rtf open LISTING destinations.;
ods rtf close;
ods pdf close;
ods listing;

quit;
