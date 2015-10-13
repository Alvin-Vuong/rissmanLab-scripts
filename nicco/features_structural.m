function feature_set = features_structural(type, net1, net2)
% 
%==========================================================================================
% features_structural.m
%
% Take in network name(s), and a type of relation (specified in "Connectivities Naming.xlsx").
%
% Creates a feature set containing structural connectivity values (along with their
% corresponding ROI pairs) in descending order for each network or network pair.
%
% Resulting struct has 3 matrices: mean, volume, voxels (sorted accordingly).
% Each matrix is formatted as follows:
% Column 1: ROI #1
% Column 2: ROI #2
% Column 3: Mean connectivity value associated with ROI #1 and ROI #2
% Column 4: Volume connectivity value associated with ROI #1 and ROI #2
% Column 5: Voxels connectivity value associated with ROI #1 and ROI #2
% Column 6: ROI #1's network code (1 for net1, 2 for net2)
% Column 7: ROI #2's network code (^)
%
% Type of feature set must be specified.
% Allowed types are: 
%   wX, amXY_wX_wY, amXY_wX, amXY_wY, amXY, aoXY_wX_wY, ao_XY_wX, ao_XY_wY, aoXY.
% Explained below:
% - Intranetwork Connectivities (w/in each individual network X)
%   Possible Sets:                                      Naming Convention:
%   - w/in X                                            wX
% - Internetwork Connectivities (2 networks: X and Y)
%   Possible Sets:                                      Naming Convention:
%   - across mutual XY, w/in X, w/in Y                  amXY_wX_wY
%   - across mutual XY, w/in X                          amXY_wX
%   - across mutual XY, w/in Y                          amXY_wY
%   - across mutual XY                                  amXY
%   - across one-way XY, w/in X, w/in Y                 aoXY_wX_wY
%   - across one-way XY, w/in X                         aoXY_wX
%   - across one-way XY, w/in Y                         aoXY_wY
%   - across one-way XY                                 aoXY
%
% "Across mutual" describes the mutual averaged connections between ROIs in separate networks.
%   Uses mean connectivity values for this.
% "Across one-way" describes the specific one-directional connection from an ROI in one network to another.
%   Uses the values in "Compiled_Values" for this.
%
% Note: All intranetwork connectivities are averaged.
% 
% If only one network is specified, type must be wX. Function will return
% an empty struct otherwise.
% 
% If a network and its subset are given as arguments, function will return
% an empty struct. (Example: Default_Mode_L & Default_Mode)
%
% Averaged structural data is located at:
% ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Average_Values/Subj_{SubjectID}_avg.mat
%
% For non-averaged structural data, we use data located at:
% ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Subj_{SubjectID}.mat
%
% For the network indices, we use:
% ~/Nicco/NIQ/Network_Indices/Petersen_Networks.mat
%
%==========================================================================================

% Set paths
structural_avg_path = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Average_Values/';
structural_path = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/';
network_indices_path = '/space/raid6/data/rissman/Nicco/NIQ/Network_Indices/';

% Get network info
load([network_indices_path 'Petersen_Networks.mat']);
networks = fieldnames(Petersen_Networks);

% Retrieve subjects using structural path
cd(structural_path);
subjs = dir();
regex = regexp({subjs.name},'Subj_*');
subjs = {subjs(~cellfun('isempty',regex)).name}.';

% Only do one subject for now. TODO: Ask how to store multiple subjects' data
s = 1; %for s = 1:length(subjs)

% Grab info for subject
file_str = char(subjs(s));
subjectID = file_str(6:end-4);
    
% Get subject's data
load([structural_avg_path 'Subj_' subjectID '_avg.mat']);
load([structural_path 'Subj_' subjectID '.mat']);

