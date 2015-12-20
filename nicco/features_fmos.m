function [subjs_used_upper, feature_set_upper, subjs_used_lower, feature_set_lower] = features_fmos(conn_type, val_type, percent,Network_1,Network_2)

toolboxRoot='/space/raid6/data/rissman/Nicco/MATLAB_PATH/';
addpath(genpath(toolboxRoot));
toolboxRoot='/space/raid6/data/rissman/Nicco/NIQ/Scripts';
addpath(genpath(toolboxRoot));

switch nargin
    case 4
        fprintf('Creating feature_set_upper...\n');
        [subjs_used_upper, feature_set_upper] = features_fmos_upper(conn_type, val_type, percent, Network_1, Network_2);
        fprintf('Creating feature_set_lower...\n');
        [subjs_used_lower, feature_set_lower] = features_fmos_lower(conn_type, val_type, percent, Network_1, Network_2);
    case 3
        fprintf('Creating feature_set_upper...\n');
        [subjs_used_upper, feature_set_upper] = features_fmos_upper(conn_type, val_type, percent, Network_1);
        fprintf('Creating feature_set_lower...\n');
        [subjs_used_lower, feature_set_lower] = features_fmos_lower(conn_type, val_type, percent, Network_1);
    otherwise
        fprintf('Invalid # of arguments.\n');
        feature_set_upper = struct;
        feature_set_lower = struct;
        subjs_used_lower = struct;
        subjs_used_upper = struct;
end