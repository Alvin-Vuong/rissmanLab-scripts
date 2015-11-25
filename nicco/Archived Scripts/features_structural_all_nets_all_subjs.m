% Finds feature sets for all networks for all subjects.
% Mostly to see which subjects have NaNs in them.

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

% Find network specified
found = 0;
results = struct;

list = []; %

for net = 1:numel(networks)
    
    % Retrieve network ROIs
    roiList = Petersen_Networks.(networks{net});

    % Initialize a matrix to hold pairwise connectivity values
    sizeROI = length(roiList);
    num_connections = (sizeROI*(sizeROI-1)/2); % Number of pairs of ROIs
    feature_set = zeros(num_connections, length(subjs));
    
    % For each subject
    for s = 1:length(subjs)

        % Grab info for subject
        file_str = char(subjs(s));
        subjectID = file_str(6:end-4);

        % Get subject's data
        load([structural_avg_path 'Subj_' subjectID '_avg.mat']);
        load([structural_path 'Subj_' subjectID '.mat']);

        % Find connectivity values for each pair...
        % ...Within network
        n = 1;
        connectivities = zeros(num_connections, 1);
        for i = 1:(length(roiList)-1)
            for j = (i+1):length(roiList)
                connectivities(n) = mean_non_zero_avg(roiList(i), roiList(j));
                if (isnan(connectivities(n))) %
                    if (ismember(str2num(subjectID), list))%
                        continue;%
                    end%
                    fprintf('%s has a nan.\n', subjectID);%
                    list = [list str2num(subjectID)];%
                    continue; %
                end%
                n = n + 1;
            end
        end

        % Sort by descending order and set return value
        feature_set(:, s) = sortrows(connectivities, -1);
    end
    
    results.(networks{net}) = feature_set;
end