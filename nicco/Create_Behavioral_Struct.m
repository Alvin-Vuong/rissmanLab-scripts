%==========================================================================================
% Create_Behavioral_Struct.m
% 
% This script extracts the behavioral data from the provided Human Connectome Project (HCP)
% .csv file.  The .csv file has been converted to an .xls file for easier use.
%
% Note: .xls file had to be cleaned in the following way:
%   TRUE/FALSE values had to be treated as text instead of generic types in Excel.
%       Done by selecting columns (one-by-one, dumb Excel) and doing:
%       Data -> Text-to-Columns... -> Next -> Next
%       Select 'Text' data format
%       Finish.
%   Some behavioral_var values are invalid field names. These were altered accordingly.
%       RS-fMRI_Count
%       Non-TB_Compl
%       NEO-FFI_Compl
%       ASR-Syn_Compl
%       ASR-DSM_Compl
%       FS_L_Non-WM_Hypointens_Vol
%       FS_R_Non-WM_Hypointens_Vol
%
%   Subject IDs must begin with a character. See below in code for handling.
%
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
[~,~,raw] = xlsread('hcp_behavioral.xlsx');

% Grab subjects and behavioral measures of interest
subjects = raw(3:544,1);
behavioral_var = raw(2,2:538).';

% Convert labels to a usable field format
% WARNING: These types of conversions may cause loss of data.
%          Don't use on actual data.
for idx = 1:numel(subjects)
   if isnumeric(subjects{idx})
      if ~isnan(subjects{idx})
        subjects{idx} = num2str(subjects{idx});
      end
   end
end
for idx = 1:numel(behavioral_var)
   if isnumeric(behavioral_var{idx})
      if ~isnan(behavioral_var{idx})
        behavioral_var{idx} = num2str(behavioral_var{idx});
      end
   end
end

% Extract data and store into appropriate place in struct
% Subject IDs are prepended with 'Subject' for valid field names
for i = 1:542
    for j = 1:537
        % Missing fields are already filled with NaN.
        if isnumeric(raw{i+2,j+1})
            all_behave.(['Subject', char(subjects(i))]).(char(behavioral_var(j))) = raw{i+2,j+1};
        else
            all_behave.(['Subject', char(subjects(i))]).(char(behavioral_var(j))) = char(raw(i+2,j+1));
        end
    end
end

% Save as file
save([ref_dir 'all_behave.mat'],'all_behave');
