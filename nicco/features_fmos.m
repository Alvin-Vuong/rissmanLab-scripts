function [feature_set_upper, feature_set_lower] = features_fmos(type, percent,Network_1,Network_2)

toolboxRoot='/space/raid6/data/rissman/Nicco/MATLAB_PATH/';
addpath(genpath(toolboxRoot));
toolboxRoot='/space/raid6/data/rissman/Nicco/NIQ/Scripts';
addpath(genpath(toolboxRoot));

switch nargin
    case 4
        fprintf('Creating feature_set_upper...\n');
        feature_set_upper = features_fmos_upper(type, percent, Network_1, Network_2);
        fprintf('Creating feature_set_lower...\n');
        feature_set_lower = features_fmos_lower(type, percent, Network_1, Network_2);
    case 3
        fprintf('Creating feature_set_upper...\n');
        feature_set_upper = features_fmos_upper(type, percent, Network_1);
        fprintf('Creating feature_set_lower...\n');
        feature_set_lower = features_fmos_lower(type, percent, Network_1);
    otherwise
        fprintf('Invalid # of arguments.\n');
        feature_set_upper = struct;
        feature_set_lower = struct;
end