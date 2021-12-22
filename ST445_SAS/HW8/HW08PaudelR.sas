*
Programmed by: Rabin Paudel
Course & Section: ST445 #001
Programmed on: 2020-11-05
Programmed to: 'cd S:\documents\HW8'

Modified by: N/A
Modified on: N/A
Modified to: N/A
;

*Create the InputDS libref and Raw Data fileref with using relative paths.;
*Try to get result path compare my data.;
x "cd L:\st445\Results"; 
libname Results ".";

*Create the InputDS libref and Raw Data fileref with using relative paths.;
x "cd L:\st445\Data";
libname InputDS ".";
filename RawData ".";

*Rabin SAS Directory in HW8 folder;
x "cd S:\Documents\HW8";
libname HW8 ".";
filename HW8 ".";
options nodate fmtsearch = (InputDS.HW8fmts); 
*Try to create easy to use format name WHOsubregion later and Usa a Macro Variable to control data.;
ods listing close;
%let MYD = 2;

*Try to read data UN World Population demographics 2004.email.;
data HW8.UNW;
  attrib  regin             label = "Region"
          CONT              label = "Numeric Continent Code"
          ID                label = "GLC Country ID Number"
          Name              label = "GLC Country Name"
          ISO               label = "ISO Country Number (900+Undefined)"
          ISOname           label = "ISO Name for Country"
          pop               label = "Population (2005)"
          popAGR            label = "Population Annual Growth Rate Percentage (1995-2005)"
          popUrban          label = "Population in Urban Areas Percentage (2005)"
          totalFR           label = "Total Fertility Rate (per women 2004)"
          AdolescentFppct   label = "Adolescent Fertility Proportion Percentage"
          AdolescentFPyear  label = "Adolescent Fertility Proportion year"
          AdultLiteracypct  label = "Adult Literacy Rate Percentage (2000-2004)"
          MaleSchoolpct     label = "Net Primary School Enrollment Ratio-Male Percentage (1998-2004)"
          FemaleSchoolpct   label = "Net Primary School Enrollment Ratio -Female Percentage (1998-2004)"
          GNI               label = "Gross National INcome per capita(PPP int.$2004)"
          PopPovertyYear    label = "Population Living Below the Poverty Line (Year)"
          PopPovertypct     label = "Population living Below the Poverty Line(% with < $1 a day)";
  infile rawData("UN World Population Demographics 2004.email") missover dlm = '09'X dsd firstobs = 13  obs = 209;
  input cont ID ISO name1 : $45. ISONAMe1 : $45. regin : $ pop : comma15. popAgr : percent9.2  popUrban : percent9.2 
  totalFR AdolescentFPpct : percent9.2 AdolescentFPyear AdultLiteracypct : percent9.2
  MaleSchoolpct : percent9.2 FemaleSchoolpct : percent9.2 GNI PopPovertypct : percent9.2 PopPovertyYear;
  format ISO Z3. pop comma15. popAGR percentn9.2  popUrban percentn9.2 AdolescentFPpct percentn9.2 AdultLiteracypct percentn9.2
  MaleSchoolpct percentn9.2 FemaleSchoolpct percentn9.2 PopPovertypct percentn9.2 regin $whosubregion.; 

  *Use an array to handle the data.;
  array hori[&MYD] Name1 ISOname1;
  Name = propcase(Name1);
  ISOname = propcase(ISOname1);
  drop Name1 ISOname1;
run;

proc sort data=HW8.UNW out = HW8.Paudeldemog;
  by regin ISO ISOname;
run;

*Try to sort data and complete validation process my data with Duggins data. ;
ods listing;
ods output;
ods exclude attributes enginehost position sortedby ;
proc contents data = HW8.Paudeldemog varnum out = HW8.Paudeldemogdesc ;
run;


proc compare base = results.HW8Dugginsdemogdesc compare = hw8.Paudeldemogdesc
             out = hw8.diffA outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-10;
run;
proc compare base = Results.HW8dugginsdemog compare = HW8.paudeldemog out = HW8.DiffsB
             outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-10;
run;

*Create Report1 and try to match Duggins report.;
ods listing close;
ods rtf file = "HW8 Paudel Report1.rtf";
ods noproctitle;
options date;
footnote j = left 'Header(n=5) of UN 2004 demography data set.' ;
footnote2 j =left 'Only using records in with GNI present but under 1,000.';
footnote3 j = left 'ISO = International Standard Organization';
footnote4 j = left 'GLC = Geographic Location Code, distributed by Government Services Administration, USA';
proc report data = HW8.UNW (obs=5) ;
  column ISoname Name pop popUrban maleschoolpct femaleSchoolpct GNI;
  where (GNI < 1000 & GNI not eq .);
  label ISOname = " ISO Country Name";
  label Name = "GLM Country Name";
  label pop = "2005 Population";
  label popUrban = "2005 Urban Population Percentage";
  label maleschoolpct = "Male School Enrollment Ratio (1998-2004)";
  label femaleSchoolpct = "Female School Enrollment Ratio (1998-2004)";
  label GNI = "Gross National Income per Capita (PPP Int. $ 2004)";
  format maleschoolpct percentn9. femaleSchoolpct percentn9. popUrban percentn9.3 pop comma15.;
  run;
ods listing;
ods rtf close;
footnote;
footnote2;
footnote3;
footnote4;

