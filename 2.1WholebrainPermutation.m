clear all
clc
load('EC_Whole_brain_XEON.mat');
load('CTQ.mat');
all_mats = EC;
all_behav = CTQ;
k = 10;
thresh_type = 'sparsity';
NUM_RUNS = 500; % Repeating runs
num_samples = size(all_behav, 1);
lambda_values = logspace(-8,1,300);% Lambda values for ridge regression
% Define threshold values to loop over
thresholds = [0.05, 0.1, 0.2];
% Loop over each threshold
for thresh = thresholds
% Initialize output variables
for run = 1:NUM_RUNS
rng(run);
Steps = 1;
shuffled_behav = CTQ(randperm(num_samples));
for lambda = lambda_values
    rng(run);
[Correlation, MAE, sum_mask_all] = run_TaskFC_Ridge(shuffled_behav, all_mats, k, thresh_type, thresh, lambda);
Repeated_Correlation(Steps, 1) = mean(Correlation);
Repeated_MAE(Steps, 1) = mean(MAE);
Repeated_lambda(Steps, 1) = lambda;
Steps = Steps + 1;
end
% Find the best correlation and corresponding lambda
[R, P] = max(Repeated_Correlation(:, 1));
BestCorrelation(run, 1) = R;
BestCorrelation(run, 2) = Repeated_lambda(P);
BestCorrelation(run, 3) = Repeated_MAE(P);
sum_mask_all_runs(:, :, run) = sum_mask_all;
end
% Save results for each threshold
outname = strcat('EC_WholeBrain_Permutation_', thresh_type, num2str(thresh), '10fold_Ridge.mat');
save(outname, 'BestCorrelation', 'sum_mask_all_runs');
end
