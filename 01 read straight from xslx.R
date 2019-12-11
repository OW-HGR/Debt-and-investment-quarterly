# -------------------------------------------------------------------------------- load data
setwd(paste(project_folder, "Source data", sep = ""))

# need to use a few publications as the newer ones drop older quarters
Q2_2019_20 <- "Borrowing_and_Investment_Live_Table_Q2_2019_20.xlsx" 
Q4_2017_18 <- "Borrowing_and_Investment_Live_Table_Q4_2017_18-2.xlsx"
Q3_2016_17 <- "Borrowing_and_Investment_Live_Table_Q3_2016_17 Lockdown.xlsx"

# a function to get the names of the tabs in a spreadsheet
tab_names <- function(source_table) {
	excel_sheets(source_table) %>%
	data.frame() %>%
	rename(tabs = ".") %>%
	mutate(tabs = as.character(tabs))
}
	
tabs_1920 <- tab_names(Q2_2019_20)
tabs_1718 <- tab_names(Q4_2017_18)
tabs_1617 <- tab_names(Q3_2016_17)

# the tabs are in broadly the same format and need broadly the same steps applied to get them into a long format
# the placement of columns varies a bit (mainly if and where to put `class_of_authority`, and `country`) so these steps are done here in four consecutive functions:
# 	1 load tab, label	cols, drop blanks. I've made a function to wrap the steps needed for this one, so that everything fits on one line.  
#		2 convert from wide to long	
#		3 add date label	
# 	4 add the name of the tab in the source publication

read <- function(sheet_name, tab_number, col_name_row_num, drop_depth) {
	read_excel(sheet_name, tab_number) %>% 															# specify the sheet to load from, and which number tab to read
	`colnames<-`(c(slice(read_excel(sheet_name, tab_number), col_name_row_num))) %>% 	# identify the row with the column names, and apply them to the columns
	clean_names() %>% 																									# set varnames to lower case, remove special characters, unique-ify duplicate names
	slice(-1:drop_depth)																								# drop unwanted top rows, to a depth of x from the top
}

# -------------------------------------------------------------------------------- Debt
#								1 load tab, label	cols, drop blanks		2 convert from wide to long			 3 add date label											4 add the name of the tab in the source publication
debt_Q2_1920 <- read(Q2_2019_20, 6, 10, -3) %>%  gather(counterparty, value, 4:24) %>% mutate(Date = as.Date("2019/09/30"), tab = tabs_1920[6,])
debt_Q1_1920 <- read(Q2_2019_20, 8, 10, -3) %>%  gather(counterparty, value, 4:24) %>% mutate(Date = as.Date("2019/06/30"), tab = tabs_1920[8,])
debt_Q4_1819 <- read(Q2_2019_20, 10, 10, -3) %>% gather(counterparty, value, 4:24) %>% mutate(Date = as.Date("2019/03/31"), tab = tabs_1920[10,])
debt_Q3_1819 <- read(Q2_2019_20, 12, 10, -3) %>% gather(counterparty, value, 4:24) %>% mutate(Date = as.Date("2018/12/31"), tab = tabs_1920[12,])
debt_Q2_1819 <- read(Q2_2019_20, 14, 10, -3) %>% gather(counterparty, value, 4:24) %>% mutate(Date = as.Date("2018/09/30"), tab = tabs_1920[14,])
debt_Q1_1819 <- read(Q2_2019_20, 16, 10, -3) %>% gather(counterparty, value, 4:24) %>% mutate(Date = as.Date("2018/06/30"), tab = tabs_1920[16,])

debt_Q4_1718 <- read(Q4_2017_18, 6, 10, -3) %>% gather(counterparty, value, 5:25) %>% mutate(Date = as.Date("2018/03/31"), tab = tabs_1718[6,]) %>% rename(local_authority = local_authority_name) # rename to align with other quarters 
debt_Q3_1718 <- read(Q4_2017_18, 8, 3, -4) %>%  gather(counterparty, value, 4:24) %>% mutate(Date = as.Date("2017/12/31"), tab = tabs_1718[8,])
debt_Q2_1718 <- read(Q4_2017_18, 10, 3, -4) %>% gather(counterparty, value, 4:24) %>% mutate(Date = as.Date("2017/09/30"), tab = tabs_1718[10,])
debt_Q1_1718 <- read(Q4_2017_18, 12, 3, -4) %>% gather(counterparty, value, 3:23) %>% mutate(Date = as.Date("2017/06/30"), tab = tabs_1718[12,])
debt_Q4_1617 <- read(Q4_2017_18, 14, 1, -2) %>% gather(counterparty, value, 3:23) %>% mutate(Date = as.Date("2017/03/31"), tab = tabs_1718[14,])

