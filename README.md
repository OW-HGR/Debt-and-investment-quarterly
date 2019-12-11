## Summary of the approach
This workflow loads data that is published across different documents, consolidates it into a single table, and irons out any differences in layout and coding between publications. It is written to be easy to add new releases as they are published.

## Applying the approach to data
The approach can be applied to lots of different publications. Here, it is applied to the MCHLG debt and investment series. This series gives the amount of debt each LA holds from various categories of lender (PWLB, banks, bonds etc), and their investments by category of investment. Main points to note on the data:
* Figures are for the stock at the end of the observation period rather than the flow within the period. 
* The geographic  scope is England, Scotland, Wales, and NI. 
* The series is annual from 2008-09 to 2015-16, and then quarterly from Q3 2016-17.
* The published live tables give the data for the most recent few quarters and the last few years. This means older data is removed from the document published on GOV.UK.
* Each sheet contains a series of tabs. Each tab has a table with a row for each LA, and a column for each of the variables of interest. 

### Step 0: set up the working environment
The workflow is broken up into thematic modules that should be run in order. To set up your working environment:
1. Clone this project to your computer.
2. Create subfolders within your project folder, called `Intermediate outputs` and `Logs`.
3. Get the data. The latest live table is available here on [on GOV.UK](https://www.gov.uk/government/statistical-data-sets/live-tables-on-local-government-finance). The publications used here are included in the repo - these are:
     - `Borrowing_and_Investment_Live_Table_Q3_2016_17 Lockdown.xlsx` for year-end totals for 2008-09 to 2015-16 inclusive, and for Q3 2016-17
     - `Borrowing_and_Investment_Live_Table_Q4_2017_18-2.xlsx` for Q4 2016-17 to Q4 2017-18 inclusive
     - `Borrowing_and_Investment_Live_Table_Q2_2019_20.xlsx` for Q1 2018-19 to Q2 2019-20 inclusive

4. Open the script called `00 Wrapper` and set your file path for your project folder and your output folder. You can also engage the option to write out the latest working table at the end of each module. This is switched off by default but can be useful for debugging.

If you then run `00 Wrapper` it will work load the required libraries, run through each module in order, and save the output in the specified folder.

### Step 1: load and clean the data
The first script, `01 read straight from xlsx.R` loads each tab from the published sheets from the input folder, sets the column names from whichever row they are in, and drops any blank rows from the top of the sheet. The identification of the row with the column names 
was done manually because we want to be extra sure that we've got the right value. 20 tabs are used as of Q2 2019-20.

The data is originally published in a wide format: a row for each LA, a column for each variable, and a value at the intersection of each. This script converts these to a long format, where there is only one value per row, with the metadata given as columns. More on the difference between wide data and long data [here](https://en.wikipedia.org/wiki/Wide_and_narrow_data)

The 20 long tables are then labelled with the coverage date and the name of the original spreadsheet and tab, stacked into one table, tidied up to remove unwanted columns and rows, and formatted to set the data types of the vectors to numerics and factors.

Because tabs are loaded by index number rather than name, and dates are added manually, there is a risk that the wrong date is applied. There is a check built in here that write a table showing the date and tab name. Just check that they are aligned. 

Finally, the table is converted back to a wide format to check that there are no duplicates.

### Step 2: standardise coding of entities and variables
The second script `02 debt standardise.R` deals with the issue of stylistic variation between releases. 

LA names are addressed first. A lookup table is loaded that contains all the variations of the names of LAs that was found in previous releases of the debt and investment series, and their standardised form. This lookup is included in this repo, in the `Libraries` folder. Here is a sample:

|`original_LA_name`|`continuity_LA_name`|
|---|---|
|Brighton and Hove|Brighton & Hove|
|Brighton & Hove|Brighton & Hove|
|Brighton & Hove UA|Brighton & Hove|

This lookup is merged into the long table produced in step one. An error log is automatically produced for any LA names that are in the data but missing from the lookup table, and written out to the `Logs` folder in the working directory that you have set in `00 Wrapper`. If an undefined value is written out, just paste it onto the end of the `original_LA_name` column in the lookup table, and provide a corresponding value for the `continuity_LA_name` column. This processes is based on names rather than ecode because not all datasets contain an ecode, and because a mis-labelled ecode is more likley to go unnoticed. 

The same process is then run for the variable, which in this case is the lender. 

The data includes totals for the UK and for E/S/W/NI. This section checks that these add up correctly and writes a table of any discrepancies. 

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
2. From Q4 2018-19 to Q2 2019-20 inclusive there are entries for both `Essex Police, Fire and Crime Commissioner Fire and Rescue Authority` and `Essex Police, Fire and Crime Commissioner Police Authority`. Clearly these are the same organisation. All the values for the second one are 0. All reference to the second one are filtered out in `02 debt standardise.R` just before the LA names are standardised. This is done this way rather than by coding the organisaiton name as `drop` in the lookup table in case the organisation name is used for non-zero values in the future. 
3. In Q3 2016-17, short-term inter-authority borrowing is incorrectly labelled as long-term, and the values for long-term inter-authority lending are missing. This is addressed towards the end of `02 debt standardise.R` by fixing the labelling error and setting NAs for long-term borrowing.

If the script is working correctly there will be no entries in the error logs for `missing_LA_` or `missing_counterparty`, no difference between the UK total and the sum of England, Scotland, Wales, and NI, and only a single discrepancy of £6.5m between the sum of individual LAs and the UK total for short-term inter-LA borrowing in Q1 2018-19 (which is defensible as a rounding error, given that the UK total for this line is £8,820m).