*Create the report4 and try to match with Duggins report.;
ods pdf file = "HW8 Paudel Reoprt4.pdf";
option nodate;
ods listing close;
ods noproctitle;
title "Selected Summaries of 2004 UN Popolation Demographics Data";
title2 "Countries with Non-Missing GNI Values Under 1,000";
footnote j = left 'Only using records in with GNI present but under 1,000.';
footnote2 j = left 'ISO = International Standard Organization';
footnote3 j = left 'GLC = Geographic Location Code, distributed by Government Services Administration, USA';
proc report data = HW8.Paudeldemog nowd out = hW8.Paudelrep41;
  where (GNI < 1000 & GNI not eq .);
  column ISOname Name pop popUrban MaleSchoolpct FemaleSchoolpct GNI;
  label ISOname = "ISO Country Name";
  label Name ="GLC Country Name";
  label pop = "2005 Population";
  label popUrban  = "2005 Urban Population Percentage";
  label MaleSchoolpct = "Male School Enrollment Ratio (1998-2004)";
  label FemaleSchoolpct = "Female School Enrollment Ratio (1998-2004)";
  label GNI = "Gross National Income per Capita (PPP INT.$2004)";
  format pop comma14.2 popUrban percentn9.3 MaleSchoolpct percentn9. FemaleSchoolpct percentn9.;
run;
title;
title2;
footnote;
footnote2;
footnote3;

*Report 2 and try to match Duggins Report.;
ods rtf file = "HW8 Paudel Report2.rtf";
options date;
ods listing close;
ods noproctitle;
title "School Enrollment Ratio and GNI by Region";
footnote j = left 'Enrollment ratios are net primary school enrollment ratio percentages for 1998-2004' ;
footnote2 j =left 'Gross National Income is in Purchasing Power Parity (PPP) in International Dollars (Int.$) for 2004';
proc report data = HW8.Paudeldemog nowd;
  columns regin MaleSchoolpct = meanMa MaleSchoolpct = medianMa MaleSchoolpct = minMa MaleSchoolpct = maxMa
                FemaleSchoolpct = meanFe  FemaleSchoolpct = medianFe FemaleSchoolpct = minFe FemaleSchoolpct = maxFe;
  define regin/group 'Region Code';
  define meanMa/mean 'Mean Male School Enrollment Ratio' format =percentn9.1;
  define  medianMa  /median "Median Male School Enrollment Ratio" format = percentn9.1 ;
  define minMa/min "Minimun Male School Enrollment Ratio" format = percentn9.;
  define maxma/ max "Maximum Male School Enrollment Ratio" format = percentn9.;
  define meanFe/mean 'Mean Female School Enrollment Ratio' format = percentn9.1;
  define  medianFe  /median "Median Female School Enrollment Ratio" format = percentn9.1;
  define minFe/min "Minimun Female School Enrollment Ratio" format = percentn9.;
  define maxFe/ max "Maximum Female School Enrollment Ratio" format = percentn9.;
  format regin $whosubregion.;
run;
ods rtf close;

*Try to create format to use in report3 and use multidimensional array.;
proc format;
value util 1 = 'Enrollment Ratio-Male'
           2 = 'Enrollment Ratio - Female'
           3 = 'Gross National Income'
;
run;
           
title;

data HW8.Report (keep = regin Metric StatMean statMedian statMinimun statMaximum) ;
  set HW8.Paudeldemog;
  array statesMeans[*] MaleSchoolpct FemaleSchoolpct GNI;
  array statesMedian[*] MaleSchoolpct FemaleSchoolpct GNI;
  do i = 1 to dim(statesMeans);
    Metric = put(i,util.);
    StatMean=StatesMeans[i];
    StatMedian=statesMedian[i];
    statMinimun = statesMedian[i];
    StatMaximum=statesMedian[i];
    output;
    end;
run;

*Create the report 3 and compare with Duggins Report.  ;
ods rtf file = "HW8 Paudel Report3.rtf";
option nodate;
ods listing close;
ods noproctitle;
title "Selected UN Metrics Summarized by Region";
proc report data = HW8.Report nowd out = HW8.Paudelrep4c;
 define regin/group 'Region Code';
 define metric/group 'UN Demographics Metric';
 define statMean/mean 'Mean' format =comma12.5;
 define statMedian/median 'Median' format = comma10.3 ;
 define statMinimun/min 'Minimum' format = comma10.2;
 define statMaximum/max 'Maximum' format = comma10.2;
 
run;
ods rtf close;
ods pdf close;
title;
footnote;
footnote2;

*Finally, full validation(descriptor and data) my and Duggins data.;

proc sort data=hW8.Paudelrep41 out = hw8.Paudelrep4a;
  by Isoname;
run;


proc compare base = results.hw8dugginsrep4a compare = hw8.Paudelrep4a
             out = hw8.diffC outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-10;
run;

proc contents data = hw8.Paudelrep4a varnum out = HW8.Paudel4adese;
run;

proc compare base = results.hw8duggins4adesc compare = hw8.Paudel4adese
             out = hw8.diffE outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-10;
run;


proc compare base = results.hw8dugginsrep4c compare = hw8.Paudelrep4c
             out = hw8.diffD outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-10;
run;

proc contents data = hw8.Paudelrep4c varnum out = HW8.Paudel4cdese;
run;

proc compare base = results.hw8duggins4cdesc compare = hw8.Paudel4cdese out = HW8.DiffF
             outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-10;
run;
quit;
