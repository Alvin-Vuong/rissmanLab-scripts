% Set paths and dependencies
toolboxRoot = '/space/raid6/data/rissman/Nicco/MATLAB_PATH/';
addpath(genpath(toolboxRoot))
toolboxRoot = '/space/raid6/data/rissman/Nicco/NIQ/Scripts';
addpath(genpath(toolboxRoot))

% Get network info
network_indices_path = '/space/raid6/data/rissman/Nicco/NIQ/Network_Indices/';
load([network_indices_path 'Petersen_Networks.mat']);
networks = fieldnames(Petersen_Networks);

% Declare connection types
internetwork_mutual_connection_types = {'amXY_wX_wY', 'amXY_wX', 'amXY_wY', 'amXY'};
internetwork_oneway_connection_types = {'aoXY_wX_wY', 'aoXY_wX', 'aoXY_wY', 'aoXY'};
intranetwork_connection_types={'wX'};

% Choose behavioral variables of interest
%behavs_of_interest = {'PMAT24_A_CR'};
behavs_of_interest = {'LifeSatisf_Unadj', 'MeanPurp_Unadj', 'PosAffect_Unadj'};

%{
% Choose networks of interest (specific)
Network_1 = 'Default_Mode';
Network_2 = 'Salience_w_Cingulo_Opercular';
%}

% Choose networks of interest (for looping)
%Networks = {'Subcortical','Salience_w_Cingulo_Opercular','Cingulo_Opercular','Salience','Auditory','Sensory_Somatomotor_Hand','Memory_Retrieval','Visual','Ventral_Attention','Fronto_Parietal','Cerebellar','Dorsal_Attention','Sensory_Somatomotor_Mouth'};
Networks = {'Default_Mode','Subcortical','Salience_w_Cingulo_Opercular','Cingulo_Opercular','Salience','Auditory','Sensory_Somatomotor_Hand','Memory_Retrieval','Visual','Ventral_Attention','Fronto_Parietal','Cerebellar','Dorsal_Attention','Sensory_Somatomotor_Mouth'};

for n1 = 1:size(networks,2)
    %for n2 = 1:size(networks,2)  %TODO: Handshake Problem Implementation
Network_1 = Networks{n1};
%Network_2 = Networks{n2};

%===================================================================================
% Optimizations

%%%%%%%%%%%%%%%%%%%%%%%%%%% Internetwork  Ridge  Varied  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% aoXY_wY  Interact  0:.5:100  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%             Mean             %%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
for i = 3 %1:size(internetwork_oneway_connection_types,2)
    for j = 1 %:size(behavs_of_interest,2)
        fprintf('Starting Ridge: %s %s %s\n', internetwork_oneway_connection_types{i}, Network_1, Network_2);
        try NIQ_full_Ridge_Pen_Varied(behavs_of_interest{j},internetwork_oneway_connection_types{i},Network_1,Network_2); 
        catch
            continue
        end
    end
end
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%% Internetwork   SVR   Varied  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% aoXY_wY  Interact  0:.5:100  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%    epsilon/nu       Mean     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%   linear/poly/rad/sigmoid    %%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
for i = 3 %1:size(internetwork_oneway_connection_types,2)
    for j = 1 %:size(behavs_of_interest,2)
        fprintf('Starting SVR: %s %s %s\n', internetwork_oneway_connection_types{i}, Network_1, Network_2);
        try NIQ_full_SVR_Varied(behavs_of_interest{j},internetwork_oneway_connection_types{i},Network_1,Network_2); 
        catch
            continue
        end
    end
end
%}
%===================================================================================
% Regular Iterations

