% projB_run_simulink.m
% Run Simulink model for Part IV using mean parameters from Part III.

clear; clc;
run('projB_paths.m');

% Load data
load(fullfile(data_path, 'xdata.mat'));
load(fullfile(data_path, 'projB_param_mean.mat'));
load(fullfile(data_path, 'projB_tf_fit.mat'));

t = t(:);
F = F(:);

xpred = xpred_mean;

% Prepare input for From Workspace block
simF = [t, F];

% Parameters
k   = param_mean(1);
k1  = param_mean(2);
b   = param_mean(3);
m   = 0.0001;          % kg

% Assign to base workspace for Simulink
assignin('base', 'simF', simF);
assignin('base', 'k', k);
assignin('base', 'k1', k1);
assignin('base', 'b', b);
assignin('base', 'm', m);

% Run Simulink model
simOut = sim('ProjB_SimulinkModel', 'StopTime', '10');

% Extract Simulink output xSim (To Workspace block)
xSim = simOut.get('xSim');
xSim = xSim(:);

% Save
save(fullfile(data_path, 'projB_sim_output.mat'), 'xSim');
save(fullfile(data_path, 'projB_param_mean.mat'), 'param_mean');
save(fullfile(data_path, 'projB_tf_fit.mat'), 'xpred_mean');
