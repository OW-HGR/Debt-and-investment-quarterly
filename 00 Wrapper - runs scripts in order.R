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
HMT_project_folder <- "C:/Users/RHMTOWilliamson/OneDrive - TrIS/Debt-and-investment-quarterly/"
Mac_15_project_folder <- "/Users/mbp15/Dropbox/git/Debt-and-investment-quarterly/"

project_folder <- Mac_15_project_folder

HMT_output_folder <- "C:/Users/RHMTOWilliamson/OneDrive - TrIS/Long-data-output/"
Mac_15_output_folder <- "/Users/mbp15/Dropbox/Output/"

output_folder <- Mac_15_output_folder
	
#	decide if you want each script to write out intermediate outputs and drop the tables, or just keep them loaded in the environment
write_out_y_n <- "n"

#	run scripts. tell it to return to the project folder after each one so it can find the next script
setwd(project_folder)

source("01 read straight from xslx.R")

setwd(project_folder)
source("02 debt standardise.R")

Sys.time() - t_0