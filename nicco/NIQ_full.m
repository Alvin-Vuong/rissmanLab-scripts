% NIQ_full.m

% Set variables of interest
behavioral_var = 'PMAT24_A_CR';
classification_patterns = features_structural('wX', 'Cingulo_Opercular');

% Initialize paths
compiled_val_dir = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/Compiled_Values/';
behavioral_dir = '/space/raid6/data/rissman/Nicco/NIQ/Behavioral/';
top_dir = '/space/raid6/data/rissman/Nicco/NIQ/EXPANSION/Probtrack_Subject_Specific/';

% Grab subjects (folders starting with a number)
cd(compiled_val_dir);
subjs = dir();
regex = regexp({subjs.name},'[0-9]*');
subjs = {subjs(~cellfun('isempty',regex)).name}.';

% Grab subjects' behavioral data
cd(behavioral_dir);
load('all_behave.mat');

% Initialize a vector for behavioral values for each subject
pmat = zeros(1, length(subjs));

% Loop through subjects
for s = 1:length(subjs)
    
    % Grab info for subject
    file_str = char(subjs(s));
    subject_str = file_str(6:end-4);
    
    % Grab subject's behavioral value
    pmat(s) = all_behave.(['Subject' subject_str]).(behavioral_var);
    
end

% Cross Validation
behav_vector=pmat;
condensed_regs_of_interest=1:length(behav_vector);
[selectors]=enforce_forced_choice(condensed_regs_of_interest);

%% Classification
running_Betas=zeros(size(classification_patterns,1),1);

for n=1:size(selectors,2)
    current_selector=selectors{n};
    train_idx = find(current_selector==1);
    test_idx  = find(current_selector==2);
    
    train_labels=behav_vector(:,train_idx);
    test_labels=behav_vector(:,test_idx);
    
    train_pats=classification_patterns(:,train_idx);
    test_pats=classification_patterns(:,test_idx);
    
    % SVR
    [model]=svmtrain_NR(train_labels', train_pats','-s 3 -t 1 -c 1 -q');
    [svr_acts{n}] = svmpredict_NR(test_labels',test_pats',model,'-q');
    
    %RIDGE
    class_args.penalty = size(classification_patterns,1);
    [scratch]=train_ridge(train_pats, train_labels, class_args);
    [ridge_acts{n} scratchpad] = test_ridge(test_pats,test_labels,scratch);
    
    %LASSO
    [B fitinfo]=lasso(train_pats',train_labels,'Lambda',.0003);
    Betas=B;
    running_Betas=running_Betas+Betas;
    lasso_acts{n}=sum(test_pats.*Betas);
    
end
Lasso=corr(cell2mat(lasso_acts)', behav_vector');
SVR=corr(cell2mat(svr_acts)', behav_vector');
Ridge=corr(cell2mat(ridge_acts)', behav_vector');

% Output results
