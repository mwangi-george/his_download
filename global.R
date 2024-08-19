
# Packages required -----
pacman::p_load(
    tidyverse, shiny, shinydashboard, shinyjs, memoise, fs, httr, emo
)

# run options
options(shiny.launch.browser = TRUE)

# Imports --------------
# custom functions
source("utils.R")

# custom styles
source("styles.R")

# sourcing modules
dir_ls("modules/") %>% map(., ~ source(.x))

# sourcing ui parts
dir_ls("ui_parts/") %>% map(., ~ source(.x))

