%==========================================================================================
% Create_Behavioral_Struct.m
% 
% This script extracts the behavioral data from the provided Human Connectome Project (HCP)
% Excel files, and stores it into a struct for later analysis. This file will be stored
% at and as:
% 
% ~/Nicco/NIQ/Behavioral/all_behave.mat
% 
% The struct is structured as follows:
% 
% all_behave -> Subject ID # -> Behavioral measure of Interest
%                    |                        |
%                    v                        v
%              500+ subjects    (i.e. Fluid intelligence score)
%                                      PMAT_CR, PMAT_RT
%
%==========================================================================================

% Initialize paths
ref_dir = '/space/raid6/data/rissman/Nicco/NIQ/Behavioral/';

% Move to reference directory
cd(ref_dir);

% Grab all Excel data spreadsheets
files = dir();
regex = regexp({files.name},'*.xls');
files = {files(~cellfun('isempty',regex)).name}.';

% Initialize struct and fields


% Iterate through files
for f = 1:length(files)
    % Extract data and store in a matrix
    % Store matrix in appropriate place in struct
