## Summary of the approach
This workflow offers a way through two common problems in the analysis of public data:
1. A common publication format is a set of tables, in a spreadsheet or set of spreadsheets, released quarterly or annually, covering the period since the previous release. The structure and format of these publications changes between releases. Consolidating these into a single series can be labour intensive, because the small variations in presentation mean you cannot safely assume that cell X5 of the third tab will be measuring the same thing in different releases.
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
2. Copy each table to the clipboard and transpose and paste-as-values into a csv. Transposition puts the names of the LAs as a row and the variables as a column, which is more tractable in R than the other way around. 
3. No other changes

### Step 1: load and clean the data
The first script, `01 stack debt.R` loads every file in the input folder and identifies variable names, entitity names, and values; and marks unwanted cells for deletion. The data is originally published in a wide format, with a row for each LA, a column for each variable, and a value at the intersection of each. This script converts these to a long format, where there is only one value per row, with the metadata given as columns.

<table>
<tr><th>Wide format</th><th>Long format</th></tr>
<tr><td>
  
|LA_name|Var1|Var2|Var3|
|---|---|---|---|
|LA_1|a|b|c|
|LA_2|d|e|f|
|LA_3|g|h|i|
</td><td>
  
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
</td></tr> </table>

The coverage date is then added to each input table. The 20 input tables are then stacked into one table.

### Step 2: standardise coding of entities and variables
The second script `02 debt standardise.R` deals with the issue of stylistic variation between releases. First, a lookup table is loaded that contains all the variations of the names of LAs that was found in previous releases of the debt and investment series, and their standardised form. This lookup is included in this repo, in the `Libraries` folder. Here is a sample:

|`original_LA_name`|`continuity_LA_name`|
|---|---|
|Brighton and Hove|Brighton & Hove|
|Brighton & Hove|Brighton & Hove|
|Brighton & Hove UA|Brighton & Hove|

This lookup is merged into the long table produced in step one. An error log is automatically produced for any LA names that are in the data but missing from the lookup table, and written out to the `Logs` folder in the working directory that you have set in `00 Wrapper`. If an undefined value is written out, just paste it onto the end of the `original_LA_name` column in the lookup table, and provide a corresponding value for the `continuity_LA_name` column.

The same process is then run for the variable, which in this case is the lender. 

There is labelling error in Q3 2016-17. Short term borrowing is incorrectly labelled as long term borrowing, and the variable labelled as short term borrowing is left blank. The code fixes the labelling error.  

You now have a single table with four variables (LA name, lender, whether the debt is long term or short term, and the date of the observation), and 216,321 observations. As a last step, the table is converted to a wide format, with a column for each date, and written out. This final long-to-wide transformation turns it from an 8MB file to a 3.2MB file with no loss of information.
