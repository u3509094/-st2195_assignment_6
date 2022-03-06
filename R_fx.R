#Daily USD/EUR reference exchange rate dataset from the ECB Statistical Data Warehouse
fx <- read.csv("data.csv", header = FALSE, col.names = c("period", "value", 'obs.status'))
fx <- fx[, c("period", "value")]

#Speeches dataset from the European Central Bank
speeches <- read.csv("speeches.csv", sep = "|", quote = "")
speeches <- speeches[, c("date", "contents")]

fx_speeches <- fx %>% left_join(speeches, by = c("period" = "date"))
str(fx_speeches)

# period column data type: chr to Date
fx_speeches$period <- as.Date(fx_speeches$period)
# value column data type: chr to num
fx_speeches$value <- as.numeric(fx_speeches$value)

#NA, min and max in the value column
sum(is.na(fx_speeches$value))
min(fx_speeches$value, na.rm = TRUE)
max(fx_speeches$value, na.rm = TRUE)

#Distribution of exchange rate in the value column
library(ggplot2)
ggplot(fx_speeches) +
  geom_histogram(aes(x = value))