## Summary of the approach
This workflow offers a way through two common problems in the analysis of public data:
1. A most common publication format is a set of tables, in a spreadsheet or set of spreadsheets, released quarterly or annually, covering the period since the previous release. The structure and format of these publications changes between releases. Consolidating these into a single series can be labour intensive, because the small variations in presentation mean you cannot safely assume that cell X5 of the third tab will be measuring the same thing in different releases.
2. The coding of entities and variables often changes slightly between releases. `&` becomes `and`. A computer would not recognise that this is just a coding change and would instead treat it as the end of one series and the start of a brand new one. 

The approach here irons out all this variation and produces a single, reproducible table. It is written in such a way that it is easy to add new releases as they are published, even where this involes novel formatting or coding.

The workflow is broken up into thematic modules that should be run in order. If you just want the final output table, clone this project to your computer, open the script called `00 Wrapper`, and set your file path for your project folder and your output folder. If you then run `00 Wrapper` it will work through each module in order and save the output in the specified folder.

## Applying the approach to data: putting the MCHLG debt and investment series into a consistent format
MHCLG [publish a series](https://www.gov.uk/government/statistical-data-sets/live-tables-on-local-government-finance) giving the amount of debt each LA holds from various categories of lender (PWLB, banks, bonds etc), and their investments in various categories. 
Figures are for the stock at the end of the observation period rather than the flow within the period. 
The geograpic scope is England, Scotland, Wales, and NI. 
The series is annual from 2008-09 to 2015-16, and then quarterly from Q3 2016-17.

### Step 0: getting the data out of the tabs of the spreadsheets and into CSVs
The published source is a spreadsheet with a tab each with the balance of debt and for investments at the end of each period. Each tab has a table with a row for each each LA, and a column for each of the variables of interest. To get this into R we paste each one into a CSV and perform the minimum of manual modification. The steps are: 
1. Open each tab in the source publication. There are 19 input sheets for debt up to Q2 2019-20.
2. ctrl+c each table and transpose and paste-as-values into a csv. Transposition puts the names of the LAs as a row and the variables as a column, which is more tractable in R than the other way around. 
3. No other changes

### Step 1: load and clean the data
The first script, `01 stack debt.R` loads every file in the input folder and identifies variable names, entitity names, and values; and marks unwanted cells for deletion. The data is originally published in a wide format, with a row for each LA, a column for each variable, and a value at the intersection of each. This script converts these to a long format, where there is only one value per row, with the metadata given as columns.

**Wide format**

|LA_name|Var1|Var2|Var3|
|---|---|---|---|
|LA_1|a|b|c|
|LA_2|d|e|f|
|LA_3|g|h|i|

**Long format**

|LA_name|Var|Value|
|---|---|---|
|LA_1|Var1|a|
|LA_1|Var2|b|
|LA_1|Var3|c|
|LA_2|Var1|d|
|LA_2|Var2|e|
|LA_2|Var3|f|
|LA_3|Var1|g|
|LA_3|Var2|h|
|LA_3|Var3|i|

The coverage date is then added to each input table. The 20 input tables are then stacked into one table, 5 x 216,321.

### Step 2: standardise coding of entities and variables

|original_LA_name|continuity_LA_name|
|---|---|
|Brighton and Hove|Brighton & Hove|
|Brighton & Hove|Brighton & Hove|
|Brighton & Hove UA|Brighton & Hove|




3.  merge in lookup tables with standardised forms of LA name and variable name, write out error logs of any undefined values, apply any adjustments (the only one in this case being to address a labelling error in Q3 2016-17), then convert back to wide format (for space-saving reasons) and write out. 






This workflow applies the long data procedure described [here](https://github.com/OW-HGR/Capital-spending-outturn-2): 

This is the simplest of the main long data workflows (the others being capital spending, capital financing, RO).




