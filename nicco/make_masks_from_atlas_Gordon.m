%======================================================================================
% make_masks_from_atlas_Gordon.m
%
% This script creates the masks for each ROI given by the Gordon atlas.
%
% Code is based on 'make_masks_from_atlas.m' located at:
%
% ~/Nicco/MATLAB_PATH/NR_Scripts/General_Use/
%
% See that file for details.
%======================================================================================

% Set paths
atlas_name = '/space/raid6/data/rissman/Nicco/MNI/Parcels_MNI_111.nii';
save_dir = '/space/raid6/data/rissman/Nicco/MNI/Gordon/';

% Load in data from atlas
V = spm_vol(atlas_name);
v_data = spm_read_vols(V);

% Find nonzero unique values (ROIs) in data
array_of_values = unique(v_data);
array_of_values = array_of_values(2:end);

% Construct a mask for every ROI and save it
for a = array_of_values(1):array_of_values(end)
    V.fname=[save_dir 'Gordon_' num2str(a) '.nii'];
    temp = zeros(size(v_data));
    temp(find(v_data == a)) = 1;
    spm_write_vol(V, temp);
end