%%%%%%%%%%%%%%%%%%%%%%%%%%% Intranetwork Ridge SVR Lasso %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Intranetwork Ridge only
for i = 1:size(intranetwork_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting Ridge: %s %s\n', intranetwork_connection_types{i}, Network_1);
        try NIQ_full_Ridge(behavs_of_interest{j},intranetwork_connection_types{i},Network_1);
        catch
            continue
        end
    end
end

for i = 1:size(intranetwork_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting Ridge: %s %s\n', intranetwork_connection_types{i}, Network_2);
        try NIQ_full_Ridge(behavs_of_interest{j},intranetwork_connection_types{i},Network_2);
        catch
            continue
        end
    end
end

% Pen = 1
for i = 1:size(intranetwork_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting Ridge: %s %s\n', intranetwork_connection_types{i}, Network_1);
        try NIQ_full_Ridge_pen1(behavs_of_interest{j},intranetwork_connection_types{i},Network_1);
        catch
            continue
        end
    end
end

for i = 1:size(intranetwork_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting Ridge: %s %s\n', intranetwork_connection_types{i}, Network_2);
        try NIQ_full_Ridge_pen1(behavs_of_interest{j},intranetwork_connection_types{i},Network_2);
        catch
            continue
        end
    end
end

% Intranetwork SVR
for i = 1:size(intranetwork_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting SVR: %s %s\n', intranetwork_connection_types{i}, Network_1);
        try NIQ_full_SVR(behavs_of_interest{j},intranetwork_connection_types{i},Network_1);
        catch
            continue
        end
    end
end

for i = 1:size(intranetwork_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting SVR: %s %s\n', intranetwork_connection_types{i}, Network_2);
        try NIQ_full_SVR(behavs_of_interest{j},intranetwork_connection_types{i},Network_2);
        catch
            continue
        end
    end
end

% Intranetwork Lasso
for i = 1:size(intranetwork_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting Lasso: %s %s\n', intranetwork_connection_types{i}, Network_1);
        try NIQ_full_Lasso(behavs_of_interest{j},intranetwork_connection_types{i},Network_1);
        catch
            continue
        end
    end
end

for i = 1:size(intranetwork_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting Lasso: %s %s\n', intranetwork_connection_types{i}, Network_2);
        try NIQ_full_Lasso(behavs_of_interest{j},intranetwork_connection_types{i},Network_2);
        catch
            continue
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%% Internetwork Ridge SVR Lasso %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Internetwork Ridge Only
for i = 1:size(internetwork_mutual_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting Ridge: %s %s %s\n', internetwork_mutual_connection_types{i}, Network_1, Network_2);
        try NIQ_full_Ridge(behavs_of_interest{j},internetwork_mutual_connection_types{i},Network_1,Network_2); 
        catch
            continue
        end
    end
end
for i = 1:size(internetwork_oneway_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting Ridge: %s %s %s\n', internetwork_oneway_connection_types{i}, Network_1, Network_2);
        try NIQ_full_Ridge(behavs_of_interest{j},internetwork_oneway_connection_types{i},Network_1,Network_2); 
        catch
            continue
        end
    end
end
for i = 1:size(internetwork_oneway_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting Ridge: %s %s %s\n', internetwork_oneway_connection_types{i}, Network_2, Network_1);
        try NIQ_full_Ridge(behavs_of_interest{j},internetwork_oneway_connection_types{i},Network_2,Network_1); 
        catch
            continue
        end
    end
end

% Pen = 1
for i = 1:size(internetwork_mutual_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting Ridge: %s %s %s\n', internetwork_mutual_connection_types{i}, Network_1, Network_2);
        try NIQ_full_Ridge_pen1(behavs_of_interest{j},internetwork_mutual_connection_types{i},Network_1,Network_2); 
        catch
            continue
        end
    end
end
for i = 1:size(internetwork_oneway_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting Ridge: %s %s %s\n', internetwork_oneway_connection_types{i}, Network_1, Network_2);
        try NIQ_full_Ridge_pen1(behavs_of_interest{j},internetwork_oneway_connection_types{i},Network_1,Network_2); 
        catch
            continue
        end
    end
end
for i = 1:size(internetwork_oneway_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting Ridge: %s %s %s\n', internetwork_oneway_connection_types{i}, Network_2, Network_1);
        try NIQ_full_Ridge_pen1(behavs_of_interest{j},internetwork_oneway_connection_types{i},Network_2,Network_1); 
        catch
            continue
        end
    end
end

% Internetwork SVR
for i = 1:size(internetwork_mutual_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting SVR: %s %s %s\n', internetwork_mutual_connection_types{i}, Network_1, Network_2);
        try NIQ_full_SVR(behavs_of_interest{j},internetwork_mutual_connection_types{i},Network_1,Network_2); 
        catch
            continue
        end
    end
end
for i = 1:size(internetwork_oneway_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting SVR: %s %s %s\n', internetwork_oneway_connection_types{i}, Network_1, Network_2);
        try NIQ_full_SVR(behavs_of_interest{j},internetwork_oneway_connection_types{i},Network_1,Network_2); 
        catch
            continue
        end
    end
end
for i = 1:size(internetwork_oneway_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting SVR: %s %s %s\n', internetwork_oneway_connection_types{i}, Network_2, Network_1);
        try NIQ_full_SVR(behavs_of_interest{j},internetwork_oneway_connection_types{i},Network_2,Network_1); 
        catch
            continue
        end
    end
end

% Internetwork Lasso
for i = 1:size(internetwork_mutual_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting Lasso: %s %s %s\n', internetwork_mutual_connection_types{i}, Network_1, Network_2);
        try NIQ_full_Lasso(behavs_of_interest{j},internetwork_mutual_connection_types{i},Network_1,Network_2); 
        catch
            continue
        end
    end
end
for i = 1:size(internetwork_oneway_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting Lasso: %s %s %s\n', internetwork_oneway_connection_types{i}, Network_1, Network_2);
        try NIQ_full_Lasso(behavs_of_interest{j},internetwork_oneway_connection_types{i},Network_1,Network_2); 
        catch
            continue
        end
    end
end
for i = 1:size(internetwork_oneway_connection_types,2)
    for j = 1:size(behavs_of_interest,2)
        fprintf('Starting Lasso: %s %s %s\n', internetwork_oneway_connection_types{i}, Network_2, Network_1);
        try NIQ_full_Lasso(behavs_of_interest{j},internetwork_oneway_connection_types{i},Network_2,Network_1); 
        catch
            continue
        end
    end
end

end
