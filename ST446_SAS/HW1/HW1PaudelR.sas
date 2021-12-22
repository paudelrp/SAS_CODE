
*Include an OPTIONS statement that includes FMTSEARCH = (HW1);
options number pageno=1 FMTSEARCH= (HW1) nodate;

* Try to get result path compare my data. ;
x "cd L:\st446\Results"; 
libname Results ".";

*Create the InputDS libref and Raw Data fileref with using relative paths.;
x "cd L:\st446\data";
libname InputDS ".";
filename RawData ".";

*Rabin SAS Directory in HW1 folder;
x "cd S:\Documents\HW1";
libname HW1 ".";
filename HW1 ".";


*Read Lead Movies data set and clean data issues;
data HW1.Movies(drop=_:);
  infile RawData ('Movies.dat') dlm = '-' firstobs =9 truncover ;
  attrib  Title      label        =  "Movic Title"
          Studio     label        =  "Lead Studio Name"
          Rotten     label        =  "Rotten Tomatoes Score"                         
          Audience   label        =  "Audience Score" 
          ScoreDiff  label        = "Score Differenxe (Rotten -Audience)"
          Theme      label        =  "Movie Theme" 
          Genre      label        =  "Movie Genre"
;
    input Title $68. @
          /Rotten  Audience 
          /Genre : $9.  Theme : $18. 
          /_Studio $500.  Studio $25.
    ;
      
      Studio = strip(compbl(_Studio));
      _Studio = compress(Studio);
      _G7 = scan(Genre,1,'-');
      Genre = _G7;
      _G8 = scan(Theme, 1, '-');
      Theme = _G8;
      *Read in the studio first- then get rid of the record and do not read in the rest of the data.;
      *If the studio does not belong to Weinstein, continue reading in the remaining variable and creat new variable, ScoreDiff;
     
      if _Studio eq 'WeinsteinCompany' then delete;
      if _Studio eq 'TheWeinstein' then delete;
      if _Studio eq 'TheWeinsteinCompany' then delete;
      ScoreDiff = Rotten-Audience;
run;

*Validating the data add homework1 library.;
proc sort data = HW1.movies out = HW1.Paudelmovies;
  by Genre; 
run;
ods exclude attributes enginehost position sortedby;
proc contents data = HW1.Paudelmovies varnum out = HW1.Dick;
run;

proc compare base = Results.hw1Dugginsmovies compare = HW1.Paudelmovies out = HW1.DiffA
             outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-10;
run;
proc compare base = Results.hw1dugginsmoviesdesc
             compare = HW1.Dick out = HW1.DiffB
             outbase outcompare outdiff outnoequal noprint
             method = absolute criterion = 1E-10;
run;
*Create my format.;
proc format;
value Met
  . = 'N/A'
  0 = 'N/A'
  other = [5.2]
;
run;

proc format;
  value color(fuzz=0) 0   = 'cxffffcc'
                        1   = 'cxc2e699'
                        2   = 'cx78c679'
                        3   = 'cx31a354'
                        3 <- high  = 'cx006837';
run;

*To find the report.;
proc report data = HW1.Movies split = "*" out = HW1.MoV  nowd ; 
  column  studio (Rotten  Audience ),( mean std median qrange Min Max ) genre  
  case1 case2 case3 case4 case5 case6 rowSeq;
  define studio / group;
  define genre /across;
 
  define case1 / computed "Mean(Std)";
  compute case1 / char length = 12;
  case1 = cats(put(Rotten.mean, 4.1), '(', put(Rotten.std, met.), ')' );
  endcomp;
  
  define case2/ computed "Median(IQR)";
  compute case2 / char length = 12;
  case2 = cats(put(Rotten.median, 4.1), '(', put(Rotten.qrange, met.), ')' );
  endcomp;

  define case3/ computed "(Min,Max)";
  compute case3 / char length = 12;
  case3 = cats( '(', put(Rotten.min, 4.), ',', put(Rotten.max, 4.), ')' );
  endcomp;


  define case4 / computed "Mean(Std)";
  compute case4/ char length = 12;
  case4 = cats(put(Audience.mean, 4.1), '(', put(Audience.std, met.), ')' );
  endcomp;

  define case5 / computed "Median (IQR)";
  compute case5 / char length = 12;
  case5 = cats(put(Audience.median, 4.1), '(', put(Audience.qrange, met.), ')' );
  endcomp;

  define case6 / computed "(Min, Max)";
  compute case6 / char length = 12;
  case6 = cats( '(', put(Audience.min, 4.), ',', put(Audience.max, 4.0), ')' );
 
  endcomp;
  compute after ;
  if _break_ eq '_RBREAK_' then studio = 'Overall';
  if studio eq 'Overall' then rowSeq = 1;
  else
  rowSeq = 0;
  endcomp;
  
run;

*Data minipulating;
data hW1.rp ;
      set HW1.MoV;
      attrib 
            studio     label     = "Lead Studio Name"
            score      label     =  "Score Statistics"
            score      length    = $12.
            statMe     label     =  "Rotten Tomatoes Score"
            statMe     length    = $12.
            statMd     label     =  "Audience Score"  
            statMd     length    = $12. 
            _C14_      label     =  "Action" 
            _C14_      length    = 8
            _C16_      label     = "Animation"
            _C16_      length    = 8
            _C17_      label     =  "Comedy" 
            _C17_      length    = 8
            _C18_      label     =  "Drama"
            _C18_      length    = 8
            _C15_      label     = "Fantasy"
            _C15_      length    = 8
            _C19_      label     = "Horror"
            _C19_      length    = 8
            _C21_      label     = "Romance"
            _C21_      length    = 8
            _C20_      label     = "Thriller"
            _C20_      length    = 8
