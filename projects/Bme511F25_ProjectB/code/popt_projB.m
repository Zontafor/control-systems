% `popt_projB.m`
% popt_projB  Parameter estimation for viscoelastic tissue model (Project B)
%   Estimates viscoelastic parameters (k, k1, b) by minimizing the
%   normalized mean squared error (NMSE) between model-predicted
%   displacement x_pred(t) and measured displacement x(t).
%
%   Required data file:
%       xdata.mat  (must contain: t (s), F (mN), x (µm))
%
%   Output:
%       * Table of initial and final parameters and NMSE for 20 runs.
%       * Summary statistics (mean, std, COV) for each parameter.
%       * Plot of measured x(t) vs predicted x_pred(t) using mean parameters.

clear; clc;

global t u x xpred m

%% Define paths
data_path = '/Users/mlwu/Documents/Academia/USC/BME/511/project/Bme511F25_ProjectB/data';
fig_path  = '/Users/mlwu/Documents/Academia/USC/BME/511/project/Bme511F25_ProjectB/data/figs';

% Ensure paths exist
if ~exist(data_path, 'dir')
    error('Data path does not exist: %s', data_path);
end

if ~exist(fig_path, 'dir')
    mkdir(fig_path);
end

%% Load data
S = load(fullfile(data_path, 'xdata.mat'));

% % Extract data fields explicitly
% t = S.t(:);
% F = S.F(:);
% x = S.x(:);

%% Helper to grab a field if it exists
getField = @(names) ...
    getfield(S, names{find(isfield(S, names), 1, 'first')}); %#ok<GFLD>

%% Candidate names for time, force, displacement
timeNames  = {'t','time','Time','T'};
forceNames = {'F','force','Force','u','U'};
dispNames  = {'x','xdata','x_data','x_meas','xmeas','X'};

%% Time vector
if any(isfield(S, timeNames))
    t = getField(timeNames);
else
    error('popt_projB:NoTimeVar', ...
          'Could not find a time vector in xdata.mat. Expected one of: %s', ...
          strjoin(timeNames, ', '));
end

%% Input force
if any(isfield(S, forceNames))
    F = getField(forceNames);
else
    error('popt_projB:NoForceVar', ...
          'Could not find a force vector in xdata.mat. Expected one of: %s', ...
          strjoin(forceNames, ', '));
end

%% Measured displacement
if any(isfield(S, dispNames))
    x = getField(dispNames);
else
    error('popt_projB:NoDispVar', ...
          'Could not find a displacement vector in xdata.mat. Expected one of: %s', ...
          strjoin(dispNames, ', '));
end

%% Force all signals to column vectors
t = t(:);
F = F(:);
x = x(:);

%% Enforce a common length
N = min([length(t), length(F), length(x)]);
if N < 2
    error('popt_projB:TooFewSamples', ...
          ['After attempting to align t, F, and x, there are only N = %d ' ...
           'samples. Please check the contents of xdata.mat (use "whos -file xdata.mat") ' ...
           'and ensure that time, force, and displacement vectors are defined.'], N);
end

if any([length(t), length(F), length(x)] ~= N)
    warning('popt_projB:LengthMismatch', ...
            'Truncating t, F, and x to common length N = %d samples.', N);
    t = t(1:N);
    F = F(1:N);
    x = x(1:N);
end

u = F;          % input force in mN
m = 0.0001;     % kg, given in project statement

%% Optimization settings
n_runs = 20;

param_init_all  = zeros(n_runs, 3);
param_final_all = zeros(n_runs, 3);
NMSE_all        = zeros(n_runs, 1);

options = optimset('PlotFcns','optimplotfval', ...
                   'TolX',1e-7, ...
                   'MaxFunEvals',2e3, ...
                   'Display','iter');

rng(1);  % reproducible random initial guesses

% Parameter ranges (order of 0.1 as suggested)
k_range  = [0.01, 0.2];
k1_range = [0.01, 0.2];
b_range  = [0.01, 0.2];

for run = 1:n_runs

    % Random initial guesses in specified ranges
    k0  = k_range(1)  + (k_range(2)  - k_range(1))*rand;
    k10 = k1_range(1) + (k1_range(2) - k1_range(1))*rand;
    b0  = b_range(1)  + (b_range(2)  - b_range(1))*rand;

    param_init = [k0, k10, b0]';

    param_init_all(run, :) = param_init';

    % Perform optimization
    [param_opt, NMSE_opt] = fminsearch(@fn_projB, param_init, options);

    param_final_all(run, :) = param_opt';
    NMSE_all(run)           = NMSE_opt;

    fprintf('Run %2d: NMSE = %.4e, k = %.4f, k1 = %.4f, b = %.4f\n', ...
            run, NMSE_opt, param_opt(1), param_opt(2), param_opt(3));

end

%% Summary statistics across runs
param_mean = mean(param_final_all, 1);
param_std  = std(param_final_all, 0, 1);
param_cov  = 100 * param_std ./ abs(param_mean);  % percent

fprintf('\nSummary of parameter estimates across %d runs:\n', n_runs);
fprintf('Parameter   Mean       Std        COV(%%)\n');
fprintf('k        %10.4g %10.4g %10.3f\n', param_mean(1), param_std(1), param_cov(1));
fprintf('k1       %10.4g %10.4g %10.3f\n', param_mean(2), param_std(2), param_cov(2));
fprintf('b        %10.4g %10.4g %10.3f\n', param_mean(3), param_std(3), param_cov(3));

