%% run with `plot_hw4_data`
clear; close all; clc;

% define fig path
figpath = '/Users/mlwu/Documents/Academia/USC/BME/511/hw/hw4/code/figs';
if ~exist(figpath, 'dir')
    mkdir(figpath);
end

% load data
load('llm_data2.mat', 't', 'u', 'y');   % ensure variables exist

t = t(:);
u = u(:);
y = y(:);

% plot
figure; hold on; grid on;

plot(t, u, 'b-', 'LineWidth', 1.0);
plot(t, y, 'k-', 'LineWidth', 1.0);

xlabel('Time (s)', 'FontSize', 12);
ylabel('Pressure (u,y)', 'FontSize', 12);
% title('Problem 4(a): Airway Opening Pressure u(t) and Alveolar Pressure y(t)');

legend('u(t) — input pressure','y(t) — alveolar pressure','Location','Best');
set(gca, 'FontSize', 12);

saveas(gcf, fullfile(figpath, 'hw4_problem4_data_u_y.png'));