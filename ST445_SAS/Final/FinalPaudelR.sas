
*Option nota and FMTSEARCH for format.;
options number pageno=1 FMTSEARCH= (Final) nodate label;
*Result folder libref.;
x "cd L:\st445\Results";
libname Results ".";

*The clinical trial folder use and InputDS libref and RawData fileref.;
x "cd L:\st445\data\BookData\Data\Clinical Trial Case Study";
libname InputDS ".";
filename RawData ".";

*My library for strong result be called Final.;
x "cd S:\Documents\Final";
libname Final ".";
filename Final ".";

*All images use 300 dpi.;
ods _all_ close;
ods listing image_dpi = 300;

*I created three format, but instruction said four. I had no idea for other format;
proc format library = Final;
  value $screen  (fuzz=0) 0  = 'Fail'
                          1  = 'Pass'
  ;
  value $Sex (fuzz=0)     F = 'Female'
                          M = 'Male'
  ;
  value sbp (fuzz = 0)
                          0 <-120     = 'Acceptable(120 or below)'
                          120 <- high = 'High'
  ;
run;

*Read Site 1, Baseline Visit.txt data.;
data Final.PaudelSite1(drop =_:);
attrib   Subject        label   = 'Subject Number'
         sf_reason      label   = 'Screen Failure Reason'              length = $ 50
         screen         label   = 'Screening Flag, 0=Failure, 1= Pass' length = $ 1
         Sex            length  = $ 1
         DOV            label   = 'Date of Visit'
         _DOV           length  = $9
         notif_date     label   = ' Notification Date'                 length = $ 9
         sbp            label   = 'Systolic Blood Pressure'
         dbp            label   = 'Diastolic Blood Pressure'
         bpUnits        label   = 'BP Units'                           length = $ 5
         pulse          label   = 'Pulse'
         pulseUnits     label   = 'Pulse Units'                        length = $ 9
         pos            label   = 'Position'                           length = $ 9
         temp           label   = 'Temperature'                                     format = 5.1
         tempUnits      label   = 'Temperature Units'                  length = $ 1
         weight         label   = 'Weight'
         weightUnits    label   = 'Weight Units'                       length = $ 2

  ;

  infile RawData ('Site 1, Baselilne Visit.txt') dlm = '09'X truncover dsd ;
  input Subject             sf_reason  $   Screen  $      Sex       $      _DOV    $
        notif_date   $      sbp            dbp            bpUnits   $      pulse
        pulseUnits   $      Pos        $   temp           tempUnits $      weight
        weightUnits  $      pain           start_trt ;
  format temp 5.1 ;
  DOV=input(_DOV,date9.);
  format DOV date9.;
run;


*Output destination: All output objects are sent to the pdf. It uses the Meadow style. ;
*RTF: All tbles are sent to the rtf, but no figures. It uses the Sapphire style.;
*PowerPoint: Only 8.2.4,8.2.5,8.6.3,and 8.7.1. It uses the PowerPointDark style.;
ods pdf file = "Paudel Final Report Site 1.pdf" style = Meadow;
ods rtf file = "Paudel Final Report Site 1.rtf" style = Sapphire;
ods powerpoint file = " Paudel Final Report Site 1.pptx" style = PowerPointDark;
ods noproctitle;
*Controlling Powerpoint output and Using some format. and trying to match book table.;
ods powerpoint exclude all;
title 'Output 8.2.3: Sex Versus Pain Level Split on Screen Failure Versus Pass, Site 1 Baseline';
proc freq data=Final.PaudelSite1;
  tables  screen*sex*pain/nocol;
  format  screen $screen. sex $Sex.;
run;
title;
ods powerpoint exclude none;

title  'Output 8.2.4: Sex Versus Screen Failure at Baseline Visit in Site 1';
proc freq data=Final.PaudelSite1 ;
  table sex*sf_reason/nocol nopercent;
  format  sex $Sex.;
run;
title;

