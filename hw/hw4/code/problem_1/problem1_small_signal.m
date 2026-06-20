% problem1_small_signal.m
% Compare nonlinear system to its linearization near (0,0)

clear; clc;

% Define fig path
figdir = '/Users/mlwu/Documents/Academia/USC/BME/511/hw/hw4/code/figs';
if ~exist(figdir, 'dir')
    mkdir(figdir);
end

% Nonlinear system
f = @(t,z)[z(1) - 2*z(1)*z(2); ...
           2*z(1)*z(2) - z(2)];

% Linearized system at (0,0): dx/dt = x, dy/dt = -y
g = @(t,z)[z(1); -z(2)];

% Small initial condition
z0 = [0.02; 0.02];
tspan = [0 5];

% Nonlinear solution
[tn, zn] = ode45(f, tspan, z0);

% Linear solution (analytical)
tl = linspace(0,5,200);
x_lin = z0(1)*exp(tl);
y_lin = z0(2)*exp(-tl);

figure;
subplot(2,1,1);
plot(tn, zn(:,1), 'b-', 'LineWidth', 1.2); hold on;
plot(tl, x_lin, 'k--', 'LineWidth', 1.0);
ylabel('x(t)');
% title('Small-signal behavior near (0,0)');
legend('nonlinear','linearized','Location','best');
grid on;

subplot(2,1,2);
plot(tn, zn(:,2), 'r-', 'LineWidth', 1.2); hold on;
plot(tl, y_lin, 'k--', 'LineWidth', 1.0);
xlabel('Time (s)');
ylabel('y(t)');
legend('nonlinear','linearized','Location','best');
grid on;

saveas(gcf, fullfile(figdir, 'problem1_smallsignal.png'));
saveas(gcf, fullfile(figdir, 'problem1_smallsignal.fig'));