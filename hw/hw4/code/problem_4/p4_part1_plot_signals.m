%% Problem 4 Part (1): Plot u(t) and y(t) vs t
clear; close all; clc;

% Load data (adjust filename as needed)
load('data_1lm2.mat');   % should define t, u, y

figure;
plot(t, u, 'LineWidth', 1); hold on;
plot(t, y, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Pressure');
legend({'u(t) airway opening', 'y(t) alveolar'}, 'Location', 'best');
title('Problem 4 Part (1): Input and Output vs Time');
grid on;