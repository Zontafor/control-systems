% problem2_phase_reset.m
% Phase-reset computation for the Poincare oscillator (Problem 2)

clear; clc;

% Define fig path
figdir = '/Users/mlwu/Documents/Academia/USC/BME/511/hw/hw4/code/figs';
if ~exist(figdir, 'dir')
    mkdir(figdir);
end

% Phase function for unperturbed oscillator (1 rev / 16 s)
phase = @(t) mod(t/16, 1);

% Map old phase phi and stimulus magnitude b to new phase theta
theta_from_phi = @(phi, b) local_theta_from_phi(phi, b);

%% Stimulus at t = 4 s, magnitude 1
t1   = 4;
phi1 = phase(t1);
theta1 = theta_from_phi(phi1, 1);
dt1  = (1 - theta1) * 16;
t1_next     = t1 + dt1;
t1_nextnext = t1_next + 16;

fprintf('Part I:\n');
fprintf('  phi_1   = %.3f rev\n', phi1);
fprintf('  theta_1 = %.3f rev\n', theta1);
fprintf('  Next spikes at t = %.1f s and t = %.1f s\n\n', t1_next, t1_nextnext);

%% Stimulus at t = 12 s, magnitude 1
t2   = 12;
phi2 = phase(t2);
theta2 = theta_from_phi(phi2, 1);
dt2  = (1 - theta2) * 16;
t2_next     = t2 + dt2;
t2_nextnext = t2_next + 16;

fprintf('Part II:\n');
fprintf('  phi_2   = %.3f rev\n', phi2);
fprintf('  theta_2 = %.3f rev\n', theta2);
fprintf('  Next spikes at t = %.1f s and t = %.1f s\n\n', t2_next, t2_nextnext);

%% Stimulus at t = 8 s, various magnitudes
t3   = 8;
phi3 = phase(t3);

b_vals = [0.99, 1.00, 1.01];
for b = b_vals
    if abs(b - 1.0) < 1e-12
        % Exactly hits the origin; model stays at r = 0, no more spikes
        fprintf('Part III:\n');
        fprintf('  b = %.2f: hits origin -> oscillation stops, no further spikes.\n', b);
    else
        theta3 = theta_from_phi(phi3, b);
        dt3    = (1 - theta3) * 16;
        t3_next = t3 + dt3;
        fprintf('Part III:\n');
        fprintf('  b = %.2f:\n', b);
        fprintf('  theta_3 = %.3f rev, next spike at t = %.1f s\n', theta3, t3_next);
    end
end

%% Local theta function
function theta = local_theta_from_phi(phi, b)
    % Map old phase phi (rev) and magnitude b to new phase theta (rev)
    ang = 2*pi*phi;
    x = cos(ang);
    y = sin(ang);

    X = x + b;  % add stimulus vector along +x
    Y = y;

    if hypot(X, Y) == 0
        theta = NaN; % origin; phase undefined
    else
        theta = mod(atan2(Y, X), 2*pi) / (2*pi);
    end
end