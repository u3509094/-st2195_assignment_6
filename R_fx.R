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

#No. of NAs in the value column
sum(is.na(fx_speeches$value))
#Minimum and maximum value in the value column
min(fx_speeches$value, na.rm = TRUE)
max(fx_speeches$value, na.rm = TRUE)

#Distribution of the exchange rate
library(ggplot2)
ggplot(fx_speeches) +
  geom_histogram(aes(x = value))

#Replace NAs with exchange rate in the previous date
library(tidyr)
fx_speeches <- fx_speeches %>% 
  fill(value, .direction = "up")
sum(is.na(fx$value))

#Repeat lines 13-17 and lines 29-34 on fx dataset
fx$period <- as.Date(fx$period)
fx$value <- as.numeric(fx$value)
fx <- fx %>%
  fill(value, .direction = "up")
sum(is.na(fx$value))

#Create new columns in the fx dataframe
fx <- fx %>% 
  mutate(fx_diff = value - lead(value),
         fx_per_diff = fx_diff / value * 100,
         good_news = ifelse(fx_per_diff > 0.5, 1, 0),
         bad_news = ifelse(fx_per_diff < -0.5, 1, 0))

#Align the data type in the date column for joining
speeches$date <- as.Date(speeches$date)
fx_speeches <- fx %>%
  left_join(speeches, by = c("period" = "date"))
str(fx_speeches)

#Remove NAs in the contents column
sum(is.na(fx_speeches$contents))
fx_speeches <- fx_speeches %>%
  drop_na(contents)
#Remove the prefix "SPEECH" in the contents column
fx_speeches$contents <- ifelse(substr(fx_speeches$contents, 1, 11) == "   SPEECH  ",
                               substr(fx_speeches$content, 12, nchar(fx_speeches$contents)),
                               fx_speeches$contents)

#Select good_news and bad_news for word extraction
fx_good <- fx_speeches %>%
  filter(good_news == 1) %>%
  select(period, contents)
fx_bad <- fx_speeches %>%
  filter(bad_news == 1) %>%
  select(period, contents)

#Count the word occurrence in the contents column in fx_good
library(tidytext)
fx_good_indicators <- fx_good %>%
  unnest_tokens(input = contents, output = word) %>%
  count(word) %>%
  arrange(desc(n)) %>%
  top_n(100)

#Exclude the prepositions and connectors and select 20 words with highest count
connector_list <- c("the", "of", "and", "in", "to", "a", "is", "that", "for", "on", "this", "as", "â", "be", "by", "are", "have", "it", "with", "has", "de", "at", "we", "which", "not", "an", "i", "will", "from", "more", "also", "been", "der", "die", "our", "would", "can", "these", "s", "their", "la", "but", "its", "or", "was", "should", "all", "they", "some", "there")
fx_good_indicators <- fx_good_indicators %>% 
  filter(!word %in% connector_list) %>% 
  top_n(20)

#Re-do word counting in fx_bad
fx_bad_indicators <- fx_bad %>% 
  unnest_tokens(input = contents, output = word) %>% 
  count(word) %>% 
  arrange(desc(n)) %>% 
  top_n(100)
fx_bad_indicators <- fx_bad_indicators %>% 
  filter(!word %in% connector_list) %>% 
  top_n(20)

#Check any words in common in two cases
good_bad_intersect <- intersect(fx_good_indicators$word, fx_bad_indicators$word)

#Store the good_indicators and bad_indicators in CSV files
write.csv(fx_good_indicators, file = "good_indicators_r.csv")
write.csv(fx_bad_indicators, file = "bad_indicators_r.csv")