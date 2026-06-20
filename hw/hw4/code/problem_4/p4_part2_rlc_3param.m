%% Problem 4 Part (2): 3-param RLC fit with simplex (fminsearch)
clear; close all; clc;
global t u y ypred

% Load data
load('data_1lm2.mat');   % t, u, y

% Optimization options
opts = optimset('fminsearch');
opts.Display = 'off';
opts.MaxIter = 2000;
opts.MaxFunEvals = 4000;

nRuns = 20;

% Preallocate
R_est   = zeros(nRuns,1);
L_est   = zeros(nRuns,1);
C_est   = zeros(nRuns,1);
NMSEmin = zeros(nRuns,1);
startR  = zeros(nRuns,1);
startL  = zeros(nRuns,1);
startC  = zeros(nRuns,1);

% Choose broad starting ranges (tunable)
R_range = [0.1  20];     % example: cmH2O·s/L
L_range = [1e-3  0.2];   % example: cmH2O·s^2/L
C_range = [0.01  1.0];   % example: L/cmH2O

for k = 1:nRuns
    % Random initial guesses
    R0 = R_range(1) + diff(R_range)*rand;
    L0 = L_range(1) + diff(L_range)*rand;
    C0 = C_range(1) + diff(C_range)*rand;

    startR(k) = R0;
    startL(k) = L0;
    startC(k) = C0;

    params0 = [R0 L0 C0];

    % Simplex optimization
    [params_opt, fval] = fminsearch(@fn_rlc_NMSE, params0, opts);

    R_est(k)   = params_opt(1);
    L_est(k)   = params_opt(2);
    C_est(k)   = params_opt(3);
    NMSEmin(k) = fval;
end

% Compute mean, std, and COV (percent)
mean_R = mean(R_est);    std_R = std(R_est);    COV_R = 100*std_R/mean_R;
mean_L = mean(L_est);    std_L = std(L_est);    COV_L = 100*std_L/mean_L;
mean_C = mean(C_est);    std_C = std(C_est);    COV_C = 100*std_C/mean_C;
mean_N = mean(NMSEmin);  std_N = std(NMSEmin);  COV_N = 100*std_N/mean_N;

% Display summary in Command Window
fprintf('3-param model (R, L, C), %d runs\n', nRuns);
fprintf('R: mean = %.4g, std = %.4g, COV = %.2f%%\n', mean_R, std_R, COV_R);
fprintf('L: mean = %.4g, std = %.4g, COV = %.2f%%\n', mean_L, std_L, COV_L);
fprintf('C: mean = %.4g, std = %.4g, COV = %.2f%%\n', mean_C, std_C, COV_C);
fprintf('NMSEmin: mean = %.4g, std = %.4g, COV = %.2f%%\n', mean_N, std_N, COV_N);

% Create table of all runs
Run = (1:nRuns).';
T = table(Run, startR, startL, startC, R_est, L_est, C_est, NMSEmin, ...
    'VariableNames', {'Run','R0','L0','C0','R_final','L_final','C_final','NMSEmin'});

% Optional: write table to file
writetable(T, 'p4_part2_rlc_3param_results.csv');

% Choose one run to plot model vs data (e.g., best NMSE)
[~, bestIdx] = min(NMSEmin);
bestParams   = [R_est(bestIdx) L_est(bestIdx) C_est(bestIdx)];

% Generate prediction using best parameters
fn_rlc_NMSE(bestParams);  % updates global ypred

figure;
plot(t, y, 'LineWidth', 1); hold on;
plot(t, ypred, '--', 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Alveolar pressure');
legend({'Measured y(t)', 'Predicted y_{model}(t)'}, 'Location', 'best');
title(sprintf('Problem 4 Part (2): Best 3-param fit (Run %d)', bestIdx));
grid on;