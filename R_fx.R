#Daily USD/EUR reference exchange rate dataset from the ECB Statistical Data Warehouse
fx <- read.csv("data.csv", header = FALSE, col.names = c("period", "value", 'obs.status'))
fx <- fx[, c("period", "value")]

#Speeches dataset from the European Central Bank
speeches <- read.csv("speeches.csv", sep = "|", quote = "")
speeches <- speeches[, c("date", "contents")]

fx_speeches <- fx %>% left_join(speeches, by = c("period" = "date"))
str(fx_speeches)
