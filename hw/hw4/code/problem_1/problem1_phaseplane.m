% problem1_phaseplane.m
% Phase portrait for dx/dt = x - 2xy, dy/dt = 2xy - y

clear; clc;

% Define fig path
figdir = '/Users/mlwu/Documents/Academia/USC/BME/511/hw/hw4/code/figs';
if ~exist(figdir, 'dir')
    mkdir(figdir);
end

% Grid for vector field
[xg, yg] = meshgrid(linspace(0,1.2,25), linspace(0,1.2,25));

dx = xg - 2.*xg.*yg;
dy = 2.*xg.*yg - yg;

figure;
quiver(xg, yg, dx, dy, 'AutoScale', 'on', 'AutoScaleFactor', 1.2);
hold on; box on;
xlabel('x (infected fraction)');
ylabel('y (therapeutic fraction)');
% title('Phase plane for viral–therapeutic interaction');

% Nullclines
plot([0 1.2],[0.5 0.5],'k--','LineWidth',1);   % y = 1/2
plot([0.5 0.5],[0 1.2],'k--','LineWidth',1);   % x = 1/2
plot([0 0],[0 1.2],'k-','LineWidth',1);        % x = 0
plot([0 1.2],[0 0],'k-','LineWidth',1);        % y = 0

% Equilibria
plot(0,0,'ro','MarkerFaceColor','r','MarkerSize',6);
plot(0.5,0.5,'bo','MarkerFaceColor','b','MarkerSize',6);

% Sample trajectories via ode45
f = @(t,z)[z(1) - 2*z(1)*z(2); 2*z(1)*z(2) - z(2)];

ics = [0.1 0.9;
       0.9 0.1;
       0.8 0.8;
       0.2 0.2;
       0.7 0.3];

tspan = [0 20];

for k = 1:size(ics,1)
    [t,z] = ode45(f, tspan, ics(k,:).');
    plot(z(:,1), z(:,2), 'LineWidth', 1.2);
end

axis([0 1.2 0 1.2]);
legend({'vector field','y=1/2','x=1/2','x=0','y=0', ...
        'eq (0,0)','eq (1/2,1/2)'}, ...
        'Location','bestoutside');

saveas(gcf, fullfile(figdir, 'problem1_phaseplane.png'));
saveas(gcf, fullfile(figdir, 'problem1_phaseplane.fig'));