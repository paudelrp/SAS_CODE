*
Programmed by: Rabin Paudel
Course & Section: ST445 #001
Programmed on: 2020-10-14
Programmed to: 'cd S:\documents\HW6'

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

*Rabin SAS Directory in HW6 folder;
x "cd S:\Documents\HW6";
libname HW6".";
filename HW6 ".";

option fmtsearch = (HW6 INputDS) nodate ;

ods listing ;
ods listing image_dpi = 300;
ods pdf dpi = 300 file ="HW6 Paudel IPUMS Report.pdf" startpage = never;

*Creating the format we use later.;
proc format;
value MetroDesc
  0 = 'Indeterminable'
  1 = 'Not in a Metro Area'
  2 = 'In central/Principal City'
  3 = 'Not in Centra/ Principelcity'
  4 = 'Central/Principal Indeterminable'
;
run;

*Try to read Data file including Cities.txt, States.txt, Contract.txt, FreeClear.sas7bdat, and Renters.sas7bdat ;
data Cities;
  infile rawData("Cities.txt") dlm = "09"X dsd firstobs = 2;
  input  city : $40. cityPop : comma10. ;
  format cityPop comma6.;
run;

data States;
  infile rawData("States.txt") dlm = '09'X dsd firstobs = 2;
  length state $20. City $40.;
  input   serial    state $20.   city   $45. ;
run;

data Contract;
  infile rawData("Contract.txt") dlm = '09'X firstobs = 2;
  input   serial  Metro  CountyFIPS : $3.  MortPay : DOLLAR6. HHI : DOLLAR10. HomeVal : DOLLAR10. ;
  format MortPay DOLLAR6. HHI DOLLAR10. HomeVal DOLLAR10.;
run; 

data Mortgaged;
  infile rawData("Mortgaged.txt") dlm = '09'X  firstobs = 2  truncover;
  input   serial  Metro   CountyFIPS : $3. MortPay : DOLLAR6. HHI : DOLLAR10. HomeVal : DOLLAR10. ;
  format MortPay DOLLAR6. HHI DOLLAR10. HomeVal DOLLAR10.;
run;

data Rent (rename =(FIPS = CountyFIPS));
  set InputDS.Renters;
run;

data freeClear;
  set InputDS.freeClear;
run;

*Try to sort the data.;
proc sort data = work.Cities ;
  by city;
run;

proc sort data = work.States;
  by city;
run;

*Join similar type of data.;
data Join1;
  merge work.states
        work.cities;
        by city;
  run;
*Sort the data;
proc sort data = work.Join1 ;
  by serial;
run;

proc sort data = work.Rent;
  by serial;
run;

proc sort data = work.Contract;
  by serial;
run;

proc sort data = work.Mortgaged;
  by serial;
run;

proc sort data = work.freeClear;
  by serial;
run;

*All data merge by interchangeable way.;
ods select position;
data Joinall;
attrib  Serial label = "Household Serial Number"
          CountyFIPS  label = "County FIPS Code"
          Metro label = "Metro Status Code"
          MetroDesc label ="Metro Status Description"
          CityPop label = "City Population (in 100s"
          MortPay label = "Monthly Mortgage Payment"
          HHI label = "Household Income"
          HomeVal label = "Home Value"
          State label = "State, District, or Temtory"
          City label = "City Name"
          MortStat label = "Mortage Status"
          Ownership label = "Ownership Status"; 
          format MortPay DOLLAR6. HHI DOLLAR10. HomeVal DOLLAR10. MetroDesc MetroDesc. ;
          *Final Merge data.;
  merge  work.join1
         work.Rent
         work.Contract
         work.Mortgaged
         work.freeClear;   
         by serial;
  MetroDesc = Metro;
  *Try to refine the data.;
  if homeVal eq 9999999 then homeVal='.R';
      else if homeVal eq . then homeVal = '.M';
  if  MortPay >159  and HomeVAl > 50000 then MortStat = 'Yes, mortgaged/ dead of trust or similar debt';
      else if MortPay eq 0 and HomeVal > 0 then MortStat = 'No, owned free and clear';
      else if MortPay eq 0 and HomeVal eq '.R' then MortStat = 'N/A';
      else MortStat = 'Yes, contract to purchage';
  if HomeVal eq '.R' then Ownership = 'Rented';
      else Ownership = 'Owned';
  if cityPop = 1810 then delete;
    else if cityPop = 2554 then delete;
    else if cityPop = 5227 then delete;
    else if cityPop = 1835 then delete;
run;

proc sort data = work.Joinall out = HW6.HW6PaudelIpums2005;
  by serial; 
run;
ods exclude attributes enginehost position sortedby;
proc contents data = HW6.HW6PaudelIpums2005 varnum;
run;
*We have Sort and contents data HW6 library. ;

proc compare base = Results.HW6dugginsipums2005 
             compare = HW6.HW6PaudelIpums2005 out = HW6.DiffsA
             outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-15;
run;

*Compare data with duggins data and validate descriptor portion.;
proc compare base = Results.HW6dugginsdesc
             compare = HW6.HW6Paudeldesc out = HW6.DiffsB
             outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-15;
run;

*Creating some report.;
title 'Listing of Households in NC with Incomes Over $500,000';
proc report data = work.Joinall nowd ;
  where HHI ge 500000 & (city in ( 'Raleigh, NC' 'Fayetteville, NC' 'Charlotte, NC' 'Greensboro, NC' )) ;
  columns city metro mortstat hhi homeval;
run;
title;

*Again Creating some report. ;
ods graphics /reset width = 5.5in ;
ods listing exclude quantiles BasicMeasures extremeobs;
proc univariate data = work.Joinall;
  var  cityPop; 
  ods select BasicMeasures Quantiles;

  histogram citypop/kernel (k=quadratic);
  inset kernel/position =ne;

  var MortPay;
  ods select Quantiles;
  var hhi;
  ods select BasicMeasures extremeobs;
  var homeval;
  ods select basicMeasures extremeobs missingvalues; 
run;

*Create the required graph.;
title 'Distribution of City Population';
title2 h = 8pt"(For Households in a Recognized City";
footnote j=left 'Recognized cities have a non-zero value of City Population';
proc sgplot data = work.Joinall noautolegend ;
    histogram citypop/ binwidth = 1000 binstart = 0 scale = proportion;
    density citypop / type = kernel (weight = quadratic ) lineattrs = (color = green);
    xaxis label = 'City Population (in 100s)';
    yaxis display = (nolabel) valuesformat= percent7.;
    keylegend /location = inside position =ne;
run;
title;
title2;
footnote;

*Create the required graph.;
title 'Distribution of Household income Stratified by Mortgage Status';
footnote  'Kernel estimate parameters were determined automatically';
proc sgpanel data = work.Joinall noautolegend;
    panelby MortStat /novarname;
    histogram HHI/ binwidth = 50000 binstart = 100 scale = proportion ;
    density HHI/type = kernel (weight = quadratic) lineattrs  = (color = red);
    rowaxis display = (nolabel) valuesformat = percent7.;
    colaxis label = 'Household Income';
run;
title;
footnote;
ods listing close;
ods pdf close;
quit;


