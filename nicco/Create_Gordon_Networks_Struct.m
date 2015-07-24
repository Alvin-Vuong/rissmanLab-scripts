%==========================================================================================
% Create_Gordon_Networks_Struct.m
% 
% This script extracts the Gordon parcellations and the ROI indices of each network.
%
% Note: .xls file had to be cleaned in the following way:
%   Parcel IDs must begin with a character. See below in code for handling.
%
% The script stores the data into a struct for later analysis. This file will be stored as:
% 
% ~/Nicco/NIQ/Network_Indices/Gordon_Networks.mat
% 
% The struct is structured as follows:
% 
% Gordon_Networks -> Network Name = Array of parcel IDs (indices) in network
%                         |                          |
%                         v                          v
%                   (i.e. Visual)      (i.e. [5, 9, 16, 17 ,18, ...])
%
% Note: A lot of the matrix accesses use hard-coded row-by-column values.
%       This can be improved.
%
%==========================================================================================

% Initialize paths
ref_dir = '/space/raid6/data/rissman/Nicco/NIQ/Network_Indices/';

% Move to reference directory
cd(ref_dir);

% Load in Gordon parcellation .xls file data
[~,~,raw] = xlsread('parcellation_gordon.xlsx');

% Grab networks
networks = raw(2:334,5);
hemis = raw(2:334,2);

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
for idx = 1:numel(hemis)
   if isnumeric(hemis{idx})
      if ~isnan(hemis{idx})
        hemis{idx} = num2str(hemis{idx});
      end
   end
end

% Initialize struct and done array
Gordon_Networks = struct;
done = [];

% Split hemispheres
hemis_L = strfind(hemis, 'L');
hemis_L = find(~cellfun(@isempty,hemis_L));
hemis_R = strfind(hemis, 'R');
hemis_R = find(~cellfun(@isempty,hemis_R));

% Iterate through networks
for i = 1:333
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
    Gordon_Networks.([char(networks(i)) '_L']) = net_matches_L;
    Gordon_Networks.([char(networks(i)) '_R']) = net_matches_R;
end

% Save as file
save([ref_dir 'Gordon_Networks.mat'],'Gordon_Networks');
