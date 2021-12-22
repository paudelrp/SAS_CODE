*
Programmed by: Rabin Paudel
Course & Section: ST445 #001
Programmed on: 2020-10-07
Programmed to: 'cd S:\documents\HW5'

Modified by: N/A
Modified on: N/A
Modified to: N/A
;

*Create the InputDS libref and Raw Data fileref with using relative paths.;
*Try to get result path compare my data.;
x "cd L:\st445\Results"; 
libname Results ".";

*Create the InputDS libref and Raw Data fileref with using relative paths.;
x "cd L:\st445\data";
libname InputDS ".";
filename RawData ".";

*Rabin SAS Directory in HW5 folder;
x "cd S:\Documents\HW5";
libname HW5 ".";
filename HW5 ".";

option fmtsearch = (HW5) nodate;
ods noproctitle;
ods exclude all;
ods listing;

*Try to read Data file including LeadProjects, O3Projects, COProjects, SO2 Projects, and TSPProjects ;
data O3Projects(drop = _:);
  attrib  StName label = "State Name"
          Region length = $ 9 
          JobID  label = ""
          Date   format = DATE9.
          StName length = $ 2
          Poltype label = "Pollutant Name"
          Polcode label = "Pollutant Code"
          Equipment label = "Equipment Date"
          Personnel label = "Personnel Costs"
          Poltype length = $ 4
          Polcode length = $ 8
          JobTotal format = DOLLAR11.
;
  infile  RawData ('O3Projects.txt') dsd truncover  firstobs =2;
  input    _st $  _JobI $  _DateRegion : $30. _Pol $ (Equipment Personnel) (: comma.);
  StName = upcase (_st);
  JobID = input(TRANWRD(tranwrd(_JobI,'O','0'), 'l', '1'), 5.);
  Date = input(compress(_dateRegion,,'a'), 5.);
  Region = propcase(compress(_dateRegion,, 'ka'));
  Poltype= substr(_Pol,2);
  Polcode = input(substr(_Pol,1,1), $8.);
  JobTotal = SUM( Equipment,Personnel);

Run;

data COProjects(drop = _:);
  attrib  StName label = "State Name"
          Region length = $ 9 
          JobID  label = ""
          Date   format = DATE9.
          StName length = $ 2
          Equipment label = "Equipment Cost"
          Personnel label = "Personnel Costs"
          JobTotal format = DOLLAR11.
;
  infile  RawData ('COProjects.txt') dsd truncover  firstobs =2;
  input    _st $  _JobI $  _DateRegion : $30. (Equipment Personnel) (: comma.);
  StName = upcase (_st);
  JobID = input(TRANWRD(tranwrd(_JobI,'O','0'), 'l', '1'), 5.);
  Date = input(compress(_dateRegion,,'a'), 5.);
  Region = propcase(compress(_dateRegion,, 'ka'));
  JobTotal = SUM( Equipment,Personnel);
Run;

data SO2Projects(drop = _:);
  attrib  StName label = "State Name"
          Region length = $ 9 
          JobID  label = ""
          Date   format = DATE9.
          StName length = $ 2
          Equipment label = "Equipment Costs"
          Personnel label = "Personnel Costs"
          JobTotal format = DOLLAR11.
;
  infile  RawData ('SO2Projects.txt') dsd truncover  firstobs =2;
  input    _st $  _JobI $  _DateRegion : $30. (Equipment Personnel) (: comma11.);
  StName = upcase (_st);
  JobID = input(TRANWRD(tranwrd(_JobI,'O','0'), 'l', '1'), 5.);
  Date = input(compress(_dateRegion,,'a'), 5.);
  Region = propcase(compress(_dateRegion,, 'ka'));
  JobTotal = SUM( Equipment,Personnel);
Run;

data TSPProjects(drop =_:);
  attrib  StName    label  = "State Name"
          Region    length = $ 9 
          JobID     label  = " "
          Date      format = DATE9.
          StName    length = $ 2
          Equipment label  = "Equipment Costs"
          Personnel label  = "Personnel Costs"
          JobTotal  format = DOLLAR11.
;
  infile  RawData ('TSPProjects.txt') dsd truncover  firstobs =2;
  input    _st $  _JobI $  _DateRegion : $30.  (Equipment Personnel) (: comma11.);
  StName = upcase (_st);
  JobID = input(TRANWRD(tranwrd(_JobI,'O','0'), 'l', '1'), 5.);
  Date = input(compress(_dateRegion,,'a'), 5.);
  Region = propcase(compress(_dateRegion,, 'ka'));
  JobTotal = SUM( Equipment,Personnel);
Run;

*All data cleaning placed in a single location and also I used LeadProjects file previous Homework (HW4).;
data Total(drop=_:);
  set Results.hw4dugginslead (in =inLEAD)
      work.TSPProjects(in = inTSP)
      HW5.COProjects (in = inCO)
      HW5.SO2Projects (in = inSO2)
      HW5.O3Projects (in = inO3);
      _Code = 3*inCo + 1*inTSP + 2*inLEAD + 5*inO3 + 4*inSO2;
  if _code eq 3 then PolType = 'CO' ;
        else if _code eq 1 then PolType = 'TSP';
        else if _Code eq 2 then PolType = 'LEAD';
        else if _Code eq 4 then PolType = 'SO2';
        else PolType = "O3";
        if JobID eq 24850 then do;
        PolType = "O3";
        _Code = ' ';
        end;
        polcode =compress(_CODE);
