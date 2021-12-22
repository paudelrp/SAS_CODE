
*Include an OPTIONS statement that includes FMTSEARCH = (InputDS);
options number pageno=1 FMTSEARCH= (InputDS) nodate;

* Try to get result path compare my data. ;
x "cd L:\st445\Results"; 
libname NEW ".";

*Create the InputDS libref and Raw Data fileref with using relative paths.;
x "cd L:\st445\data\BookData\Data\Clinical Trial Case Study";
libname InputDS ".";
filename RawData ".";

*Rabin SAS Directory in HW3 folder;
x "cd S:\Documents\HW3";
libname HW3 ".";
filename HW3 ".";

*Read in the Baseline Visit.txt file from our shared library on the L drive.;
data HW3.PaudelSite1;
  attrib  Subj        label     =  'Subject Number' 
          sfReas      label     =  'Screen Failure Reason'                         
          sfStatus    label     =  'Screen Falure Status (0=Failed)' 
          BioSex      label     =  'Biological Sex'
          VisitDate   label     =  'Visit Date ' 
          failDate    label     =  'Failure Notification Date' 
          sbp         label     =  'Systolic Blood Pressure' 
          dbp         label     =  'Diastolic Blood Pressure'
          bpUnits     label     =  'Units (BP)' 
          pulse       label     =  'Pulse' 
          pulseUnits  label     =  'Units(Pulse)' 
          position    label     =  'Position' 
          temp        label     =  'Temperature' 
          tempUnits   label     =  'Units(Temp)' 
          weight      label     =  'Weight'
          weightUnits label     =  'Units(Weight)' 
          pain        label     =  'Pain Score' 
        ;
  infile RawData ('Site 1, Baselilne Visit.txt') dlm = '09'X dsd firstobs =1  ;
  input Subj             sfReas:    $50.   sfStatus : $1. BioSex :    $1.    VisitDate : $9. 
        failDate :   $9. sbp               dbp            bpUnits :   $5.    pulse         
        pulseUnits : $9. position : $9.    temp           tempUnits : $1.    weight  
        weightUnits :$2. pain ;
  format temp 5.1;
run;

data HW3.PaudelSite2;
  attrib  Subj        label     =  'Subject Number' 
          sfReas      label     =  'Screen Failure Reason'                         
          sfStatus    label     =  'Screen Falure Status (0=Failed)' 
          BioSex      label     =  'Biological Sex'
          VisitDate   label     =  'Visit Date ' 
          failDate    label     =  'Failure Notification Date' 
          sbp         label     =  'Systolic Blood Pressure' 
          dbp         label     =  'Diastolic Blood Pressure'
          bpUnits     label     =  'Units (BP)' 
          pulse       label     =  'Pulse' 
          pulseUnits  label     =  'Units(Pulse)' 
          position    label     =  'Position' 
          temp        label     =  'Temperature' 
          tempUnits   label     =  'Units(Temp)' 
          weight      label     =  'Weight'
          weightUnits label     =  'Units(Weight)' 
          pain        label     =  'Pain Score' 
        ;
  infile RawData ('Site 2, Baseline Visit.csv') dsd firstobs = 1;
  input Subj              sfReas   : $50. sfStatus : $1.  BioSex    : $1.     VisitDate : $10. 
        failDate   : $10. sbp             dbp             bpUnits   : $5.     pulse  
        pulseUnits : $9.  position : $9.  temp            tempUnits : $1.     weight  
        weightUnits: $2.  pain ;
  format temp 3.1;
run;


data HW3.PaudelSite3;
  attrib  Subj        label     =  'Subject Number' 
          sfReas      label     =  'Screen Failure Reason'                         
          sfStatus    label     =  'Screen Falure Status (0=Failed)' 
          BioSex      label     =  'Biological Sex'
          VisitDate   label     =  'Visit Date ' 
          failDate    label     =  'Failure Notification Date' 
          sbp         label     =  'Systolic Blood Pressure' 
          dbp         label     =  'Diastolic Blood Pressure'
          bpUnits     label     =  'Units (BP)' 
          pulse       label     =  'Pulse' 
          pulseUnits  label     =  'Units(Pulse)' 
          position    label     =  'Position' 
          temp        label     =  'Temperature' 
          tempUnits   label     =  'Units(Temp)' 
          weight      label     =  'Weight'
          weightUnits label     =  'Units(Weight)' 
          pain        label     =  'Pain Score' 
        ;
  infile RawData ('Site 3, Baseline Visit.dat') dlm = '09'X  dsd firstobs =1  ;
  input      Subj       1-7        @8 sfReas    $50.       @59 sfStatus $1.        @62 BioSex $1.       @63 VisitDate : $10.  
        @73  failDate $ 73-82      @83 sbp      83-85      @86 dbp       86-88     @89 bpUnits $ 89-93  @95  pulse $ 95-97   
        @98 pulseUnits $ 98-106    @108 position $ 108-116 @121 temp    121-123    @124 tempUnits $ 124 @125 weight  125-127 
        @128 weightUnits $ 128-129 @132 pain ;
  format temp 3.1;
