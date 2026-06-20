%% projB_paths.m
%   Path config

% Data directory
data_path = '/Users/mlwu/Documents/Academia/USC/BME/511/project/Bme511F25_ProjectB/data';

% Figures directory
fig_path  = '/Users/mlwu/Documents/Academia/USC/BME/511/project/Bme511F25_ProjectB/data/figs';

% Ensure the directories exist
if ~exist(data_path, 'dir')
    error('Data directory does not exist: %s', data_path);
end

if ~exist(fig_path, 'dir')
    mkdir(fig_path);
end

% Add project root to MATLAB path
proj_root = fileparts(data_path);
addpath(genpath(proj_root));