title 'Output 8.2.5: Diastolic Blood Pressure and Pulse Summary Statistics at Baseline Visit in Site 1';
proc means data=Final.PaudelSite1 n mean stddev min max maxdec =1  ;
  class sex sbp;
  var dbp pulse;
  format sbp sbp. sex $sex.;
run;
title;


*Read Site 1, Baseline Lab Results.txt data. ;
option label;
data Final.Baseline(drop = _:);
attrib   Subject          label = 'Subject'
         DOV              label = 'Date Of Visit'                         length = $ 9
         Notif_Date       label = ' Notification Date'                    length = $ 9
         _SF_Reas         label = 'Screen Failure Reason'
         screen           label = 'Screening Flag, 0=Failure, 1= Pass'    length = $ 1
         Sex                                                              length = $ 1
         ALB              label = 'Chem-Albumin, g/dL'
         Alk_Phos         label = ' Chem-ALk. Phos.,IU/L'
         ALT              label = 'Chem-Alt,IU/L'
         AST              label = 'Chem-AST, IU/L'
         D_Bili           label = 'Chem-Dir. Birirubin, mg/dL'
         GGTP             label = 'Chem-GGTP,IU/L'
         C_Gluc           label = 'Chem-Glucose, mg/dL'
         U_Gluc           label = 'Uri.-Glucose,1label = high'
         Hemattocr        label = 'EVF/PCV,%'
         Hemoglob         label = 'Hemoglobin,g/DL'
         T_Bili           label = 'Chem-Tot. Bilirubin, mg/dL'
         Prot             label = 'Chem-Tot. Prot., g/dL'
         Preg             label = 'Pregnancy Flag,1 = Pregnant, 0 = Not'
       ;
infile   RawData ('Site 1, Baseline Lab Results.txt') dlm = '09'X dsd;
  input  Subject    DOV    $  Notif_Date $  _SF_Reas  Screen  $  Sex  $  ALB
         Alk_Phos   ALT       AST           D_Bili    GGTP
         C_Gluc     U_Gluc    T_Bili        Prot      Hemoglob
         Hemattocr  Preg;

run;

*Controlling powerpoint.;
ods powerpoint exclude all;
option nolabel;
title 'Output 8.2.6: Glucose and Hemoglobin Summary Statistics from Baseline Lab Results, Site 1';
proc means data=Final.Baseline min q1 median q3 max maxdec =1  ;
  class  sex ;
  var    c_gluc  hemoglob;
  format sex $sex.;
run;
title;

*Using some special formats eg monyy7. and try to match book fiures. and reset 6 inches wide.;
ods pdf exclude all;
title 'Output 8.3.2: Recruits that Pass Initial Screening, by Month in Site 1';
ods graphics / reset width = 6in imagename = "FinalFIRST";
proc sgplot data = Final.PaudelSite1;
  vbar dov  /group=sex groupdisplay=cluster stat=mean;
  format DOV monyy7.;
  where screen eq '1';
  xaxis label = 'Month';
  yaxis label = 'Passed Screening at Baseline Visit';
  keylegend / location = Inside position = topleft title ='';
run;
title;

title 'Output 8.3.3: Average Albumin Results�Baseline Lab, Site 1';
proc sgplot data = Final.Baseline;
  hbar sex /response=ALB stat=mean dataskin=gloss limits=upper;
  xaxis label = 'Chem-Albumin, g/dL';
  yaxis display = (nolabel);
  keylegend / location = Outside  position= bottom title = '';
run;
title;

