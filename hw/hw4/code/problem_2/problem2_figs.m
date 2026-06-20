% problem2_figs.m
%   Fig 1C: spike train, stimulus at t = 4 s (new spikes at 18, 34 s)
%   Fig 1D: spike train, stimulus at t = 12 s (new spikes at 14, 30 s)
%   Fig 1E (Part 1): phase circle with (phi_1, theta_1)
%   Fig 1E (Part 2): phase circle with (phi_2, theta_2)

clear; close all; clc;

% Define fig path
figdir = '/Users/mlwu/Documents/Academia/USC/BME/511/hw/hw4/code/figs';
if ~exist(figdir,'dir')
    mkdir(figdir);
end

%% Common settings for spike trains
tmin = -2;
tmax = 40;
xticks_vec = tmin:2:tmax;
ytop = 1.1;

%% Fig 1C: spike train, stimulus at t = 4 s
t_stim1        = 4;
t_spikes_new_1 = [18 34];   % next two spikes after perturbation

figure(1); clf;

% spike at t = 0 s
stem(0, 1, ...
    'Color','k', ...
    'LineWidth',1.2, ...
    'Marker','^', ...
    'MarkerFaceColor','k', ...
    'MarkerSize',6);
hold on;

% new spikes (dark arrows)
stem(t_spikes_new_1, ones(size(t_spikes_new_1)), ...
    'Color','k', ...
    'LineWidth',1.4, ...
    'Marker','^', ...
    'MarkerFaceColor','k', ...
    'MarkerSize',7);

% stimulus arrow (grey, at t = 4 s)
plot([t_stim1 t_stim1], [0 ytop*0.95], ...
     'Color',[0.6 0.6 0.6], 'LineWidth',1.0);
plot(t_stim1, ytop*0.95, '^', ...
     'MarkerFaceColor',[0.6 0.6 0.6], ...
     'MarkerEdgeColor',[0.6 0.6 0.6], ...
     'MarkerSize',6);

xlabel('Time (sec)');
set(gca,'XLim',[tmin tmax], ...
        'YLim',[0 ytop], ...
        'XTick',xticks_vec, ...
        'YTick',[], ...
        'Box','on');

saveas(gcf, fullfile(figdir,'problem2_fig1C_spikes.png'));
saveas(gcf, fullfile(figdir,'problem2_fig1C_spikes.fig'));

%% Fig 1D: spike train, stimulus at t = 12 s
t_stim2        = 12;
t_spikes_new_2 = [14 30];

figure(2); clf;

% spike at t = 0 s
stem(0, 1, ...
    'Color','k', ...
    'LineWidth',1.2, ...
    'Marker','^', ...
    'MarkerFaceColor','k', ...
    'MarkerSize',6);
hold on;

% new spikes (dark arrows)
stem(t_spikes_new_2, ones(size(t_spikes_new_2)), ...
    'Color','k', ...
    'LineWidth',1.4, ...
    'Marker','^', ...
    'MarkerFaceColor','k', ...
    'MarkerSize',7);

% stimulus arrow (grey, at t = 12 s)
plot([t_stim2 t_stim2], [0 ytop*0.95], ...
     'Color',[0.6 0.6 0.6], 'LineWidth',1.0);
plot(t_stim2, ytop*0.95, '^', ...
     'MarkerFaceColor',[0.6 0.6 0.6], ...
     'MarkerEdgeColor',[0.6 0.6 0.6], ...
     'MarkerSize',6);

xlabel('Time (sec)');
set(gca,'XLim',[tmin tmax], ...
        'YLim',[0 ytop], ...
        'XTick',xticks_vec, ...
        'YTick',[], ...
        'Box','on');

saveas(gcf, fullfile(figdir,'problem2_fig1D_spikes.png'));
saveas(gcf, fullfile(figdir,'problem2_fig1D_spikes.fig'));

%% Fig 1E (Part 1): phase circle (phi_1, theta_1)
% Part 1: phi_1 = 0.25 rev (pi/2), theta_1 = 0.125 rev (pi/4)
phi_1   = 0.25;
theta_1 = 0.125;
b_mag   = 1.0;

