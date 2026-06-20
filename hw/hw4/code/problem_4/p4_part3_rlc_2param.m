%% Problem 4 Part (3): 2-param model with theta1 = LC, theta2 = RC
clear; close all; clc;
global t u y ypred

% Load data
load('data_1lm2.mat');   % t, u, y

opts = optimset('fminsearch');
opts.Display = 'off';
opts.MaxIter = 2000;
opts.MaxFunEvals = 4000;

nRuns = 20;

theta1_est = zeros(nRuns,1);  % LC
theta2_est = zeros(nRuns,1);  % RC
NMSEmin    = zeros(nRuns,1);
theta1_0   = zeros(nRuns,1);
theta2_0   = zeros(nRuns,1);

% Choose broad starting ranges for composites
th1_range = [1e-4  0.2];    % plausible LC range
th2_range = [0.001  20];    % plausible RC range

for k = 1:nRuns
    % Random initial guesses
    th1_0 = th1_range(1) + diff(th1_range)*rand;
    th2_0 = th2_range(1) + diff(th2_range)*rand;

    theta1_0(k) = th1_0;
    theta2_0(k) = th2_0;

    params0 = [th1_0 th2_0];

    % Simplex optimization
    [params_opt, fval] = fminsearch(@fn_rlc_NMSE_2p, params0, opts);

    theta1_est(k) = params_opt(1);
    theta2_est(k) = params_opt(2);
    NMSEmin(k)    = fval;
end

% Compute summary stats
mean_th1 = mean(theta1_est); std_th1 = std(theta1_est);
mean_th2 = mean(theta2_est); std_th2 = std(theta2_est);
COV_th1  = 100*std_th1/mean_th1;
COV_th2  = 100*std_th2/mean_th2;
mean_N   = mean(NMSEmin);    std_N   = std(NMSEmin);
COV_N    = 100*std_N/mean_N;

fprintf('2-param model (theta1=LC, theta2=RC), %d runs\n', nRuns);
fprintf('theta1: mean = %.4g, std = %.4g, COV = %.2f%%\n', ...
    mean_th1, std_th1, COV_th1);
fprintf('theta2: mean = %.4g, std = %.4g, COV = %.2f%%\n', ...
    mean_th2, std_th2, COV_th2);
fprintf('NMSEmin: mean = %.4g, std = %.4g, COV = %.2f%%\n', ...
    mean_N, std_N, COV_N);

% Table of runs
Run = (1:nRuns).';
T2 = table(Run, theta1_0, theta2_0, theta1_est, theta2_est, NMSEmin, ...
    'VariableNames', {'Run','theta1_0','theta2_0','theta1_final','theta2_final','NMSEmin'});

writetable(T2, 'p4_part3_rlc_2param_results.csv');

% Plot best run prediction vs measured data
[~, bestIdx] = min(NMSEmin);
bestParams   = [theta1_est(bestIdx) theta2_est(bestIdx)];
fn_rlc_NMSE_2p(bestParams);   % updates ypred

figure;
plot(t, y, 'LineWidth', 1); hold on;
plot(t, ypred, '--', 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Alveolar pressure');
legend({'Measured y(t)', 'Predicted y_{2p}(t)'}, 'Location', 'best');
title(sprintf('Problem 4 Part (3): Best 2-param fit (Run %d)', bestIdx));
grid on;