debt_Q3_1617 <- read(Q3_2016_17, 5, 1, -2) %>% gather(counterparty, value, 3:23) %>% mutate(Date = as.Date("2016/12/31"), tab = tabs_1617[5,])
debt_1516 <-  read(Q3_2016_17, 8, 1, -2)  %>%  gather(counterparty, value, 3:23) %>% mutate(Date = as.Date("2016/03/31"), tab = tabs_1617[8,])
debt_1415 <-  read(Q3_2016_17, 10, 1, -2) %>%  gather(counterparty, value, 3:23) %>% mutate(Date = as.Date("2015/03/31"), tab = tabs_1617[10,])
debt_1314 <-  read(Q3_2016_17, 12, 1, -2) %>%  gather(counterparty, value, 3:23) %>% mutate(Date = as.Date("2014/03/31"), tab = tabs_1617[12,])
debt_1213 <-  read(Q3_2016_17, 14, 1, -2) %>%  gather(counterparty, value, 3:23) %>% mutate(Date = as.Date("2013/03/31"), tab = tabs_1617[14,])
debt_1112 <-  read(Q3_2016_17, 16, 1, -2) %>%  gather(counterparty, value, 3:23) %>% mutate(Date = as.Date("2012/03/31"), tab = tabs_1617[16,])
debt_1011 <-  read(Q3_2016_17, 18, 1, -2) %>%  gather(counterparty, value, 5:25) %>% mutate(Date = as.Date("2011/03/31"), tab = tabs_1617[18,])
debt_0910 <-  read(Q3_2016_17, 20, 1, -2) %>%  gather(counterparty, value, 3:24) %>% mutate(Date = as.Date("2010/03/31"), tab = tabs_1617[20,])
debt_0809 <-  read(Q3_2016_17, 22, 1, -2) %>%  gather(counterparty, value, 3:24) %>% mutate(Date = as.Date("2009/03/31"), tab = tabs_1617[22,])

# stack by source, and label with the file name of the publication
Q2_2019_20 <- bind_rows(debt_Q1_1819, debt_Q2_1819, debt_Q3_1819, debt_Q4_1819, debt_Q1_1920, debt_Q2_1920)  %>% 
	rename(local_authority = local_authority_name) %>% # rename to align with other quarters 
	mutate(source_publication = Q2_2019_20)

Q4_2017_18 <- bind_rows(debt_Q4_1617, debt_Q1_1718, debt_Q2_1718, debt_Q3_1718, debt_Q4_1718) %>% 
	mutate(source_publication = Q4_2017_18)

Q3_2016_17 <- bind_rows(debt_0809, debt_0910, debt_1011, debt_1112, debt_1213, debt_1314, debt_1415, debt_1516, debt_Q3_1617) %>%
	mutate(source_publication = Q3_2016_17)

# stack again, and label as debt
debt <- bind_rows(Q2_2019_20, Q4_2017_18, Q3_2016_17) %>%
	mutate(stock = "Debt")

rm(debt_Q1_1819, debt_Q2_1819, debt_Q3_1819, debt_Q4_1819, debt_Q1_1920, debt_Q2_1920,
	 debt_Q4_1617, debt_Q1_1718, debt_Q2_1718, debt_Q3_1718, debt_Q4_1718,
	 debt_0809, debt_0910, debt_1011, debt_1112, debt_1213, debt_1314, debt_1415, debt_1516, debt_Q3_1617,
	 Q2_2019_20, Q4_2017_18, Q3_2016_17)

# -------------------------------------------------------------------------------- STACK
debt_and_investments <- debt %>%
#debt_and_investments <- bind_rows(debt, investments) %>%
	select(-c(na, na_2, dclg_e_code, ons_code, lgf_code, office_for_national_statistics_e_code_or_if_this_does_not_exist_dclg_code, region_code, category, class_of_authority, country)) %>%	
	mutate(
		local_authority = as.factor(local_authority),
		counterparty = as.factor(counterparty),
		value = as.numeric(value),
		value = value/1000,
		tab = as.factor(tab),
		stock = as.factor(stock),
		Units = "GPBmillion") %>%
	filter(!is.na(local_authority)) %>%
	filter(!is.na(value))

rm(debt)

# check that the dates match the labels from the tabs
debt_and_investments %>% select(tab, Date) %>% unique()

# -------------------------------------------------------------------------------- tidy up and write out
# There are duplicates. Check what they are, and then drop them once happy
debt_and_investments <- debt_and_investments %>% mutate(dup = duplicated(debt_and_investments))
dup <- debt_and_investments %>% filter(dup == TRUE)

debt_and_investments %<>% filter(dup == FALSE) %>% select(-dup)

debt_and_investments_wide <- debt_and_investments %>% select(-c(source_publication, tab)) %>% spread(Date, value) # to check that there are no duplicates

#write out
setwd(paste(project_folder, "Intermediate outputs", sep = ""))

ifelse(write_out_y_n == "y", write.csv(Debt, file = "01 stack debt.csv", row.names = FALSE), "")

rm(debt_and_investments_wide, dup, tabs_1617, tabs_1718, tabs_1920)
