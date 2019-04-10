Python import sas catalogs and export to R dataframe

Win 7 64bit SAS 9.4 64bit

I have not tried 32bit format catalogs.

Python reading sas catalogs without sas and exporting to R

* R does not support SAS format catalogs?;

Python packages;
https://github.com/Roche/pyreadstat
https://github.com/ofajardo/pyreadr#what-objects-can-be-read

Note the package does not read a stanalone SAS format catalog. It needs
a SAS table with the user formats. The package can only
identify labels associated with code in the associated SAS table.

*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;

******************
SAS FORMAT CATALOG
******************;

*  d:/sd1/pyfmt.sas7bcat;

options valivarname=upcase;

libname sd1 "d:/sd1";

options fmtsearch=(sd1.pyfmt);

proc format lib=sd1.pyfmt;
  value $sex
   "M"="Male"
   "F"="Female"
;quit;

*********
SAS TABLE
*********;

  d:/sd1/have.sas7bdat

data sd1.have;
   set sashelp.class(obs=5 keep=name sex age);
run;quit;

/*
Up to 40 obs from SASHELP.CLASS total obs=19

Obs    NAME       SEX    AGE

  1    Alfred      M      14
  2    Alice       F      13
  3    Barbara     F      13
  4    Carol       F      14
  5    Henry       M      14
*/

*            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;

R Datafram WANT

     code      label
1       M       Male
2       F     Female

*
 _ __  _ __ ___   ___ ___  ___ ___
| '_ \| '__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
;

%utlfkil(d:/rds/pytable.Rds);

* create a panda dataframe with formatted values;

%utl_submit_py64_37('
 import pyreadr;
 import pandas as pd;
 import pyreadstat;
 df, meta = pyreadstat.read_sas7bdat("d:/sd1/have.sas7bdat",
catalog_file="d:/sd1/pyfmt.sas7bcat", formats_as_category=True);
 pyreadr.write_rds("d:/rds/pytable.Rds", df);
');

%utl_submit_r64('
  library(RSQLite);
  library(sqldf);
  library(haven);
  have<-read_sas("d:/sd1/have.sas7bdat");
  pytable <- readRDS("d:/rds/pytable.Rds");
  want <- sqldf("
    select
      distinct
        l.sex   as code
       ,r.sex   as label
      from
        have as l, pytable as r
      where
        l.name = r.name
    ");
  want;
');

LOG

> library(RSQLite); library(sqldf); library(haven); have<-read_sas("d:/sd1/have.sas7bdat");
pytable <- readRDS("d:/rds/pytable.Rds"); want <- sqldf(" select d
istinct l.sex as code ,r.sex as label from have as l, pytable as r where l.name = r.name "); want;

  code  label
1    M   Male
2    F Female
>



