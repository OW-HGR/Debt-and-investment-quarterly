## Summary of the approach
This workflow offers a way through two common problems in the analysis of public data:
1. Data is often scattered across many different documents with slightly different formats and layouts. Consolidating these into a single series is tricky because you cannot safely assume that cell X5 of the third tab will be measuring the same thing in different publications.
2. The coding of entities and variables often changes slightly between releases. `&` becomes `and`. A computer would not recognise that this is just a coding change and would instead treat it as the end of one series and the start of a brand new one. 

The approach here irons out all this variation and produces a single, reproducible table. It is written to be easy to add new releases as they are published, even where this involves novel formatting or coding.

The workflow is broken up into thematic modules that should be run in order. If you just want the final output table, clone this project to your computer, get the data, open the script called `00 Wrapper`, and set your file path for your project folder and your output folder. If you then run `00 Wrapper` it will work through each module in order and save the output in the specified folder.

## Applying the approach to data: putting the MCHLG debt and investment series into a consistent format
MHCLG [publish a series](https://www.gov.uk/government/statistical-data-sets/live-tables-on-local-government-finance) giving the amount of debt each LA holds from various categories of lender (PWLB, banks, bonds etc), and their investments by category of investment. 
* Figures are for the stock at the end of the observation period rather than the flow within the period. 
* The geographic  scope is England, Scotland, Wales, and NI. 
* The series is annual from 2008-09 to 2015-16, and then quarterly from Q3 2016-17.
The publication gives the last few quarters and the last few years. This means older data is removed from GOV.UK. MHCLG can supply older publications. 

The publications used here are:
* `Borrowing_and_Investment_Live_Table_Q3_2016_17 Lockdown.xlsx` for year-end totals for 2008-09 to 2015-16 inclusive, and for Q3 2016-17
* `Borrowing_and_Investment_Live_Table_Q4_2017_18-2.xlsx` for Q4 2016-17 to Q4 2017-18 inclusive
* `Borrowing_and_Investment_Live_Table_Q2_2019_20.xlsx` for Q1 2018-19 to Q2 2019-20 inclusive

Each sheet contains a series of tabs; each tab has a table with a row for each LA, and a column for each of the variables of interest. 

### Step 1: load and clean the data
The first script, `01 read straight from xlsx.R` loads each tab from the published sheets from the input folder and identifies which cells contain variable names, entity names, or values. This identification was done manually, because we can't tolerate the risk of error in fuzzy matching. 20 tabs are used as of Q2 2019-20.

The data is originally published in a wide format, with a row for each LA, a column for each variable, and a value at the intersection of each. This script converts these to a long format, where there is only one value per row, with the metadata given as columns. More on the difference between wide data and long data [here](https://en.wikipedia.org/wiki/Wide_and_narrow_data)

The 20 long tables are then labelled with the coverage date and the name of the original spreadsheet and tab, stacked into one table, and tidied up to remove unwanted columns and rows, and set the data types of the vectors.

Because tabs are loaded by index number rather than name, and dates are added manually, there is a risk that the wrong date is applied. There is a check built in here that write a table showing the date and tab name. Just check that they are aligned. 

Finally, the table is converted back to a wide format to check that there are no duplicates.

### Step 2: standardise coding of entities and variables
The second script `02 debt standardise.R` deals with the issue of stylistic variation between releases. First, a lookup table is loaded that contains all the variations of the names of LAs that was found in previous releases of the debt and investment series, and their standardised form. This lookup is included in this repo, in the `Libraries` folder. Here is a sample:

|`original_LA_name`|`continuity_LA_name`|
|---|---|
|Brighton and Hove|Brighton & Hove|
|Brighton & Hove|Brighton & Hove|
|Brighton & Hove UA|Brighton & Hove|

This lookup is merged into the long table produced in step one. An error log is automatically produced for any LA names that are in the data but missing from the lookup table, and written out to the `Logs` folder in the working directory that you have set in `00 Wrapper`. If an undefined value is written out, just paste it onto the end of the `original_LA_name` column in the lookup table, and provide a corresponding value for the `continuity_LA_name` column.

The same process is then run for the variable, which in this case is the lender. 

The data includes totals for the UK and for E/S/W/NI. This section checks that these add up correctly and writes a table of any discrepancies. 

There is labelling error in Q3 2016-17. Short term borrowing is incorrectly labelled as long term borrowing, and the variable labelled as short term borrowing is left blank. The code fixes the labelling error.  

You now have a single table 218,358 rows, each with a single observation and seven variables:
1. LA name
2. whether the data is from the debt series or the investment series
3. the counterparty (UK banks, PWLB etc)
4. whether the debt is long term or short term
5. the date of the observation
6. the units (£ms),
7. the filename of the source publication)

As a last step, the table is written out to the output folder you have set in `00 Wrapper`. 

### Note on errors in the data
Three errors are identified and fixed:
1. Forest of Dean appears twice in 2008-09. This is fixed at the end of `01 read straight from xlsx.R` by removing the duplicated rows
2. From Q4 2018-19 to Q2 2019-20 inclusive there are entries for both `Essex Police, Fire and Crime Commissioner Fire and Rescue Authority` and `Essex Police, Fire and Crime Commissioner Police Authority`. Clearly these are the same organisation. All the values for the second one are 0. All reference to the second one are flitered out in `02 debt standardise.R` just before the LA names are standardised. This is done this way rather than by coding the organisaiton name as `drop` in the lookup table in case the organisation name is used for non-zero values in the future. 
3. In Q3 2016-17, short-term inter-authority borrowing is incorrectly labelled as long-term, and the values for long-term inter-authority lending are missing. This is addressed towards the end of `02 debt standardise.R` by fixing the labelling error and setting NAs for long-term borrowing.
