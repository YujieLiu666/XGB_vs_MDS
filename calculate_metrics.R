library(Metrics)
library(lmodel2)
calculate_metrics <- function(truth, prediction) {
  print(paste0("gaps in truth, ", sum(is.na(truth))))
  print(paste0("gaps in prediction, ", sum(is.na(prediction))))

  non_na_indices <- which(!is.na(truth)) # more gaps in truth
  truth <- truth[non_na_indices]
  prediction <- prediction[non_na_indices]
  
  # Calculate metrics
  rmse_value <- rmse(truth, prediction)
  percent_bias_value <- percent_bias(truth, prediction)
  mae_value <- rae(truth, prediction)
  bias_value = mean(prediction - truth)
  
  # Create data frame
  data <- data.frame(
    truth = truth,
    prediction = prediction
  )
  
  # Fit linear regression model
  fit <- lmodel2(prediction ~ truth, data,  range.y="interval",range.x="interval", 99)
  reg <- fit$regression.results
  names(reg) <- c("method", "intercept", "slope", "angle", "p-value")
  reg <- reg[2,] # pull out just 1 of the regression fits (MA)
  rsquare = round(fit$rsquare,3)
  
  # Number of observations
  num_observations <- length(truth)
  
  # Store results in a data frame
  results <- data.frame(
    RMSE = rmse_value, 
    Percent_Bias = percent_bias_value,
    Bias = bias_value,
    MAE = mae_value, 
    R2 = rsquare,
    intercept = reg$intercept,
    slope = reg$slope,
    angle = reg$angle,
    p_value = reg$`p-value`,
    Num_Observations = num_observations
  )
  
  return(results)
  write(results, "calculate_metrics_results.csv")
}

print("load function calculate_metrics is done!")