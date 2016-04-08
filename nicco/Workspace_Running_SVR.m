% Set paths and dependencies
toolboxRoot = '/space/raid6/data/rissman/Nicco/MATLAB_PATH/';
addpath(genpath(toolboxRoot))
toolboxRoot = '/space/raid6/data/rissman/Nicco/NIQ/Scripts';
addpath(genpath(toolboxRoot))

% Get network info
network_indices_path = '/space/raid6/data/rissman/Nicco/NIQ/Network_Indices/';
load([network_indices_path 'Petersen_Networks.mat']);
networks = fieldnames(Petersen_Networks)';

% Declare connection types
internetwork_mutual_connection_types = {'amXY_wX_wY', 'amXY_wX', 'amXY_wY', 'amXY'};
internetwork_oneway_connection_types = {'aoXY_wX_wY', 'aoXY_wX', 'aoXY_wY', 'aoXY'};
intranetwork_connection_types={'wX'};

% Choose behavioral variables of interest
behavs_of_interest1 = {'PMAT24_A_CR'};
behavs_of_interest2 = {'PMAT24_A_RTCR', 'LifeSatisf_Unadj', 'MeanPurp_Unadj', 'PosAffect_Unadj', 'Endurance_Unadj', 'Strength_Unadj', 'Odor_Unadj', 'Taste_Unadj', 'PainInterf_Tscore'};
%{
% All networks wX s, smof_u/l, fmos_u/l, Interact, f
% Leave-1-Out, PMAT-CR, M/V
% Non-hemispherical
for n1 = 3:3:size(networks,2)
Network_1 = networks{n1};

% Intranetwork SVR
for i = 1:size(intranetwork_connection_types,2)
    for j = 1:size(behavs_of_interest1,2)
        fprintf('Starting SVR: %s %s\n', intranetwork_connection_types{i}, Network_1);
        try NIQ_full_SVR(behavs_of_interest1{j},intranetwork_connection_types{i},Network_1);
        catch
            continue
        end
    end
end
end
for n1 = size(networks,2)
Network_1 = networks{n1};

% Intranetwork SVR
for i = 1:size(intranetwork_connection_types,2)
    for j = 1:size(behavs_of_interest1,2)
        fprintf('Starting SVR: %s %s\n', intranetwork_connection_types{i}, Network_1);
        try NIQ_full_SVR(behavs_of_interest1{j},intranetwork_connection_types{i},Network_1);
        catch
            continue
        end
    end
end
end
%{
% Hemispherical
for n1 = 1:size(networks,2)
    if (mod(n1,3) == 0)
        continue
    end
Network_1 = networks{n1};

% Intranetwork SVR
for i = 1:size(intranetwork_connection_types,2)
    for j = 1:size(behavs_of_interest1,2)
        fprintf('Starting SVR: %s %s\n', intranetwork_connection_types{i}, Network_1);
        try NIQ_full_SVR(behavs_of_interest1{j},intranetwork_connection_types{i},Network_1);
        catch
            continue
        end
    end
end
end
%}
%}
% DMN-CO,S,SCO am/ao "
% Leave-1-Out, PMAT-CR, M/V
Network_2s = {'Cingulo_Opercular', 'Salience', 'Salience_w_Cingulo_Opercular'};

for n2 = 3 %:size(Network_2s, 2)
Network_1 = 'Default_Mode';
Network_2 = Network_2s{n2};

% Internetwork SVR
for i = 1:size(internetwork_mutual_connection_types,2)
    for j = 1:size(behavs_of_interest1,2)
        fprintf('Starting SVR: %s %s %s\n', internetwork_mutual_connection_types{i}, Network_1, Network_2);
        try NIQ_full_SVR(behavs_of_interest1{j},internetwork_mutual_connection_types{i},Network_1,Network_2); 
        catch
            continue
        end
    end
end

for i = 1:size(internetwork_oneway_connection_types,2)
    for j = 1:size(behavs_of_interest1,2)
        fprintf('Starting SVR: %s %s %s\n', internetwork_oneway_connection_types{i}, Network_1, Network_2);
        try NIQ_full_SVR(behavs_of_interest1{j},internetwork_oneway_connection_types{i},Network_1,Network_2); 
        catch
            continue
        end
    end
end

for i = 1:size(internetwork_oneway_connection_types,2)
    for j = 1:size(behavs_of_interest1,2)
        fprintf('Starting SVR: %s %s %s\n', internetwork_oneway_connection_types{i}, Network_2, Network_1);
        try NIQ_full_SVR(behavs_of_interest1{j},internetwork_oneway_connection_types{i},Network_2,Network_1); 
        catch
            continue
        end
    end
