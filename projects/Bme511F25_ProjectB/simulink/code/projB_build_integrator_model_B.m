function projB_build_integrator_model_B()
% projB_build_integrator_model_B
% Build a clean 3-integrator state-space realization of the tissue model
% (Option B: horizontal, one row per integrator chain).
%
% Model name:  ProjB_IntegratorModelB
%
% Dynamics realized:
%       z_dot = A z + B F,     x = C z + D F
% where [A,B,C,D] are obtained from the transfer function
%
%          X(s)        b s + (k + k1)
%   G(s) = ---- = -------------------------
%          F(s)   m b s^3 + m(k+k1)s^2 + b(k+k1)s + k k1
%
% Inputs / files required:
%   - xdata.mat              (contains t, F, x)
%   - projB_param_mean.mat   (contains param_mean = [k_mean; k1_mean; b_mean])
%
% Workspace variables created for Simulink:
%   simF   : [t, F(t)] (N-by-2 array for From Workspace)
%   A, B, C, D : state-space matrices

%% Paths
data_path = '/Users/mlwu/Documents/Academia/USC/BME/511/project/Bme511F25_ProjectB/data';

%% Load input data t, F  (x not needed just to build the model)
S = load(fullfile(data_path,'xdata.mat'));   % assumes S.t, S.F
t = S.t(:);
F = S.F(:);
simF = [t, F];   % From Workspace expects [time, data]

%% Load mean parameter estimates
P = load(fullfile(data_path,'projB_param_mean.mat'),'param_mean');
param_mean = P.param_mean(:);

m  = 1.0e-4;
k  = param_mean(1);
k1 = param_mean(2);
b  = param_mean(3);

%% Transfer function coefficients and state-space realization
numG = [b, (k + k1)];
denG = [m*b, m*(k + k1), b*(k + k1), k*k1];

[A,B,C,D] = tf2ss(numG,denG);

%% Export variables needed by Simulink
assignin('base','simF',simF);
assignin('base','A',A);
assignin('base','B',B);
assignin('base','C',C);
assignin('base','D',D);

%% Build Simulink model
model = 'ProjB_IntegratorModelB';

if bdIsLoaded(model)
    close_system(model,0);
end

new_system(model);
open_system(model);

% Layout constants (Option B: horizontal rows for each integrator chain)
xF   = 60;   yF   = 160;     % From Workspace F location
xSum = 220;                  % column for Sum_z blocks
xInt = 340;                  % column for integrators
xG_C = 470;                  % column for C*gains
xOut = 620;                  % column for Sum_y / ToWorkspace / Scope
dy   = 80;                   % vertical spacing between rows

%% From Workspace: F(t)
add_block('simulink/Sources/From Workspace', ...
          [model '/F_fromWS'], ...
          'VariableName','simF', ...
          'Position',[xF yF xF+80 yF+30]);

%% Three integrator chains: z1, z2, z3
for i = 1:3
    yRow = 80 + (i-1)*dy;
    
    % Sum_z_i: z_dot_i = A(i,1)*z1 + A(i,2)*z2 + A(i,3)*z3 + B(i)*F
    add_block('simulink/Math Operations/Sum', ...
              sprintf('%s/Sum_z%d',model,i), ...
              'Inputs','++++', ...   % z1, z2, z3, F
              'Position',[xSum yRow xSum+30 yRow+30]);
    
    % Integrator Int_i: z_i = ∫ z_dot_i dt
    add_block('simulink/Continuous/Integrator', ...
              sprintf('%s/Int%d',model,i), ...
              'InitialCondition','0', ...
              'Position',[xInt yRow xInt+40 yRow+40]);
    
    % Connect Sum_z_i -> Int_i
    add_line(model, ...
             sprintf('Sum_z%d/1',i), ...
             sprintf('Int%d/1',i), ...
             'autorouting','on');
end

