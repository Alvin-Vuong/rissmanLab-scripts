function NIQ_full_SVR_Varied(behavioral_var,conn_type,Network_1,Network_2)

toolboxRoot=['/space/raid6/data/rissman/Nicco/MATLAB_PATH/'];
addpath(genpath(toolboxRoot))
toolboxRoot=['/space/raid6/data/rissman/Nicco/NIQ/Scripts'];
addpath(genpath(toolboxRoot))

% Loop over types of analyses
types = {'s', 'smof_upper', 'smof_lower', 'fmos_upper', 'fmos_lower', 'Interact', 'f'};
val_types = {'M', 'V'};
percent = .5;
for t = 6 %1:size(types, 2)
    for tt = 1 %:size(val_types, 2)
        % Set variables of interest
        switch nargin
            case 3
                fprintf('Trying intranetwork...\n');
                fprintf('%s...\n', types{t});
                if t == 1
                    [subjs_used,classification_patterns] = features_structural(conn_type, val_types{tt}, Network_1);
                elseif t == 2
                    [subjs_used,classification_patterns] = features_smof_upper(conn_type, val_types{tt}, percent, Network_1);
                elseif t == 3
                    [subjs_used,classification_patterns] = features_smof_lower(conn_type, val_types{tt}, percent, Network_1);
                elseif t == 4
                    [subjs_used,classification_patterns] = features_fmos_upper(conn_type, val_types{tt}, percent, Network_1);
                elseif t == 5
                    [subjs_used,classification_patterns] = features_fmos_lower(conn_type, val_types{tt}, percent, Network_1);
                elseif t == 6
                    [subjs_used,classification_patterns] = features_sf_Interact(conn_type, val_types{tt}, Network_1);
                elseif t == 7 && tt ~= 2
                    [subjs_used,classification_patterns] = features_functional(conn_type, Network_1);
                end

                if t == 7 && tt == 2
                    continue
                end

                fprintf('Retrieved feature set.\n');
            case 4
                fprintf('Trying internetwork...\n');
                fprintf('%s...\n', types{t});
                if t == 1
                    [subjs_used,classification_patterns] = features_structural(conn_type, val_types{tt}, Network_1, Network_2);
                elseif t == 2
                    [subjs_used,classification_patterns] = features_smof_upper(conn_type, val_types{tt}, percent, Network_1, Network_2);
                elseif t == 3
                    [subjs_used,classification_patterns] = features_smof_lower(conn_type, val_types{tt}, percent, Network_1, Network_2);
                elseif t == 4
                    [subjs_used,classification_patterns] = features_fmos_upper(conn_type, val_types{tt}, percent, Network_1, Network_2);
                elseif t == 5
                    [subjs_used,classification_patterns] = features_fmos_lower(conn_type, val_types{tt}, percent, Network_1, Network_2);
                elseif t == 6
                    [subjs_used,classification_patterns] = features_sf_Interact(conn_type, val_types{tt}, Network_1, Network_2);
                elseif t == 7 && tt ~= 2
                    [subjs_used,classification_patterns] = features_functional(conn_type, Network_1, Network_2);
                end

                if t == 7 && tt == 2
                    continue
                end

                fprintf('Retrieved feature set.\n');
        end
           
        % Vary the ridge penalty (from 0 to 100 incrementally by .5) -c
        for pen = 5.5:.5:100
            % Vary the kernel type (linear, polynomial) -t Sigmoid = NaN, radial = weird negatives
            for kern_t = 0:1
                % Vary the SVR type (epsilon vs. nu) -s
                for svr_t = 3:4
                    
                    fprintf('SVR with s %d, t %d, c %s \n', svr_t, kern_t, num2str(pen));
                    
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
                        [model]=svmtrain_NR(train_labels', train_pats',['-s ' num2str(svr_t) ' -t ' num2str(kern_t) ' -c ' num2str(pen) ' -q']);
                        [svr_acts(n)] = svmpredict_NR(test_labels',test_pats',model,'-q');

                    end

                    fprintf('Finishing Classification...\n');

                    SVR = corr(svr_acts', behav_vector');

                    % Output results
                    fprintf('Saving results...\n\n');
                    switch nargin
                        case 3
                            if tt == 1
                                if svr_t == 3
                                    if kern_t == 0
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/' Network_1 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_epsilon_linear_Cost_' num2str(pen) '_Mean.txt'];
                                    elseif kern_t == 1
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/' Network_1 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_epsilon_poly_Cost_' num2str(pen) '_Mean.txt'];
                                    elseif kern_t == 2
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/' Network_1 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_epsilon_radial_Cost_' num2str(pen) '_Mean.txt'];
                                    elseif kern_t == 3
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/' Network_1 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_epsilon_sigmoid_Cost_' num2str(pen) '_Mean.txt'];
                                    end
                                elseif svr_t == 4
                                    if kern_t == 0
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/' Network_1 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_nu_linear_Cost_' num2str(pen) '_Mean.txt'];
                                    elseif kern_t == 1
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/' Network_1 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_nu_poly_Cost_' num2str(pen) '_Mean.txt'];
                                    elseif kern_t == 2
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/' Network_1 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_nu_radial_Cost_' num2str(pen) '_Mean.txt'];
                                    elseif kern_t == 3
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/' Network_1 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_nu_sigmoid_Cost_' num2str(pen) '_Mean.txt'];
                                    end
                                end
                            elseif tt == 2
                                save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/' Network_1 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_s' num2str(svr_t) 'k' num2str(kern_t) 'c' num2str(pen) '_Volume.txt'];
                            end
                        case 4
                            if tt == 1
                                if svr_t == 3
                                    if kern_t == 0
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/SVR_Varied/' Network_1 '_and_' Network_2 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_epsilon_linear_Cost_' num2str(pen) '_Mean.txt'];
                                    elseif kern_t == 1
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/SVR_Varied/' Network_1 '_and_' Network_2 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_epsilon_poly_Cost_' num2str(pen) '_Mean.txt'];
                                    elseif kern_t == 2
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/SVR_Varied/' Network_1 '_and_' Network_2 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_epsilon_radial_Cost_' num2str(pen) '_Mean.txt'];
                                    elseif kern_t == 3
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/SVR_Varied/' Network_1 '_and_' Network_2 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_epsilon_sigmoid_Cost_' num2str(pen) '_Mean.txt'];
                                    end
                                elseif svr_t == 4
                                    if kern_t == 0
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/SVR_Varied/' Network_1 '_and_' Network_2 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_nu_linear_Cost_' num2str(pen) '_Mean.txt'];
                                    elseif kern_t == 1
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/SVR_Varied/' Network_1 '_and_' Network_2 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_nu_poly_Cost_' num2str(pen) '_Mean.txt'];
                                    elseif kern_t == 2
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/SVR_Varied/' Network_1 '_and_' Network_2 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_nu_radial_Cost_' num2str(pen) '_Mean.txt'];
                                    elseif kern_t == 3
                                        save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/SVR_Varied/' Network_1 '_and_' Network_2 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_nu_sigmoid_Cost_' num2str(pen) '_Mean.txt'];
                                    end
                                end
                            elseif tt == 2
                                %save_file = ['/space/raid6/data/rissman/Nicco/NIQ/Results/EXPANSION/' Network_1 '_and_' Network_2 '_' conn_type '_' behavioral_var '_n' num2str(length(subjs_used)) '_' types{t} '_SVR_s' num2str(svr_t) 'k' num2str(kern_t) 'c' num2str(pen) '_Volume.txt'];
                            end
                    end

                    header = {'SVR'};
                    data = SVR;

                    save_data_with_headers(header,data,save_file);
                end
            end
        end
    end
end
