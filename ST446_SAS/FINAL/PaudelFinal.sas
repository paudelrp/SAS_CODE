*
Programmed by: Rabin Paudel
Course & Section: ST446 #001
Programmed on: 2021-04-30
Programmed to: 'cd S:\documents\FINAL'
Modified by: N/A
Modified on: N/A
Modified to: N/A
;
*Include an OPTIONS statement that includes FMTSEARCH = (FINAL);
options number pageno=1 FMTSEARCH= (FINAL) nodate;

*Create the InputDS libref and Raw Data fileref with using relative paths.;

x "cd L:\st446\data";
libname Inputds ".";

*Rabin SAS Directory in FINAL folder;
*The SAS library where the final data set should go.;

ods _all_ close;
x "cd S:\Desktop\FINAL";
libname FINAL ".";

*Just for Rabin Purpose.;
ods listing;
ods pdf file = "Rp.pdf";

**************************;
*Quention Number 1;

*Try to use single PROC SQL step and one MACRO defination;
%macro stateSplit(StList=);
PROC SQL;
create view FINAL.PolInfo as
  select Pol_Type, Pol_Code
  from inputds.projects
 ;
create view Final.RegionInfo as
  select stname, REGION 
  from inputds.projects
;
quit;
quit;

*Try to Use one data Step;
%let St = %upcase(%scan(&stList,1));
%let r = 2;
%let St = %scan(&StList, &r);
%let cnt = 48;
%do %while(%str(&St) ne);
  data &i ;
  set inputds.projects;
  where Stname = "stname&i";
run;
%end;
%mend StateSplit;
%stateSplit;

**************************;
*Quention Number 2;

*Define three library parameters.;
*Four options parameters.;
%macro CompMac (BaseLib = , CompList =, OutList=);
  %if print eq N %then %let noprint = noprint;
  array list{3} BaseLib, CompList, OutList;
  array counts{list};
  val = countw(counts);
  data _null_
    val1 = mean(BaseLib);
    val2 = mean(CompList);
    val3 = mean(OutList);
    put val1=, val2=, val3=;
  end;
  %let counts = 0;
  do i = 1 dim(Counts);
      CountDiff + (AvgCount ne Counts[i]);
  end;
%mend;

*****************************;
*QUESTION NUMBER 3(A);
*****************************;

ods listing;
*ods select anova fitstatistics parameterestimates;
*Two PROC steps, including the provided code.;
proc reg data = inputds.Demo(where = (blackIncar ne 0));
  model BlackIncar = Year BlackCounty;
  run;
quit;

*Read the data into IML and create a vector y to hold the response variable and a matrix x;
*Store the computed results in a table called Work.PrisonEst;
*DF, Estimate, StdErr, tValue, and Probt with given label;

