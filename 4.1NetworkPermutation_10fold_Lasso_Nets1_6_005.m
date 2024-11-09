clear all
clc
load('CTQ.mat');
load('EC_networks.mat');

% Define the thresholds to iterate over
thresh_values = [0.05];

% Loop over different thresholds
for thresh = thresh_values
    % Loop over the 7 networks
    for Network = 1:6;
        all_mats = within_network_submatrices{Network,1};
        all_behav = CTQ;
        k = 10;
        thresh_type = 'sparsity';
        NUM_RUNS = 100; % Repeating runs
        lambda_values = logspace(-8,1,300);% Lambda values for ridge regression
        % Initialize output variables for each threshold and network
        BestCorrelation = zeros(NUM_RUNS, 3);
        
        for run = 1: NUM_RUNS
            Steps = 1;
            for lambda = lambda_values
                rng(run);
                [Correlation, MAE, sum_mask_all] = run_TaskFC_Lasso(all_behav, all_mats, k, thresh_type, thresh, lambda);
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
        
        % Save output for each threshold and network
        outname = string(strcat('EC_network',num2str(Network),thresh_type,'_',num2str(thresh),'10fold_Lasso.mat'));
        save(outname,'BestCorrelation','sum_mask_all_runs');
        
        % Clear variables except the ones needed for the next iteration
        clearvars -except within_network_submatrices Network CTQ thresh_values thresh
    end
end