*Read Site 1, 3 Month Lab Results.txt data.;
option label;
data Final.Month3;
attrib   Subject        label = 'Subject'
         DOV            label = 'Date Of Visit'                      length = $ 9
         Notif_Date     label = ' Notification Date'                 length = $ 9
         SF_Reas        label = 'Screen Failure Reason'
         screen         label = 'Screening Flag, 0=Failure, 1= Pass' length = $ 1
         Sex                                                         length = $ 1
         ALB            label = 'Chem-Albumin, g/dL'
         Alk_Phos       label = ' Chem-ALk. Phos.,IU/L'
         ALT            label = 'Chem-Alt,IU/L'
         AST            label = 'Chem-AST, IU/L'
         D_Bili         label = 'Chem-Dir. Birirubin, mg/dL'
         GGTP           label = 'Chem-GGTP,IU/L'
         C_Gluc         label = 'Chem-Glucose, mg/dL'
         U_Gluc         label = 'Uri.-Glucose,1label = high'
         T_Bili         label = 'Chem-Tot. Bilirubin, mg/dL'
         Prot           label = 'Chem-Tot. Prot., g/dL'
         Hemoglob       label = 'Hemoglobin,g/DL'
         Hemattocr      label = 'EVF/PCV,%'
         Preg           label = 'Pregnancy Flag,1 = Pregnant, 0 = Not'

  ;
infile RawData ('Site 1, 3 Month Lab Results.txt') dlm = '09'X dsd ;
  input Subject    DOV    $  Notif_Date $   SF_Reas   Screen  $ Sex $ ALB
        Alk_Phos   ALT       AST            D_Bili    GGTP
        C_Gluc     U_Gluc    T_Bili         Prot      Hemoglob
        Hemattocr  Preg;
run;

*Trying to combine data.;
data Final.BaselineandMonth3;
  set Final.Baseline(in = inBaseline)
  Final.Month3 (in= inMonth3);
  if inBaseline eq 1 then type = 'Baseline';
     else if inMonth3 eq 1 then type = '3Month';
     drop inBaseline inMonth3;
run;

*Creating the output for the out put 8.4.3 and try to match book figure.;
title 'Output 8.4.3: Glucose Distributions, Baseline and 3 Month Visits, Site 1';
proc sgpanel data= Final.BaselineandMonth3;
  panelby   type/novarname headerattrs=(family = 'Georgia');
  histogram C_Gluc / binwidth = 3.4 binstart = 95 scale=proportion;
  colaxis label = 'Chem-Glucose, mg/dL' values = (95 to 125 by 5);
  rowaxis label= 'Percent'  values = (0 to 0.25 by 0.05) valuesformat = percent7.;
  where   C_Gluc gt 0;
run;
title;

*Read: Site 1, 12 Month Visit.txt data.;
option label;
data Final.MonthVisit12(drop = _:);
attrib   Subject        label = 'Subject Number'
         sf_reason      label = 'Screen Failure Reason'              length = $ 50
         screen         label = 'Screening Flag, 0=Failure, 1= Pass' length = $ 1
         Sex                                                         length = $ 1
         DOV            label = 'Date of Visit'
          _DOV                                                       length = $9
         notif_date     label = ' Notification Date'                 length = $ 9
         sbp            label = 'Systolic Blood Pressure'
         dbp            label = 'Diastolic Blood Pressure'
         bpUnits        label = 'BP Units'                           length = $ 5
         pulse          label = 'Pulse'
         pulseUnits     label = 'Pulse Units'                        length = $ 9
         pos            label = 'Position'                           length = $ 9
         temp           label = 'Temperature'                                        format = 5.1
         tempUnits      label = 'Temperature Units'                  length = $ 1
         weight         label = 'Weight'
         weightUnits    label = 'Weight Units'                       length = $ 2

  ;

  infile RawData ('Site 1, 12 Month Visit.txt') dlm = '09'X truncover dsd;
  input Subject             sf_reason    $   Screen  $ Sex  $   _DOV  $
        notif_date $        sbp              dbp                bpUnits $     pulse
        pulseUnits $        Pos $            temp               tempUnits $   weight
        weightUnits  $      pain             start_trt;
  format temp 5.1 ;
  DOV=input(_DOV,date9.);
  format DOV date9.;
  *Try to manage date format.;
