## Summary of the approach
This workflow offers a way through two common problems in the analysis of public data:
1. A most common publication format is a set of tables, in a spreadsheet or set of spreadsheets, released quarterly or annually, covering the period since the previous release. The structure and format of these publications changes between releases. Consolidating these into a single series can be labour intensive, because the small variations in presentation mean you cannot safely assume that cell X5 of the third tab will be measuring the same thing in different releases.
2. The coding of entities and variables often changes slightly between releases. `&` becomes `and`. A computer would not recognise that this is just a coding change and would instead treat it as the end of one series and the start of a brand new one. 

The approach here irons out all this variation and produces a single, reproducible table. It is written in such a way that it is easy to add new releases as they are published, even where this involes novel formatting or coding.

The workflow is broken up into thematic modules that should be run in order. 

## Applying the approach to data: putting the MCHLG debt and investment series into a consistent format
This series gives the amount of debt each LA holds from various categories of lender (PWLB, banks, bonds etc), and their investments in various categories. Figures are for the stock at the end of the observation period rather than the flow within the period. The geograpic scope is England, Scotland, Wales, and NI. The series is annual from 2008-09 to 2015-16, and then quarterly from Q3 2016-17. Original tables are available [here](https://www.gov.uk/government/statistical-data-sets/live-tables-on-local-government-finance).

### Step 0: getting the data out of the tabs of the spreadsheets and into CSVs
The published source tables have a row for each each LA, and a column for each of the variables of interest. 

The data tables in this repository are done by pasting the values from the published xls/xlsx files into CSVs and performing the minimum of manual modification. The steps are: 
1. Open each tab in the source publication. There are 77 input sheets as of 2018/19.
2. ctrl+c each table and transpose and paste-as-values into a csv. Transposition puts the names of the LAs as a row and the variables as a column, which is more tractable in R than the other way around. 
3. Because the sub-service areas in the original tables are given as merged cells sitting above a handful of columns, the paste-and-transpose procedure means only one of the rows inherits the sub-service area label. To manage this, manually fill in the blanks in the CSV to ensure every row has a sub-service area. Check that there are the right number of each label, as the inherited value isn't always placed in the same place.
4. Some sheets have full stops and commas within some number and not in others. Fix this manually.



### Step 1: convert data from wide format to long format

Data is originally published in a wide format: a row for each LA, a column for each variable, and a value at the intersection of each. 

|LA_name|Var1|Var2|Var3|
|---|---|---|---|
|LA_1|a|b|c|
|LA_2|d|e|f|
|LA_3|g|h|i|

Tables are loaded and converted to a long format, where there is only one value per row, with the metadata given as columns.

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


|original_LA_name|continuity_LA_name|
|---|---|
|Brighton and Hove|Brighton & Hove|
|Brighton & Hove|Brighton & Hove|
|Brighton & Hove UA|Brighton & Hove|




3.  merge in lookup tables with standardised forms of LA name and variable name, write out error logs of any undefined values, apply any adjustments (the only one in this case being to address a labelling error in Q3 2016-17), then convert back to wide format (for space-saving reasons) and write out. 






This workflow applies the long data procedure described [here](https://github.com/OW-HGR/Capital-spending-outturn-2): 

This is the simplest of the main long data workflows (the others being capital spending, capital financing, RO).




