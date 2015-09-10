%==========================================================================================
% features_structural_mask_of_functional_Petersen.m
% 
% This script takes in the top x% of connections (pairs of ROIs) ranked by their
% average mean_non_zero connectivity values and populates a feature vector of 
% functional connectivity values corresponding to the pairs of ROIs.
%
% The ranked lists are stored at:
% ~/Nicco/NIQ/Top_Connections/Subj_{SubjectID}_top_connect.mat
%
% Functional data is located at:
% ~/Nicco/HCP_ALL/Resting_State/Petersen_FC/{SubjectID}_Petersen_FC_Matrices.mat
%==========================================================================================

% Set paths
functional_path = '/space/raid6/data/rissman/Nicco/HCP_ALL/Resting_State/Petersen_FC/';
ranked_path = '/space/raid6/data/rissman/Nicco/NIQ/Top_Connections/';
save_dir = '/space/raid6/data/rissman/Nicco/NIQ/Structural_Mask_of_Functional/';

% Retrieve subjects via ranked lists path
cd(ranked_path);
subjs = dir();
regex = regexp({subjs.name},'Subj_*');
subjs = {subjs(~cellfun('isempty',regex)).name}.';

% Loop over subjects
for s = 1:length(subjs)
    % Grab info for subject
    file_str = char(subjs(s));
    subjectID = file_str(6:end-16);
    
    % Get subject's data (Skip subject if functional data is missing)
    load([ranked_path file_str]);
    try
        load([functional_path subjectID '_Petersen_FC_Matrices.mat']);
    catch
        fprintf('Subject %s is missing functional data. Skipping.\n', subjectID);
        continue;
    end
    
    % Initialize struct for saved data
    features = struct;

    % Loop over networks
    networks = fieldnames(saved);
    for net = 1:numel(networks)
        
        % Initialize a vector to hold functional connectivity values
        num_connections_top = size(saved.(char(networks{net})).mean_top, 1);
        num_connections_bottom = size(saved.(char(networks{net})).mean_bottom, 1);
        func_vals_top_mean = zeros(num_connections_top, 1);
        func_vals_bottom_mean = zeros(num_connections_bottom, 1);

        % Find functional connectivity values for each pair in lists
        for i = 1:num_connections_top
            x = saved.(char(networks{net})).mean_top(i, 1);
            y = saved.(char(networks{net})).mean_top(i, 2);
            func_vals_top_mean(i) = FC_Matrix(x,y);
        end
        for j = 1:num_connections_bottom
            x = saved.(char(networks{net})).mean_bottom(j, 1);
            y = saved.(char(networks{net})).mean_bottom(j, 2);
            func_vals_bottom_mean(j) = FC_Matrix(x,y);
        end

        % Store into struct
        features.(char(networks{net})).func_vals_top_mean = func_vals_top_mean;
        features.(char(networks{net})).func_vals_bottom_mean = func_vals_bottom_mean;
    end

    % Save work
    fprintf('Saving subject: %s\n', subjectID);
    save([save_dir 'Subj_' subjectID '_features_SMoF.mat'],'features');
end
