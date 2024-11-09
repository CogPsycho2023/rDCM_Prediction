clear all
clc

load('EC_Whole_brain_XEON.mat');
load('CTQ.mat');
all_mats = EC;
all_behav = CTQ;
k = 10;
thresh_type = 'sparsity';
thresh_values = [0.05, 0.1, 0.2]; % Thresholds to iterate over
NUM_RUNS = 100; % Repeating runs
lambda_values = logspace(-8,1,300);% Lambda values for ridge regression

% Loop over different thresholds
for thresh = thresh_values
    % Initialize output variables for each threshold
    BestCorrelation = zeros(NUM_RUNS, 3);
    sum_mask_all_runs = [];
    
    for run = 1:NUM_RUNS
        Steps = 1;
        for lambda = lambda_values
            rng(run); %control random seed for each lambda, then each lambda will face the same k-splits%
            [Correlation, MAE, sum_mask_all] = run_TaskFC_Ridge(all_behav, all_mats, k, thresh_type, thresh, lambda);
            Repeated_Correlation(Steps,1) = mean(Correlation);
            Repeated_MAE(Steps,1) = mean(MAE);
            Repeated_lambda(Steps,1) = lambda;
            Steps = Steps + 1;
        end
        
        % Find the best correlation and corresponding lambda
        [R, P] = max(Repeated_Correlation(:,1));
        BestCorrelation(run, 1) = R;
        BestCorrelation(run, 2) = Repeated_lambda(P);
        BestCorrelation(run, 3) = Repeated_MAE(P);
        sum_mask_all_runs(:,:,run) = sum_mask_all;
    end
    
    % Save output for each threshold
    outname = string(strcat('EC_Wholebrain',thresh_type,'_',num2str(thresh),'10fold_Ridge.mat'));
    save(outname, 'BestCorrelation', 'sum_mask_all_runs');
end
