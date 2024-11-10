# rDCM_Prediction
Scripts for whole-brain and network-specific effective connectivity in predicting individual characteristics

# About prediction
Our script uses a ridge-regularized and lasso-regularized linear regression model, and the hyperparameter (lambda) was searched for each case.

# One important change
Our previous scritp didn't control the random seeds well, where rng(seed) was performed outside of the lambda searching loop. This led to different k-fold splits for a set of lambda. It has been corrected by setting rng(seed) inside of the lambda searching loop. 

# Script description
1.Whole_brain.m for merging individual whole-brain EC into a 3D matrix
2.WholeBrainPrediction.m for whole-brain prediction, where lambda searching areas and feature selection thresholds can be changed depending on purposes.
3.WithinBetweenNetworks.m for down-resampling whole-brain EC into seven networks, based on the parcel.mat (parcellation labels).
4.NetworkPrediction_Ridge/Lasso.m for network predictions with different linear regression model.
2.1WholebrainPermutation.m and 4.1NetworkPermutation.m scripts for permutation tests.
run_EC_Ridge/Lasso.m for predictions with different models.

# The current study included a Schaefer-based atlas (100-parcellation, 7 networks)
The Parcellation_labels.txt records the network, which refers to (https://github.com/ThomasYeoLab/CBIG/blob/master/stable_projects/brain_parcellation/Schaefer2018_LocalGlobal/Parcellations)

