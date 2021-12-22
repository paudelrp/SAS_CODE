*
Programmed by: Rabin Paudel
Course & Section: ST446 #001
Programmed on: 2021-04-05
Programmed to: 'cd S:\documents\HW3'

Modified by: N/A
Modified on: N/A
Modified to: N/A
;
*Include an OPTIONS statement that includes FMTSEARCH = (HW1);
options number pageno=1 FMTSEARCH= (HW1) nodate;

*Create the InputDS libref and Raw Data fileref with using relative paths.;

x "cd L:\st446\data";
libname Inputds ".";
libname OrdList "State-Level Projects Data";

*Rabin SAS Directory in HW3 folder;
*The SAS library where the final data set should go.;

ods _all_ close;
x "cd S:\Documents";
libname HW3 "HW3";
libname OutLib "OutLib";

*Convert into macro languages.;
%let DeatLib = InputDS;
%let JUP = HW3;
%macro combine;
  ods exclude all;
* To create state list A list of state abbreviations  as well keep name of data set.;
ods output members = dsetoutds(keep = name);
  proc contents data = OrdList._all_;
  run;
 *Use symputx function try to change stname and compress ;
data _null_;
    set dsetOutDS end = final;
      call symputx(cats("Stname",put(_n_,2.)),compress(name));
    if final eq 1 then do;
      call symputx('num',compress(put(_n_,2.)));
    end;
    *If no state list is given, print an error message to the log that says QC_ERROR;
    else %str(put "QC_ERROR No states provided. No data set will be created";);
  run;
  
  data all;
    set OrdList.&Stname1;
    length Stname $ 5;
    Stname = "&Stname1";
  run;
 *Try to combine all the states use macro all records from those states, also we are able handle comma-or space-delimited lists.;
  %do i = 2 %to &num;
    data all;
    set all OrdList.&&Stname&i (in = AB);
    if AB eq 1 then Stname = "&&Stname&i";
   
    %end;
    *Produce the data set normally without sorting it. ;
    else %str(put "QC_NOTE: No sorting variables provided. Data set will not be sorted.";);
    run;

%mend;
%combine
quit;
ods exclude all;

*One PROC SQL step with one query.;
*Combine all the data set most efficient manner possible.;
proc sql;

*Save the data HW3RabinPaudelStates in HW3 library.Try to change our code into macro'izes.;
create table &JUP..RabinPaudelStates as 
    select D.jobid,D.Date,D.Equipmnt,D.PERSONEL,D.JOBTOTAL,
    S.*, P.*
    from work.all as D join &DeatLib..RegionInfo as S
    on S.Stname eq D.Stname 
    join &DeatLib..polinfo as P
    on D.polcode eq P.polcode
    order by date, StName, date
   ;

quit;