run;
*Read: Site 1, 9 Month Visit.txt data.;
option label;
data Final.MonthVisit9(drop = _:);
attrib   Subject        label = 'Subject Number'
         sf_reason      label = 'Screen Failure Reason'              length = $ 50
         screen         label = 'Screening Flag, 0=Failure, 1= Pass' length = $ 1
         Sex                                                         length = $ 1
         DOV            label = 'Date of Visit'
          _DOV                                                       length = $9
         notif_date     label = ' Notification Date'                 length = $ 9
         sbp            label = 'Systolic Blood Pressure'
         dbp            label = 'Diastolic Blood Pressure'
         bpUnits        label = 'BP Units'                           length = $ 5
         pulse          label = 'Pulse'
         pulseUnits     label = 'Pulse Units'                        length = $ 9
         pos            label = 'Position'                           length = $ 9
         temp           label = 'Temperature'                                        format = 5.1
         tempUnits      label = 'Temperature Units'                  length = $ 1
         weight         label = 'Weight'
         weightUnits    label = 'Weight Units'                       length = $ 2

  ;

  infile RawData ('Site 1, 9 Month Visit.txt') dlm = '09'X truncover dsd  ;
  input Subject             sf_reason    $    Screen  $      Sex  $       _DOV  $
        notif_date $        sbp               dbp            bpUnits $    pulse
        pulseUnits $        Pos          $    temp           tempUnits $  weight
        weightUnits  $      pain start_trt;
  format temp 5.1 ;
  DOV=input(_DOV,date9.);
  format DOV date9.;


run;

*Read:Site 1, 6 Month Visit.txt data. ;
option label;
data Final.MonthVisit6(drop = _:);
attrib   Subject        label = 'Subject Number'
         sf_reason      label = 'Screen Failure Reason'              length = $ 50
         screen         label = 'Screening Flag, 0=Failure, 1= Pass' length = $ 1
         Sex                                                         length = $ 1
         DOV            label = 'Date of Visit'
         _DOV                                                        length = $9
         notif_date     label = ' Notification Date'                 length = $ 9
         sbp            label = 'Systolic Blood Pressure'
         dbp            label = 'Diastolic Blood Pressure'
         bpUnits        label = 'BP Units'                           length = $ 5
         pulse          label = 'Pulse'
         pulseUnits     label = 'Pulse Units'                        length = $ 9
         pos            label = 'Position'                           length = $ 9
         temp           label = 'Temperature'                                       format = 5.1
         tempUnits      label = 'Temperature Units'                  length = $ 1
         weight         label = 'Weight'
         weightUnits    label = 'Weight Units'                       length = $ 2

  ;

  infile RawData ('Site 1, 6 Month Visit.txt') dlm = '09'X truncover dsd ;
  input Subject             sf_reason    $   Screen  $          Sex  $        _DOV  $
        notif_date $        sbp              dbp                bpUnits $      pulse
        pulseUnits $        Pos $            temp               tempUnits $    weight
        weightUnits  $      pain             start_trt;
  format temp 5.1 ;
  DOV=input(_DOV,date9.);
  format DOV date9.;
run;

*Read the data: Site 1, 3 Month Visit.txt;
option label;
data Final.MonthVisit3(drop =_:);
attrib   Subject        label = 'Subject Number'
         sf_reason      label = 'Screen Failure Reason'              length = $ 50
         screen         label = 'Screening Flag, 0=Failure, 1= Pass' length = $ 1
         Sex                                                         length = $ 1
         DOV            label = 'Date of Visit'
         _DOV                                                        length = $9
         notif_date     label = ' Notification Date'                 length = $ 9
         sbp            label = 'Systolic Blood Pressure'
         dbp            label = 'Diastolic Blood Pressure'
         bpUnits        label = 'BP Units'                           length = $ 5
         pulse          label = 'Pulse'
         pulseUnits     label = 'Pulse Units'                        length = $ 9
         pos            label = 'Position'                           length = $ 9
         temp           label = 'Temperature'                                         format = 5.1
         tempUnits      label = 'Temperature Units'                  length = $ 1
         weight         label = 'Weight'
         weightUnits    label = 'Weight Units'                       length = $ 2

  ;

  infile RawData ('Site 1, 3 Month Visit.txt') dlm = '09'X truncover dsd;
  input Subject             sf_reason    $    Screen  $ Sex  $   _DOV  $
        notif_date $        sbp               dbp                bpUnits $     pulse
        pulseUnits $        Pos $             temp               tempUnits $   weight
        weightUnits  $      pain              start_trt;
  format temp 5.1 ;
  DOV=input(_DOV,date9.);
  format DOV date9.;
