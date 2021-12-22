
*Include an OPTIONS statement that includes FMTSEARCH = (HW1);
options number pageno=1 FMTSEARCH= (HW1) nodate;

* Try to get result path compare my data. ;
x "cd L:\st446\Results\ST446HW2"; 
libname ST446HW2 ".";

*Create the InputDS libref and Raw Data fileref with using relative paths.;
x "cd L:\st446\data";
libname InputDS ".";
filename RawData ".";

*Rabin SAS Directory in HW2 folder;
x "cd S:\Documents\HW2";
libname HW2 ".";
filename HW2 ".";
ods listing close;
options nodate nobyline;


*Create two format we need to use below in the report.;
proc format;
  value mattY       low - -3    = '<-3'
                    -3 <- -2    = '(-3, -2]'
                    -2 <- -1    = '(-2, -1]'
                    -1 <-  0    = '(-1, 0]'
                     0 <-  1    = '(0, 1]'
                     1 <-  2    = '(1, 2]'
                     2 <-  3    = '(2, 3]'
                     3 <-  high = '>3'
  ;
value mattZ         0  -  5    = 'cxf1eef6'
                    5 <- 10    = 'cxd0d1e6'
                   10 <- 15    = 'cxa6bddb'
                   15 <- 20    = 'cx74a9cf'
                   20 <- 25    = 'cx3690c0'
                   25 <- 30    = 'cx0570b0'
                   30 <- high  = 'cx034e7b'
  ;
run;

*Use some macro variable.;
%let date = %sysfunc(today(), date7.);
%let UID = rpaudel; 
%let stt = Mean; 
%let group = dist reps size;
%let key = position = NE location = inside;
%let kp = 15;

*Trying to read the data.;
data HW2.sims;
  infile RawData ('Params.txt') dlm = '09'x firstobs =2 truncover;
  input Dist$ reps @ ;
  call streaminit(2021);
    do i = 1 to &kp ;
      input size @;
        if size eq . then delete;
          do sample = 1 to reps;
            do ou = 1 to size;
              y = rand(dist);
            output;
          end;
        end;
    end;
    keep dist reps size sample ou y;
run;

*Try to validate data;
proc sort data = HW2.sims out = HW2.PaudelSims;
  by descending dist; 
run;

proc compare base = ST446HW2.hw2DugginsSims compare = HW2.PaudelSims out = HW2.DiffA
             outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-10;
run;

*Mean summary report.;
ods output summary = Hw2.statSum;
proc means data = hw2.sims nonobs &stt;
  class dist reps size sample;
  var y;
run;


*Try to calculate the minimum and maximum of the summary statistic.;
ods output summary = Hw2.statSum1;
proc means data = hw2.statSum nonobs min max ;
  class dist;
  var y_&stt;
  id reps size;
run;


*Use of macro variable _null_ to get min and max using the format inside symputx function.;
data _null_;
  set hw2.statSum1;
  call symputx(cats(dist,'Min'),compress(put(y_&stt._min,comma12.2)));
  call symputx(cats(dist,'Max'),compress(put(y_&stt._max,comma12.2)));
run;


*Try to get output of graph in our distination HW2 folder and fixed image size.;
ods graphics on / imagename='histoNoMac' width=6in;
ods listing image_dpi = 300;

* To use #BYVAL and #BYVAR to create different title.;
title "Sampling Distribution of the &stt of the #byval1";
title2 "Using #byval2 Replications of Size #byval3";
footnote2 j = left h = 8pt "Created by &UID on &date";
proc sgplot data = hw2.statSum;
  by &group;
  histogram y_&stt;
  density y_&stt / legendlabel = 'Empirical Normal';
  yaxis display = (nolabel);
  xaxis label = 'Sample Mean';
  keylegend /  &key;
run;
title;
footnote;
footnote2;


*Try to generate six different graph and try to set six times to generate value.;
*Try to create Cauchy and Normal distribution both with sample sizes of 2, 30, and 100. for all six with 25 samples.;

%let dist = Cauchy;
%let Reps = 25;
%let Sizes = 2;

ods graphics on / reset=index imagename = "&Dist.R&reps.N&sizes" width=6in; *Use macro and fix value with dist reps sizes.;
title1 "Sampling Distribution of the &stt of the &dist"; * Try to match Duggins title.;
title2 h = 8pt "Using &reps Replications of Size &sizes";
footnote j = left h = 6pt "Across all simulations values ranged from &&&dist.min to &&&dist.max"; *Min and Max value with macro &&& dist.;
footnote2 j = left h = 6pt "Created by &UID on &date"; * Create USD and today data.;
proc sgplot data = hw2.statSum;
  where (upcase(dist) = upcase("&dist") and size = &sizes and reps = &reps); *Try to control graph. ;
  histogram y_&stt;
  yaxis display = (nolabel);
  xaxis label = 'Sample Mean';
  keylegend / &key;
  density y_&stt / legendlabel='Empirical Normal';
run;
title;
footnote;
footnote2;

*Similar way changes sizes.;
%let dist = Cauchy;
%let Reps = 25;
%let Sizes = 30;

