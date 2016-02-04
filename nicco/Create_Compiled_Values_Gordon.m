%======================================================================================
% Create_Compiled_Values_Gordon.m
%
% This script performs pairwise calculations on each of the selected 333
% nodes with every other node for every subject. These calculated values (matrices):
%   mean_non_zero
%   volume_non_zero
%
% The following are the old calculated matrices:
%   mean_non_zero
%   count_non_zero
%   mean_non_zero_div_waytotal
%   count_non_zero_div_waytotal
%   voxels_non_zero
%
% are then stored in a .mat file located at:
%
% ~/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Gordon/{SubjectID}.mat
%
% Inside these matrices, rows are seeds and columns are targets.
%
% This code has an option to run in parallel with 8 workers (on seeds only).
% Alter the code wherever 'PARALLEL:' is stated in order to enable this.
%
% Estimated runtime:
%   ~5-6 hours/subject on typical server load.
%   ~2-3 hours/subject on light server load.
%
% Suggested use:
%   Run at most 2 MATLAB processes running on different ranges of subjects.
%   Use dentate workstation (seems to be the fastest).
%
% **Update**
%   The code has been modified to use fslstats instead of spm_vols.
%   This is intended to lighten the server load and make this script less 
%   computationally heavy.
%======================================================================================

% Grab subjects (folders starting with a number)
cd('/space/raid6/data/rissman/Nicco/NIQ/Scripts/');
[subjs, ~] = features_sf_Interact('aoXY_wY', 'M', 'Default_Mode', 'Salience_w_Cingulo_Opercular');

% Initialize paths
save_dir = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Gordon/';
top_dir = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/';

% Go to top directory
cd(top_dir);

