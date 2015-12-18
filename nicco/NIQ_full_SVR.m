function NIQ_full_SVR(behavioral_var,conn_type,Network_1,Network_2)

toolboxRoot=['/space/raid6/data/rissman/Nicco/MATLAB_PATH/'];
addpath(genpath(toolboxRoot))
toolboxRoot=['/space/raid6/data/rissman/Nicco/NIQ/Scripts'];
addpath(genpath(toolboxRoot))

% Loop over types of analyses
types = {'s', 'smof_upper', 'smof_lower', 'fmos_upper', 'fmos_lower', 'Interact', 'f'};
percent = .5;
for t = 1:size(types, 2)
    
    % Set variables of interest
    switch nargin
        case 3
            fprintf('Trying intranetwork...\n');
            fprintf('%s...\n', types{t});
            if t == 1
                [subjs_used,classification_patterns] = features_structural(conn_type, Network_1);
            elseif t == 2
                [subjs_used,classification_patterns] = features_smof_upper(conn_type, percent, Network_1);
            elseif t == 3
                [subjs_used,classification_patterns] = features_smof_lower(conn_type, percent, Network_1);
            elseif t == 4
                [subjs_used,classification_patterns] = features_fmos_upper(conn_type, percent, Network_1);
            elseif t == 5
                [subjs_used,classification_patterns] = features_fmos_lower(conn_type, percent, Network_1);
            elseif t == 6
                [subjs_used,classification_patterns] = features_sf_Interact(conn_type, Network_1);
            elseif t == 7
                [subjs_used,classification_patterns] = features_functional(conn_type, Network_1);
            end
            fprintf('Retrieved feature set.\n');
        case 4
            fprintf('Trying internetwork...\n');
            fprintf('%s...\n', types{t});
            if t == 1
                [subjs_used,classification_patterns] = features_structural(conn_type, Network_1, Network_2);
            elseif t == 2
                [subjs_used,classification_patterns] = features_smof_upper(conn_type, percent, Network_1, Network_2);
            elseif t == 3
                [subjs_used,classification_patterns] = features_smof_lower(conn_type, percent, Network_1, Network_2);
            elseif t == 4
                [subjs_used,classification_patterns] = features_fmos_upper(conn_type, percent, Network_1, Network_2);
            elseif t == 5
                [subjs_used,classification_patterns] = features_fmos_lower(conn_type, percent, Network_1, Network_2);
            elseif t == 6
                [subjs_used,classification_patterns] = features_sf_Interact(conn_type, Network_1, Network_2);
            elseif t == 7
                [subjs_used,classification_patterns] = features_functional(conn_type, Network_1, Network_2);
            end
            fprintf('Retrieved feature set.\n');
    end

    %% Behavioral Data

    % Initialize paths
    behavioral_dir = '/space/raid6/data/rissman/Nicco/NIQ/Behavioral/';

    % Grab subjects' behavioral data
    fprintf('Grabbing behavioral data...\n');
    cd(behavioral_dir);
    load('all_behave.mat');

    % Initialize a vector for behavioral values for each subject
    temp_behav = zeros(1, length(subjs_used));

    % Loop through subjects
    for s = 1:length(subjs_used)

        % Grab info for subject
        subjectID = subjs_used(s);

        % Grab subject's behavioral value
        temp_behav(s) = all_behave.(['Subject' num2str(subjectID)]).(behavioral_var);
    end

    % Cross Validation
    fprintf('Finding selectors...\n');
    behav_vector = temp_behav;
    condensed_regs_of_interest = 1:length(behav_vector);
    [selectors] = enforce_forced_choice(condensed_regs_of_interest);

    %% Classification
    fprintf('Beginning Classification...\n');
    svr_acts = zeros(1, size(selectors, 2));

    for n=1:size(selectors,2)
        current_selector = selectors{n};
        train_idx = find(current_selector == 1);
        test_idx  = find(current_selector == 2);

        train_labels = behav_vector(:,train_idx);
        test_labels = behav_vector(:,test_idx);

        train_pats = classification_patterns(:,train_idx);
        test_pats = classification_patterns(:,test_idx);

        fprintf('SVR for n = %d \n', n);

        % SVR
        [model]=svmtrain_NR(train_labels', train_pats','-s 3 -t 1 -c 1 -q');
        [svr_acts(n)] = svmpredict_NR(test_labels',test_pats',model,'-q');

    end

    fprintf('Finishing Classification...\n');

    SVR=corr(svr_acts', behav_vector');

    % Output results
    fprintf('Saving results...\n\n');
    switch nargin
        case 3
    save_file=['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/' Network_1 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR.txt'];
        case 4
    save_file=['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/' Network_1 '_and_' Network_2 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR.txt'];
    end

    header = {'SVR'};
    data = SVR;

    save_data_with_headers(header,data,save_file);
end
