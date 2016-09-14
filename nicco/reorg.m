% Compile all subject data into organized location and data structure

% Clear workspace
clear all
clc

% Add script paths
toolboxRoot = '/space/raid6/data/rissman/Nicco/MATLAB_PATH/';
addpath(genpath(toolboxRoot))
toolboxRoot = '/space/raid6/data/rissman/Nicco/NIQ/Scripts';
addpath(genpath(toolboxRoot))

% Set directories
top_dir = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/';
save_dir = '/space/raid6/data/rissman/Nicco/NIQ/Save/';
SC_dir_unavg = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/';
SC_dir_avg = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Average_Values/';
FC_dir = '/space/raid6/data/rissman/Nicco/HCP_ALL/Resting_State/Petersen_FC/';

% Grab subjects (folders starting with a number)
cd(top_dir);
subjs = dir();
regex = regexp({subjs.name},'[0-9]*');
subjs = {subjs(~cellfun('isempty',regex)).name}.';

% Create new data structure
newMasterCell{length(subjs)} = [];

% Iterate through subjects
for s = 1:length(subjs)
    
    % Check if subject is finished already
    if (~isempty(newMasterCell{s}))
        continue
    end
    
    % Grab & save info for subject
    subject_str = char(subjs(s));
    fprintf('Compiling %s\n', subject_str);
    newMasterCell{s}.ID = subject_str;
    
    % Load in & save subject Petersen SC unaveraged matrices
    cd(SC_dir_unavg);
    file_str = ['Subj_' subject_str '.mat'];
    try
        load(file_str);
        fprintf('Loading in %s\n', file_str);
        newMasterCell{s}.Petersen_SC_unavg.mean = mean_non_zero;
        newMasterCell{s}.Petersen_SC_unavg.volume = volume_non_zero;
        newMasterCell{s}.Petersen_SC_unavg.voxels = voxels_non_zero;
        clear mean_non_zero;
        clear volume_non_zero;
        clear voxels_non_zero;
    catch
        fprintf('Subject P_SC_unavg not found\n');
    end
    
    % Load in & save subject Petersen SC averaged matrices
    cd(SC_dir_avg);
    file_str = ['Subj_' subject_str '_avg.mat'];
    try
        load(file_str);
        fprintf('Loading in %s\n', file_str);
        newMasterCell{s}.Petersen_SC_avg.mean = mean_non_zero_avg;
        newMasterCell{s}.Petersen_SC_avg.volume = volume_non_zero_avg;
        newMasterCell{s}.Petersen_SC_avg.voxels = voxels_non_zero_avg;
        clear mean_non_zero_avg;
        clear volume_non_zero_avg;
        clear voxels_non_zero_avg;
    catch
        fprintf('Subject P_SC_avg not found\n');
    end
    
    % Load in & save subject Petersen FC matrices
    cd(FC_dir);
    file_str = [subject_str '_Petersen_FC_Matrices.mat'];
    try
        load(file_str);
        fprintf('Loading in %s\n', file_str);
        newMasterCell{s}.Petersen_FC.matrix = FC_Matrix;
        newMasterCell{s}.Petersen_FC.partials = FC_Matrix_partials;
        clear FC_Matrix;
        clear FC_Matrix_partials;
    catch
        fprintf('Subject P_FC not found\n');
    end
    
    % Load in & save subject Gordon SC unaveraged matrices
    cd([SC_dir_unavg '/Gordon/']);
    file_str = ['Subj_' subject_str '.mat'];
    try
        load(file_str);
        fprintf('Loading in %s\n', file_str);
        newMasterCell{s}.Gordon_SC_unavg.mean = mean_non_zero;
        newMasterCell{s}.Gordon_SC_unavg.volume = volume_non_zero;
        clear mean_non_zero;
        clear volume_non_zero;
    catch
        fprintf('Subject G_SC_unavg not found\n');
    end
    
    % Load in & save subject Gordon SC averaged matrices
    cd([SC_dir_unavg '/Gordon/Average_Values/']);
    try
        load(file_str);
        fprintf('Loading in %s\n', file_str);
        newMasterCell{s}.Gordon_SC_avg.mean = mean_non_zero_avg;
        newMasterCell{s}.Gordon_SC_avg.volume = volume_non_zero_avg;
        clear mean_non_zero_avg;
        clear volume_non_zero_avg;
    catch
        fprintf('Subject G_SC_avg not found\n');
    end
    
end

masterCell = newMasterCell;

% Save work
fprintf('Saving master cell');
save([save_dir 'masterCell.mat'],'masterCell');

%================================================

% Go through and output which subjects can be taken off the FUNC
% For now, assume if P_SC_unavg is done, take off

fileID = fopen('toRemove.txt','w');

for i = 1:length(masterCell)
    if (isfield(masterCell{i}, 'Petersen_SC_unavg'))
        fprintf(fileID, '%s\n', masterCell{i}.ID);
    end
end

fclose(fileID);
