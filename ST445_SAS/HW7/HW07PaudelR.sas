*
Programmed by: Rabin Paudel
Course & Section: ST445 #001
Programmed on: 2020-10-27
Programmed to: 'cd S:\documents\HW7'

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

*Rabin SAS Directory in HW7 folder;
x "cd S:\Documents\HW7";
libname HW7".";
filename HW7 ".";


*Try to read Data file including EPA Data.csv, EPA DAta(1) EPA Data (2), PM10.sas7bdat,
AQSsites.sas7bdat, Methods.sas7bdat;
data work.EPADaTA(drop = _:);
  infile rawData("EPA Data.csv") truncover dsd firstobs = 7;
  input   siteid  aqscode poc @
/ _day $ 
/ _aqs $
/ _aqi $
/ _count $
;
attrib aqsabb length = $4;
_day = input (substr(_day,4), 9.);
aqs = input(substr(_aqs,4), 8.);
aqi = input(substr(_aqi,4), 8.);
count = input(substr(_count,6), 8.);
aqsabb = 'SO2';
_percent=(count/24)*100;
percent = round(_percent,1);
format date yymmdd10.;
retain date'01JAN2019'd;
if date then date +1;
output;

run;

data work.EPADaTA1;
  infile rawData ("EPA Data (1).csv") truncover dsd firstobs = 2;
  input date : mmddyy10. siteid : 10. poc aqs aqi count aqscode ;
  format date mmddyy10.;
  aqsabb = 'O3';
  
run;

data work.EPADaTA2(drop =i);
  infile rawData ("EPA Data (2).csv") truncover dsd firstobs = 6;
  input siteid aqscode poc@;
  do i = 1 to 122;
  input aqs AQI count @;
  aqsabb = 'CO';
   attrib length length = $4;
  format date yymmdd10.;
  retain date'01JAN2019'd;
  if date then date +1;
  output;
  end;
  
run;

proc transpose data = InputDS.pm10 out = HW7.pm10Trans (drop = _name_);
               by siteID aqscode poc;
               id metric;
               
run;

data work.PM10;
  
  set HW7.pm10Trans;
  aqsabb = 'TSP';
  attrib length length = $4;
  format date yymmdd10.;
  retain date'01JAN2019'd;
  if date then date +1;
  output;
 run;

 *Try to create StCode CountyCode, SiteNum, SIteID found to other file.
 For example, NC has StCode =37 and Wake County in NC has County code 183 14th site in wake County, NC has SiteID = 371830014.;
data work.AQSsites(drop= _:);
  set InputDS.AQSsites;
  _stCde = stCode*10;
  _stcd =compress(_stcde);
  _stc=input(substr(_stcd,1,2),8.);
  _CountCode = countyCode*100;
  _CountC =compress(_CountCode);
  _CountCO=input(substr(_CountC,1,3),8.);
  _stCde = stCode*10;
  _stcd =compress(_stcde);
  _stc=input(substr(_stcd,1,2),8.);
_variable = put(siteNum, Z4.);
  _siteID = catt(_stc ,_CountCO ,_variable);
  siteID= input(_siteID, 9.);
 
run;

proc sort data = InputDs.Methods out = work.AllTT;
  by aqscode;
run;

proc sort data = work.aqssites out = work.assiT;
  by siteid;
run;
*Try to merge the data.;
data merge1;
  set   epadata(in =inepadata) 
        epadata1(in = inepadata1)
        epadata2 (in = inepadata2)
        pm10(in = inpm10)
        assiT(in = inassiT);
        by siteid;
run;

Data work.First1;
        merge merge1(in =inmerge1) 
              allTT(in = AllTT) ;
        
  attrib  
          date  label = "Observation Date"
          siteid label = "Site Id"
          poc label = "Parameter Occurance Code 
                      (Instrument Number within Site and 
                        Parameter)"
          aqscode label = "Aqs ParameterCode"
          parameter label = "AQS Parameter Name"
          parameter length = $50
          aqsabb label = "Aqs Parameter bbreviation" 
          aqsdese label = "AQS Measurement Description"
          aqsdese length = $40
          aqs     label = "AQS observed Value"
          aqi      label = "Daily Air Quality Index Value"
          aqidese   label = "Daily AQi Category"
          aqidese length = $30
          count     label = "Daily AQS Observations"
          percent label =  "Percent of AQS Observations
                            (100*Observation/24)"
          mode  label = "Measurement Mode"
          mode length = $50
          collectdescr label = "Description of Collection Process"
          collectdeser length = $50
          analysis label = "Analysis Technique"
          analysis length = $50
          mdl label = "Federal Method Dections Limit"
          localName label = "Site Name"
          localName length = $50
          lat label ="Site Latitude"
          long label = "Site Longitude"
          stabbrev label = "State Abbreviation"
          stabbrev length = $50
          countyname label = "County Name"
          countyname length =$50
          cityname label = "City Name"
          cityname length = $50
          estabdate label = "Site Established Date"
          closedate label = "Site Closed Date"
          ;
          format estabdate yymmdd10. closedate yymmdd10.;

          if aqsabb eq "CO" then parameter = "Carbon monoxide" ;
          else if  aqsabb eq "SO2" then parameter  = "Sulfur dioxide";
          else if  aqsabb eq "O3" then parameter  = "Ozone";
          else parameter = "PM10nTotal 0-10um STP";
          *format AQsdesc AQICAT.; *We use this format but in my case not loaded;
          *if siteid ~= 371830014 then delete;
          *else if siteid ~=371830021 then delete;
run;
proc sort data = work.First1 out = HW7.HW7Paudelfinal;
  by siteid; 
run;
*Compare data with duggins data and validate descriptor portion.;
proc compare base = Results.hw7dugginsfinal
             compare = HW7.HW7Paudelfinal out = DiffA
             outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-15;
run;
proc compare base = Results.hw7dugginsfinal100
             compare = HW7.HW7Paudelfinal out = DiffB
             outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-15;
run;
