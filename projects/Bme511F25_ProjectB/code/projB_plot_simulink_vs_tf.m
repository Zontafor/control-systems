% projB_plot_simulink_vs_tf.m
% Compare Simulink ODE model and TF prediction

clear;
clc;
run('projB_paths.m');

load(fullfile(data_path, 'xdata.mat'));            % t
load(fullfile(data_path, 'projB_tf_fit.mat'));     % xpred_mean
% load(fullfile(data_path, 'projB_sim_output.mat')); % xSim

t = t(:);
xpred_mean = xpred_mean(:);
% xSim = xSim(:);

figure;
plot(t, xpred_mean, '--', 'LineWidth', 1.5); hold on;
plot(t, xSim, 'k', 'LineWidth', 1.0);
xlabel('Time (s)');
ylabel('Displacement x (\mum)');
legend('Transfer-function prediction', 'Simulink model', 'Location', 'Best');
title('Part IV: Comparison of Simulink and Transfer-Function Predictions');
grid on;

saveas(gcf, fullfile(fig_path, 'ProjB_Simulink_vs_TF.png'));