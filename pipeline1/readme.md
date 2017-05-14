# PDX Animal Studies

## Tidyxl.R

This script is designed to extract the information from the unformatted Lab Excel file to a well formatted RData file.

Users should run the script with the argument of the target filename in the terminal.


> $Rscript --vanilla Tidyxl.R


For example,
```{shell}
Rscript --vanilla Tidyxl.R UWSCC-1_TH-4000.xlsx

...

'data.frame':	456 obs. of  14 variables:
 $ Mouse                : num  234 234 232 232 229 229 230 230 231 231 ...
 $ PDX                  : chr  "UWSCC-1" "UWSCC-1" "UWSCC-1" "UWSCC-1" ...
 $ Cage                 : Factor w/ 2 levels "A","B": 1 1 1 1 1 1 1 1 1 1 ...
 $ Passage              : Factor w/ 1 level "6": 1 1 1 1 1 1 1 1 1 1 ...
 $ Engraftment.Date     : Date, format: "2016-01-13" "2016-01-13" ...
 $ Trt.start            : Date, format: "2016-02-16" "2016-02-16" ...
 $ Side                 : Factor w/ 2 levels "Lt","Rt": 2 1 2 1 2 1 2 1 2 1 ...
 $ Treatment            : Factor w/ 2 levels "TH-4000","Vehicle": 2 2 2 2 2 2 2 2 2 2 ...
 $ Days.post.engraftment: num  19 19 19 19 19 19 19 19 19 19 ...
 $ Days.post.trt        : num  -15 -15 -15 -15 -15 -15 -15 -15 -15 -15 ...
 $ long.axis            : num  8.77 7.45 11.94 8.46 7.59 ...
 $ short.axis           : num  4.19 4.39 5.11 6.06 6.54 7.67 6.84 5.91 6.39 6.04 ...
 $ Volume               : num  80.6 75.2 163.2 162.7 170 ...
 $ Weight               : num  22 22 22 22 22 22 24 24 23 23 ...
```

It will generate well formatted *UWSCC-1_TH-4000.csv* with the information from *UWSCC-1_TH-4000.xlsx* in the working directory.

A handy shell script can be used in the batch fashion:

```{shell}
for file in *.xlsx
do
Rscript --vanilla Tidyxl.R ${file}
done
```
And the results csv files can be combined by:

```{shell}
cat *.csv | sort | uniq > combined.csv
```