switch nargin
    case 3
        % Internetwork Connectivities (two networks specified)
        if (strcmp(type, 'amXY_wX_wY'))
            % Type: Across Mutual XY, w/in X, w/in Y
            
            % Find networks specified
            found1 = 0;
            found2 = 0;
            for net = 1:numel(networks)
                if (strcmp(networks{net}, net1))
                    % Found network
                    found1 = 1;
                elseif (strcmp(networks{net}, net2))
                    % Found network
                    found2 = 1;
                end
            end
            if (found1 == 0 || found2 == 0)
                % Invalid network name
                fprintf('Invalid network name.\n');
                feature_set = struct;
                return
            end
            
            % Network is a subset of the other
            if (strcmp(net1(1:end-2), net2) || strcmp(net2(1:end-2), net1))
                fprintf('No network subsets allowed.\n');
                feature_set = struct;
                return
            end
            
            % Retrieve networks' ROIs
            roiList1 = Petersen_Networks.(net1);
            roiList2 = Petersen_Networks.(net2);
            
            % Initialize a matrix to hold pairwise connectivity values
            sizeROI1 = length(roiList1);
            sizeROI2 = length(roiList2);
            num_connections = (sizeROI1 * sizeROI2) + (sizeROI1*(sizeROI1-1)/2) + (sizeROI2*(sizeROI2-1)/2);
            connectivities = zeros(num_connections, 7);
            
            % Find connectivity values for each pair...
            % ...Across networks
            n = 1;
            for i = 1:length(roiList1)
                for j = 1:length(roiList2)
                    connectivities(n, 1) = roiList1(i);
                    connectivities(n, 2) = roiList2(j);
                    connectivities(n, 3) = mean_non_zero_avg(roiList1(i), roiList2(j));
                    connectivities(n, 4) = volume_non_zero_avg(roiList1(i), roiList2(j));
                    connectivities(n, 5) = voxels_non_zero_avg(roiList1(i), roiList2(j));
                    connectivities(n, 6) = 1;
                    connectivities(n, 7) = 2;
                    n = n + 1;
                end
            end
            
            % ...Within net1
            for i = 1:(length(roiList1)-1)
                for j = (i+1):length(roiList1)
                    connectivities(n, 1) = roiList1(i);
                    connectivities(n, 2) = roiList1(j);
                    connectivities(n, 3) = mean_non_zero_avg(roiList1(i), roiList1(j));
                    connectivities(n, 4) = volume_non_zero_avg(roiList1(i), roiList1(j));
                    connectivities(n, 5) = voxels_non_zero_avg(roiList1(i), roiList1(j));
                    connectivities(n, 6) = 1;
                    connectivities(n, 7) = 1;
                    n = n + 1;
                end
            end
            
            % ...Within net2
            for i = 1:(length(roiList2)-1)
                for j = (i+1):length(roiList2)
                    connectivities(n, 1) = roiList2(i);
                    connectivities(n, 2) = roiList2(j);
                    connectivities(n, 3) = mean_non_zero_avg(roiList2(i), roiList2(j));
                    connectivities(n, 4) = volume_non_zero_avg(roiList2(i), roiList2(j));
                    connectivities(n, 5) = voxels_non_zero_avg(roiList2(i), roiList2(j));
                    connectivities(n, 6) = 2;
                    connectivities(n, 7) = 2;
                    n = n + 1;
                end
            end
            
            % Sort by descending order and set return value
            feature_set.mean = sortrows(connectivities, -3);
            feature_set.volume = sortrows(connectivities, -4);
            feature_set.voxels = sortrows(connectivities, -5);
            
        elseif (strcmp(type, 'amXY_wX'))
            % Type: Across Mutual XY, w/in X
            
            % Find networks specified
            found1 = 0;
            found2 = 0;
            for net = 1:numel(networks)
                if (strcmp(networks{net}, net1))
                    % Found network
                    found1 = 1;
                elseif (strcmp(networks{net}, net2))
                    % Found network
                    found2 = 1;
                end
            end
            if (found1 == 0 || found2 == 0)
                % Invalid network name
                fprintf('Invalid network name.\n');
                feature_set = struct;
                return
            end
            
            % Network is a subset of the other
            if (strcmp(net1(1:end-2), net2) || strcmp(net2(1:end-2), net1))
                fprintf('No network subsets allowed.\n');
                feature_set = struct;
                return
            end
            
            % Retrieve networks' ROIs
            roiList1 = Petersen_Networks.(net1);
            roiList2 = Petersen_Networks.(net2);
            
            % Initialize a matrix to hold pairwise connectivity values
            sizeROI1 = length(roiList1);
            sizeROI2 = length(roiList2);
            num_connections = (sizeROI1 * sizeROI2) + (sizeROI1*(sizeROI1-1)/2);
            connectivities = zeros(num_connections, 7);
            
            % Find connectivity values for each pair...
            % ...Across networks
            n = 1;
            for i = 1:length(roiList1)
                for j = 1:length(roiList2)
                    connectivities(n, 1) = roiList1(i);
                    connectivities(n, 2) = roiList2(j);
                    connectivities(n, 3) = mean_non_zero_avg(roiList1(i), roiList2(j));
                    connectivities(n, 4) = volume_non_zero_avg(roiList1(i), roiList2(j));
                    connectivities(n, 5) = voxels_non_zero_avg(roiList1(i), roiList2(j));
                    connectivities(n, 6) = 1;
                    connectivities(n, 7) = 2;
                    n = n + 1;
                end
            end
            
            % ...Within net1
            for i = 1:(length(roiList1)-1)
                for j = (i+1):length(roiList1)
                    connectivities(n, 1) = roiList1(i);
                    connectivities(n, 2) = roiList1(j);
                    connectivities(n, 3) = mean_non_zero_avg(roiList1(i), roiList1(j));
                    connectivities(n, 4) = volume_non_zero_avg(roiList1(i), roiList1(j));
                    connectivities(n, 5) = voxels_non_zero_avg(roiList1(i), roiList1(j));
                    connectivities(n, 6) = 1;
                    connectivities(n, 7) = 1;
                    n = n + 1;
                end
            end
            
            % Sort by descending order and set return value
            feature_set.mean = sortrows(connectivities, -3);
            feature_set.volume = sortrows(connectivities, -4);
            feature_set.voxels = sortrows(connectivities, -5);
            
        elseif (strcmp(type, 'amXY_wY'))
            % Type: Across Mutual XY, w/in Y
            
            % Find networks specified
            found1 = 0;
            found2 = 0;
            for net = 1:numel(networks)
                if (strcmp(networks{net}, net1))
                    % Found network
                    found1 = 1;
                elseif (strcmp(networks{net}, net2))
                    % Found network
                    found2 = 1;
                end
            end
            if (found1 == 0 || found2 == 0)
                % Invalid network name
                fprintf('Invalid network name.\n');
                feature_set = struct;
                return
            end
            
            % Network is a subset of the other
            if (strcmp(net1(1:end-2), net2) || strcmp(net2(1:end-2), net1))
                fprintf('No network subsets allowed.\n');
                feature_set = struct;
                return
            end
            
            % Retrieve networks' ROIs
            roiList1 = Petersen_Networks.(net1);
            roiList2 = Petersen_Networks.(net2);
            
            % Initialize a matrix to hold pairwise connectivity values
            sizeROI1 = length(roiList1);
            sizeROI2 = length(roiList2);
            num_connections = (sizeROI1 * sizeROI2) + (sizeROI2*(sizeROI2-1)/2);
            connectivities = zeros(num_connections, 7);
            
            % Find connectivity values for each pair...
            % ...Across networks
            n = 1;
            for i = 1:length(roiList1)
                for j = 1:length(roiList2)
                    connectivities(n, 1) = roiList1(i);
                    connectivities(n, 2) = roiList2(j);
                    connectivities(n, 3) = mean_non_zero_avg(roiList1(i), roiList2(j));
                    connectivities(n, 4) = volume_non_zero_avg(roiList1(i), roiList2(j));
                    connectivities(n, 5) = voxels_non_zero_avg(roiList1(i), roiList2(j));
                    connectivities(n, 6) = 1;
                    connectivities(n, 7) = 2;
                    n = n + 1;
                end
            end
            
            % ...Within net2
            for i = 1:(length(roiList2)-1)
                for j = (i+1):length(roiList2)
                    connectivities(n, 1) = roiList2(i);
                    connectivities(n, 2) = roiList2(j);
                    connectivities(n, 3) = mean_non_zero_avg(roiList2(i), roiList2(j));
                    connectivities(n, 4) = volume_non_zero_avg(roiList2(i), roiList2(j));
                    connectivities(n, 5) = voxels_non_zero_avg(roiList2(i), roiList2(j));
                    connectivities(n, 6) = 2;
                    connectivities(n, 7) = 2;
                    n = n + 1;
                end
            end
            
            % Sort by descending order and set return value
            feature_set.mean = sortrows(connectivities, -3);
            feature_set.volume = sortrows(connectivities, -4);
            feature_set.voxels = sortrows(connectivities, -5);
            
        elseif (strcmp(type, 'amXY'))
            % Type: Across Mutual XY
            
            % Find networks specified
            found1 = 0;
            found2 = 0;
            for net = 1:numel(networks)
                if (strcmp(networks{net}, net1))
                    % Found network
                    found1 = 1;
                elseif (strcmp(networks{net}, net2))
                    % Found network
                    found2 = 1;
                end
            end
            if (found1 == 0 || found2 == 0)
                % Invalid network name
                fprintf('Invalid network name.\n');
                feature_set = struct;
                return
            end
            
            % Network is a subset of the other
            if (strcmp(net1(1:end-2), net2) || strcmp(net2(1:end-2), net1))
                fprintf('No network subsets allowed.\n');
                feature_set = struct;
                return
            end
            
            % Retrieve networks' ROIs
            roiList1 = Petersen_Networks.(net1);
            roiList2 = Petersen_Networks.(net2);
            
            % Initialize a matrix to hold pairwise connectivity values
            sizeROI1 = length(roiList1);
            sizeROI2 = length(roiList2);
            num_connections = (sizeROI1 * sizeROI2);
            connectivities = zeros(num_connections, 7);
            
            % Find connectivity values for each pair...
            % ...Across networks
            n = 1;
            for i = 1:length(roiList1)
                for j = 1:length(roiList2)
                    connectivities(n, 1) = roiList1(i);
                    connectivities(n, 2) = roiList2(j);
                    connectivities(n, 3) = mean_non_zero_avg(roiList1(i), roiList2(j));
                    connectivities(n, 4) = volume_non_zero_avg(roiList1(i), roiList2(j));
                    connectivities(n, 5) = voxels_non_zero_avg(roiList1(i), roiList2(j));
                    connectivities(n, 6) = 1;
                    connectivities(n, 7) = 2;
                    n = n + 1;
                end
            end
            
            % Sort by descending order and set return value
            feature_set.mean = sortrows(connectivities, -3);
            feature_set.volume = sortrows(connectivities, -4);
            feature_set.voxels = sortrows(connectivities, -5);
            
        elseif (strcmp(type, 'aoXY_wX_wY'))
            % Type: Across One-Way XY, w/in X, w/in Y
            
            % Find networks specified
            found1 = 0;
            found2 = 0;
            for net = 1:numel(networks)
                if (strcmp(networks{net}, net1))
                    % Found network
                    found1 = 1;
                elseif (strcmp(networks{net}, net2))
                    % Found network
                    found2 = 1;
                end
            end
            if (found1 == 0 || found2 == 0)
                % Invalid network name
                fprintf('Invalid network name.\n');
                feature_set = struct;
                return
            end
            
            % Network is a subset of the other
            if (strcmp(net1(1:end-2), net2) || strcmp(net2(1:end-2), net1))
                fprintf('No network subsets allowed.\n');
                feature_set = struct;
                return
            end
            
            % Retrieve networks' ROIs
            roiList1 = Petersen_Networks.(net1);
            roiList2 = Petersen_Networks.(net2);
            
            % Initialize a matrix to hold pairwise connectivity values
            sizeROI1 = length(roiList1);
            sizeROI2 = length(roiList2);
            num_connections = (sizeROI1 * sizeROI2) + (sizeROI1*(sizeROI1-1)/2) + (sizeROI2*(sizeROI2-1)/2);
            connectivities = zeros(num_connections, 7);
            
            % Find connectivity values for each pair...
            % ...Across networks
            n = 1;
            for i = 1:length(roiList1)
                for j = 1:length(roiList2)
                    connectivities(n, 1) = roiList1(i);
                    connectivities(n, 2) = roiList2(j);
                    connectivities(n, 3) = mean_non_zero(roiList1(i), roiList2(j));
                    connectivities(n, 4) = volume_non_zero(roiList1(i), roiList2(j));
                    connectivities(n, 5) = voxels_non_zero(roiList1(i), roiList2(j));
                    connectivities(n, 6) = 1;
                    connectivities(n, 7) = 2;
                    n = n + 1;
                end
            end
            
            % ...Within net1
            for i = 1:(length(roiList1)-1)
                for j = (i+1):length(roiList1)
                    connectivities(n, 1) = roiList1(i);
                    connectivities(n, 2) = roiList1(j);
                    connectivities(n, 3) = mean_non_zero_avg(roiList1(i), roiList1(j));
                    connectivities(n, 4) = volume_non_zero_avg(roiList1(i), roiList1(j));
                    connectivities(n, 5) = voxels_non_zero_avg(roiList1(i), roiList1(j));
                    connectivities(n, 6) = 1;
                    connectivities(n, 7) = 1;
                    n = n + 1;
                end
            end
            
            % ...Within net2
            for i = 1:(length(roiList2)-1)
                for j = (i+1):length(roiList2)
                    connectivities(n, 1) = roiList2(i);
                    connectivities(n, 2) = roiList2(j);
                    connectivities(n, 3) = mean_non_zero_avg(roiList2(i), roiList2(j));
                    connectivities(n, 4) = volume_non_zero_avg(roiList2(i), roiList2(j));
                    connectivities(n, 5) = voxels_non_zero_avg(roiList2(i), roiList2(j));
                    connectivities(n, 6) = 2;
                    connectivities(n, 7) = 2;
                    n = n + 1;
                end
            end
            
            % Sort by descending order and set return value
            feature_set.mean = sortrows(connectivities, -3);
            feature_set.volume = sortrows(connectivities, -4);
            feature_set.voxels = sortrows(connectivities, -5);
            
        elseif (strcmp(type, 'aoXY_wX'))
            % Type: Across One-Way XY, w/in X
            
            % Find networks specified
            found1 = 0;
            found2 = 0;
            for net = 1:numel(networks)
                if (strcmp(networks{net}, net1))
                    % Found network
                    found1 = 1;
                elseif (strcmp(networks{net}, net2))
                    % Found network
                    found2 = 1;
                end
            end
            if (found1 == 0 || found2 == 0)
                % Invalid network name
                fprintf('Invalid network name.\n');
                feature_set = struct;
                return
            end
            
            % Network is a subset of the other
            if (strcmp(net1(1:end-2), net2) || strcmp(net2(1:end-2), net1))
                fprintf('No network subsets allowed.\n');
                feature_set = struct;
                return
            end
            
            % Retrieve networks' ROIs
            roiList1 = Petersen_Networks.(net1);
            roiList2 = Petersen_Networks.(net2);
            
            % Initialize a matrix to hold pairwise connectivity values
            sizeROI1 = length(roiList1);
            sizeROI2 = length(roiList2);
            num_connections = (sizeROI1 * sizeROI2) + (sizeROI1*(sizeROI1-1)/2);
            connectivities = zeros(num_connections, 7);
            
            % Find connectivity values for each pair...
            % ...Across networks
            n = 1;
            for i = 1:length(roiList1)
                for j = 1:length(roiList2)
                    connectivities(n, 1) = roiList1(i);
                    connectivities(n, 2) = roiList2(j);
                    connectivities(n, 3) = mean_non_zero(roiList1(i), roiList2(j));
                    connectivities(n, 4) = volume_non_zero(roiList1(i), roiList2(j));
                    connectivities(n, 5) = voxels_non_zero(roiList1(i), roiList2(j));
                    connectivities(n, 6) = 1;
                    connectivities(n, 7) = 2;
                    n = n + 1;
                end
            end
            
            % ...Within net1
            for i = 1:(length(roiList1)-1)
                for j = (i+1):length(roiList1)
                    connectivities(n, 1) = roiList1(i);
                    connectivities(n, 2) = roiList1(j);
                    connectivities(n, 3) = mean_non_zero_avg(roiList1(i), roiList1(j));
                    connectivities(n, 4) = volume_non_zero_avg(roiList1(i), roiList1(j));
                    connectivities(n, 5) = voxels_non_zero_avg(roiList1(i), roiList1(j));
                    connectivities(n, 6) = 1;
                    connectivities(n, 7) = 1;
                    n = n + 1;
                end
            end
            
            % Sort by descending order and set return value
            feature_set.mean = sortrows(connectivities, -3);
            feature_set.volume = sortrows(connectivities, -4);
            feature_set.voxels = sortrows(connectivities, -5);
            
        elseif (strcmp(type, 'aoXY_wY'))
            % Type: Across One-Way XY, w/in Y
            
            % Find networks specified
            found1 = 0;
            found2 = 0;
            for net = 1:numel(networks)
                if (strcmp(networks{net}, net1))
                    % Found network
                    found1 = 1;
                elseif (strcmp(networks{net}, net2))
                    % Found network
                    found2 = 1;
                end
            end
            if (found1 == 0 || found2 == 0)
                % Invalid network name
                fprintf('Invalid network name.\n');
                feature_set = struct;
                return
            end
            
            % Network is a subset of the other
            if (strcmp(net1(1:end-2), net2) || strcmp(net2(1:end-2), net1))
                fprintf('No network subsets allowed.\n');
                feature_set = struct;
                return
            end
            
            % Retrieve networks' ROIs
            roiList1 = Petersen_Networks.(net1);
            roiList2 = Petersen_Networks.(net2);
            
            % Initialize a matrix to hold pairwise connectivity values
            sizeROI1 = length(roiList1);
            sizeROI2 = length(roiList2);
            num_connections = (sizeROI1 * sizeROI2) + (sizeROI2*(sizeROI2-1)/2);
            connectivities = zeros(num_connections, 7);
            
            % Find connectivity values for each pair...
            % ...Across networks
            n = 1;
            for i = 1:length(roiList1)
                for j = 1:length(roiList2)
                    connectivities(n, 1) = roiList1(i);
                    connectivities(n, 2) = roiList2(j);
                    connectivities(n, 3) = mean_non_zero(roiList1(i), roiList2(j));
                    connectivities(n, 4) = volume_non_zero(roiList1(i), roiList2(j));
                    connectivities(n, 5) = voxels_non_zero(roiList1(i), roiList2(j));
                    connectivities(n, 6) = 1;
                    connectivities(n, 7) = 2;
                    n = n + 1;
                end
            end
            
            % ...Within net2
            for i = 1:(length(roiList2)-1)
                for j = (i+1):length(roiList2)
                    connectivities(n, 1) = roiList2(i);
                    connectivities(n, 2) = roiList2(j);
                    connectivities(n, 3) = mean_non_zero_avg(roiList2(i), roiList2(j));
                    connectivities(n, 4) = volume_non_zero_avg(roiList2(i), roiList2(j));
                    connectivities(n, 5) = voxels_non_zero_avg(roiList2(i), roiList2(j));
                    connectivities(n, 6) = 2;
                    connectivities(n, 7) = 2;
                    n = n + 1;
                end
            end
            
            % Sort by descending order and set return value
            feature_set.mean = sortrows(connectivities, -3);
            feature_set.volume = sortrows(connectivities, -4);
            feature_set.voxels = sortrows(connectivities, -5);
            
        elseif (strcmp(type, 'aoXY'))
            % Type: Across One-Way
            
            % Find networks specified
            found1 = 0;
            found2 = 0;
            for net = 1:numel(networks)
                if (strcmp(networks{net}, net1))
                    % Found network
                    found1 = 1;
                elseif (strcmp(networks{net}, net2))
                    % Found network
                    found2 = 1;
                end
            end
            if (found1 == 0 || found2 == 0)
                % Invalid network name
                fprintf('Invalid network name.\n');
                feature_set = struct;
                return
            end
            
            % Network is a subset of the other
            if (strcmp(net1(1:end-2), net2) || strcmp(net2(1:end-2), net1))
                fprintf('No network subsets allowed.\n');
                feature_set = struct;
                return
            end
            
            % Retrieve networks' ROIs
            roiList1 = Petersen_Networks.(net1);
            roiList2 = Petersen_Networks.(net2);
            
            % Initialize a matrix to hold pairwise connectivity values
            sizeROI1 = length(roiList1);
            sizeROI2 = length(roiList2);
            num_connections = (sizeROI1 * sizeROI2);
            connectivities = zeros(num_connections, 7);
            
            % Find connectivity values for each pair...
            % ...Across networks
            n = 1;
            for i = 1:length(roiList1)
                for j = 1:length(roiList2)
                    connectivities(n, 1) = roiList1(i);
                    connectivities(n, 2) = roiList2(j);
                    connectivities(n, 3) = mean_non_zero(roiList1(i), roiList2(j));
                    connectivities(n, 4) = volume_non_zero(roiList1(i), roiList2(j));
                    connectivities(n, 5) = voxels_non_zero(roiList1(i), roiList2(j));
                    connectivities(n, 6) = 1;
                    connectivities(n, 7) = 2;
                    n = n + 1;
                end
            end
            
            % Sort by descending order and set return value
            feature_set.mean = sortrows(connectivities, -3);
            feature_set.volume = sortrows(connectivities, -4);
            feature_set.voxels = sortrows(connectivities, -5);
            
        else
            % Type is invalid
            fprintf('Invalid type.\n');
            feature_set = struct;
        end
        
    case 2
        % Intranetwork Connectivities (only one network specified)
        if (strcmp(type, 'wX'))
            % Type: w/in X
            
            % Find network specified
            found = 0;
            for net = 1:numel(networks)
                if (strcmp(networks{net}, net1))
                    % Found network
                    found = 1;
                    break;
                end
            end
            if (found == 0)
                % Invalid network name
                fprintf('Invalid network name.\n');
                feature_set = struct;
                return
            end
            
            % Retrieve network ROIs
            roiList = Petersen_Networks.(net1);
            
            % Initialize a matrix to hold pairwise connectivity values
            sizeROI = length(roiList);
            num_connections = sizeROI*(sizeROI-1)/2; % Number of pairs of ROIs
            connectivities = zeros(num_connections, 7);

            % Find connectivity values for each pair in ROI list
            n = 1;
            for i = 1:(length(roiList)-1)
                for j = (i+1):length(roiList)
                    connectivities(n, 1) = roiList(i);
                    connectivities(n, 2) = roiList(j);
                    connectivities(n, 3) = mean_non_zero_avg(roiList(i), roiList(j));
                    connectivities(n, 4) = volume_non_zero_avg(roiList(i), roiList(j));
                    connectivities(n, 5) = voxels_non_zero_avg(roiList(i), roiList(j));
                    connectivities(n, 6) = 1;
                    connectivities(n, 7) = 1;
                    n = n + 1;
                end
            end
            
            % Sort by descending order and set return value
            feature_set.mean = sortrows(connectivities, -3);
            feature_set.volume = sortrows(connectivities, -4);
            feature_set.voxels = sortrows(connectivities, -5);
            
        else
            % Type is invalid
            fprintf('Invalid type.\n');
            feature_set = struct;
        end
        
    otherwise
        % Invalid # of arguments
        fprintf('Invalid # of arguments.\n');
        feature_set = struct;
end

end

