if(!require("foreign")) install.packages("foreign")
if(!require("tidyverse")) install.packages("tidyverse")
if(!require("readxl")) install.packages("readxl")
if(!require("fs")) install.packages("fs")
if(!require("janitor")) install.packages("janitor")

library(foreign)		# loads .CSVs
library("tidyverse")	
library("readxl")		
library("fs")			# Provides a cross-platform, uniform interface to file system operations
library("janitor")		# tools for cleaning messy data
options(scipen = 999)	# disable exponential notation

# -------------------------------------------------------------------------------- load data
setwd("/Users/mbp15/Dropbox/Source data original format/Borrowing and investment")

Q3_2017_18 <- "Borrowing_and_Investment_Live_Table_Q3_2016_17 Lockdown.xlsx"

# get the names of the tabs
tabs <- excel_sheets(Q3_2017_18) %>%
	data.frame() %>%
	rename(tabs = ".") %>%
	mutate(tabs = as.character(tabs))

# the tabs are the same format - build a function to clean and format any tab
read_clean <- function(sheet_name, tab_number, n_col) {
	read_excel(sheet_name, tab_number) %>% 								# specify the sheet to load from, and the number of the tab
	`colnames<-`(c(slice(read_excel(sheet_name, tab_number), 1))) %>% 	# specify column names
	clean_names() %>% 													# set varnames to lower case, remove special characters, unique-ify duplicate names
	slice(-1:-2) %>%
	gather(lender, value, 3:ncol(read_excel(sheet_name, tab_number))) %>%
	mutate(sheet = tabs[tab_number,])									# label the sheet with the name of the tab
}

# load, clean, and label each sheet
debt_0809 <- read_clean(Q3_2017_18, 22, ncol(debt_0809)) %>% mutate(stock = "Debt", Date = as.Date("2009/03/31", format = "%Y/%m/%d"))
debt_0910 <- read_clean(Q3_2017_18, 20, ncol(debt_0910)) %>% mutate(stock = "Debt", Date = as.Date("2010/03/31", format = "%Y/%m/%d"))
debt_1011 <- read_clean(Q3_2017_18, 18, ncol(debt_1011)) %>% mutate(stock = "Debt", Date = as.Date("2011/03/31", format = "%Y/%m/%d"))
debt_1112 <- read_clean(Q3_2017_18, 16, ncol(debt_1112)) %>% mutate(stock = "Debt", Date = as.Date("2012/03/31", format = "%Y/%m/%d"))
debt_1213 <- read_clean(Q3_2017_18, 14, ncol(debt_1213)) %>% mutate(stock = "Debt", Date = as.Date("2013/03/31", format = "%Y/%m/%d"))
debt_1314 <- read_clean(Q3_2017_18, 12, ncol(debt_1314)) %>% mutate(stock = "Debt", Date = as.Date("2014/03/31", format = "%Y/%m/%d"))
debt_1415 <- read_clean(Q3_2017_18, 10, ncol(debt_1415)) %>% mutate(stock = "Debt", Date = as.Date("2015/03/31", format = "%Y/%m/%d"))
debt_1516 <- read_clean(Q3_2017_18, 8, ncol(debt_1516)) %>% mutate(stock = "Debt", Date = as.Date("2016/03/31", format = "%Y/%m/%d"))
debt_Q3_1617 <- read_clean(Q3_2017_18, 5, ncol(debt_Q3_1617)) %>% mutate(stock = "Debt", Date = as.Date("2017/12/31", format = "%Y/%m/%d"))

investments_0809 <- read_clean(Q3_2017_18, 23, 16) %>% mutate(stock = "Investments", Date = as.Date("2009/03/31", format = "%Y/%m/%d"))
investments_0910 <- read_clean(Q3_2017_18, 21, 16) %>% mutate(stock = "Investments", Date = as.Date("2010/03/31", format = "%Y/%m/%d"))
investments_1011 <- read_clean(Q3_2017_18, 19, 16) %>% mutate(stock = "Investments", Date = as.Date("2011/03/31", format = "%Y/%m/%d"))
investments_1112 <- read_clean(Q3_2017_18, 17, 16) %>% mutate(stock = "Investments", Date = as.Date("2012/03/31", format = "%Y/%m/%d"))
investments_1213 <- read_clean(Q3_2017_18, 15, 16) %>% mutate(stock = "Investments", Date = as.Date("2013/03/31", format = "%Y/%m/%d"))
investments_1314 <- read_clean(Q3_2017_18, 13, 16) %>% mutate(stock = "Investments", Date = as.Date("2014/03/31", format = "%Y/%m/%d"))
investments_1415 <- read_clean(Q3_2017_18, 11, 16) %>% mutate(stock = "Investments", Date = as.Date("2015/03/31", format = "%Y/%m/%d"))
investments_1516 <- read_clean(Q3_2017_18, 9, 16) %>% mutate(stock = "Investments", Date = as.Date("2016/03/31", format = "%Y/%m/%d"))
investments_Q3_1617 <- read_clean(Q3_2017_18, 6, 16) %>% mutate(stock = "Investments", Date = as.Date("2017/12/31", format = "%Y/%m/%d"))

debt_and_investments <- bind_rows(debt_0809, debt_0910, debt_1011, debt_1112, debt_1213, debt_1314, debt_1415, debt_1516, debt_Q3_1617, investments_0809, investments_0910, investments_1011, investments_1112, investments_1213, investments_1314, investments_1415, investments_1516, investments_Q3_1617) %>%
	select(-dclg_e_code) %>%
	mutate(
		local_authority = as.factor(local_authority),
		lender = as.factor(lender),
		value = as.numeric(value),
		sheet = as.factor(sheet),
		stock = as.factor(stock),
		source_publication = "Borrowing_and_Investment_Live_Table_Q3_2016_17 Lockdown.xlsx") %>%
	filter(!is.na(local_authority)) %>%
	filter(!is.na(value))

# check that the dates match the labels from the tabs
debt_and_investments %>% select(sheet, Date) %>% unique()

debt_and_investments %<>% select(-sheet) %>% mutate(value = value/1000, Units = "GPBmillion")

rm(debt_0809, debt_0910, debt_1011, debt_1112, debt_1213, debt_1314, debt_1415, debt_1516, debt_Q3_1617, investments_0809, investments_0910, investments_1011, investments_1112, investments_1213, investments_1314, investments_1415, investments_1516, investments_Q3_1617)

# -------------------------------------------------------------------------------- tidy up and write out

# There are duplicates. Check what they are, and drop them
dup <- debt_and_investments %>% filter(duplicated(debt_and_investments) == TRUE)
debt_and_investments <- debt_and_investments %>% filter(duplicated(debt_and_investments) == FALSE)

debt_and_investments_wide <- debt_and_investments %>% spread(Date, value)

#write out
setwd(paste(project_folder, "Intermediate outputs", sep = ""))

ifelse(write_out_y_n == "y", write.csv(Debt, file = "01 stack debt.csv", row.names = FALSE), "")


