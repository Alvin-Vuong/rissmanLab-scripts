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
% Type of feature set must be specified.
% These types are explained in "Connectivities Naming.xlsx".
% Allowed types are: 
%   wX, amXY_wX_wY, amXY_wX, amXY_wY, amXY, aoXY_wX_wY, ao_XY_wX, ao_XY_wY, aoXY.
% 
% If only one network is specified, type must be wX. Function will return
% an empty struct.
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
            
        elseif (strcmp(type, 'amXY_wX'))
            % Type: Across Mutual XY, w/in X
            
        elseif (strcmp(type, 'amXY_wY'))
            % Type: Across Mutual XY, w/in Y
            
        elseif (strcmp(type, 'amXY'))
            % Type: Across Mutual XY
            
        elseif (strcmp(type, 'aoXY_wX_wY'))
            % Type: Across One-Way XY, w/in X, w/in Y
            
        elseif (strcmp(type, 'aoXY_wX'))
            % Type: Across One-Way XY, w/in X
            
        elseif (strcmp(type, 'aoXY_wY'))
            % Type: Across One-Way XY, w/in Y
            
        elseif (strcmp(type, 'aoXY'))
            % Type: Across One-Way
            
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
                check = networks{net};
                if (strcmp(check, net1))
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

