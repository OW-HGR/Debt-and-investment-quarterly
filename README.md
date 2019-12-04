# Debt and investment series

## Convert the MHCLG debt and investment series into a consistent time series

This series gives the amount of debt each LA holds from various categories of lender (PWLB, banks, bonds etc), and their investments in various categories. Figures are for the stock at the end of the observation period rather than the flow within the period.

Unusually, the scope is England, Scotland, Wales, and NI. 

The series is annual from 2008-09 to 2015-16, and then quarterly from Q3 2016-17. 

This workflow applies the long data procedure described [here](https://github.com/OW-HGR/Capital-spending-outturn-2): load n sheets of wide-format data, convert them to long format, stack them into one long table, merge in lookup tables with standardised forms of LA name and variable name, write out error logs of any undefined values, apply any adjustments (the only one in this case being to address a labelling error in Q3 2016-17), then convert back to wide format (for space-saving reasons) and write out. 

This is the simplest of the main long data workflows (the others being capital spending, capital financing, RO).
