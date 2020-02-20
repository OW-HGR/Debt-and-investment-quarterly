# -------------------------------------------------------------------------------- 1 duplicates

debt_and_investments <- debt_and_investments %>% mutate(dup = duplicated(debt_and_investments))
dup <- debt_and_investments %>% filter(dup == TRUE)

debt_and_investments %<>% filter(dup == FALSE) %>% select(-dup)

debt_and_investments_wide <- debt_and_investments %>% 
	select(-c(source_publication, tab)) %>% 
	spread(Date, value) # to check that there are no duplicates

# -------------------------------------------------------------------------------- 2 double entry for Essex Police and Fire
# some years have entries for 'Essex Police, Fire and Crime Commissioner Fire and Rescue Authority' and for 'Essex Police, Fire and Crime Commissioner Police Authority'. Clearly these are the same org. All the values for the second one are 0. Drop this one 
# there is a section later on for fixing errors but this is added here because otherwise this step will give both entries the same name

debt_and_investments <- debt_and_investments %>% 
	filter(local_authority != "Essex Police, Fire and Crime Commissioner Police Authority")

# -------------------------------------------------------------------------------- 3 short-term borrowing mis-labeled
# in Q3 2016-17/ 31-12-2016, short term borrowing from other LAs is incorrectly labelled as long term borrowing, and long term borrowing is missing
# correct labelling

debt_and_investments <- bind_rows(
	
	# this is the subset that is mislabelled as long-term - relabel it as short-term
debt_and_investments %>% 
		filter(counterparty == "longer_term_loans_local_authorities" & Date == as.Date("2016-12-31", format = "%Y-%m-%d")) %>% 
		mutate(counterparty = "short_term_loans_local_authorities"),
	
	# this is the missing values for long-term - fill it with NAs
debt_and_investments %>% 
		filter(counterparty == "longer_term_loans_local_authorities" & Date == as.Date("2016-12-31", format = "%Y-%m-%d")) %>% 
		mutate(value = NA),
	
	# this is the rest of the dataset
debt_and_investments %>% 
		filter(!(counterparty %in% c("short_term_loans_local_authorities", "longer_term_loans_local_authorities") & Date == as.Date("2016-12-31", format = "%Y-%m-%d")))
)

# -------------------------------------------------------------------------------- tidy up and write out
debt_and_investments <- debt_and_investments %>%
	mutate(
		Units = as.factor(Units),
		source_publication = as.factor(source_publication))

debt_and_investments_wide <- debt_and_investments %>% select(-source_publication) %>% spread(Date, value)
