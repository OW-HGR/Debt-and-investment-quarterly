t_0 <- Sys.time()
#	install the required libraries and their dependencies if they are not already in place 
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

#	set global variables

project_folder <- "/Users/mbp15/Dropbox/git/Debt-and-investment-quarterly/"
output_folder <- "/Users/mbp15/Dropbox/Output/"


#	run scripts. tell it to return to the project folder after each one so it can find the next script
setwd(project_folder)
source("01 stack data.R")

setwd(project_folder)
source("02 fix errors.R")

setwd(project_folder)
source("03 03 standardise vars and entities.R.R")

missing_counterparty
missing_LA
UK_country_comparison
UK_LA_comparison