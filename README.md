# Debt and investment series

## Convert the MHCLG debt and investment series into a consistent time series
This workflows takes wide-format data from various publications, converts it to long-format, and standardises the variables to make it quick and easy to do cross-year comparisons. 

### Step 1: convert data from wide format to long format

Data is originally published in a wide format: a row for each LA, a column for each variable, and a value at the intersection of each. 
|LA_name|Var1|Var2|Var3|
|LA_1|a|b|c|
|LA_2|d|e|f|
|LA_3|g|h|i|

Tables are loaded and converted to a long format, where there is only one value per row, with the metadata given as columns.
|LA_name|VarValue|
|LA_1|Var1|a|
|LA_1|Var2|b|
|LA_1|Var3|c|
|LA_2|Var1|d|
|LA_2|Var2|e|
|LA_2|Var3|f|
|LA_3|Var1|g|
|LA_3|Var2|h|
|LA_3|Var3|i|


This series gives the amount of debt each LA holds from various categories of lender (PWLB, banks, bonds etc), and their investments in various categories. Figures are for the stock at the end of the observation period rather than the flow within the period.

Unusually, the scope is England, Scotland, Wales, and NI. 

The series is annual from 2008-09 to 2015-16, and then quarterly from Q3 2016-17. 

This workflow applies the long data procedure described [here](https://github.com/OW-HGR/Capital-spending-outturn-2): load n sheets of wide-format data, convert them to long format, stack them into one long table, merge in lookup tables with standardised forms of LA name and variable name, write out error logs of any undefined values, apply any adjustments (the only one in this case being to address a labelling error in Q3 2016-17), then convert back to wide format (for space-saving reasons) and write out. 

This is the simplest of the main long data workflows (the others being capital spending, capital financing, RO).