run;

*Try to combine all data.;
data Final.BaselineandMonthT(drop =_:);
 set Final.PaudelSite1(in = inP)
      Final.MonthVisit3 (in= inM3)
      Final.MonthVisit6 (in= inM6)
      Final.MonthVisit9 (in= inM9)
      Final.MonthVisit12 (in= inM12);
      _code = 1* inP + 2 * inM3 + 3 *inM6 + 4 *inM9 + 5*inM12;
      attrib visit length = $15;
  if _code eq 1 then visit = 'Baseline Visit';
      else if _code eq 2 then visit = '3 Month Visit';
      else if _code eq 3 then visit = '6 Month Visit';
      else if _code eq 4 then visit = '9 Month Visit';
      else if _code eq 5 then visit = '12 Month Visit';
run;

*Try to sort data.;
proc sort data = Final.BaselineandMonthT out = Final.BaselineandMonthT2 ;
  by subject;
run;

*Creating some table and trying to match book table.;
ods rtf exclude all;
proc means data= Final.BaselineandMonthT  p25 p75;
  class visit;
  var sbp;
  ods output summary= work.BaselineandMonthTT;
run;
ods rtf exclude none;

*Creating the bar diagram and trying to match book figure with some change.;
title 'Output 8.4.4: Systolic Blood Pressure Quartiles, Site 1';
proc sgplot data= work.BaselineandMonthTT;
  highlow x=visit low=sbp_p25 high=sbp_P75/type = bar fillattrs =(color = cx3399FF) barwidth=.3 ;
  xaxis label = 'Visit';
  yaxis label= 'Systolic BP--Q1 to Q3 Span' values = (95 to 125 by 5);
run;
title;

*Arrange the data.;
ods pdf exclude none;
proc transpose data= Final.BaselineandMonthT2 (obs =38)out= Final.BaselineandMonthT3( rename=(Baseline_Visit=Vis1
  _3_Month_Visit=Vis2 _6_Month_Visit=Vis3 _9_Month_Visit=Vis4 _12_Month_Visit=Vis5)) ;
  by subject;
  id visit;
  var dov ;
  where subject not in (3 5 7);
  format dov mmddyy10.;
run;

*Again re arrange the data set BaselineandMonthT2 using some function and try to match book table.;
data Final.BaselineandMonthT4;
  set Final.BaselineandMonthT3;
  Days = intck('day', Vis1,Vis5);
  if subject eq 4 then Days = intck('day',Vis1,Vis2);
  if  vis3  eq ('17JUL2018'd) then vis3 =.;
run;

*Report the data set BaselineandMonthT4.;
title 'Output 8.5.6: Visits for All Subjects with Days on Study, Site 1 (Partial Listing)';
proc report data = Final.BaselineandMonthT4 ;
  column subject vis1 vis2 vis3 vis4 vis5 Days;
  define subject / display;
  define Days/ display;
run;
title;

*Again resapping Site 1, Baseline Lab Results.txt file ;
proc transpose data= Final.Baseline out= Final.Baseline1;
  by subject;
  where subject eq 75;
run;

*Merge two data set Baseline1 and InputDS.lab_info to create new data set.;
option label;
data Final.Baseline2;
merge Final.Baseline1
      InputDS.lab_info
