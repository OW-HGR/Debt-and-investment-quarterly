# if intermediate outputs are enabled, load these outputs; else, stick with the outputs already in the environment
setwd(paste(project_folder, "Intermediate outputs", sep = ""))

ifelse(write_out_y_n == "y", Debt <- read.csv("01 stack debt.csv"), "")

# -------------------------------------------------------------------------------- Standardise lender names across years
setwd(paste(project_folder, "Libraries", sep = ""))

debt_lib <- read.csv("Debt_category_library.csv") %>% 
	unique()

Debt <- left_join(Debt %>% rename(original_Debt_type = Debt_type), debt_lib)

missing_lender <- Debt %>% select(original_Debt_type, continuity_lender) %>%
	filter(is.na(continuity_lender)) %>%
	unique()

setwd(paste(project_folder, "Logs", sep = ""))

write.csv(missing_lender, file = "missing_lender.csv", row.names = FALSE)

rm(debt_lib, missing_lender)

Debt <- Debt %>% select(-original_Debt_type) %>% rename(Lender = continuity_lender)

# -------------------------------------------------------------------------------- Standardise LA names
setwd(paste(project_folder, "Libraries", sep = ""))

LA_name_lookup <- read.csv("la_names_lookup.csv") %>% unique() %>% 
	`colnames<-` (c("original_LA_name", "continuity_LA_name")) 

Debt %<>%
	rename(original_LA_name = LA) %>% 
	left_join(LA_name_lookup)
rm(LA_name_lookup)

#write out missing LA names
missing_LA <- Debt %>%
	select(original_LA_name, continuity_LA_name) %>%
	filter(is.na(continuity_LA_name)) %>% 
	unique()

setwd(paste(project_folder, "Logs", sep = ""))

write.csv(missing_LA, file = "missing_LA_name.csv", row.names = FALSE)
rm(missing_LA)

Debt <- Debt %>% select(-original_LA_name) %>% rename(LA = continuity_LA_name) %>% select(LA, Lender, Term, Date, Units, Value)

# --------------------------------------------  clean up, check, and write out
# in Q3 2016-17/ 31-12-2016, short term borrowing from other LAs is incorrectly labelled as long term borrowing, and long term borrowing is missing
# correct labelling
	
Debt <- bind_rows(
	Debt %>% filter(Lender == "Local authorities" & Date == as.Date("2016-12-31", format = "%Y-%m-%d") & Term == "Over a year") %>% mutate(Term = "Under a year"),
	Debt %>% filter(!(Lender == "Local authorities" & Date == as.Date("2016-12-31", format = "%Y-%m-%d"))))
													
Debt <- Debt %>% mutate(Term = as.factor(Term))

#write out
setwd(output_folder)

 Debt <- Debt %>% spread(Date, Value)

write.csv(Debt, file = "Debt holdings outturn, 2008-09 to Q1 2019.csv", row.names = FALSE)