run;


*Try to compare my data with Duggins data and using ABSOLUTE method with a CRITERION of 1E-10 for numeric differences.;
proc compare base = NEW.hw3dugginssite1 compare = HW3.PaudelSite1 out = Work.Diffs1
             outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-10;
run;

proc compare base = NEW.hw3dugginssite2 compare = HW3.PaudelSite2 out = Work.Diffs2
             outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-10;
run;

proc compare base = NEW.hw3dugginssite3 compare = HW3.PaudelSite3 out = Work.Diffs3
             outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-10;
run;


*Set PDF and RTF includes results file.;
ods pdf file = "HW3 Paudel Clinical Report.pdf" columns=1 ;
ods rtf file = "HW3 Paudel Clinical Report.rtf" style = Sapphire;
ods noproctitle;
ods select position;

proc sort data=HW3.PaudelSite1 out=PaudelSite1;
  by descending sfStatus sfReas Descending VisitDate Descending failDate Subj;
run;

*Use select position to see the variable names and labels also sort the data.;
title 'Variable-Level Attributes and Sort Information: Site 1';
ods exclude Attributes;
ods exclude EngineHost;
proc contents data=work.PaudelSite1 varnum;
run;
title;

proc sort data=HW3.PaudelSite2 out=PaudelSite2;
  by descending sfStatus sfReas Descending VisitDate Descending failDate Subj;
run;

title 'Variable-Level Attributes and Sort Information: Site 2';
ods exclude Attributes;
ods exclude EngineHost;
proc contents data=work.PaudelSite2 varnum;
run;
title;

proc sort data=HW3.PaudelSite3 out=PaudelSite3;
  by descending sfStatus sfReas Descending VisitDate Descending failDate Subj;
run;

title 'Variable-Level Attributes and Sort Information: Site 3';
ods exclude Attributes;
ods exclude EngineHost;
proc contents data=work.PaudelSite3 varnum;
run;
title;

*Out put distation powerpoint data and also using proc mean data.;
ods powerpoint file = "HW3 Paudel Clinical Report.pptx" style = PowerPointDark;
title "Selected Summary Statistics on Baseline Measurements";
title2  "for Patients from Site 1";
footnote j= left h=8pt "Statistic and SAS keyword: Sample size(n), Mean(mean), Standard Deviation (stddev), Median(median), IGR(qrange)";
proc means data=HW3.PaudelSite1 n mean stddev median qrange maxdec =1 nonobs  ;
  class pain;
  var  weight temp pulse  dbp sbp ;
run;
title;
title2;
footnote;

*Applied a custom format to (DBP & SBP) variables.;
proc format;
  value sbp (fuzz = 0)
  0 -< 130 = 'Acceptable'
  130 - high = 'High'
  ;
  value dbp (fuzz=0)
  0 -< 80 = 'Acceptable'
  80  - high = 'High'
  ;
run;


title "Frequency Analysis of Baseline Positions and Pain Measurements by Blood Pressure Status";
title2 "for Patients from Site 2";
footnote j = left 'Hypertension (high blood pressure) begins when systolic reaches 130 or diastolic 80' ;
*ods output create colums with in pdf file;
ods pdf columns=2 ;
proc freq data=HW3.PaudelSite2;
  tables position  pain*dbp*sbp/nocol norow ;
  format dbp dbp. sbp sbp.;
run;
title;
title2;
ods powerpoint close;

*ods outpute again create columns 1 options ;
ods pdf columns=1 ;
title 'Selected Listing of Patients with a Screen Failure and Hypertension';
title2 'for patients from Site 3';
footnote2 j= left 'only patients with a screen failure are included.';
*Produce needed information After sorting and try to match provided report.;
proc print data=PaudelSite3 noobs label;
  id  subj pain;
  var visitDate sfStatus sfReas failDate BioSex sbp dbp bpUnits weight weightUnits;
  where (sfstatus in ('0')&(dbp >=80)) ;
run;
title;
footnote;
footnote2;
*Close PDF and RTF open LISTING destinations.;

ods pdf close;
ods rtf close;
ods listing;
quit;