;
 keep Subject Col1 labtest Colunits lownorm highnorm RangeFlag;
 attrib labtest     label = 'Laboratory Test'
        Colunits    label = 'Collected Units'
        Col1        label = 'Value'
        lownorm     label = 'Normal Range Lower Limit'
        highnorm    label = 'Normal Range Upper Limit';

      if highnorm eq . then RangeFlag = 0;
      else if col1 > highnorm then RangeFlag = 1;
      else RangeFlag = 0;
run;

*Try to match book table 8.5.8 with the help of Final.Baseline2 data set.;
title 'Output 8.5.8: Baseline Lab Results for Subject 75, Site 1�Including Flag for Values Outside Normal Range';
proc report data = Final.Baseline2 ;
  column Subject labtest colunits col1 lownorm highnorm RangeFlag;
  define subject / display ;
run;
title;

*Try to manage data use arrays to handle and the reshaping of the data producing some report table.;
data Final.BaselineVisit;
  set  Final.PaudelSite1;
  array StateMeans[5] sbp dbp pulse temp weight;
  array measure[5] $15_temporary_('Systolic BP' 'Diastolic BP' 'Pulse' 'Temperature' 'Weight' );
  array UnitesT[5] bpunits bpunits pulseunits tempunits weightunits;
  do i = 1 to dim(StateMeans);
  name = measure[i];
  Value = StateMeans[i];
  units=UnitesT[i];
  output;
  end;
  keep subject DOV name Value units;
  format dov mmddyy10.;
run;

title 'Output 8.6.1: Rotated Data from Baseline Visit, Site 1 (Partial Listing)';
proc report data = Final.BaselineVisit (obs = 10) ;
  column subject DOV name Value units;
  define subject / display ;
  define value / display  format = comma10.1;
run;
title;

*Again use arrays and rearrange the data.;
data Final.BaselineandMT;
  set  Final.BaselineandMonthT;
  array StateMeans[*] dbp pulse sbp temp ;
  array measure[4] $15_temporary_('Diastolic BP' 'Pulse' 'Systolic Bp' 'Temperature');
  array UnitesT[*] bpunits  pulseunits bpunits tempunits ;
  do i = 1 to dim(StateMeans);
  measurement=measure[i];
  units=UnitesT[i];
  StatMean=StateMeans[i];
  StatMedian=StateMeans[i];
  StdDevitation= StateMeans[i];
  statMinimum = StateMeans[i];
  StatMaximum=StateMeans[i];
  output;
  end;
  keep visit Measurement units Statmean StatMedian stdDevitation statMinimum statMaximum;
run;
*Try to produce some report table.;
title "Output 8.6.2: Summary Report on Selected Vital Signs, All Visits, Site 1";
proc report data = Final.BaselineandMT nowd;
 define visit/group 'Visit';
 define measurement/group 'Measurement';
 define units/group 'Units';
 define statMean/mean 'Mean'              format = comma10.1;
 define statMedian/median 'Median'        format = comma10.1 ;
 define stdDevitation/std 'Std.Deviation' format = comma10.2;
 define statMinimum/min 'Minimum'         format = comma10.1;
 define statMaximum/max 'Maximum'         format = comma10.1;
run;
title;
ods powerpoint exclude none;

*Creating the output of 8.6.3;
title "Output 8.6.3: BP Summaries, All Visits, Site ";
proc report data = Final.BaselineandMT nowd;
  column visit Measurement,(Statmean StatMedian stdDevitation);
  where Measurement in('Diastolic BP','Systolic Bp');
  define Measurement/across 'Measurement';
  define visit/group 'Visit';
  define statMean/mean 'Mean'              format = comma10.1;
  define statMedian/median 'Median'        format = comma10.1 ;
  define stdDevitation/std 'Std.Deviation' format = comma10.2;
run;
title;