% Run-by-run table
run_idx = (1:n_runs)';
T = table(run_idx, ...
          param_init_all(:,1), param_init_all(:,2), param_init_all(:,3), ...
          param_final_all(:,1), param_final_all(:,2), param_final_all(:,3), ...
          NMSE_all, ...
          'VariableNames', {'Run', ...
                            'k_init','k1_init','b_init', ...
                            'k_final','k1_final','b_final', ...
                            'NMSE_min'});

disp(' ');
disp('Run-by-run optimization results:');
disp(T);
save(fullfile(data_path, 'projB_param_mean.mat'), 'param_mean');

% Convert arrays to double for safety
param_init_all  = double(param_init_all);
param_final_all = double(param_final_all);
NMSE_all        = double(NMSE_all(:));   % ensure column vector

% Compute summary statistics
param_mean = mean(param_final_all, 1);
param_std  = std(param_final_all, 0, 1);
param_cov  = 100 * (param_std ./ abs(param_mean));  % percentage

% Create sparse matrix version (optional but requested)
results_sparse = sparse([param_init_all, param_final_all, NMSE_all]);

% Create a structured results variable
projB_results = struct();
projB_results.param_init_all  = param_init_all;
projB_results.param_final_all = param_final_all;
projB_results.NMSE_all        = NMSE_all;
projB_results.param_mean      = param_mean;
projB_results.param_std       = param_std;
projB_results.param_cov       = param_cov;
projB_results.results_sparse  = results_sparse;
projB_results.timestamp       = datestr(now);
projB_results.description     = '20-run simplex optimization results for Project B (k, k1, b)';

% Save both standard and sparse formats
save(fullfile(data_path, 'projB_param_runs.mat'), ...
     'projB_results', 'param_init_all', 'param_final_all', ...
     'NMSE_all', 'param_mean', 'param_std', 'param_cov', ...
     'results_sparse');
disp('Saved optimization results to: projB_param_runs.mat');

%% Use mean parameters to generate prediction and plot x(t) vs x_pred(t)
params_mean = param_mean(:);

fn_projB(params_mean);    % populates global xpred
xpred_mean = xpred;

figure;
plot(t, x, 'b', 'LineWidth', 1.2); hold on;               % measured = blue
plot(t, xpred_mean, 'r--', 'LineWidth', 1.5);             % predicted = red dashed
xlabel('Time (s)');
ylabel('Displacement x (\mum)');
legend('Measured x(t)', ...
       'Predicted x_{pred}(t) (mean params)', ...
       'Location', 'Best');
grid on;

saveas(gcf, fullfile(fig_path, 'ProjB_x_measured_vs_predicted.png'));
save(fullfile(data_path, 'projB_tf_fit.mat'), 'xpred_mean');


%% Plot measured F(t) and measured x(t) for reference
t = t(:);
F = F(:);
x = x(:);

figure;

subplot(2,1,1);
plot(t, F, 'k', 'LineWidth', 1.2);                        % stimulus = black
xlabel('Time (s)');
ylabel('F (mN)');
title('Creep Stimulus: Force Input F(t)');
grid on;

subplot(2,1,2);
plot(t, x, 'b', 'LineWidth', 1.2);                        % measured x(t) = blue
xlabel('Time (s)');
ylabel('x (\mum)');
title('Measured Creep Response x(t)');
grid on;

saveas(gcf, fullfile(fig_path, 'ProjB_F_and_x_measured.png'));

%% Optional LaTeX tables
% 
% T
% 
% % Create a LaTeX table for the report:
% fid = fopen('projB_param_table.tex','w');
% fprintf(fid, '\\begin{table}[h]\n\\centering\n');
% fprintf(fid, '\\caption{Optimization results for viscoelastic parameters (k, k_1, b).}\n');
% fprintf(fid, '\\label{tab:projB_param_runs}\n');
% fprintf(fid, '\\begin{tabular}{c|ccc|ccc|c}\n');
% fprintf(fid, '\\hline\n');
% fprintf(fid, 'Run & k_{init} & k_{1,init} & b_{init} & k_{final} & k_{1,final} & b_{final} & NMSE_{min}\\\\\\hline\n');
% for i = 1:height(T)
%     fprintf(fid, '%2d & %.4g & %.4g & %.4g & %.4g & %.4g & %.4g & %.4g \\\\\n', ...
%         T.Run(i), ...
%         T.k_init(i), T.k1_init(i), T.b_init(i), ...
%         T.k_final(i), T.k1_final(i), T.b_final(i), ...
%         T.NMSE_min(i));
% end
% fprintf(fid, '\\hline\n\\end{tabular}\n\\end{table}\n');
% fclose(fid);
% 
% fid = fopen('projB_param_stats.tex','w');
% fprintf(fid, '\\begin{table}[h]\n\\centering\n');
% fprintf(fid, '\\caption{Summary statistics of estimated viscoelastic parameters over 20 runs.}\n');
% fprintf(fid, '\\label{tab:projB_param_stats}\n');
% fprintf(fid, '\\begin{tabular}{c|ccc}\n');
% fprintf(fid, '\\hline\n');
% fprintf(fid, 'Parameter & Mean & Std. dev. & COV (\\%%)\\\\\\hline\n');
% fprintf(fid, 'k   & %.4g & %.4g & %.3f\\\\\n', param_mean(1), param_std(1), param_cov(1));
% fprintf(fid, 'k_1 & %.4g & %.4g & %.3f\\\\\n', param_mean(2), param_std(2), param_cov(2));
% fprintf(fid, 'b   & %.4g & %.4g & %.3f\\\\\n', param_mean(3), param_std(3), param_cov(3));
% fprintf(fid, '\\hline\n\\end{tabular}\n\\end{table}\n');
% fclose(fid);