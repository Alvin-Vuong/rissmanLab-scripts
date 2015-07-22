%==========================================================================================
% Create_Behavioral_Struct.m
% 
% This script extracts the behavioral data from the provided Human Connectome Project (HCP)
% .csv file.  The .csv file has been converted to an .xls file for easier use.
% The script stores the data into a struct for later analysis. This file will be stored as:
% 
% ~/Nicco/NIQ/Behavioral/all_behave.mat
% 
% The struct is structured as follows:
% 
% all_behave -> Subject ID # -> Behavioral measure of Interest = Value
%                    |                        |
%                    v                        v
%              500+ subjects    (i.e. Fluid intelligence score)
%                                      PMAT_CR, PMAT_RT
%
% Note: A lot of the matrix accesses use hard-coded row-by-column values.
%       This can be improved.
%
%==========================================================================================

% Initialize paths
ref_dir = '/space/raid6/data/rissman/Nicco/NIQ/Behavioral/';

% Move to reference directory
cd(ref_dir);

% Load in .xls file data
[num,txt,raw] = xlsread('hcp_behavioral.xlsx');

% Grab subjects and behavioral measures of interest
subjects = raw(3:544,1);
behavioral_var = raw(2,2:538);

% Extract data and store into appropriate place in struct
all_behave.{subjects(i)}.{behavioral_var} = raw(,);

% If field is missing, store NaN
if raw(,) == 
    = NaN;
end

% Save as file
save([save_dir 'all_behave.mat'],'all_behave');

