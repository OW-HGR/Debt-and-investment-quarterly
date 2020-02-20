# if intermediate outputs are enabled, load these outputs; else, stick with the outputs already in the environment
setwd(paste(project_folder, "Intermediate outputs", sep = ""))

ifelse(write_out_y_n == "y", Debt <- read.csv("01 stack debt.csv"), "")

# -------------------------------------------------------------------------------- Standardise lender names across years
setwd(paste(project_folder, "Libraries", sep = ""))

counterparty_lib <- read.csv("debt_and_investment_library.csv") %>% unique()

debt_and_investments <- 
	left_join(debt_and_investments %>% 
	rename(original_counterparty = counterparty), counterparty_lib)

missing_counterparty <- debt_and_investments %>% 
	filter(stock == "Debt") %>%
	select(original_counterparty, continuity_counterparty) %>%
	filter(is.na(continuity_counterparty)) %>%
	unique()

setwd(paste(project_folder, "Logs", sep = ""))

write.csv(missing_counterparty, file = "missing_counterparty.csv", row.names = FALSE)

rm(counterparty_lib)

debt_and_investments %<>% 
	select(-original_counterparty) %>% 
	rename(Counterparty = continuity_counterparty)

# -------------------------------------------------------------------------------- Standardise LA names
setwd(paste(project_folder, "Libraries", sep = ""))

LA_name_lookup <- read.csv("la_names_lookup.csv") %>% unique() %>% 
	`colnames<-` (c("original_LA_name", "continuity_LA_name")) 

debt_and_investments %<>%
	rename(original_LA_name = local_authority) %>% 
	mutate(
		original_LA_name = gsub(" ", "_", original_LA_name),
		original_LA_name = gsub("&", "", original_LA_name),
		original_LA_name = gsub("-", "_", original_LA_name),
		original_LA_name = gsub("__", "_", original_LA_name),
		original_LA_name = tolower(original_LA_name)) %>%
	left_join(LA_name_lookup)
	
rm(LA_name_lookup)

#write out missing LA names
missing_LA <- debt_and_investments %>%
	select(original_LA_name, continuity_LA_name) %>%
	filter(is.na(continuity_LA_name)) %>% 
	unique()

setwd(paste(project_folder, "Logs", sep = ""))

write.csv(missing_LA, file = "missing_LA_name.csv", row.names = FALSE)

debt_and_investments %<>% select(-original_LA_name) %>% rename(LA = continuity_LA_name) %>% select(LA, stock, Counterparty, Term, Date, Units, value, source_publication)

# --------------------------------------------  check country and LA sums add up to published UK total
UK_country_comparison <- full_join(

	debt_and_investments %>% 
		filter(LA %in% c("England", "Scotland", "Wales", "Northern Ireland")) %>% 
		group_by(stock, Counterparty, Term, Date, Units, source_publication) %>%
		summarise(value = sum(value)) %>% ungroup() %>%
		rename(sum_of_countries = value),
	
	debt_and_investments %>% 
		filter(LA == "UK") %>%
		select(-LA) %>%
		rename(UK_published_total = value)) %>%
	
	mutate(
		diff = UK_published_total - sum_of_countries,
		diff = round(diff, 6)) %>%
	
	filter(diff != 0)


UK_LA_comparison <- full_join(
	
	debt_and_investments %>% 
		filter(!LA %in% c("UK", "England", "Scotland", "Wales", "Northern Ireland")) %>% 
		group_by(stock, Counterparty, Term, Date, Units, source_publication) %>%
		summarise(value = sum(value)) %>% ungroup() %>%
		rename(sum_of_LAs = value),
	
	debt_and_investments %>% 
		filter(LA == "UK") %>%
		select(-LA) %>%
		rename(UK_published_total = value)) %>%
	
	mutate(
		diff = UK_published_total - sum_of_LAs,
		diff = round(diff, 6),
		diff_pc = diff/ UK_published_total,
		diff_pc = round(diff_pc, 3)) %>%
	
	filter(diff != 0)

# -------------------------------------------------------------------------------- tidy up and write out
setwd(output_folder)

debt_and_investments_wide <- debt_and_investments %>% select(-source_publication) %>% spread(Date, value)

write.csv(debt_and_investments, file = "Debt and investment outturn, 2008-09 to Q3 2019.csv", row.names = FALSE)

rm(debt_and_investments_wide)