run;

*Try to short data and compare with duggins data of 1E-9 for numeric comparisons. ;
proc sort data = work.total out = HW5.HW5PaudelProject;
  by PolCode Region  decending Jobtotal ;
run;

proc compare base = Results.hw5DugginsProjects compare = HW5.HW5PaudelProjects out = HW5.Diffs
             outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-9;
run;

*My stats data set has 6 columns and 137 records also utilizing $polMap format.;
ods output summary;
ods output summary = HW5.MyStarts ;
proc means data = hW5.HW5PaudelProjects  p25 p75;
  class region date polcode/missing;
  var jobtotal;
  format date DateT. polcode $polMap.;
  by polcode;
 run;

 *Try to create output distination.;
ods pdf file = "HW5 Paudel Projects Graph.pdf" STARTPAGE = NEVER;
ods listing image_dpi = 300;
option nobyline;
ods graphics / reset width = 6in imagename = "HW5PaudelPctPlot90";
title "25th and 75th Percentiles of Total Job Cost";
title2 h=8pt "By Region and Controlling for Pollutant = #byval1";
title3 h=6pt "Including Records where Region was Unknown (Missing)";
footnote j = left 'Bars are labeled with the number of jobs contributing to each bar' ;

*Six plots in the graph each paje two, SGPLT Step include two VBAR Statements and also add graph KEYLEGEND statement.;
 proc sgplot data = hw5.myStarts ;
      by polcode;
vbar region/response = jobtotal_p75 response= jobtotal_p25 
      name = 'First-1' stat = mean
      outlineattrs=(color=gray3F thickness=3pt)
      group =date
      grouporder = ascending
      DATALABELATTRS=(size = 7pt)
      groupdisplay = cluster missing
      fillattrs = (color = FF00FF00)
      datalabel = nobs datalabelattrs = (size =6pt);
      
  vbar region/response = jobtotal_p25  response= jobtotal_p75
      name = 'Second-2'
      group =date
      groupdisplay = cluster
      DATALABELATTRS=(size = 7pt)
      datalabel = nobs datalabelattrs = (size =6pt);
      where polcode  in ( '.' '1');
      xaxis display = (nolabel);
      yaxis values = (0 to 80000 by 10000) grid gridattrs = (thickness = 3 color = grayCC) display = (nolabel) ;
      format jobtotal_p25 dollar6. jobtotal_p75 dollar6. polcode $polMap. date DateT.;
      keylegend 'Second-2' / location = outside position = top across = 4  ;
     
run;


proc sgplot data = hw5.myStarts ;
      by polcode;
  vbar region/response = jobtotal_p75 response= jobtotal_p25
      name = 'First-1' stat = mean
      group =date
      outlineattrs=(color=gray3F thickness=3pt)
      grouporder = ascending
      groupdisplay = cluster
      DATALABELATTRS=(size = 7pt)
      datalabel = nobs datalabelattrs = (size =6pt);  
vbar region/response = jobtotal_p75 response= jobtotal_p25
      name = 'Second-2'
      group =date
      groupdisplay = cluster
      DATALABELATTRS=(size = 7pt)
      datalabel = nobs datalabelattrs = (size =6pt);
      where polcode  in ( '2'  '3');
      xaxis display = (nolabel);
      yaxis values = (0 to 100000 by 10000) grid gridattrs = (thickness = 3 color = grayCC) display = (nolabel) ;
      format jobtotal_p25 dollar6. jobtotal_p75 dollar6. polcode $polMap. date DateT.;
      keylegend 'First-1' / location = outside position = top across = 4  ;
      styleattrs datacolors =(cx7570b3 cx7570b3 cx7570b3 cx7570b3 );
  
run;

proc sgplot data = hw5.myStarts ;
      by polcode;
  vbar region/response = jobtotal_p75 fillattrs=(color=green) response= jobtotal_p25
      name = 'First-1' stat = mean
      group =date
      outlineattrs=(color=gray3F thickness=3pt)
      grouporder = ascending
      groupdisplay = cluster
      DATALABELATTRS=(size = 7pt)
      datalabel = nobs datalabelattrs = (size =6pt);
  vbar region/response = jobtotal_p75 response= jobtotal_p25
      name = 'Second-2'
      group =date
      groupdisplay = cluster
      DATALABELATTRS=(size = 7pt)
      datalabel = nobs datalabelattrs = (size =6pt);
      where polcode  in ( '4' '5');
      xaxis display = (nolabel);
      yaxis values = (0 to 60000 by 10000) grid gridattrs = (thickness = 3 color = grayCC) display = (nolabel) ;
      format jobtotal_p25 dollar6. jobtotal_p75 dollar6. polcode $polMap. date DateT.;
      keylegend 'First-1' / location = outside position = top across = 4  ;
      styleattrs datacolors =(FF00FF00 FF00FF00 FF00FF00  FF00FF00  );
 run;

title;
title1;
title2;
footnote;

*Close PDF open LISTING destinations.;
ods pdf close;
ods listing;
quit;
