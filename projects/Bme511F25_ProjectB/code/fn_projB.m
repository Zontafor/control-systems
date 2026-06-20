function NMSE = fn_projB(params)
% fn_projB  Criterion function for viscoelastic tissue model (Project B)
%   NMSE = fn_projB(params) computes the normalized mean squared error (NMSE)
%   between the measured displacement x(t) and the model-predicted
%   displacement x_pred(t) for the Kelvin–Voigt-in-series-with-spring model.
%
%   Parameter vector:
%       params(1) = k   : stiffness of Kelvin–Voigt spring  (mN/µm)
%       params(2) = k1  : stiffness of series spring        (mN/µm)
%       params(3) = b   : viscous damping coefficient       (mN·s/µm)
%
%   Globals (set in popt_projB.m):
%       t      : time vector (s)
%       u      : input force F(t) (mN)
%       x      : measured displacement (µm)
%       xpred  : model-predicted displacement (µm)
%       m      : mass of glass plate (kg)

    global t u x xpred m

    % Unpack parameters
    k  = params(1);
    k1 = params(2);
    b  = params(3);

    % Penalize non-physical parameter values
    if any(params <= 0)
        NMSE = 1e6;
        return;
    end

    % Transfer function from F(s) to X(s):
    %   G(s) = (b*s + k1 + k) / (m*b*s^3 + m*(k1 + k)*s^2 + k1*b*s + k1*k)
    num = [b, (k1 + k)];
    den = [m*b, m*(k1 + k), k1*b, k1*k];

    Gs = tf(num, den);

    % Simulate tissue displacement response to the measured input force u(t)
    xpred = lsim(Gs, u, t);
    xpred = xpred(:);     % ensure column vector

    % Safety check: sizes must match
    if length(xpred) ~= length(x)
        error('fn_projB:LengthMismatch', ...
              'Length(x) = %d, Length(xpred) = %d.', ...
              length(x), length(xpred));
    end

    % Compute NMSE: variance of error divided by variance of measured data
    e    = x - xpred;
    NMSE = var(e) / var(x);

end