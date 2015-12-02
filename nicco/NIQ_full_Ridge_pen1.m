function NIQ_full_Ridge_pen1(behavioral_var,conn_type,Network_1,Network_2)

toolboxRoot=['/space/raid6/data/rissman/Nicco/MATLAB_PATH/'];
addpath(genpath(toolboxRoot))
toolboxRoot=['/space/raid6/data/rissman/Nicco/NIQ/Scripts'];
addpath(genpath(toolboxRoot))

% Loop over types of analyses
types = {'s', 'smof_upper', 'smof_lower', 'fmos_upper', 'fmos_lower', 'Interact'}; % 'f'?
percent = .5;
for t = 2:size(types, 2)
    
    % Set variables of interest
    switch nargin
        case 3
            fprintf('Trying intranetwork...\n');
            fprintf('%s...\n', types{t});
            if t == 1
                [~,classification_patterns] = features_structural(conn_type, Network_1);
            elseif t == 2
                [~,classification_patterns] = features_smof_upper(conn_type, percent, Network_1);
            elseif t == 3
                [~,classification_patterns] = features_smof_lower(conn_type, percent, Network_1);
            elseif t == 4
                [~,classification_patterns] = features_fmos_upper(conn_type, percent, Network_1);
            elseif t == 5
                [~,classification_patterns] = features_fmos_lower(conn_type, percent, Network_1);
            elseif t == 6
                [~,classification_patterns] = features_sf_Interact(conn_type, Network_1);
            end
            fprintf('Retrieved feature set.\n');
        case 4
            fprintf('Trying internetwork...\n');
            fprintf('%s...\n', types{t});
            if t == 1
                [~,classification_patterns] = features_structural(conn_type, Network_1, Network_2);
            elseif t == 2
                [~,classification_patterns] = features_smof_upper(conn_type, percent, Network_1, Network_2);
            elseif t == 3
                [~,classification_patterns] = features_smof_lower(conn_type, percent, Network_1, Network_2);
            elseif t == 4
                [~,classification_patterns] = features_fmos_upper(conn_type, percent, Network_1, Network_2);
            elseif t == 5
                [~,classification_patterns] = features_fmos_lower(conn_type, percent, Network_1, Network_2);
            elseif t == 6
                [~,classification_patterns] = features_sf_Interact(conn_type, Network_1, Network_2);
            end
            fprintf('Retrieved feature set.\n');
    end

    %% Data QA
    fprintf('Cleaning Subject list...\n');

    % See if any NaNs creep in.
    TF = isnan(classification_patterns);
    bad_subj = sum(TF);
    bad_subjs = find(bad_subj);

    % Make sure there aren't 0s for every value in a subject
    sums = sum(classification_patterns);
    bad_subjs = [bad_subjs find(sums == 0)];

    % Delete patterns that are at this index
    classification_patterns(:, bad_subjs)=[];

    % Initialize paths
    compiled_val_dir = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/';
    avg_val_dir = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/Average_Values';
    behavioral_dir = '/space/raid6/data/rissman/Nicco/NIQ/Behavioral/';
    top_dir = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/';

    % Grab subjects (folders starting with a number)
    cd(avg_val_dir);
    subjs = dir();
    regex = regexp({subjs.name},'[0-9]*');
    subjs = {subjs(~cellfun('isempty',regex)).name}.';

    % Maintain list of NaN subjects
    nanlist = [];

    % For each subject
    for s = 1:length(subjs)

        % Grab info for subject
        file_str = char(subjs(s));
        subjectID = file_str(6:end-8);

        % Get subject's data
        load([compiled_val_dir 'Subj_' subjectID '.mat']);

        % Check connectivity values for each pair...
        for i = 1:264
            for j = 1:264
                % Skip diagonals
                if i == j
                    continue;
                end
                val = mean_non_zero(i, j);
                % If NaN is found, add subject to list if not added already
                if (isnan(val))
                    if (ismember(str2num(subjectID), nanlist))
                        continue;
                    end
                    %fprintf('%s has a nan.\n', subjectID);
                    nanlist = [nanlist str2num(subjectID)];
                    continue;
                end
            end
        end
    end

    % Now remove these subjects from subject list
    temp = subjs;
    c = 0;
    for s = 1:length(subjs)
        file_str = char(subjs(s));
        subject_str = file_str(6:end-8);

        for n = 1:length(nanlist)
            if (str2num(subject_str) == nanlist(n))
                temp(s-c,:) = [];
                c = c + 1;
                break;
            end
        end
    end
    subjs = temp;

    % Grab subjects' behavioral data
    fprintf('Grabbing behavioral data...\n');
    cd(behavioral_dir);
    load('all_behave.mat');

    % Initialize a vector for behavioral values for each subject
    temp_behav = zeros(1, length(subjs));

    % Loop through subjects
    for s = 1:length(subjs)

        % Grab info for subject
        file_str = char(subjs(s));
        subject_str = file_str(6:end-8);

        % Grab subject's behavioral value
        temp_behav(s) = all_behave.(['Subject' subject_str]).(behavioral_var);
    end

    % Cross Validation
    fprintf('Finding selectors...\n');
    behav_vector = temp_behav;
    condensed_regs_of_interest = 1:length(behav_vector);
    [selectors] = enforce_forced_choice(condensed_regs_of_interest);

    %% Classification
    fprintf('Beginning Classification...\n');
    running_Betas=zeros(size(classification_patterns,1),1);

    for n=1:size(selectors,2)
        current_selector = selectors{n};
        train_idx = find(current_selector == 1);
        test_idx  = find(current_selector == 2);

        train_labels = behav_vector(:,train_idx);
        test_labels = behav_vector(:,test_idx);

        train_pats = classification_patterns(:,train_idx);
        test_pats = classification_patterns(:,test_idx);

        fprintf('Ridge for n = %d \n', n);

        %RIDGE
        class_args.penalty = 1;
        [scratch]=train_ridge(train_pats, train_labels, class_args);
        [ridge_acts{n} scratchpad] = test_ridge(test_pats,test_labels,scratch);

    end

    fprintf('Finishing Classification...\n');

    Ridge=corr(cell2mat(ridge_acts)', behav_vector');

    % Output results
    fprintf('Saving results...\n\n');
    switch nargin
        case 3
    save_file=['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/' Network_1 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs)) '_' types(t) '_Ridge_pen1.txt'];
        case 4
    save_file=['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/' Network_1 '_and_' Network_2 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs)) '_' types(t) '_Ridge_pen1.txt'];
    end

    header={'Ridge'};
    data=[Ridge];

    save_data_with_headers(header,data,save_file);
end