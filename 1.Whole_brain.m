% Open the file
fileID = fopen('subject.txt', 'r');

% Read the file line by line into a cell array
list = textscan(fileID, '%s');

% Close the file
fclose(fileID);

% Convert to a string array (optional, depending on your preference)
list = string(list{1});

% Initialize counter
m = 1;

% Loop through each subject in the list
for subj = sort(list)'
    
    % Construct the path to the subject's DCM file
    dcm = string(strcat('C:\Users\Administrator\Desktop\CTQ_Validation\rDCM\', subj,'rDCM_XEON.mat'));
    
    % Load the DCM file
    load(dcm);
    
    % Extract the effective connectivity matrix and remove diagonal elements
    EC(:,:,m) = rDCM.Ep.A - diag(diag(rDCM.Ep.A));
    
    % Clear all variables except EC, subj, list, and m
    clearvars -except EC subj list m;
    
    % Increment counter
    m = m + 1;

end

% Save the entire EC matrix to a .mat file
save('EC_Whole_brain_XEON.mat', 'EC');