figure(3); clf;
draw_phase_circle(phi_1, theta_1, b_mag, '1');
saveas(gcf, fullfile(figdir,'problem2_fig1E_part1_phase.png'));
saveas(gcf, fullfile(figdir,'problem2_fig1E_part1_phase.fig'));

%% Fig 1E (Part 2): phase circle (phi_2, theta_2)
% Part 2: phi_2 = 0.75 rev (3pi/2), theta_2 = 0.875 rev (7pi/4)
phi_2   = 0.75;
theta_2 = 0.875;

figure(4); clf;
draw_phase_circle(phi_2, theta_2, b_mag, '2');
saveas(gcf, fullfile(figdir,'problem2_fig1E_part2_phase.png'));
saveas(gcf, fullfile(figdir,'problem2_fig1E_part2_phase.fig'));


%% Define local phase-circle template function
function draw_phase_circle(phi, theta, b, idx_str)
% draw_phase_circle
%   phi      old phase (0–1 rev)
%   theta    new phase (0–1 rev)
%   b        stimulus magnitude
%   idx_str  '1' or '2' for labeling (phi_1/theta_1 or phi_2/theta_2)

    hold on; axis equal;

    % crosshairs
    plot([-1.5 1.5],[0 0],'k','LineWidth',1.2);
    plot([0 0],[-1.5 1.5],'k','LineWidth',1.2);

    % radial grid circles
    ang = linspace(0,2*pi,400);
    for r = 0.2:0.2:1.0
        plot(r*cos(ang), r*sin(ang), 'Color',[0.85 0.85 0.85]);
    end

    % circumference dots every 10 deg
    ang_dots = linspace(0,2*pi,36+1);
    ang_dots(end) = [];
    plot(cos(ang_dots), sin(ang_dots), 'k.', 'MarkerSize',9);

    % phase labels on axes
    text(1.05,  0,   '\phi=0 / 1', 'FontSize',10);
    text(0,     1.1, '\phi=0.25', 'HorizontalAlignment','center');
    text(-1.1,  0,   '\phi=0.5',  'HorizontalAlignment','center');
    text(0,    -1.1, '\phi=0.75', 'HorizontalAlignment','center');

    % old and new phase angles
    ang_phi   = 2*pi*phi;
    ang_theta = 2*pi*theta;

    x_phi   = cos(ang_phi);
    y_phi   = sin(ang_phi);
    x_theta = cos(ang_theta);
    y_theta = sin(ang_theta);

    % old phase marker (black)
    plot(x_phi, y_phi, 'ko', ...
        'MarkerFaceColor','k', ...
        'MarkerSize',7);
    text(x_phi+0.05, y_phi+0.05, ...
        ['\phi_', idx_str], ...
        'FontSize',10, 'Color','k');

    % new phase marker (grey)
    plot(x_theta, y_theta, 'o', ...
        'MarkerFaceColor',[0.7 0.7 0.7], ...
        'MarkerEdgeColor',[0.3 0.3 0.3], ...
        'MarkerSize',7);
    text(x_theta+0.05, y_theta+0.05, ...
        ['\theta_', idx_str], ...
        'FontSize',10, 'Color',[0.2 0.2 0.2]);

    % stimulus vector "b" from old-phase point, horizontal to the right
    quiver(x_phi, y_phi, b, 0, 0, ...
        'Color','k', 'LineWidth',1.2, 'MaxHeadSize',0.35);
    text(x_phi + b/2, y_phi + 0.08, 'b', ...
        'HorizontalAlignment','center', 'FontSize',10);

    % dashed radial line from origin to direction of (x_phi + b, y_phi)
    x_after = x_phi + b;
    y_after = y_phi;
    scale   = 1 / hypot(x_after, y_after);
    plot([0, x_after*scale], [0, y_after*scale], ...
        'k--', 'LineWidth',1.0);

    axis([-1.5 1.5 -1.5 1.5]);
    axis off;
end