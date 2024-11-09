clear all
clc
% Load the connectivity matrix
load('EC_Whole_brain_XEON.mat');  % Assuming 'Ep_A.mat' contains a variable named 'connectivity_matrix' of size 100x100x257
connectivity_matrix = EC;

% Load node labels (assuming you have a variable named 'node_labels' of size 100x1)
load('Parcels.mat');  % Assuming 'node_labels.mat' contains a variable named 'node_labels' of size 100x1
node_labels = net_labels; % Corrected variable name

num_networks = 7;

% Initialize a cell array to store within-network submatrices
within_network_submatrices = cell(num_networks, 1);

% Initialize a 7x7 cell array to store the combined metrics
combined_metrics_cell = cell(num_networks, num_networks);

% Initialize a variable to store the number of subjects
num_subjects = size(connectivity_matrix, 3);

% Initialize a cell array to store between-network metrics across subjects
between_network_metrics = cell(num_networks, num_networks, num_subjects);

% Loop through each time point (265 in this example)
for t = 1:size(connectivity_matrix, 3)
    for network_i = 1:num_networks
        nodes_in_network_i = find(node_labels == network_i);
        
        % Extract the submatrix for nodes in network_i
        submatrix_within = connectivity_matrix(nodes_in_network_i, nodes_in_network_i, t);
        
        % Store the submatrix of within-network connections in the cell array
        within_network_submatrices{network_i} = cat(3, within_network_submatrices{network_i}, submatrix_within);
        
        for network_j = 1:num_networks
            if network_i == network_j
                % If the indices are the same, store the within-network submatrix
                combined_metrics_cell{network_i, network_j} = cat(3, combined_metrics_cell{network_i, network_j}, submatrix_within);
            else
                nodes_in_network_j = find(node_labels == network_j);
                
                % Extract the submatrix for nodes in network_i and network_j
                submatrix_between = connectivity_matrix(nodes_in_network_i, nodes_in_network_j, t);
                
                % Store the between-network metric in the cell array
                between_network_metrics{network_i, network_j, t} = submatrix_between;
                
                % Optionally, you can also store it in the combined_metrics_cell
                combined_metrics_cell{network_i, network_j} = cat(3, combined_metrics_cell{network_i, network_j}, submatrix_between);
            end
        end
    end
end

% Display the 7x7 cell array of metrics (each cell contains a submatrix or between-network metric)
disp('Combined Metrics Cell Array:');
disp(combined_metrics_cell);

% Save the data including within-network submatrices and between-network metrics
save('EC_networks.mat', 'combined_metrics_cell', 'node_labels', 'within_network_submatrices', 'between_network_metrics');
