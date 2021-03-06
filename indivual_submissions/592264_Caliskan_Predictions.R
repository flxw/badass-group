setwd("~/Desktop/Assignment_BADS_WS1718")
# caliskae@hu-berlin.de

# Data read / Data cleansing

sales <- read.csv2("BADS_WS1718_class.csv", sep = ",", stringsAsFactors = FALSE)

## Item-size conversion
sales$item_size [sales$item_size == "XS" ] <- "xs"
sales$item_size [sales$item_size == "XL" ] <- "xl"
sales$item_size [sales$item_size == "L" ] <- "l"
sales$item_size [sales$item_size == "M" ] <- "m"
sales$item_size [sales$item_size == "S" ] <- "s"
sales$item_size [sales$item_size == "XXL" ] <- "xxl"
sales$item_size [sales$item_size == "XXXL" ] <- "xxxl"
sales$item_size [sales$item_size == "36" ] <- "s"
sales$item_size [sales$item_size == "37" ] <- "s"
sales$item_size [sales$item_size == "38" ] <- "m"
sales$item_size [sales$item_size == "35" ] <- "xs"
sales$item_size [sales$item_size == "38+" ] <- "m"
sales$item_size [sales$item_size == "36+" ] <- "s"
sales$item_size [sales$item_size == "37+" ] <- "s"
sales$item_size [sales$item_size == "39+" ] <- "m"
sales$item_size [sales$item_size == "39" ] <- "m"
sales$item_size [sales$item_size == "40" ] <- "m"
sales$item_size [sales$item_size == "40+" ] <- "m"
sales$item_size [sales$item_size == "41" ] <- "l"
sales$item_size [sales$item_size == "41+" ] <- "l"
sales$item_size [sales$item_size == "42+" ] <- "l"
sales$item_size [sales$item_size == "42" ] <- "l"
sales$item_size [sales$item_size == "43" ] <- "l"
sales$item_size [sales$item_size == "43+" ] <- "xl"
sales$item_size [sales$item_size == "44+" ] <- "xl"
sales$item_size [sales$item_size == "44" ] <- "xl"
sales$item_size [sales$item_size == "45" ] <- "xl"
sales$item_size [sales$item_size == "45+" ] <- "xl"
sales$item_size [sales$item_size == "46" ] <- "xl"
sales$item_size [sales$item_size == "46+" ] <- "xl"
sales$item_size [sales$item_size == "47" ] <- "xxl"
sales$item_size [sales$item_size == "48" ] <- "xxl"
sales$item_size [sales$item_size == "50" ] <- "xxl"
sales$item_size [sales$item_size == "34" ] <- "xs"
sales$item_size [sales$item_size == "52" ] <- "xxxl"
sales$item_size [sales$item_size == "54" ] <- "xxxl"
sales$item_size [sales$item_size == "56" ] <- "xxxl"
#sales$item_size [sales$item_size == "unsized"] <- "m"
# user_dob / data cleansing
sales$user_dob <- substring(sales$user_dob,1,4)
sales$user_dob [sales$user_dob == "?"] <- NA
sales$user_dob [sales$user_dob < 1920 ] <-NA
count<- table(sales$user_dob)
MFV <- names(count) [count == max (count)]
sales$user_dob [is.na(sales$user_dob)] <- MFV 
sales$user_dob <- as.numeric(sales$user_dob)
standardize <- function(x){
  mu <- mean(x)
  std <- sd(x)
  result <- (x - mu)/std
  return(result)}
