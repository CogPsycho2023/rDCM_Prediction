# rDCM_Prediction
Scripts for whole-brain and network-specific effective connectivity in predicting individual characteristics

# About prediction
Our script uses a ridge-regularized and lasso-regularized linear regression model, and the hyperparameter (lambda) was searched for each case.

# One key change
Our previous scritp didn't control the random seeds well, where rng(seed) was performed outside of the lambda searching loop. This led to different k-fold splits for a set of lambda. It has been corrected by setting rng(seed) inside of the lambda searching loop. 
