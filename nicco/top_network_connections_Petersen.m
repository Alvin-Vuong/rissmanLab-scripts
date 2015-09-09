%==========================================================================================
% top_network_connections_Petersen.m
% 
% This script takes in a Petersen network name, and finds the top x% of connections 
% (pairs of ROIs) ranked by their average mean_non_zero connectivity values.
%
% Currently the script only performs this ranking with structural data.
%
% Averaged structural data is located at:
% ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Average_Values/Subj_{SubjectID}_avg.mat
%
% Functional data is located at:
% ~/Nicco/HCP_ALL/Resting_State/Petersen_FC/{SubjectID}_Petersen_FC_Matrices.mat
%
% For the network indices, we use:
% ~/Nicco/NIQ/Network_Indices/Petersen_Networks.mat
%==========================================================================================

% Some variables
top_percent = .5; % Enter in decimal format

% Set paths
structural_path = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Average_Values/';
functional_path = '/space/raid6/data/rissman/Nicco/HCP_ALL/Resting_State/Petersen_FC/';
network_indices_path = '/space/raid6/data/rissman/Nicco/NIQ/Network_Indices/';
save_dir = '/space/raid6/data/rissman/Nicco/NIQ/Top_Connections/';

% Get network indices
load([network_indices_path 'Petersen_Networks.mat']);

% Retrieve subjects using structural path
% TODO: Retrieve only subjects with both structural and functional data
cd(structural_path);
subjs = dir();
regex = regexp({subjs.name},'Subj_*');
subjs = {subjs(~cellfun('isempty',regex)).name}.';

% Loop over subjects
for s = 1:2 %length(subjs)
    % Grab info for subject
    file_str = char(subjs(s));
    subjectID = file_str(6:end-8);
    
    % Get subject's data
    load([structural_path 'Subj_' subjectID '_avg.mat']);
    load([functional_path subjectID '_Petersen_FC_Matrices.mat']);
    
    % Initialize struct for saved data
    saved = struct;

    % Loop over networks
    networks = fieldnames(Petersen_Networks);
    for net = 1:numel(networks)
        % Retrieve network ROIs
        roiList = Petersen_Networks.(networks{net});

        % Initialize a matrix to hold pairwise connectivity values
        sizeROI = length(roiList);
        connectivities = zeros((sizeROI*(sizeROI-1)/2), 5);

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

        % Take top percent of connections
        top_amount = top_percent*size(connectivities,1);
        mean_sorted = sortrows(connectivities, -3);
        volume_sorted = sortrows(connectivities, -4);
        voxels_sorted = sortrows(connectivities, -5);

        % Save results
        mean_saved = mean_sorted(1:ceil(top_amount), :);
        volume_saved = volume_sorted(1:ceil(top_amount), :);
        voxels_saved = voxels_sorted(1:ceil(top_amount), :);

        % Store into struct
        saved.(char(networks{net})).mean = mean_saved;
        saved.(char(networks{net})).volume = volume_saved;
        saved.(char(networks{net})).voxels = voxels_saved;
    end

    % Save work
    fprintf('Saving subject: %s\n', subjectID);
    save([save_dir 'Subj_' subjectID '_top_connect.mat'],'saved');
end
