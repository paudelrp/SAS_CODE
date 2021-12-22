
options ps=150 ls=95 number pageno=1 nodate;
x 'cd L:\st445\data';
libname InputDS ".";
x 'cd S:\documents\HW1';
libname HW1 ".";
*Open PDF destination and set any destination-specific options;
ods listing close;
ods pdf file="HW1PaudelShoesReport.pdf" style=Festival;
*title 'Descriptor Information Before Sorting';
ods noproctitle;
ods select on;
title 'Descriptor Information Before Sorting';
ods select position;
ods exclude EngineHost;
ods output Attributes=attrs;
*Select and print desired metadata;

proc contents data=InputDS.shoes varnum;
run;

title;
*Preparing data with proc sort;

proc sort data=InputDS.shoes out=shoes;
  by region subsidiary descending product;
run;

title 'Descriptor Information After Sorting';
ods exclude EngineHost;
ods output Attributes=attrs;
*Select and print desired metadata After Sorting;

proc contents data=shoes varnum;
run;

title;
*By group processing in proc print using format and label statement;
*Title and sub title 8pt font.;
title ' Listing of Amounts';
title2 h=8pt 'Including Region and Subsidiary within Region Totals ';

proc print data=shoes noobs label;
  by region subsidiary descending product;
  Id region subsidiary product;
  var date sales Inventory returns stores;
  label region="Sales Region" subsidiary="Local within Region" 
    product="Product Description" date="Reporting Date" sales="Reseller's Sales" 
    Inventory="Reseller's Inventory" returns="Reseller's Returns" 
    stores="Number of Stores in Subsidiary";
  *To add dollar and commas use the dollar format.;
  format date YYMMDDD10. sales dollar12. Inventory dollar12. returns dollar12.;
  sum sales Inventory returns;
run;

title;
*Smaller title are 8pt font.;
title 'Selected Numerical Summaries of Shoe Sales';
title2 h=8pt 'by Type, Region and Returns Classification';
ods noproctitle;
*footnote statement;
footnote j=l 'Excluding Slipper and Sandal';
footnote2 j=left 'Tier 1= Up to $600, Tier 2 = Up to $1400, Tier 3 = Up to $3500, Tier 4 = Over $3500';
*Data grouping with formats;

proc format;
  value mag(fuzz=0) 
  low -< 600='Tier1' 
  600 -< 1400='Tier2' 
  1400 -< 3500='Tier3' 
  3500 - high='Tier4';
run;

*Apply formats and class variables;
*try to fine means median q1 and q3;

proc means data=InputDS.shoes n min q1 median q3 max maxdec=1 nonobs;
  where product not in ('Slipper' 'Sandal');
  class region product returns;
  var stores sales inventory;
  format returns mag.;
  *Return in Tier1, Tire2, Tire3, Tire4;
  label region="Sales Region" subsidiary="Local within Region" 
    product="Product Description" date="Reporting Date" sales="Reseller's Sales" 
    Inventory="Reseller's Inventory" returns="Reseller's Returns" 
    stores="Number of Stores in Subsidiary";
run;

title;
*To find requency of data.;
option label;
title 'Frequency of Stores by Region and Region by Product';
title2 'and Region by Returns Classification';
*Using Where statement try to remove sandal and slipper variable;

proc freq data=InputDS.shoes (where=(product not in ('Sandal' 'Slipper')));
  *Creating three diffrent table;
  weight stores;
  tables region region*product;
  tables region*returns/nocol;
  format returns mag.;
  label region="Sales Region" product ="Product Description" returns="Reseller's Returns";
run;

footnote;
*Close external destinations;
ods pdf close;
ods listing;
*GPP-mandated QUIT statement;
quit;
