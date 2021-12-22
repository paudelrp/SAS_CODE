
*Include an OPTIONS statement that includes FMTSEARCH = (HW4);
options number pageno=1 FMTSEARCH= (HW1) nodate;

*Create the InputDS libref and Raw Data fileref with using relative paths.;

*Try to get result path to compare my data;
x "cd L:\st446\results";
libname results ".";

*Create the InputDS using relative paths.;
x "cd L:\st555\data";
libname Inputds ".";

*Rabin SAS Directory in HW4 folder;
ods _all_ close;
x "cd S:\Desktop";
libname HW4 "HW4";

*Try to creates an ordinal function when given a numeral and save HW4 library.;
option cmplib = (HW4.funcs _displayloc_);
proc fcmp outlib = HW4.funcs.st446;
  function HWFOUR(numst) $;
  val1 =  prxmatch('/(?<!1)1\s*$/',numst);
  val2 =  prxmatch('/(?<!1)2\s*$/',numst);
  val3 =  prxmatch('/(?<!1)3\s*$/',numst);
  if val1 then return(catt(numst, ( 'st')));
  else if val2 then return(catt(numst, ('nd')));
  else if val3 then return( catt(numst, ('rd')));
  else return(catt(numst,('th')));
  endsub;
run;

*Try to create the format that displays a numerical value as an ordinal value  and save HW4 library.;
proc format;
  value ORD other = [HWFOUR()];
run;

*Try to do macrolize the variable;
*macro xkcdCombine (comicList= , outLib = HW4, outDs = xkcdCombined, dsn = inputds);
*The combine data set into homework four library.;
%global comicList;
%Let comic = comicNum;
%Let outDs = xkcdCombined;
%Let outLib = HW4;
%Let dsn = inputds;
data &outLib..&outDs;
  *Define the attrib use later;
  attrib ComicDesc label="comicDesc" length = $200
         comicNum label = "ComicNum" length = 8.;
  *Create ComicDesc variable using regular expressions.;
  set &dsn..xkcdinfo;
  comicDesc = prxchange ('s/(\w), (\w)/$2 $1/', -0, comicDesc) ;
  *Create a new ComicNum variables ;
  ComicOrd = comicNum;
  *Formats the ComicNum variable so its formatted values match the internal values of ComicOrd;
  format comicNum ORD.;
  format comicOrd ORD.;
  *Try to create null/empty value that pulls no commics.;
  %if &comic eq null %then %do;
  put "Error: SAS should be throwing an error.";
  %end;

 *Create the PremLink variables include records if they have a match.;
  PermLink = cats("https:/xkcd.com/", &comic , "/");

  *Try to combine xkedInfo and xkedAccess data set using ComicDesc as the single linking variable.;
  declare hash lookup (dataset: "&dsn..xkcdinfo"); *Declare hash;
  lookup.definekey("ComicDesc");
  lookup.definedata("comicNum" );
  lookup.definedone();
  
  *Create only 100 obs if we need more observation we use upto 2044;
  set &dsn..xkcdaccess (obs = 100);
  rc = lookup.find();
  if (rc eq 0) then put;
  drop rc;
 run;
 %put _all_;
 quit;
*mend;

