function problem3_describing_function()
%  Verify describing-function analysis for ventilator + lung loop
%  - Relay: +/-0.05 L/s
%  - Lung dynamics: Nyquist data G(jw) from Fig 2B or provided file
%  Last checked: Nov. 24, 2025

%% --- User-supplied Nyquist data for G(jw) -----------------------------
% f_vec: frequency in Hz, 0.01 to 0.05 (or whatever grid is provided)
% Gre, Gim: real and imag parts of G(jw) in mmHg s / L
%
% TODO: replace these example values with the actual course data
%       (e.g., load from a .mat file or paste numeric columns).

f_vec = [0.01 0.02 0.03 0.04 0.05];  % Hz (placeholder)
Gre   = [  0  -80  -60    0   30];   % Re{G(jw)} example only
Gim   = [-100 -80    0   50   50];   % Im{G(jw)} example only

G = Gre + 1j*Gim;

%% --- Describing function of relay ------------------------------------
M = 0.05;                 % relay output level (L/s)
A_vec = linspace(0.5,10,400);    % amplitude range in mmHg

DF = (4*M)./(pi*A_vec);   % DF(A) = 4M/(pi A), real > 0

% locus of -1/DF(A) (negative real axis)
x_df = -1./DF;
y_df = zeros(size(x_df));

%% --- Nyquist of -G(jw) -----------------------------------------------
G_minus = -G;             % effective loop nonlinearity is -G*DF
Gre_m   = real(G_minus);
Gim_m   = imag(G_minus);

%% --- Find approximate intersection with -1/DF(A) line -----------------
% Strategy:
%  1) look for Nyquist points whose imag part ~ 0 (on real axis)
%  2) for those, match real part to -1/DF(A) and infer A, freq.

tol_im = 5;   % mmHg s/L; tolerance for "approximately real"
idx_real = find(abs(Gim_m) <= tol_im);

A_int   = NaN(numel(idx_real),1);
f_int   = NaN(numel(idx_real),1);

for k = 1:numel(idx_real)
    i = idx_real(k);
    x_target = Gre_m(i);              % real part of -G
    % Solve -1/DF(A) = x_target => -pi*A/0.2 = x_target
    A_int(k) = -0.2 * x_target / pi;
    f_int(k) = f_vec(i);
end

% choose positive A only
valid = A_int > 0 & ~isnan(A_int);
A_int = A_int(valid);
f_int = f_int(valid);

% pick the one with largest |G| among candidates (typical DF choice)
A_star = NaN; f_star = NaN; G_star = NaN;
if ~isempty(A_int)
    cand_idx = idx_real(valid);
    [~,j] = max(abs(G(cand_idx)));
    A_star = A_int(j);
    f_star = f_int(j);
    G_star = G_minus(cand_idx(j));
end

%% --- Plot Nyquist + DF locus -----------------------------------------
figure; hold on; grid on; box on;
plot(Gre, Gim, 'k.-', 'LineWidth', 1.2, 'MarkerSize', 14);       % G(jw)
plot(Gre_m, Gim_m, 'b.-', 'LineWidth', 1.2, 'MarkerSize', 10);   % -G(jw)
plot(x_df, y_df, 'r--', 'LineWidth', 1.5);                       % -1/DF(A)

% mark frequencies on -G(jw)
for i = 1:numel(f_vec)
    text(Gre_m(i), Gim_m(i), sprintf(' %.3g Hz', f_vec(i)), ...
        'FontSize', 8, 'HorizontalAlignment', 'left');
end

% mark intersection estimate
if ~isnan(A_star)
    plot(real(G_star), imag(G_star), 'ro', 'MarkerSize', 10, ...
         'MarkerFaceColor', 'r');
    legend('G(j\omega)', '-G(j\omega)', '-1/DF(A)', 'intersection', ...
           'Location', 'Best');
else
    legend('G(j\omega)', '-G(j\omega)', '-1/DF(A)', 'Location', 'Best');
end

xlabel('Real\{ \cdot \}  (mmHg s / L)');
ylabel('Imag\{ \cdot \}  (mmHg s / L)');
title('Problem 3: Nyquist of lung dynamics and describing-function locus');
axis equal;

%% --- Report estimated limit-cycle properties --------------------------
if ~isnan(A_star)
    fprintf('Estimated limit-cycle amplitude A  ~ %.2f mmHg\n', A_star);
    fprintf('Estimated limit-cycle frequency f ~ %.3f Hz\n', f_star);
else
    fprintf('No intersection found with current Nyquist data + tolerance.\n');
end

end