zScores_sales_dob <- standardize(sales$user_dob)
sales$user_dob [zScores_sales_dob > 3] <- round(mean(sales$user_dob) + 3*sd(sales$user_dob), digit=0)
sales$user_dob [zScores_sales_dob < -3] <- round(mean(sales$user_dob) - 3*sd(sales$user_dob), digit=0)
# order_date and delivery_date / data cleansing
sales$order_date <-   as.Date(sales$order_date, "%Y-%m-%d")
sales$delivery_date <- as.Date(sales$delivery_date, "%Y-%m-%d")
sales$delivery_duration<- difftime(sales$delivery_date , sales$order_date, units = c("days"))
sales$delivery_duration [sales$delivery_duration < 0] <- NA
sales$delivery_duration [sales$delivery_duration == "?"] <- NA
sales$delivery_duration [is.na (sales$delivery_duration)] <- 2 
sales$delivery_duration <- as.numeric(sales$delivery_duration, units="days") 
# item-price / data cleansing
sales$item_price <- as.numeric(sales$item_price)
sort(table(sales$item_price), decreasing = TRUE) #MFV
sales$item_price [is.na(sales$item_price) ] <- 59.9 
boxplot(sales$item_price)
zScores <- standardize(sales$item_price)
sales$item_price [zScores > 3] <- round(mean(sales$item_price) + 3*sd(sales$item_price), digit=2)
boxplot(sales$item_price)
#user_reg_date / data cleansing
sales$user_reg_date <-   as.Date(sales$user_reg_date, "%Y-%m-%d")
sales$ user_maturity <- difftime(sales$order_date , sales$user_reg_dat, units = c("days"))
sales$user_maturity <- as.numeric(sales$user_maturity, units="days") 
#user_title / data cleansing
sales$user_title [sales$user_title == "not reported"] <-NA
sales$user_title [is.na(sales$user_title)] <- "Mrs"
#item_color /  data cleansing
sales$item_color [sales$item_color == "blau"] <- "blue"
sales$item_color [sales$item_color == "brwon"] <- "brown"
sales$item_color [sales$item_color == "oliv"] <- "olive"
sales$item_color [sales$item_color == "?"] <- NA
sort(table(sales$item_color), decreasing = TRUE) ## MFV
sales$item_color [is.na (sales$item_color)] <- "black"
sales$user_dob <- as.numeric(sales$user_dob)
# Month of Delivery
 sales$month_of_delivery <- substring(sales$delivery_date,6,7)
 sales$month_of_delivery [is.na(sales$month_of_delivery)] <- "01"
 # Factoring
chrIdx <- which(sapply(sales, is.character))
sales[, chrIdx] <- lapply( sales[, chrIdx],factor)
sales$item_price <- as.numeric(sales$item_price)

sales$return <- factor(sales$return, labels = c("keep","return"))

#  Funcion for replacing new levels in the new data with NA 

missingLevelsToNA<-function(object,data){
  
#Obtaining factors in the model and their levels
  
  factors<-(gsub("[-^0-9]|as.factor|\\(|\\)", "",names(unlist(object$xlevels))))
  factorLevels<-unname(unlist(object$xlevels))
  modelFactors<-as.data.frame(cbind(factors,factorLevels))
  
#Select column names of the factors
  
  predictors<-names(data[names(data) %in% factors])
  
#For each factor level that doesn't exist in the original data set; set the value to NA
  
  for (i in 1:length(predictors)){
    found<-data[,predictors[i]] %in% modelFactors[modelFactors$factors==predictors[i],]$factorLevels
    if (any(!found)) data[!found,predictors[i]]<-NA
  }
  
  data
  
}

pred_model <- glm(return ~  user_dob + delivery_duration + user_maturity + user_state + item_price + item_color +item_size+ month_of_delivery,data = retail,family = binomial(link = "logit"))
sales <- missingLevelsToNA(pred_model,sales)

prob.pred  = as.vector(predict(dt, newdata=sales ,type="prob") [,"return"])
class.pred  = ifelse(prob.pred > 0.5, 1, 0)
sales$return<- class.pred

result <- subset(sales, select = c("order_item_id", "return"))
colnames(result) = c("order_item_id","return")

write.csv(result, file = "592264_Caliskan.csv", row.names = FALSE)

str(result) # int and numeric 
table(result$return, useNA = "ifany") # No NA's spotted!
NROW(result$return) # in the interval 100001:150000
# keep / return levels 0 / 1 are manually checked!
# Col names as stated above c("order_item_id", "return")
# Obv. 2 columns!


# Problem evaluation

# I have used a naive threshold of 0.5 for "return" and "keep" classifications.

# A returned item is a cost for the business. On the other hand, if a customer does not order an item that would not have been returned, a higher revenue is lost.

# Since the above mentioned costs are asymmetric, instead of a naive threshold of 0.5 for "return" and "keep" classifications, a threshold higher than 0.5 can be employed. So that the business have a safety zone and the number of warnings prompted when unnecessary would be minimized!