## Function Description:

#  This function creates the forecasts for the specified model and data.  The model will be of the form:

# yt = b0 + exp(b1*y(t-1)) + b2x1 + b3x2 + ...

## Function Inputs:


#   Data     : The model data
#   model    : The model specification
#   Base_No  : The placement of the factor in the exponent.
#   Positions: A vector which contains the positions of the dependent and lagged dependent variable in the matrix


## Function Output:

# The forecasted values


dynforecast_exponent <- function(Data, model, Base_No,positions){
  
  
  ### Extract the model inofrmation
  
  Data <- Data[order(Data$Date, Data$POA_CODE),]                                           # Order the date according to the date and the postcode
  mindate <- min(Data$Date)                                                                # Determine the minimum date
  coef <- as.data.frame(summary(model)$coefficients[,1])                                   # Determine the coefficients from the model
  n_initial <- nrow(Data[Data$Date == mindate,])                                           # Determine the number of unique postcodes
  n_rows <- nrow(Data)                                                                     # The number of rows in the dataset
  
  
  ### Prepare the model file and Data for the forecasts
  
  
  model$coefficients[Base_No] <- rep(0,nrow(Base_No),1)                                    # Set the coefficients inside the exponent equal to zero 
  
  Data[(n_initial+1):n_rows,positions[2]] <- rep(0,n_rows-n_initial,1)                     # Set the lagged dependent variable to 0 after the initial period
  
  
  ### Forecast the model using the updated model file and data
  
  Data$Forecasts <- predict(model, Data)-1                                                 # Note: subtract 1 because exp(0) = 1
  
  
  ### Set the predictions for the first period to the actual data
  
  Data$Prediction[1:n_initial] <- Data[1:n_initial,positions[1]]
  
  ### Loop through the data and forecast the response.

  
  for (i in (n_initial+1):n_rows){
    
    
    Data$Prediction[i] <- Data$Forecasts[i] + exp(coef[Base_No,1]*Data$Prediction[i-n_initial]) 
    
  }
  
  return(Data)
  
}