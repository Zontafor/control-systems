function projB_run_integrator_model()
% Run the explicit 3-integrator Simulink model and compare with
% (i) measured x(t) and (ii) TF-based prediction using mean parameters.

clear;
clc;

data_path = '/Users/mlwu/Documents/Academia/USC/BME/511/project/Bme511F25_ProjectB/data';
fig_path  = '/Users/mlwu/Documents/Academia/USC/BME/511/project/Bme511F25_ProjectB/data/figs';

%% Load measurement data
S = load(fullfile(data_path,'xdata.mat'));

t = S.t(:);
F = S.F(:);

if isfield(S,'x')
    x = S.x(:);
elseif isfield(S,'xdata')
    % safety fallback if the displacement variable has a different name
    x = S.xdata(:);
else
    error('xdata.mat does not contain a displacement signal ''x'' or ''xdata''.');
end

%% Load TF-based prediction xpred_mean(t)
Tfit = load(fullfile(data_path,'projB_tf_fit.mat'),'xpred_mean');
xpred_mean = Tfit.xpred_mean(:);

%% Build / update the 3-integrator model (Option B)
projB_build_integrator_model_B();

%% Simulate the integrator model
simStop = t(end);   % match measurement time span

simOut = sim('ProjB_IntegratorModelB', ...
             'StopTime', num2str(simStop));

t_sim  = simOut.x_sim.time;
x_sim3 = simOut.x_sim.signals.values;

%% Plot measured vs TF vs integrator-model responses
figure;
plot(t, x, 'k', 'LineWidth', 1.0); hold on;
plot(t, xpred_mean, '--', 'LineWidth', 1.5);
plot(t_sim, x_sim3, ':', 'LineWidth', 1.5);

xlabel('Time (s)');
ylabel('Displacement x (\mum)');
legend('Measured x(t)', ...
       'TF prediction x_{pred}(t)', ...
       'Integrator model x_{sim}(t)', ...
       'Location','Best');
grid on;

saveas(gcf, fullfile(fig_path, ...
       'ProjB_x_measured_vs_TF_vs_integrator.png'));
end