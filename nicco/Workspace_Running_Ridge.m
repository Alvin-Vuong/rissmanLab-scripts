toolboxRoot=['/space/raid6/data/rissman/Nicco/MATLAB_PATH/'];
addpath(genpath(toolboxRoot))
toolboxRoot=['/space/raid6/data/rissman/Nicco/NIQ/Scripts'];
addpath(genpath(toolboxRoot))

internetwork_connection_types={'amXY_wX_wY', 'amXY_wX', 'amXY_wY', 'amXY', 'aoXY_wX_wY', 'aoXY_wX', 'aoXY_wY', 'aoXY'};
intranetwork_connection_types={'wX'};

behavs_of_interest={'PMAT24_A_CR'};
Network_1='Default_Mode';
Network_2='Cingulo_Opercular';

%for c=1:size(intranetwork_connection_types,2)
%    for b=1:size(behavs_of_interest,2)
%        try NIQ_full(behavs_of_interest{b},intranetwork_connection_types{c},Network_1); 
%        catch        
%        try NIQ_full(behavs_of_interest{b},intranetwork_connection_types{c},Network_2); 
%        catch
%            continue
%        end
%        end
%    end
%end

for c=2:size(internetwork_connection_types,2)
    for b=1:size(behavs_of_interest,2)
        try NIQ_full_Ridge(behavs_of_interest{b},internetwork_connection_types{c},Network_1,Network_2); 
        catch
            continue
        end
    end
end