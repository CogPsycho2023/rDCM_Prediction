clear all
clc

% Load data
load('EC_networks.mat');  % Network submatrices
load('CTQ.mat');  % Behavioral data

% Define thresholds to loop over
thresholds = [0.05, 0.1, 0.2];  % Include multiple thresholds

% Loop over each threshold
for thresh = thresholds
    % Loop over each network (1 to 7)
    for Network = 1:7;
        all_mats = within_network_submatrices{Network, 1};  % Extract network submatrix
        all_behav = CTQ;  % Use CTQ as behavioral data
        k = 10;  % Number of folds for cross-validation
        thresh_type = 'sparsity';  % Type of threshold
        num_samples = size(all_behav, 1);  % Number of subjects/samples
        NUM_RUNS = 500;  % Number of repeated runs
        lambda_values = logspace(-8,1,300);% Lambda values for ridge regression
        
        % Initialize output variables
        BestCorrelation = zeros(NUM_RUNS, 3);  % Stores best correlation, lambda, and MAE
        sum_mask_all_runs = [];  % Initialize for storing sum mask across runs
        
        % Loop for each permutation run
        for run = 1:NUM_RUNS
            rng(run);  % Set random seed for reproducibility
            Steps = 1;
            shuffled_behav = all_behav(randperm(num_samples));  % Shuffle behavioral data
            
            % Loop over lambda values
            for lambda = lambda_values
                rng(run)
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
            sum_mask_all_runs(:, :, run) = sum_mask_all;  % Store sum mask for this run
        end
        
        % Save results for each network and threshold
        outname = strcat('EC_network', num2str(Network), '_Permutation_', thresh_type, num2str(thresh), '10fold_Ridge.mat');
        save(outname, 'BestCorrelation', 'sum_mask_all_runs');
        
        % Clear variables except the required ones for the next iteration
        clearvars -except within_network_submatrices CTQ thresholds thresh Network
    end
end
