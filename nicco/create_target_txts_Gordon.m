%==============================================================================================
% create_target_txts_Gordon.m
%
% This script creates the target text files for each seed per subject, 
% specifically for the Gordon ROIs.
%
% The text files created will be saved as:
%
% ~/Nicco/NIQ/Reference/{SubjectID}_Gordon_From_{Seed#}.txt
%
% Each file contains a list of all the target paths in the following format:
% /space/raid6/data/rissman/Nicco/NIQ/masks/Subject_Specific/{SubjectID}_Gordon_{Seed#}.nii.gz
%
% Writing to files is based on 'create_target_txts.m' located at:
%
% ~/Nicco/HCPQ3/Scripts/
%
% **For some reason parallel option is not working (memory usage of other processes maybe)**
% This code has an option to run in parallel with 8 workers (on seeds only).
% Just alter the code where it says 'PARALLEL'.
%
% Parallelization and loops based on 'Create_Compiled_Values.m' located at:
%
% ~/Nicco/NIQ/Scripts/
%
%
% Bug! For some reason the grabbing subjects takes in more than just subject names.
% It takes in all the extra FUNC output files as well.
% Something to do with the regex expression.
%
%==============================================================================================

% Initialize paths
targets_dir = '/space/raid6/data/rissman/Nicco/NIQ/masks/Subject_Specific/';
ref_dir = '/space/raid6/data/rissman/Nicco/NIQ/Reference/';
subj_dir = '/space/raid6/data/rissman/Nicco/HCP_ALL/Move2Func/';

% Grab subjects
cd(subj_dir);
subjs = dir();
regex = regexp({subjs.name},'[0-9]*');
subjs = {subjs(~cellfun('isempty',regex)).name}.';

% Move to reference directory (where the .txt files will go)
cd(ref_dir);

% Iterate over subjects
for s = 1:length(subjs)
    % Create subject string
    subject_str = char(subjs(s));

    % Iterate over seeds
    % PARALLEL: Use parfor instead of for
    for seed = 1:333
        % Create seed string
        seed_str = num2str(seed);
        
        % Open a specific .txt file for subject's seed
        fprintf('Opening %s_Gordon_From_%s.txt\n', subject_str, seed_str);
        filename = [ref_dir subject_str '_Gordon_From_' seed_str '.txt'];
        fid = fopen(filename,'w');

        % Iterate over targets
        targets = setdiff(1:333,seed);
        for t = 1:length(targets)
            target = targets(t);
            target_str = num2str(target);

            % Write full path to target
            fprintf('Writing subject %s seed %s to target %s\n', subject_str, seed_str, target_str);
            cur_path = [targets_dir subject_str '_Gordon_' target_str '.nii.gz'];
            fprintf(fid, cur_path);
            fprintf(fid, '\n');
        end
        
        % Close .txt file after completion
        fclose(fid);
    end
end
