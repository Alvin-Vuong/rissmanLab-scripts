% Set paths and dependencies
toolboxRoot=['/space/raid6/data/rissman/Nicco/MATLAB_PATH/'];
addpath(genpath(toolboxRoot))
toolboxRoot=['/space/raid6/data/rissman/Nicco/NIQ/Scripts'];
addpath(genpath(toolboxRoot))

% Declare types and vars
internetwork_connection_types={'amXY_wX_wY', 'amXY_wX', 'amXY_wY', 'amXY', 'aoXY_wX_wY', 'aoXY_wX', 'aoXY_wY', 'aoXY'};
intranetwork_connection_types={'wX'};

behavs_of_interest={'PMAT24_A_CR'};
Network_1='Default_Mode';
Network_2='Cingulo_Opercular';

% Ridge
for c=2:size(internetwork_connection_types,2)
    for b=1:size(behavs_of_interest,2)
        fprintf('Starting Ridge: %s\n', internetwork_connection_types{c});
        try NIQ_full_Ridge(behavs_of_interest{b},internetwork_connection_types{c},Network_1,Network_2); 
        catch
            continue
        end
    end
end

% SVR
for c=2:size(internetwork_connection_types,2)
    for b=1:size(behavs_of_interest,2)
        fprintf('Starting SVR: %s\n', internetwork_connection_types{c});
        try NIQ_full_SVR(behavs_of_interest{b},internetwork_connection_types{c},Network_1,Network_2); 
        catch
            continue
        end
    end
end

% Lasso
for c=2:size(internetwork_connection_types,2)
    for b=1:size(behavs_of_interest,2)
        fprintf('Starting Lasso: %s\n', internetwork_connection_types{c});
        try NIQ_full_Lasso(behavs_of_interest{b},internetwork_connection_types{c},Network_1,Network_2); 
        catch
            continue
        end
    end
end