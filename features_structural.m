%==========================================================================================
% features_structural.m
%
% Take in network name(s), and a subject.
%
% Creates a feature set containing structural connectivity values (along with their
% corresponding ROI pairs) in descending order for each network or network pair.
%
%
% This script takes in a subject's structural data and finds the top x% of connections 
% (pairs of ROIs) ranked by their average connectivity values.
%
% Averaged structural data is located at:
% ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Average_Values/Subj_{SubjectID}_avg.mat
%
% For non-averaged structural data, we use data located at:
% ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Subj_{SubjectID}.mat
%
% For the network indices, we use:
% ~/Nicco/NIQ/Network_Indices/Petersen_Networks.mat
%==========================================================================================

% Some variables
top_percent = .5; % Enter in decimal format

% Set paths
structural_avg_path = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Average_Values/';
structural_path = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/';
network_indices_path = '/space/raid6/data/rissman/Nicco/NIQ/Network_Indices/';

% Get network indices
load([network_indices_path 'Petersen_Networks.mat']);

% Retrieve subjects using structural path
cd(structural_path);
subjs = dir();
regex = regexp({subjs.name},'Subj_*');
subjs = {subjs(~cellfun('isempty',regex)).name}.';

% Loop over subjects
for s = 1 %length(subjs)
    % Grab info for subject
    file_str = char(subjs(s));
    subjectID = file_str(6:end-8);
    
    % Get subject's data
    load([structural_path 'Subj_' subjectID '_avg.mat']);
    
    % Initialize struct for saved data
    saved = struct;

    % Loop over networks
    networks = fieldnames(Petersen_Networks);
    for net = 1:numel(networks)
        % Retrieve network ROIs
        roiList = Petersen_Networks.(networks{net});

        % Initialize a matrix to hold pairwise connectivity values
        sizeROI = length(roiList);
        num_connections = sizeROI*(sizeROI-1)/2; % Number of pairs of ROIs
        connectivities = zeros(num_connections, 5);

        % Find connectivity values for each pair in ROI list
        n = 1;
        for i = 1:(length(roiList)-1)
            for j = (i+1):length(roiList)
                connectivities(n, 1) = roiList(i);
                connectivities(n, 2) = roiList(j);
                connectivities(n, 3) = mean_non_zero_avg(roiList(i), roiList(j));
                connectivities(n, 4) = volume_non_zero_avg(roiList(i), roiList(j));
                connectivities(n, 5) = voxels_non_zero_avg(roiList(i), roiList(j));
                n = n + 1;
            end
        end

        % Calculate top percent of connections
        top_amount = top_percent*size(connectivities,1);
        
        % Sort by descending order
        mean_sorted = sortrows(connectivities, -3);
        volume_sorted = sortrows(connectivities, -4);
        voxels_sorted = sortrows(connectivities, -5);

        % Save top % results (include midpoint if odd # of connections)
        mean_top_saved = mean_sorted(1:ceil(top_amount), :);
        volume_top_saved = volume_sorted(1:ceil(top_amount), :);
        voxels_top_saved = voxels_sorted(1:ceil(top_amount), :);
        
        % Save bottom % results (include midpoint if odd # of connections)
        mean_bottom_saved = mean_sorted(ceil(top_amount):num_connections, :);
        volume_bottom_saved = volume_sorted(ceil(top_amount):num_connections, :);
        voxels_bottom_saved = voxels_sorted(ceil(top_amount):num_connections, :);

        % Store into struct
        saved.(char(networks{net})).mean_top = mean_top_saved;
        saved.(char(networks{net})).volume_top = volume_top_saved;
        saved.(char(networks{net})).voxels_top = voxels_top_saved;
        saved.(char(networks{net})).mean_bottom = mean_bottom_saved;
        saved.(char(networks{net})).volume_bottom = volume_bottom_saved;
        saved.(char(networks{net})).voxels_bottom = voxels_bottom_saved;
        
    end

    % Save work
    fprintf('Saving subject: %s\n', subjectID);
    save([save_dir 'Subj_' subjectID '_top_connect.mat'],'saved');
end
