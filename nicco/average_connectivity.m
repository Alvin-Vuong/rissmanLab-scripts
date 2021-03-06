%========================================================================================
% average_connectivity.m
% 
% This script takes the connectivity matrices resulting from 
% Create_Compiled_Values_Petersen.m (or Gordon) located at:
% 
% ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/{SubjectID}.mat
% ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Gordon/{SubjectID}.mat
% 
% and finds the average connectivity value between each node-pair (1-2, 2-1) for
% each matrix type.  Then it stores these values into new matrices called:
%   mean_non_zero_avg
%   volume_non_zero_avg
% 
% into a new file loacted at:
% 
% ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Average_Values/{SubjectID}_avg.mat
% ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Average_Values/Gordon/{SubjectID}_avg.mat
%
% Rows & columns of these matrices represent each ROI node in the Petersen/Gordon parcellation
%
% For example, row 1 column 3 will contain the average connectivity value between
%   Petersen node 1 to Petersen node 3.  For simplicity, row 3 column 1 will contain
%   this same value.
%
% Average connectivity values are computed by adding each directional connectivity value
% and dividing by 2.
%
% For example, if row 1 column 3 (in original matrix) has the value 1000, and
%   row 3 column 1 has the value 500...  Then the calculated value placed in the new
%   {SubjectID}_avg.mat file at row 1 column 3 and at row 3 column 1 will be 750.
%========================================================================================

% Initialize paths
% Petersen
%save_dir = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Average_Values/';
%top_dir = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/';
% Gordon
save_dir = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Gordon/Average_Values/';
top_dir = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Gordon/';

% Go to top directory
cd(top_dir);

% Grab connectivity .mat files
subjs = dir();
regex = regexp({subjs.name},'Subj_*');
subjs = {subjs(~cellfun('isempty',regex)).name}.';

% Iterate through subjects
for s = 1:length(subjs)
    % Grab info for subject
    file_str = char(subjs(s));
    subject_str = file_str(6:end-4);
    fprintf('Averaging Subject %s\n', subject_str);
    
    % Check if subject is finished already
    cd(save_dir);
    if length(dir(fullfile('.', ['Subj_' subject_str '_avg.mat']))) == 1
        fprintf('%s already exists...\n', file_str);
        continue;
    end
    
    % Ensure path is correct
    cd(top_dir);
    
    % Load in subject connectivity matrices
    try
        load(file_str);
        fprintf('Loading in %s\n', file_str);
    catch
        %fprintf('Subject not found\n');
    end

    % Calculate averages
    mean_non_zero_avg = (mean_non_zero + mean_non_zero.') ./ 2;
    %voxels_non_zero_avg = (voxels_non_zero + voxels_non_zero.') ./ 2;
    volume_non_zero_avg = (volume_non_zero + volume_non_zero.') ./ 2;
    
    %count_non_zero_avg = (count_non_zero + count_non_zero.') ./ 2;
    %mean_non_zero_div_waytotal_avg = (mean_non_zero_div_waytotal + mean_non_zero_div_waytotal.') ./ 2;
    %count_non_zero_div_waytotal_avg = (count_non_zero_div_waytotal + count_non_zero_div_waytotal.') ./ 2;

    % Save work
    fprintf('Saving averaged values for subject: %s\n', subject_str);
    save([save_dir 'Subj_' subject_str '_avg.mat'],'mean_non_zero_avg','volume_non_zero_avg');
    %save([save_dir 'Subj_' subject_str '_avg.mat'],'mean_non_zero_avg','voxels_non_zero_avg','volume_non_zero_avg');
    %save([save_dir 'Subj_' subject_str '_avg.mat'],'mean_non_zero_avg','count_non_zero_avg','mean_non_zero_div_waytotal_avg','count_non_zero_div_waytotal_avg');
end

