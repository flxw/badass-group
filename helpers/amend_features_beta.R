### Helper function to data preprocessing and feature selection before applying predictive modeling

amend_features_beta = function(dd){
  dd$order_month = as.numeric(format(dd$order_date, "%m"))
  dd$order_day   = as.numeric(format(dd$order_date, "%d"))
  dd$order_year   = as.numeric(format(dd$order_date, "%Y"))
  
  dd$del_year  = as.numeric(format(dd$delivery_date, "%Y"))
  dd$del_month = as.numeric(format(dd$delivery_date, "%m"))
  dd$del_day   = as.numeric(format(dd$delivery_date, "%d"))
  
  dd$reg_year = as.numeric(format(dd$user_reg_date, "%Y"))
  dd$reg_month = as.numeric(format(dd$user_reg_date, "%m"))
  dd$reg_day   = as.numeric(format(dd$user_reg_date, "%d"))
  
  if("return" %in% colnames(dd)) {
    dd = normalizeFeatures(dd, target="return")
  }
  return(dd)
}