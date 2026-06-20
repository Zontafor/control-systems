function projB_build_ss_model()
% Build ProjB_SSModel.slx programmatically using a State-Space ODE block.
% Uses the same transfer function G(s) as ProjB_SimulinkModel.

data_path = '/Users/mlwu/Documents/Academia/USC/BME/511/project/Bme511F25_ProjectB/data';

%% Load input data and parameter means
S = load(fullfile(data_path,'xdata.mat'));
t = S.t(:);
F = S.F(:);
simF = [t, F];

P = load(fullfile(data_path,'projB_param_mean.mat'),'param_mean');
param_mean = P.param_mean(:);

m  = 1.0e-4;
k  = param_mean(1);
k1 = param_mean(2);
b  = param_mean(3);

% Push to base workspace for Simulink
assignin('base','simF',simF);
assignin('base','m',m);
assignin('base','k',k);
assignin('base','k1',k1);
assignin('base','b',b);

%% Transfer function and state-space realization
numG = [b, (k + k1)];
denG = [m*b, m*(k + k1), b*(k + k1), k*k1];

Gs = tf(numG, denG);
[Ag,Bg,Cg,Dg] = tf2ss(numG, denG);

model = 'ProjB_SSModel';

if bdIsLoaded(model)
    close_system(model, 0);
end

new_system(model);
open_system(model);

x0 = 30;  y0 = 60;  dx = 150;

% From Workspace F(t)
add_block('simulink/Sources/From Workspace', ...
          [model '/F_fromWS'], ...
          'VariableName', 'simF', ...
          'Position', [x0 y0 x0+90 y0+30]);

% State-Space block implementing z_dot = A z + B u, y = C z + D u
add_block('simulink/Continuous/State-Space', ...
          [model '/SS_G'], ...
          'A', mat2str(Ag), ...
          'B', mat2str(Bg), ...
          'C', mat2str(Cg), ...
          'D', mat2str(Dg), ...
          'Position', [x0+dx y0 x0+dx+150 y0+80]);

% To Workspace for x_sim
add_block('simulink/Sinks/To Workspace', ...
          [model '/x_sim'], ...
          'VariableName', 'x_sim', ...
          'SaveFormat', 'StructureWithTime', ...
          'Position', [x0+2*dx+40 y0 x0+2*dx+130 y0+30]);

% Scope
add_block('simulink/Sinks/Scope', ...
          [model '/Scope_x'], ...
          'Position', [x0+2*dx+40 y0+60 x0+2*dx+130 y0+120]);

% Connect
add_line(model,'F_fromWS/1','SS_G/1');
add_line(model,'SS_G/1','x_sim/1');
add_line(model,'SS_G/1','Scope_x/1');

save_system(model);
disp('ProjB_SSModel.slx has been created/updated.');
end