proc iml;
  use inputds.demo(where = (blackIncar ne 0);
  read all var {BlackIncar} into y;
  read all var {Year BlackCounty} into x;
  n = nrow(x);
  *Try to create b0 value. ;
  bnot = repeat ({1}, n, 1);
  xone = bnot||x;
  *xone` transpose matrix;
  pone = xone` * xone;
  ptwo = xone` * y;
  *Inverse Matrix;
  xpxi = inv(pone);
  Estimate = xpxi * ptwo;
  yhat = xone * Estimate;
  resid = y-yhat;
  sse = ssq(resid);
  dfee = nrow(x)-ncol(x);
  *To create df ;
  DF = {1,1,1};
  mse = sse/dfee;
  *IML function VECDIAG;
  StdErr = sqrt(vecdiag(xpxi) * mse);
  *to find the probability using f distribution probf function ;
  tvalue = Estimate/stdErr;
  Probt = 1 - probf(tvalue#tvalue,1,dfee);
  results = DF || Estimate || StdErr || tValue || Probt ;
  create PrisonEst from results[c = { "DF" "Parameter Estimate" "Standard Error" "t Value" "Pr > |t|"}];
  append from results;
 close PrisonEst;
quit;

*****************************;
*QUESTION NUMBER 3(B);
*****************************;


*Quantile regression model;
proc quantreg data = inputds.demo (where =(blackIncar ne 0));
  model BlackIncar = year BlackCounty/nosummary
  quantiles = 0.15 0.25 0.50 0.75 0.85;
run;

*****************************;
*QUESTION NUMBER 4;
*****************************;

*Creating Function;
options nodate fmtsearch = (work)
    cmplib = (work.Func _displayloc_);
proc fcmp outlib = work.func.dat;
  function RadExpConv(unit) $10;
  user = scan(unit, -1);
  val = scan(unit, 1, '');
  if user eq 'kg' then amou = catt(put((val), 20.10), ' C/kg');
  if user eq 'R' then amou  = catt(put((val*0.000645), 20.10), ' C/kg');
  return(amou);
endsub;
run;

*****************************;
*QUESTION NUMBER 5;
*****************************;

*Creating SQL using Subqueries and inline;
*Reproduce the query in Exercise 4 as we see it including sort order and formates.;
proc sql ;
  title "2005, 2010, and 2015 Home Value to Income Ratios for NC, SC, and GA";
  select *
  from ( select  state, metroStatus label = "Matro Status", '2005' as year, avghomevalue format = dollar10. label = "Avg Homevalu",
         meanincome format = dollar10. label = "Mean Income", (avghomevalue/meanincome) as ratio
         format = 6.1 label = "Value to Income Ratio"
         from  inputds.ncscva2005 
  union all corr
      select state, metroStatus label = "Matro Status", '2010' as year, avghomevalue format = dollar10. label = "Avg Homevalu", 
      meanincome format = dollar10. label = "Mean Income", (avghomevalue/meanincome) as ratio 
      format = 6.1 label = "Value to Income Ratio"
      from inputds.ncscva2010
  union
      select state, metroStatus label = "Matro Status", '2015' as year, avgvalue format = dollar10. label = "Avg Homevalu", 
      avgIncome format = dollar10. label = "Mean Income", (avgvalue/avgincome) as ratio
      format = 6.1 label = "Value to Income Ratio"
      from inputds.ncscva2015 
  union
      select state, metroStatus label = "Matro Status", '2005' as year, avghomevalue format = dollar10. label = "Avg Homevalu",
      meanPayment format = dollar10. label = "Mean Income", (avghomevalue/meanpayment) as ratio format = 6.1
      label = "Value to Income Ratio"
      from inputds.flga2005
  union
      select state, metroStatus label = "Matro Status", '2010' as year, avghomevalue format = dollar10. label = "Avg Homevalu", 
      meanPayment format = dollar10. label = "Mean Income", (avghomevalue/meanpayment) as ratio format = 6.1
      label = "Value to Income Ratio"
      from inputds.flga2010
  )
  order by state, metroStatus
  ;

  *Creating query in Exercise 5, include the following given modification.;
  select coalesce(S.state, D.state, G.state, H.state )as state format = $20.,
       coalesce(S.metroStatus, D.metroStatus, G.metroStatus, H.metroStatus) as metroStatus format = $40. label = "Metro Status",
       coalesce(S.avghomevalue, D.avghomevalue) as value1 format = dollar10. label = "2005 Avg. Value",
       coalesce(G.avghomevalue, H.avghomevalue) as value2 format = dollar10. label = "2010 Avg. Value",
      ( coalesce(S.avghomevalue, D.avghomevalue)-(coalesce(G.avghomevalue, H.avghomevalue))) as Difference format = dollar10.
       from  inputds.ncscva2005 as S full join inputds.flga2010 as D 
       on S.state eq D.state
       full join inputds.flga2005 as G 
       on D.metroStatus eq G.metroStatus
       full  join inputds.ncscva2010 as H
       on G.avghomevalue eq H.avghomevalue and
       G.metroStatus eq H.metroStatus and
       S.state eq D.state
       order by state, metrostatus
       ;
quit;
title;
ods pdf close;
ods listing close;