;
      array UtilS[*] case1 case2 case3 ;
      array UtilS1[*] case4 case5 case6 ;
      array systr[3] $15 _temporary_ ('Mean(std)'  'Median(IQR)' '(Min,Max)');
      array change _numeric_;
      do over change ;
      if change =. then change = 0;
      end;

      do i = 1 to dim(utils);
      score = systr[i];
      statMe = Utils[i];
      statMd = Utils1 [i];
      output;
      end;
      keep  rowSeq studio score statMe statMd  _C2_  _C14_ _C16_ _C17_ _C18_ _C15_ _C19_ _C21_ _C20_;
run;

proc sort data = hW1.rp out = HW1.rppp;
  by rowSeq; 
run;

*Create the requested report;
ods pdf file = "HW1 Paudel Movies Report.pdf" dpi = 300;
title h=10pt "Genres and Movie Ratings by Studio";
title2 h =10pt "Traficlighting based on Genre";
footnote j = left h =10pt "The Adventure genre was excluded as it only applied to one movie";
footnote2 j = left h = 10pt "Harvey Weinstein's company was excluded because he is a scumbag.";
proc report data = hW1.rp  split = "*" out = HW1.production1 nowd ; 
  column  studio score statMe statMd _C14_ _C16_ _C17_ _C18_ _C15_ _C19_ _C21_ _C20_ ;
  define studio / group;
  define _C14_ / style(column) = [backgroundcolor = color.];
  define _C16_ / style(column) = [backgroundcolor = color.];
  define _C17_ / style(column) = [backgroundcolor = color.];
  define _C18_ / style(column) = [backgroundcolor = color.];
  define _C15_ / style(column) = [backgroundcolor = color.];
  define _C19_ / style(column) = [backgroundcolor = color.];
  define _C21_ / style(column) = [backgroundcolor = color.];
  define _C20_ / style(column) = [backgroundcolor = color.];
 
  
run;
title;
title2;
footnote;
footnote2;

*Create the requested report;
title h=10pt "Genres and Movie Ratings by Studio";
title2 h =10pt "Traficlighting based on Genre and Average Rotten Tomatoes Score";
footnote j = left h =10pt "The Adventure genre was excluded as it only applied to one movie";
footnote2 j = left h = 10pt "Harvey Weinstein's company was excluded because he is a scumbag.";
footnote3 j = left h =10pt "Studio Color Key: Below 60 (Darkest), 60-70, 70-80, 80-90, 90-100 (Lightest)";
footnote4 j = left h = 10pt "Studio names were colored based on mean Rotten Tomatoes score using intervals that excluded the right endpoint";
proc report data = hW1.rp split = "*" out = hw1.production2  nowd ;
  column  studio score statMe statMd  _c2_ = x2 _C14_ = x14 _C16_  = x16 _C17_ = x17 _C18_ =x18  _C15_ = x15 _C19_ = x19 _C21_ = x21 _C20_ = x20;
  define studio / group ;
  define studio / style = [cellwidth = 1.6in];
  define score / style = [cellwidth = 0.8in];
  define statMe / style = [cellwidth = 0.8in];
  define statMd / style = [cellwidth = 0.8in];
  define x14 / style(column) = [backgroundcolor = color.];
  define x16 / style(column) = [backgroundcolor = color.];
  define x17 / style(column) = [backgroundcolor = color.];
  define x18 / style(column) = [backgroundcolor = color.];
  define x15 / style(column) = [backgroundcolor = color.];
  define x19 / style(column) = [backgroundcolor = color.];
  define x21 / style(column) = [backgroundcolor = color.];
  define x20 / style(column) = [backgroundcolor = color.];
  define x2 /  analysis format =  4.1;
  compute x2;
  if x2 le 60 then call define ('studio', 'style', 'style = [backgroundcolor = cx7a0177]');
  else if  x2 le 70 then call define ('studio', 'style', 'style = [backgroundcolor = cxc51b8a]');
  else if  x2 le 80 then call define ('studio', 'style', 'style = [backgroundcolor = cxf768a1]');
  else if x2 le 90 then call define ('studio', 'style', 'style = [backgroundcolor = cxfbb4b9]');
  else call define ('studio', 'style', 'style = [backgroundcolor = cxfeebe2]');
  endcomp;
run;
title;
title2;
footnote;
footnote2;
footnote3;
footnote4;
*Create the requested graph;
*Try to match Duggins report.;
*I used 8in because width = 9in show like error WIDTH exceeds available space for PDF destination. Setting WIDTH=8in.;
ods listing image_dpi = 300;
ods graphics / reset width = 8in height = 7.5in  imagename = "HW1Pct";
ods output sgplot = HW1.PaudelGraph;
proc sgplot data =HW1.Movies; 
  vbar genre/response = scoreDiff  stat = median fillattrs = (color = red) datalabel datalabelattrs = (size = 12pt style = italic weight = bold) ; 
  xaxis label = 'Movie Genre' labelattrs = (size = 16pt);
  yaxis values = (-16 to 16 by 4) label = 'Median Score Difference (Rotten - Audience)' labelattrs = (size = 16pt) grid;
  format scoreDiff 4.1;
  run;
ods pdf close;
ods listing close;



