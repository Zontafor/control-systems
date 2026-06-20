function projB_build_simulink()
% Build ProjB_SimulinkModel.slx programmatically
% Model: From Workspace F(t) -> Transfer Fcn G(s) -> x_sim + Scope
%
% Uses:
%   /data/xdata.mat              (t, F)
%   /data/projB_param_mean.mat   (param_mean = [k_mean; k1_mean; b_mean])

%% Paths
data_path = '/Users/mlwu/Documents/Academia/USC/BME/511/project/Bme511F25_ProjectB/data';

%% Load data (t, F) from xdata.mat
S = load(fullfile(data_path,'xdata.mat'));
t = S.t(:);
F = S.F(:);
% Note: we do NOT need x here to build the Simulink model

% Define simF for From Workspace (time in first column, data in second)
simF = [t, F];

%% Load mean parameter estimates
P = load(fullfile(data_path,'projB_param_mean.mat'),'param_mean');
param_mean = P.param_mean(:);   % ensure column

m  = 1.0e-4;          % given mass (kg)
k  = param_mean(1);   % mean estimate of k
k1 = param_mean(2);   % mean estimate of k1
b  = param_mean(3);   % mean estimate of b

% Push needed variables to base workspace for Simulink
assignin('base','simF',simF);
assignin('base','m',m);
assignin('base','k',k);
assignin('base','k1',k1);
assignin('base','b',b);

%% Transfer function coefficients from Part II
%   X(s)/F(s) = (b s + (k + k1)) / (m b s^3 + m (k + k1) s^2 + b (k + k1) s + k k1)
numG = [b, (k + k1)];
denG = [m*b, m*(k + k1), b*(k + k1), k*k1];

model = 'ProjB_SimulinkModel';

% If model exists, close without saving
if bdIsLoaded(model)
    close_system(model, 0);
end

% Create new empty model
new_system(model);
open_system(model);

% Block positions (just for a clean layout)
x0 = 30;
y0 = 60;
dx = 120;
dy = 70; %#ok<NASGU>  % currently unused

%% Add blocks
% From Workspace block for F(t)
add_block('simulink/Sources/From Workspace', ...
          [model '/F_fromWS'], ...
          'VariableName', 'simF', ...
          'Position', [x0 y0 x0+90 y0+30]);

% Transfer Fcn block for G(s)
add_block('simulink/Continuous/Transfer Fcn', ...
          [model '/G'], ...
          'Numerator',   mat2str(numG), ...
          'Denominator', mat2str(denG), ...
          'Position', [x0+dx y0 x0+dx+120 y0+60]);

% To Workspace block for x(t)
add_block('simulink/Sinks/To Workspace', ...
          [model '/x_sim'], ...
          'VariableName', 'x_sim', ...
          'SaveFormat', 'StructureWithTime', ...
          'Position', [x0+2*dx+40 y0 x0+2*dx+130 y0+30]);

% Scope to visualize x(t)
add_block('simulink/Sinks/Scope', ...
          [model '/Scope_x'], ...
          'Position', [x0+2*dx+40 y0+60 x0+2*dx+130 y0+120]);

%% Connect the blocks
add_line(model, 'F_fromWS/1', 'G/1');
add_line(model, 'G/1', 'x_sim/1');
add_line(model, 'G/1', 'Scope_x/1');

% Save the model to disk
save_system(model);

disp('ProjB_SimulinkModel.slx has been created/updated.');
end