*Read: Site 1 Adverse Events.txt data and reshaping the data.;
data Final.Adverse(drop = Code);
attrib   SUBJECT
         STDT
         ENDT
         AETEXT length = $40
         PTCODE
         SOCCODE
         LLTCODE
         HLTCODE
         HLGHTCODE
         LLTERM length = $40
         HLTERM length = $40
         HIGTERM length = $40
         PREFTERM length = $40
         BODYSYS length = $40

  ;
  retain  Subject ;
  infile RawData ('Site 1 Adverse Events.txt') dlm = '09'x truncover dsd;
  input  Code $1. @;
  if code = 's' then
    input SUBJECT $ 3-4;
  else if Code = 'd' then
    do;
    input   @3 STDT  $ 3-12        @13 ENDT  $ 13-21
          / @3 AETEXT $
          / @3 PTCODE   $  SOCCODE  $  LLTCODE $  HLTCODE  $  HLGHTCODE $
          / @3 LLTERM  $   HLTERM $    HIGTERM $  PREFTERM $  BODYSYS $
          / @3 AEREL  $    AESEV  $    AESER $    AEACTION  $ AEDOSE  $
      ;
    output;
  end;
run;

*Creating Report Table and try to match book table.;
%Let obss = 10;
title "Output 8.7.1: Adverse Events, Site 1 (Partial Listing)";
proc report data = Final.Adverse ( obs = &obss.) ;
  column Subject AETEXT STDT ENDT ;
run;
title;

data Final.BaselineandMonthT8(drop=_:);
  set Final.PaudelSite1(in = inP)
      Final.MonthVisit3 (in= inM3)
      Final.MonthVisit6 (in= inM6)
      Final.MonthVisit9 (in= inM9)
      Final.MonthVisit12 (in= inM12);
      _code = 1* inP + 2 * inM3 + 3 *inM6 + 4 *inM9 + 5*inM12;

  if _code eq 1 then visI = 'Baseline Visit';
      else if _code eq 2 then viSI = '3 Month Visit';
      else if _code eq 3 then viSI = '6 Month Visit';
      else if _code eq 4 then visI = '9 Month Visit';
      else if _code eq 5 then visI = '12 Month Visit';

run;

*Sort the data.;
proc sort data = Final.BaselineandMonthT8 out = Final.BaselineandMonthT81 ;
  by decending ViSI;
run;

*Try to rearrange data for the report 8.7.3 output.;
data Final.BaselineandMT8(keep =visI MeA UT RP StatMD StdDV MiNX MaXX);
  set  Final.BaselineandMonthT81;
  array StateMeans[*] dbp pulse sbp temp ;
  array measure[4] $15_temporary_('Diastolic BP' 'Pulse' 'Systolic Bp' 'Temperature');
  array UnitesT[*] bpunits  pulseunits bpunits tempunits ;
  do i = 1 to dim(StateMeans);
  meA=measure[i];
  UT=UnitesT[i];
  RP=StateMeans[i];
  StatMD=StateMeans[i];
  StdDV= StateMeans[i];
  MiNX = StateMeans[i];
  MaXX=StateMeans[i];
  output;
  end;

run;

*Creating final table of our data using the data set BaselineandMT8.;
ods powerpoint exclude all;
title "Output 8.7.3: Summary Report on Selected Vital Signs, All Visits, Site 1�Enhanced ";
proc report data= Final.BaselineandMT8 nowd
  style(header)=[ color=black]
  style(column)=[backgroundcolor=grayF3 fontsize=10pt]
  style(summary)=[backgroundcolor=cx000000 fontweight=bold] nowd;

  define visI / group 'Visit' style(column)=[fontweight = bold];
  define meA / group 'Test';
  define UT / group 'Units';
  define RP / mean 'Mean'          format = comma10.1;
  define StatMD / median  'Median' format = comma10.1;
  define StdDV / std 'Std.Dev.'    format = comma10.2;
  define MiNX / min 'Min.'         format = comma10.1;
  define MaXX / max 'Max.'         format = comma10.1;
  break after visI / summarize;
run;
title;

*Close PDF rtf and powerpoint open LISTING destinations.;
ods pdf close;
ods rtf close;
ods powerpoint close;
ods listing;
quit;
