%==========================================================================================
% Create_Petersen_Networks_Struct.m
% 
% This script extracts the Petersen parcellations and the ROI indices of each network.
%
% Note: .xls file had to be cleaned in the following way:
%   Some network names were altered so that they could comply with field name restrictions.
%
% The script stores the data into a struct for later analysis. This file will be stored as:
% 
% ~/Nicco/NIQ/Network_Indices/Petersen_Networks.mat
% 
% The struct is structured as follows:
% 
% Petersen_Networks -> Network Name = Array of parcel IDs (indices) in network
%                           |                          |
%                           v                          v
%                     (i.e. Visual)      (i.e. [5, 9, 16, 17 ,18, ...])
%
% Note: A lot of the matrix accesses use hard-coded row-by-column values.
%       This can be improved.
%
% This code is based on 'Create_Petersen_Networks_Struct.m' located at:
% 
% ~/Nicco/NIQ/Scripts/
%
% except that this uses a positive/negative integer comparison to determine whether or not a
% parcel belongs to the left or right hemisphere.
%
%==========================================================================================

% Initialize paths
ref_dir = '/space/raid6/data/rissman/Nicco/NIQ/Network_Indices/';

% Move to reference directory
cd(ref_dir);

% Load in Petersen parcellation .xls file data
[~,~,raw] = xlsread('parcellation_petersen.xlsx');

% Grab networks and X values
networks = raw(3:266,37);
hemis = raw(3:266,7);

% Convert labels to a usable field format
% WARNING: These types of conversions may cause loss of data.
%          Don't use on actual data.
for idx = 1:numel(networks)
   if isnumeric(networks{idx})
      if ~isnan(networks{idx})
        networks{idx} = num2str(networks{idx});
      end
   end
end
hemis = cell2mat(hemis);

% Initialize struct and done array
Petersen_Networks = struct;
done = [];

% Split hemispheres (Negative is left brain, Positive is right brain)
% Note: Zero values are a part of both sides
hemis_L = find(hemis <= 0);
hemis_R = find(hemis >= 0);

% Iterate through networks
for i = 1:264
    % Check if network has already been done
    if i > 1
        if any(ismember({char(networks(i))}, done))
            continue;
        end
    end
    % Add network to done array
    done = [done {char(networks(i))}];
    
    % Find all indices of matches of current network
    net_matches = strfind(networks, char(networks(i)));
    net_matches = find(~cellfun(@isempty,net_matches));
    
    % Separate into left and right hemispheres
    net_matches_L = intersect(net_matches,hemis_L);
    net_matches_R = intersect(net_matches,hemis_R);
    
    % Store network indices into struct
    Petersen_Networks.([char(networks(i)) '_L']) = net_matches_L;
    Petersen_Networks.([char(networks(i)) '_R']) = net_matches_R;
    Petersen_Networks.(char(networks(i))) = net_matches;
end

% Save as file
save([ref_dir 'Petersen_Networks.mat'],'Petersen_Networks');
