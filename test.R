library(readxl)
library(dplyr)
library(timevis)

df <- read_excel('rooming.xlsx', sheet = 'trnsfout')
df <- df %>% filter(vehicle_out != "no transfer")

df$trnsfout_time <- df$trnsfout_time %>% as.POSIXct() %>%
  strptime("%Y-%m-%d %H:%M:%S",tz="") %>% format(format = "%H:%M")

df$pick_up <- df$pick_up %>% as.POSIXct() %>%
  strptime("%Y-%m-%d %H:%M:%S",tz="") %>% format(format = "%H:%M")

df$pick_update <- as.POSIXct(
  paste(df$trnsf_out,df$pick_up),format = "%Y-%m-%d %H:%M", tz = "")

df$trnsfout_date <- as.POSIXct(
  paste(df$trnsf_out,df$trnsfout_time),format = "%Y-%m-%d %H:%M", tz = "")

df$full_name <- paste(df$last, df$first)
df$pick_vehicle <- paste(df$pick_up,"-",df$vehicle_out)

data <- data.frame(id = 1:nrow(df),
                   content = df$full_name,
                   start = df$pick_update,
                   end = df$trnsfout_date,
                   type = "range",
                   style = "background-color:#ff9933;",
                   group = df$pick_vehicle)

groups <- data.frame(
  id = unique(df$pick_vehicle),
  content = unique(df$pick_vehicle))

data %>% timevis(groups, width = '100%', 
                 options = list(
                   orientation = "top")) %>% 
  setWindow(min(df$pick_update-3600),max(df$pick_update+13600)) %>% 
  setOptions(list(editable = TRUE)) 