ods graphics on / reset=index imagename = "&Dist.R&reps.N&sizes" width = 6in;
title1 "Sampling Distribution of the &stt of the &dist";
title2 h = 8pt "Using &reps Replications of Size &sizes";
footnote j = left h = 6pt "Across all simulations values ranged from &&&dist.min to &&&dist.max";
footnote2 j = left h = 6pt "Created by &UID on &date";
proc sgplot data = hw2.statSum;
  where (upcase(dist) = upcase("&dist") and size = &sizes and reps = &reps);
  histogram y_&stt;
  yaxis display = (nolabel);
  xaxis label = 'Sample Mean';
  keylegend /&key;
  density y_&stt / legendlabel='Empirical Normal';
run;
title;
footnote;
footnote2;


%let dist = Cauchy;
%let Reps = 25;
%let Sizes = 100;

ods graphics on / reset=index imagename = "&Dist.R&reps.N&sizes" width=6in;
title1 "Sampling Distribution of the &stt of the &dist";
title2 h = 8pt "Using &reps Replications of Size &sizes";
footnote j = left h = 6pt "Across all simulations values ranged from &&&dist.min to &&&dist.max";
footnote2 j = left h = 6pt "Created by &UID on &date";
proc sgplot data = hw2.statSum;
  where (upcase(dist) = upcase("&dist") and size = &sizes and reps = &reps);
  histogram y_&stt;
  yaxis display = (nolabel);
  xaxis label = 'Sample Mean';
  keylegend / &key;
  density y_&stt / legendlabel='Empirical Normal';
run;
title;
footnote;
footnote2;

*Similar way change distribution. ;
%let dist = Normal;
%let Reps = 25;
%let Sizes = 2;

ods graphics on / reset=index imagename="&Dist.R&reps.N&sizes" width=6in;
title1 "Sampling Distribution of the &stt of the &dist";
title2 h = 8pt "Using &reps Replications of Size &sizes";
footnote j = left h = 6pt "Across all simulations values ranged from &&&dist.min to &&&dist.max";
footnote2 j = left h = 6pt "Created by &UID on &date";
proc sgplot data = hw2.statSum;
  where (upcase(dist) = upcase("&dist") and size = &sizes and reps = &reps);
  histogram y_&stt;
  yaxis display = (nolabel);
  xaxis label = 'Sample Mean';
  keylegend / &key;
  density y_&stt / legendlabel='Empirical Normal';
run;
title;
footnote;
footnote2;

%let dist = Normal;
%let Reps = 25;
%let Sizes = 30;
ods graphics on / reset=index imagename="&Dist.R&reps.N&sizes" width=6in;
title1 "Sampling Distribution of the &stt of the &dist";
title2 h = 8pt "Using &reps Replications of Size &sizes";
footnote j = left h = 6pt "Across all simulations values ranged from &&&dist.min to &&&dist.max";
footnote2 j = left h = 6pt "Created by &UID on &date";
proc sgplot data = hw2.statSum;
  where (upcase(dist) = upcase("&dist") and size = &sizes and reps = &reps);
  histogram y_&stt;
  yaxis display = (nolabel);
  xaxis label = 'Sample Mean';
  keylegend / &key;
  density y_&stt / legendlabel='Empirical Normal';
run;
title;
footnote;
footnote2;

%let dist = Normal;
%let Reps = 25;
%let Sizes = 100;
ods graphics on / reset=index imagename="&Dist.R&reps.N&sizes" width=6in;
title1 "Sampling Distribution of the &stt of the &dist";
title2 h = 8pt "Using &reps Replications of Size &sizes";
footnote j = left h = 6pt "Across all simulations values ranged from &&&dist.min to &&&dist.max";
footnote2 j = left h = 6pt "Created by &UID on &date";
proc sgplot data = hw2.statSum;
  where (upcase(dist) = upcase("&dist") and size = &sizes and reps = &reps);
  histogram y_&stt;
  yaxis display = (nolabel);
  xaxis label = 'Sample Mean';
  keylegend / &key;
  density y_&stt / legendlabel='Empirical Normal';
run;
title;
footnote;


*Try to calculate the frequencies we need in the proc report.;
ods listing close;
ods output crosstabfreqs = hw2.frequency;
proc freq data = hw2.statSum;
  where (reps eq 25 and size in (2, 30, 100)); *Control using the where statement. ;
  table dist*size* y_&stt / nocol nofreq;
  format y_&stt mattY.;
run;

*To create proce report and try to match Duggins report.;
ods pdf file = 'HW2 Paudel Frequency Report.pdf';
title1 h = 24pt "Distribution (%) of Mean Within Each Combination";
title2  h= 22pt "of Distribution of Size";
options orientation = landscape nonumber leftmargin = 0in rightmargin = 0in; *Using some global option.;
proc report data = hw2.frequency 
  style(header) = [fontsize = 20pt] style(column) = [fontsize = 18pt];
  columns dist size ("&stt Category" y_&stt,(rowpercent)); *Using column statement try to create column.;
  define Dist / group 'Distribution';
  define Size / group 'Size';
  define y_&stt / across '' order = internal style(header) = [width = 1in]; 
  define rowpercent / format = comma. group '' style(column) = [background = mattZ.]; *Use format.; 
run;
title;
ods pdf close;
quit;