end

end
%{
% DMN-SCO Interact aoXY_wY
% Leave-1-Out, PMAT-RTCR/LifeSat/MeanPurp/PosAffect/Controls, M/V
Network_1 = 'Default_Mode';
Network_2 = 'Salience_w_Cingulo_Opercular';

% Internetwork SVR
for j = 1:size(behavs_of_interest2,2)
    fprintf('Starting SVR: %s %s %s\n', internetwork_oneway_connection_types{3}, Network_1, Network_2);
    try NIQ_full_SVR_Controls(behavs_of_interest2{j},internetwork_oneway_connection_types{3},Network_1,Network_2);
    catch
        continue
    end
end


% All of above Leave-30-Out Iterate: 400
% All networks wX s, smof_u/l, fmos_u/l, Interact, f
% Non-hemispherical
for n1 = 3:3:size(networks,2)
Network_1 = networks{n1};

% Intranetwork SVR
for i = 1:size(intranetwork_connection_types,2)
    for j = 1:size(behavs_of_interest1,2)
        fprintf('Starting SVR: %s %s\n', intranetwork_connection_types{i}, Network_1);
        try NIQ_full_SVR_Leave_n_Out(behavs_of_interest1{j},intranetwork_connection_types{i},Network_1);
        catch
            continue
        end
    end
end
end

for n1 = size(networks,2)
Network_1 = networks{n1};

% Intranetwork SVR
for i = 1:size(intranetwork_connection_types,2)
    for j = 1:size(behavs_of_interest1,2)
        fprintf('Starting SVR: %s %s\n', intranetwork_connection_types{i}, Network_1);
        try NIQ_full_SVR_Leave_n_Out(behavs_of_interest1{j},intranetwork_connection_types{i},Network_1);
        catch
            continue
        end
    end
end
end

%{
% Hemispherical
for n1 = 1:size(networks,2)
    if (mod(n1,3) == 0)
        continue
    end
Network_1 = networks{n1};

% Intranetwork SVR
for i = 1:size(intranetwork_connection_types,2)
    for j = 1:size(behavs_of_interest1,2)
        fprintf('Starting SVR: %s %s\n', intranetwork_connection_types{i}, Network_1);
        try NIQ_full_SVR_Leave_n_Out(behavs_of_interest1{j},intranetwork_connection_types{i},Network_1);
        catch
            continue
        end
    end
end
end
%}

% DMN-CO,S,SCO am/ao "
Network_2s = {'Cingulo_Opercular', 'Salience', 'Salience_w_Cingulo_Opercular'};

for n2 = 1:size(Network_2s, 2)
Network_1 = 'Default_Mode';
Network_2 = Network_2s{n2};
%{
% Internetwork SVR
for i = 1:size(internetwork_mutual_connection_types,2)
    for j = 1:size(behavs_of_interest1,2)
        fprintf('Starting SVR: %s %s %s\n', internetwork_mutual_connection_types{i}, Network_1, Network_2);
        try NIQ_full_SVR_Leave_n_Out(behavs_of_interest1{j},internetwork_mutual_connection_types{i},Network_1,Network_2); 
        catch
            continue
        end
    end
end

for i = 1:size(internetwork_oneway_connection_types,2)
    for j = 1:size(behavs_of_interest1,2)
        fprintf('Starting SVR: %s %s %s\n', internetwork_oneway_connection_types{i}, Network_1, Network_2);
        try NIQ_full_SVR_Leave_n_Out(behavs_of_interest1{j},internetwork_oneway_connection_types{i},Network_1,Network_2); 
        catch
            continue
        end
    end
end
%}
for i = 1:size(internetwork_oneway_connection_types,2)
    for j = 1:size(behavs_of_interest1,2)
        fprintf('Starting SVR: %s %s %s\n', internetwork_oneway_connection_types{i}, Network_2, Network_1);
        try NIQ_full_SVR_Leave_n_Out(behavs_of_interest1{j},internetwork_oneway_connection_types{i},Network_2,Network_1); 
        catch
            continue
        end
    end
end

end
%{
% DMN-SCO Interact aoXY_wY
Network_1 = 'Default_Mode';
Network_2 = 'Salience_w_Cingulo_Opercular';

% Internetwork SVR
for j = 1:size(behavs_of_interest2,2)
    fprintf('Starting SVR: %s %s %s\n', internetwork_oneway_connection_types{3}, Network_1, Network_2);
    try NIQ_full_SVR_Leave_n_Out_Controls(behavs_of_interest2{j},internetwork_oneway_connection_types{3},Network_1,Network_2);
    catch
        continue
    end
end
%}
%}
