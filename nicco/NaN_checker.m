% Checks if any subject has a NaN in their data.

% Set paths
structural_path = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/';

% Retrieve subjects using structural path
cd(structural_path);
subjs = dir();
regex = regexp({subjs.name},'Subj_*');
subjs = {subjs(~cellfun('isempty',regex)).name}.';

list = []; %

% For each subject
for s = 1:length(subjs)

    % Grab info for subject
    file_str = char(subjs(s));
    subjectID = file_str(6:end-4);

    % Get subject's data
    load([structural_path 'Subj_' subjectID '.mat']);

    % Check connectivity values for each pair...
    for i = 1:264
        for j = 1:264
            if i == j
                continue;
            end
            val = mean_non_zero(i, j);
            if (isnan(val)) %
                if (ismember(str2num(subjectID), list))%
                    continue;%
                end%
                fprintf('%s has a nan.\n', subjectID);%
                list = [list str2num(subjectID)];%
                continue; %
            end%
        end
    end
end