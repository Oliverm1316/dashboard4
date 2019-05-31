library(vistime)
library(dplyr)
library(readxl)
library(RColorBrewer)

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

pal <- "rgba(124,252,0,0.3)"

df$color <- rep_len(pal,length.out = nrow(df))

a <- paste("take off time:",df$trnsfout_time)
b <- paste("flight nr:",df$flight_out)

df$flights <- paste(a,b,sep = "\n")


data <- df[,c("full_name","pick_vehicle","pick_update", 
              "trnsfout_date","color","flights")]

colnames(data) <- c("event","group","start","end","color","tooltip")


cutoff <- which(data$start == "2019-05-16 08:00:00 CEST") %>% min()

data1 <- data[1:17,]
data2 <- data[18:nrow(data),]


p <- vistime(data1, linewidth = 12, background_lines = 0,
             title = "Pick up and flight times")

pp <- plotly_build(p)

pp$x$layout$xaxis$tickfont <- list(size = 14)
for (i in grep("yaxis*", names(pp$x$layout))) pp$x$layout[[i]]$tickfont <- list(size = 10)

for (i in 1:length(pp$x$data)) {
  if (pp$x$data[[i]]$mode == "text") pp$x$data[[i]]$textfont$size <- 13}

pp



