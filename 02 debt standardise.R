
# -------------------------------------------------------------------------------- Standardise service area names across years
ifelse(computer == "15", 	setwd("/Users/mbp15/Dropbox/Long data v4/Debt, from borrowing and investment series/Libraries"),
			 ifelse(computer == "12", 	setwd("/Users/oscarwilliamson/Dropbox/Long data v4/Debt, from borrowing and investment series/Libraries"),
			 			 setwd("/Users/oscar.williamson/Dropbox/Long data v4/Debt, from borrowing and investment series/Libraries")))

debt_lib <- unique(read.csv("Debt_category_library.csv"))

Debt <- merge(Debt, debt_lib, by.x = 'Debt_type', by.y = 'original_Debt_type', all.x = TRUE)

missing_lender <- select(Debt, c(Debt_type, continuity_lender))
missing_lender <- unique(filter(missing_lender, is.na(continuity_lender)))

ifelse(computer == "15", 	setwd("/Users/mbp15/Dropbox/Long data v4/Debt, from borrowing and investment series/Logs"),
			 ifelse(computer == "12", 	setwd("/Users/oscarwilliamson/Dropbox/Long data v4/Debt, from borrowing and investment series/Logs"),
			 			 setwd("/Users/oscar.williamson/Dropbox/Long data v4/Debt, from borrowing and investment series/Logs")))

write.csv(missing_lender, file = "missing_lender.csv", row.names = FALSE)
rm(debt_lib, missing_lender)

Debt <- filter(Debt, continuity_lender != "drop")

# -------------------------------------------------------------------------------- Standardise LA names
ifelse(computer == "15", 	setwd("/Users/mbp15/Dropbox/Libraries"),
			 ifelse(computer == "12", 	setwd("/Users/oscarwilliamson/Dropbox/Libraries"),
			 			 setwd("/Users/oscar.williamson/Dropbox/Libraries")))

LA_name_lookup <- unique(select(read.csv("LA lookup master.csv"), c(original_LA_name, continuity_LA_name)))

Debt <- merge(Debt, LA_name_lookup, by.x = "LA", by.y = "original_LA_name", all.x = TRUE)
rm(LA_name_lookup)

#write out missing LA names
missing_LA <- select(Debt, c(LA, Date, continuity_LA_name))
missing_LA <- unique(filter(missing_LA, is.na(continuity_LA_name)))

ifelse(computer == "15", 	setwd("/Users/mbp15/Dropbox/Long data v4/Debt, from borrowing and investment series/Logs"),
			 ifelse(computer == "12", 	setwd("/Users/oscarwilliamson/Dropbox/Long data v4/Debt, from borrowing and investment series/Logs"),
			 			 setwd("/Users/oscar.williamson/Dropbox/Long data v4/Debt, from borrowing and investment series/Logs")))

write.csv(missing_LA, file = "missing_LA_name.csv", row.names = FALSE)
rm(missing_LA)

# --------------------------------------------  clean up, check, and write out

Debt <- select(Debt, c(continuity_LA_name, Term, continuity_lender, Date, Units, Value))
names(Debt) <- c("LA", "Term", "Lender", "Date", "Units", "Value")

# in Q3 2016-17/ 31-12-2016, short term borrowing from other LAs is incorrectly labelled as long term borrowing, and long term borrowing is missing
# correct labelling

Debt <- bind_rows(
	(filter(Debt, Lender == "Local authorities" & Date == "2016-12-31" & Term == "Over a year") %>% mutate(Term = "Under a year")),
	filter(Debt, !(Lender == "Local authorities" & Date == "2016-12-31")))



plot_0 <- ggplot(aggregate(Value ~ Lender + Date + Units + Term, Debt, sum) %>% filter(Lender == "Local authorities"),
								 aes(x = Date, y = Value, group = Term, colour = Term)) +
	geom_line() + 
	ggtitle("Debt by lender, £m, UK") #+
#	facet_grid(cols = vars(Term), rows = vars(Lender)) + 
#	theme(legend.position = "none", 
#	strip.text.y = element_text(angle = 0))
plot_0

plot_1 <- ggplot(aggregate(Value ~ Lender + Date + Units, Debt, sum),
								 aes(x = Date, y = Value, group = Lender, colour = Lender)) +
	geom_line() + 
	ggtitle("Debt by lender, £m, UK") +
	facet_grid(cols = vars(Lender))
plot_1

# composite series of private lenders, pwlb, or LA
Debt_totals <- aggregate(Value ~ Lender + Date + Units, Debt, sum)

Debt_totals <- bind_rows(
	(filter(Debt_totals, !Lender %in% c("Local authorities", "PWLB")) %>% 
	 	group_by(Date, Units) %>%
	 	summarise(Value = sum(Value, na.rm = TRUE)) %>%
	 	mutate(Lender = "Private lenders")),
	filter(Debt_totals, Lender == "Local authorities"),
	filter(Debt_totals, Lender == "PWLB"))

plot_2 <- ggplot(Debt_totals,
								 aes(x = Date, y = Value, group = Lender, colour = Lender)) +
	geom_line() + 
	geom_point(size = 0.5) + 
	ggtitle("Debt by lender, £m, UK")
plot_2

ifelse(computer == "15", 	setwd("/Users/mbp15/Dropbox/Output"),
			 ifelse(computer == "12", 	setwd("/Users/oscarwilliamson/Dropbox/Output"),
			 			 setwd("/Users/oscar.williamson/Dropbox/Output")))

write.csv(spread(Debt, Date, Value, fill = NA), file = "Debt_wide.csv", row.names = FALSE, na = "")

