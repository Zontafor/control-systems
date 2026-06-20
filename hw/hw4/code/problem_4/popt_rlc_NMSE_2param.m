function results2 = popt_rlc_NMSE_2param()
% popt_rlc_NMSE_2param  Simplex estimation of 2-parameter RLC model.
%   Reduces R,L,C to two parameters:
%       theta1 = L*C, theta2 = R*C
%   Runs 20 optimizations from random initial guesses, computes
%   mean / std / COV of theta1, theta2, and plots measured vs predicted
%   y(t) for the best run.
%
%   Usage:
%       >> results2 = popt_rlc_NMSE_2param;

    %% set up data and globals
    clear global t u y ypred
    global t u y ypred

    % define fig path
    figpath = '/Users/mlwu/Documents/Academia/USC/BME/511/hw/hw4/code/figs';
    if ~exist(figpath, 'dir')
        mkdir(figpath);
    end

    % load dataset
    load('llm_data2.mat', 't', 'u', 'y');

    t = t(:);
    u = u(:);
    y = y(:);

    %% optimization settings
    nRuns = 20;
    rng(2);    % different seed from 3-parameter case

    % broad ranges for theta1 = L*C and theta2 = R*C
    th1_min = 0.01;  th1_max = 20;    % units: (cmH2O·s^2/L)*(L/cmH2O)
    th2_min = 0.1;   th2_max = 150;   % units: (cmH2O·s/L)*(L/cmH2O)

    th0_all    = zeros(nRuns, 2);     % initial guesses
    th_hat_all = zeros(nRuns, 2);     % final estimates
    NMSE_min   = zeros(nRuns, 1);     % minimum NMSE

    opts = optimset('Display', 'off', ...
                    'MaxFunEvals', 1e4, ...
                    'MaxIter',     1e4);

    %% run simplex optimization nRuns times
    for k = 1:nRuns
        % random initial guess within specified ranges
        th1_0 = th1_min + (th1_max - th1_min)*rand;
        th2_0 = th2_min + (th2_max - th2_min)*rand;
        th0   = [th1_0, th2_0];

        th0_all(k, :) = th0;

        % simplex optimization
        [th_hat, fval] = fminsearch(@fn_rlc_NMSE_2param, th0, opts);

        th_hat_all(k, :) = th_hat;
        NMSE_min(k)      = fval;
    end

    %% classify good vs bad runs (same idea as 3-parameter case)
    bestNMSE  = min(NMSE_min);
    tol       = 0.05;     % NMSE window around best value
    good_idx  = abs(NMSE_min - bestNMSE) <= tol;

    theta_good = th_hat_all(good_idx, :);
    NMSE_good  = NMSE_min(good_idx);

    % summary over good runs
    mean_th = mean(theta_good, 1);
    std_th  = std(theta_good, 0, 1);
    COV_th  = 100 * std_th ./ abs(mean_th);

    results2 = struct();
    results2.th0_all    = th0_all;
    results2.th_hat_all = th_hat_all;
    results2.NMSE_min   = NMSE_min;
    results2.good_idx   = good_idx;
    results2.theta_good = theta_good;
    results2.NMSE_good  = NMSE_good;
    results2.mean_th    = mean_th;
    results2.std_th     = std_th;
    results2.COV_th     = COV_th;

    %% print run table
    fprintf('\nRun  th1_0   th2_0   th1_hat  th2_hat  NMSE_min\n');
    fprintf('-------------------------------------------------\n');
    for k = 1:nRuns
        fprintf('%2d  %7.4f %7.4f  %7.4f %7.4f  %8.5f\n', ...
            k, th0_all(k,1), th0_all(k,2), ...
               th_hat_all(k,1), th_hat_all(k,2), NMSE_min(k));
    end

    fprintf('\nGood runs: %d out of %d (NMSE within %.3f of best).\n', ...
            sum(good_idx), numel(NMSE_min), tol);
    fprintf('Mean theta1, theta2 (good runs):  %.4f, %.4f\n', mean_th);
    fprintf('Std  theta1, theta2 (good runs):  %.4f, %.4f\n', std_th);
    fprintf('COV  theta1, theta2 (good runs):  %.2f%%, %.2f%%\n\n', COV_th);

    %% plot measured vs predicted y(t) for best run
    [~, idxBest] = min(NMSE_min);
    th_best      = th_hat_all(idxBest, :);

    % compute best-fit prediction
    fn_rlc_NMSE_2param(th_best);

    figure; hold on; grid on;
    plot(t, y, 'k-', 'LineWidth', 1.0);
    plot(t, ypred, 'r--', 'LineWidth', 1.0);
    xlabel('Time (s)');
    ylabel('Alveolar pressure y(t)');
    legend('Measured y', 'Predicted y', 'Location', 'Best');
    % title(sprintf('2-parameter model: best run %d, NMSE = %.4f', ...
    %               idxBest, NMSE_min(idxBest)));
    saveas(gcf, fullfile(figpath, 'hw4_rlc_2param_best.png'));
end