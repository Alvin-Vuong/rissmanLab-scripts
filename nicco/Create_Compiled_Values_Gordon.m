%======================================================================================
% Create_Compiled_Values_Gordon.m
%
% This script performs pairwise calculations on each of the selected 333
% nodes with every other node for every subject. These calculated values (matrices):
%   mean_non_zero
%   count_non_zero
%   mean_non_zero_div_waytotal
%   count_non_zero_div_waytotal
% are then stored in a .mat file located at:
%
% ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Gordon/Compiled_Values/{SubjectID}.mat
%
% Inside these matrices, rows are seeds and columns are targets.
%
% This code has an option to run in parallel with 8 workers (on seeds only).
% Alter the code wherever 'PARALLEL:' is stated in order to enable this.
%======================================================================================

% Initialize paths
save_dir = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Gordon/Compiled_Values/';
top_dir = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/';

% Go to top directory
cd(top_dir);

% Grab subjects (folders starting with a number)
subjs = dir();
regex = regexp({subjs.name},'[0-9]*');
subjs = {subjs(~cellfun('isempty',regex)).name}.';

% Iterate through subjects
for s = 1:length(subjs)
    % Move into subject folder
    subject_str = char(subjs(s));
    fprintf('Moving to subject: %s\n', subject_str);
    cd([top_dir subject_str]);
    
    % Check if 264 seed folders within subject
    if length(dir(fullfile('.', 'F*'))) ~= 333
        fprintf('Subject does not have 264 seeds...\n');
        cd(top_dir);
        continue; % Jump to next subject
    end
    
    % Init matrices
    mean_non_zero = zeros(333,333);
    count_non_zero = zeros(333,333);
    mean_non_zero_div_waytotal = zeros(333,333);
    count_non_zero_div_waytotal = zeros(333,333);
    
    % Iterate through seeds
    % PARALLEL: Use parfor instead of for
    parfor seed = 1:333
        % Move into seed folder
        seed_str = num2str(seed);
        fprintf('Moving to seed: %s\n', seed_str);
        cd([top_dir subject_str '/Gordon/From_' seed_str]);
        
        % Load waytotal and number of voxels
        waytotal = load('waytotal');
        num_vox = waytotal/5000;
        
        % Find all targets
        targets = setdiff(1:333,seed);
        
        % Create temporary row vectors
        % PARALLEL: Uncomment these lines
        temp_mean_non_zero = zeros(1,333);
        temp_count_non_zero = zeros(1,333);
        temp_mean_non_zero_div_waytotal = zeros(1,333);
        temp_count_non_zero_div_waytotal = zeros(1,333);
        
        % Iterate through targets
        for t = 1:length(targets)
            % Unzip and delete compressed target file
            target = targets(t);
            target_str = num2str(targets(t));
            filename = ['seeds_to_' subject_str '_Gordon_' target_str '.nii.gz'];
            fprintf('Unzipping target: %s\n', target_str);
            try
                gunzip(filename);
                delete(filename);
            catch
                fprintf('Already unzipped\n');
            end
            
            filename = filename(1:end-3);

            % Load data
            V = spm_vol(filename);
            vols = spm_read_vols(V);

            % Find all nonzero voxel indices
            nonzero_vox_idx=find(vols);
	    
            % Calculate count and mean of nonzero values
            cur_count = length(nonzero_vox_idx);
            cur_mean = mean(vols(nonzero_vox_idx));

            % Place calculated values in matrices
            % PARALLEL: Comment these lines
            %mean_non_zero(seed,target) = cur_mean;
            %count_non_zero(seed,target) = cur_count;
            %mean_non_zero_div_waytotal(seed,target) = cur_mean / waytotal;
            %count_non_zero_div_waytotal(seed,target) = cur_count / num_vox;
            
            % Place calculated values in temporary rows
            % PARALLEL: Uncomment these lines
            temp_mean_non_zero(target) = cur_mean;
            temp_count_non_zero(target) = cur_count;
            temp_mean_non_zero_div_waytotal(target) = cur_mean / waytotal;
            temp_count_non_zero_div_waytotal(target) = cur_count / num_vox;
        end

        % Add temporary rows to matrices
        % PARALLEL: Uncomment these lines
        mean_non_zero(seed,:) = temp_mean_non_zero;
        count_non_zero(seed,:) = temp_count_non_zero;
        mean_non_zero_div_waytotal(seed,:) = temp_mean_non_zero_div_waytotal;
        count_non_zero_div_waytotal(seed,:) = temp_count_non_zero_div_waytotal;
        
        % Go to next seed
        % PARALLEL: Might not need this
        cd([top_dir subject_str]);
    end
    
    % Save work
    fprintf('Saving compiled values for subject: %s\n', subject_str);
    save([save_dir 'Subj_' subject_str '.mat'],'mean_non_zero','count_non_zero','mean_non_zero_div_waytotal','count_non_zero_div_waytotal');

    % Go to next subject
    cd(top_dir);
end