%% Gain blocks: A(i,j)*z_j feeding Sum_z_i
for i = 1:3      % derivative index
    for j = 1:3  % state index
        yRow = 80 + (i-1)*dy;
        yOffset = -30 + (j-1)*25;   % small vertical offsets to separate gains
        xGain = (xSum + xInt)/2;    % halfway between Sum and Int
        
        gainName = sprintf('G_A%d%d',i,j);
        add_block('simulink/Math Operations/Gain', ...
                  sprintf('%s/%s',model,gainName), ...
                  'Gain', num2str(A(i,j)), ...
                  'Position',[xGain yRow+yOffset xGain+40 yRow+yOffset+25]);
        
        % z_j -> Gain_Aij
        add_line(model, ...
                 sprintf('Int%d/1',j), ...
                 sprintf('%s/1',gainName), ...
                 'autorouting','on');
        
        % Gain_Aij -> Sum_z_i (inputs 1..3)
        add_line(model, ...
                 sprintf('%s/1',gainName), ...
                 sprintf('Sum_z%d/%d',i,j), ...
                 'autorouting','on');
    end
    
    % Gain from F(t) to Sum_z_i (input 4: B(i)*F)
    yRow   = 80 + (i-1)*dy;
    xGainF = xF + 110;   % right of F_fromWS
    
    gainNameF = sprintf('G_B%d',i);
    add_block('simulink/Math Operations/Gain', ...
              sprintf('%s/%s',model,gainNameF), ...
              'Gain', num2str(B(i)), ...
              'Position',[xGainF yRow-10 xGainF+40 yRow+15]);
    
    add_line(model,'F_fromWS/1',sprintf('%s/1',gainNameF),'autorouting','on');
    add_line(model,sprintf('%s/1',gainNameF),sprintf('Sum_z%d/4',i),'autorouting','on');
end

%% Output: x = C z + D F
% Sum_y with four inputs: C1*z1 + C2*z2 + C3*z3 + D*F
ySumY = 80 + dy;    % middle row
add_block('simulink/Math Operations/Sum', ...
          [model '/Sum_y'], ...
          'Inputs','++++', ...
          'Position',[xOut ySumY xOut+40 ySumY+35]);

% Gains Cj * z_j (j = 1..3)
for j = 1:3
    yRow  = 80 + (j-1)*dy;
    yGain = yRow;
    
    gainNameC = sprintf('G_C%d',j);
    add_block('simulink/Math Operations/Gain', ...
              sprintf('%s/%s',model,gainNameC), ...
              'Gain', num2str(C(j)), ...
              'Position',[xG_C yGain xG_C+40 yGain+25]);
    
    add_line(model,sprintf('Int%d/1',j),sprintf('%s/1',gainNameC),'autorouting','on');
    add_line(model,sprintf('%s/1',gainNameC),sprintf('Sum_y/%d',j),'autorouting','on');
end

% Gain D * F to Sum_y input 4
xGainD = xG_C;
yGainD = yF - 40;
add_block('simulink/Math Operations/Gain', ...
          [model '/G_D'], ...
          'Gain', num2str(D), ...
          'Position',[xGainD yGainD xGainD+40 yGainD+25]);

add_line(model,'F_fromWS/1','G_D/1','autorouting','on');
add_line(model,'G_D/1','Sum_y/4','autorouting','on');

%% To Workspace + Scope for x_sim
add_block('simulink/Sinks/To Workspace', ...
          [model '/x_sim'], ...
          'VariableName','x_sim', ...
          'SaveFormat','StructureWithTime', ...
          'Position',[xOut+90 ySumY xOut+180 ySumY+30]);

add_block('simulink/Sinks/Scope', ...
          [model '/Scope_x'], ...
          'Position',[xOut+90 ySumY+60 xOut+180 ySumY+120]);

add_line(model,'Sum_y/1','x_sim/1','autorouting','on');
add_line(model,'Sum_y/1','Scope_x/1','autorouting','on');

save_system(model);
disp('ProjB_IntegratorModelB.slx has been created/updated.');
end