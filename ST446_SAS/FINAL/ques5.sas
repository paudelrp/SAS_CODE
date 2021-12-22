*
Programmed by: Rabin Paudel
Course & Section: ST446 #001
Programmed on: 2021-04-30
Programmed to: 'cd S:\documents\FINAL'

Modified by: N/A
Modified on: N/A
Modified to: N/A
;
*Include an OPTIONS statement that includes FMTSEARCH = (HW1);
options number pageno=1 FMTSEARCH= (HW1) nodate;

*Create the InputDS libref and Raw Data fileref with using relative paths.;

x "cd L:\st446\data";
libname Inputds ".";


*Rabin SAS Directory in HW3 folder;
*The SAS library where the final data set should go.;

ods _all_ close;
x "cd S:\Desktop\FINAL";
libname FINAL ".";


ods listing;
ods pdf file = "Rp.pdf";

proc iml;
  use inputds.demo(where = (blackIncar ne 0);
  read all var {BlackIncar} into y;
  read all var {Year BlackCounty} into x;
  n = nrow(x);
  *Try to create b0 value. ;
  bnot = repeat ({1}, n, 1);
  xone = bnot||x;
  pone = xone` * xone;
  ptwo = xone` * y;
  xpxi = inv(pone);
  Estimate = xpxi * ptwo;
  yhat = xone * Estimate;
  resid = y-yhat;
  sse = ssq(resid);
  dfee = nrow(x)-ncol(x);
  *To create df ;
  DF = {1,1,1};
  mse = sse/dfee;
  StdErr = sqrt(vecdiag(xpxi) * mse);
  tvalue = Estimate/stdErr;
  Probt = cdf('t',1,dfee);
  put probt= ;
  results = DF || Estimate || StdErr || tValue || Probt ;
  create PrisonEst from results[c = { "DF" "Parameter Estimate" "Standard Error" "t Value" "Pr > |t|"}];
  append from results;
 close PrisonEst;
quit;






ods pdf close;
ods listing close;