% Iterate through subjects
for s = 1:127 %length(subjs)
    % Check if subject is already done
    subject_str = char(subjs(s));
    cd(save_dir);
    if length(dir(fullfile('.', ['Subj_' subject_str '.mat']))) == 1
        fprintf('Subject %s, %s has already been completed...\n', s, subject_str);
        continue
    end
    
    % Move into subject folder
    fprintf('Moving to subject: %s, %s\n', s, subject_str);
    cd([top_dir subject_str '/Gordon/']);
    
    % Check if 333 seed folders within subject (Old way of checking)
    if length(dir(fullfile('.', 'F*'))) ~= 333
        fprintf('Subject does not have 264 seeds...\n');
        cd(top_dir);
        continue; % Jump to next subject
    end
    
    % Search all seeds for fdt_paths file
    fdt = 0;
    for ps = 1:333
        ps_str = num2str(ps);
        % Check if fdt_paths exists
        cd([top_dir subject_str '/Gordon/From_' ps_str]);
        if length(dir(fullfile('.', 'fdt_paths.*'))) ~= 1
            fdt = 1;
            fprintf('Subject Seed %s fdt_paths does not exist...\n', ps_str);
            break;
        end
    end
    if fdt == 1
        cd(top_dir);
        continue; % Jump to next subject
    end
    
    % Init matrices
    mean_non_zero = zeros(333,333);
    %voxels_non_zero = zeros(333,333);
    volume_non_zero = zeros(333,333);
    
    %count_non_zero = zeros(333,333);
    %mean_non_zero_div_waytotal = zeros(333,333);
    %count_non_zero_div_waytotal = zeros(333,333);
    
    % Iterate through seeds
    % PARALLEL: Use parfor instead of for
    parfor seed = 1:333
        % Move into seed folder
        seed_str = num2str(seed);
        fprintf('Moving to seed: %s\n', seed_str);
        spec_dir=[top_dir subject_str '/Gordon/From_' seed_str];
        
        % Load waytotal and number of voxels
        %waytotal = load('waytotal');
        %num_vox = waytotal/5000;
        
        % Find all targets
        targets = setdiff(1:333,seed);
        
        % Create temporary row vectors
        % PARALLEL: Uncomment these lines
        temp_mean_non_zero = zeros(1,333);
        %temp_voxels_non_zero = zeros(1,333);
        temp_volume_non_zero = zeros(1,333);
        
        %temp_count_non_zero = zeros(1,333);
        %temp_mean_non_zero_div_waytotal = zeros(1,333);
        %temp_count_non_zero_div_waytotal = zeros(1,333);
        
        % Iterate through targets
        for t = 1:length(targets)
            % Output current target
            target = targets(t);
            target_str = num2str(targets(t));
            filename = [spec_dir '/seeds_to_' subject_str '_Gordon_' target_str '.nii.gz'];
            fprintf('Target: %s\n', target_str);
            
            % Unzip and delete compressed target file (Old way using spm_vols)
            %fprintf('Unzipping target: %s\n', target_str);
            %try
            %    gunzip(filename);
            %    delete(filename);
            %catch
                %fprintf('Already unzipped\n');
            %end
            
            %filename = filename(1:end-3);

            % Load data (spm_vol)
            %V = spm_vol(filename);
            %vols = spm_read_vols(V);
            
            % Load data (fslstats)
            try
                % Voxels & Volume
                [~, v] = unix(['fslstats ' filename ' -V']);
            catch
                [~, v] = unix(['fslstats ' filename(1:end-3) ' -V']);
            end
            index = find(isspace(v),1);
            %voxels = v(1:index-1);
            volume = v(index+1:end);
            
            % Mean
            try
                [~, m] = unix(['fslstats ' filename ' -M']);
            catch
                [~, m] = unix(['fslstats ' filename(1:end-3) ' -M']);
            end
            
            % Recompress target file
            %fprintf('Rezipping target: %s\n', target_str);
            %try
            %    gzip(filename);
            %catch
                %fprintf('Already zipped\n');
            %end
            
            % Find all nonzero voxel indices
            %nonzero_vox_idx=find(vols);
	    
            % Calculate count and mean of nonzero values
            %cur_count = length(nonzero_vox_idx);
            %cur_mean = mean(vols(nonzero_vox_idx));
            
            % Place calculated values in matrices
            % PARALLEL: Comment these lines
            %mean_non_zero(seed,target) = cur_mean;
            %count_non_zero(seed,target) = cur_count;
            %mean_non_zero_div_waytotal(seed,target) = cur_mean / waytotal;
            %count_non_zero_div_waytotal(seed,target) = cur_count / num_vox;
            
            % Place calculated values in temporary rows
            % PARALLEL: Uncomment these lines
            temp_mean_non_zero(target) = str2double(m); %cur_mean;
            %temp_voxels_non_zero(target) = str2double(voxels);
            temp_volume_non_zero(target) = str2double(volume);
            
            %temp_count_non_zero(target) = cur_count;
            %temp_mean_non_zero_div_waytotal(target) = cur_mean / waytotal;
            %temp_count_non_zero_div_waytotal(target) = cur_count / num_vox;
        end
        
        % Add temporary rows to matrices
        % PARALLEL: Uncomment these lines
        mean_non_zero(seed,:) = temp_mean_non_zero;
        %voxels_non_zero(seed,:) = temp_voxels_non_zero;
        volume_non_zero(seed,:) = temp_volume_non_zero;
        
        %count_non_zero(seed,:) = temp_count_non_zero;
        %mean_non_zero_div_waytotal(seed,:) = temp_mean_non_zero_div_waytotal;
        %count_non_zero_div_waytotal(seed,:) = temp_count_non_zero_div_waytotal;
        
        % Go to next seed
        % PARALLEL: Might not need this
        cd([top_dir subject_str '/Gordon/']);
    end
    
    % Save work
    fprintf('Saving compiled values for subject: %s, %s\n', s, subject_str);
    save([save_dir 'Subj_' subject_str '.mat'],'mean_non_zero','volume_non_zero');
    %save([save_dir 'Subj_' subject_str '.mat'],'mean_non_zero','count_non_zero','mean_non_zero_div_waytotal','count_non_zero_div_waytotal');

    % Go to next subject
    cd(top_dir);
end
