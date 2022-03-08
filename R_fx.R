#Daily USD/EUR reference exchange rate dataset from the ECB Statistical Data Warehouse
fx <- read.csv("data.csv", header = FALSE, col.names = c("period", "value", 'obs.status'))
fx <- fx[, c("period", "value")]

#Speeches dataset from the European Central Bank
speeches <- read.csv("speeches.csv", sep = "|", quote = "")
speeches <- speeches[, c("date", "contents")]

#Joining fx and speeches dataframe
library(dplyr)
fx_speeches <- fx %>%
  left_join(speeches, by = c("period" = "date"))
str(fx_speeches)

#period column data type: chr to Date
fx_speeches$period <- as.Date(fx_speeches$period)
#value column data type: chr to num
fx_speeches$value <- as.numeric(fx_speeches$value)
str(fx_speeches)

#No. of Not Available in the value column
sum(is.na(fx_speeches$value))
#Minimum and maximum value in the value column
min(fx_speeches$value, na.rm = TRUE)
max(fx_speeches$value, na.rm = TRUE)

#Distribution of the exchange rate
library(ggplot2)
ggplot(fx_speeches) +
  geom_histogram(aes(x = value))

#Replace NA with exchange rate in the previous date
library(tidyr)
fx_speeches <- fx_speeches %>% 
  fill(value, .direction = "up")
sum(is.na(fx$value))

#Repeat lines 13-17 and lines 29-34 on fx dataset
fx$period <- as.Date(fx$period)
fx$value <- as.numeric(fx$value)
fx <- fill(fx, value, .direction = "up")
sum(is.na(fx$value))

#Create new columns in the fx dataframe
fx <- mutate(fx,
             fx_diff = value - lead(value),
             fx_per_diff = fx_diff / value * 100,
             good_news = ifelse(fx_per_diff > 0.5, 1, 0),
             bad_news = ifelse(fx_per_diff < -0.5, 1, 0))