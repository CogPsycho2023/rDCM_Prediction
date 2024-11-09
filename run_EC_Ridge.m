function [Correlation, MAE, sum_mask_all] = run_taskFC_ridge(all_behav, all_mats,k, thresh_type,thresh,lambda)

%% 1) Prepare cross-validated CPM
% preallocate arrays
% get number of ppts, nodes, arrays
no_sub = size(all_mats,3);
no_node = size(all_mats,1);

% preallocate arrays to store selected edges in each fold
pos_mask_all = zeros(no_node, no_node, k);
neg_mask_all = zeros(no_node, no_node, k);
sum_mask_all = zeros(no_node, no_node);
% specify cross-validation scheme
kfold_partition = cvpartition(no_sub, 'KFold', k);
Correlation=[];

%% 2) Run cross-validated CPM
% loop through each fold and run CPM
for fold = 1:k
    % print message to update
    fprintf('\n Leaving out fold # %6.3f\n',fold);
    
    % divide data into training and test sets (Step 2 - Shen et al. 2017)
    %% 1) Get indices of training and test set participants
    
    ix_train = find(training(kfold_partition, fold));
    ix_test = find(test(kfold_partition, fold));
    
    %% 2) Remove test set participants from training set data
    train_mats = all_mats(:, :, ix_train);
    train_vcts = reshape(train_mats,[],size(train_mats,3));
    train_behav = all_behav(ix_train,:);

    %% 3) Get data for test set participants 
    test_mats = all_mats(:, :, ix_test);
    test_behav = all_behav(ix_test,:);
    
    % feature selection - relate edges to target variable (Step 3 - Shen et
    % al. 2017)
    % Relate functional connectivity to behaviour
    [r_mat,p_mat] = corr(train_vcts',train_behav);

    % Reshape from vectors to matrices
    r_mat = reshape(r_mat,no_node,no_node);
    p_mat = reshape(p_mat,no_node,no_node);

    % feature selection - select edges (Step 4 - Shen et al. 2017)
    if strcmp(thresh_type, 'p-value');
        % Create arrays to store edges
        pos_mask = zeros(no_node,no_node);
        neg_mask = zeros(no_node,no_node);

    
        % Find edges with positive correlation to target variable that survive
        % threshold
        pos_edges = find(r_mat > 0 & p_mat < thresh);
        % Find edges with positive correlation to target variable that survive
        % threshold
        neg_edges = find(r_mat < 0 & p_mat < thresh);
        % Store edges in masks
        pos_mask(pos_edges) = 1;
        neg_mask(neg_edges) = 1;
        
    else strcmp(thresh_type, 'sparsity');
    % Create arrays to store edges  
    pos_mask = zeros(no_node,no_node);
    neg_mask = zeros(no_node,no_node);

    % Calculate number of edges to be returned in each network
    % Get number of unique mx elements by squaring number of nodes, then
    % subtracting number of nodes (i.e. minus diagonal), then divide by 2
    % (account for symmetry). Multiply num of unique mx elements by sparsity
    % threshold to get the % of edges to be returned. %It seems unnecessary to do
    % in my case (Shufei Zhang).
    %  max_edges = round((((no_node^2) - no_node)/2)*thresh);
    max_edges = round(((no_node^2))*thresh);

    % Reshape r_mat to vector
    r_vec = reshape(r_mat, [], 1);

    % Get min correlation value that survives sparsity threshold (for pos
    % network)
    min_corr = min(maxk(r_vec, max_edges));

    % Get max correlation value that survives sparsity threshold (for neg
    % network)
    max_corr = max(mink(r_vec, max_edges));

    % Find edges with positive correlation to target variable that survive
    % threshold
    pos_edges = find(r_mat >= min_corr & r_mat > 0);

    % Find edges with negative correlation to target variable that survive
    % threshold
    neg_edges = find(r_mat <= max_corr & r_mat < 0);

    % Store edges in masks
    pos_mask(pos_edges) = 1;
    neg_mask(neg_edges) = 1;
    end
    
    sum_mask = pos_mask + neg_mask ;
   
    % Get sum of all positive and negative thresholded edges in training set
    % participants. Divide by 2 control for the fact that matrices are
    % symmetric.
    train_sum=[] ; 
    for ss = 1:size(train_mats,3);
        train_sum(:,:,ss) = train_mats(:,:,ss).*sum_mask;
    end
    
    % Create independent variables for each network strength model - add column
    % of ones to network strength values
    x_combined = reshape(train_sum,[],size(train_sum,3));
    x_combined = x_combined' ;
    non_zeros_indices = any(x_combined,1) ;
    x_combined=x_combined(:,non_zeros_indices) ;
    % Fit each network strength model
    % Train linear regression model using fitrlinear
    mdl_combined = fitrlinear(x_combined, train_behav,'Regularization','ridge','Lambda',lambda);

    % Calculate network strengths for participants in the training set
    test_sum = [];
    test_sum = test_mats.*sum_mask;
    test_sum = reshape(test_sum,[],size(test_mats,3));
    test_sum = test_sum' ;
    non_zeros_indices = any(test_sum,1);
    test_sum = test_sum(:,non_zeros_indices);

    % A simple linear regression with Lasso
    pred_combined = predict(mdl_combined, test_sum);
    
        
    % store edges selected in current fold
    pos_mask_all(:, :, fold) = pos_mask;
    neg_mask_all(:, :, fold) = neg_mask;
    sum_mask_all = sum_mask_all + sum_mask;
    % calculate correlation and mean absolute error
    Correlation(:,fold) = corr(pred_combined,test_behav);
    MAE(:,fold) = mean(abs(pred_combined - test_behav));
       
end

end
