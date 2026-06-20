function NMSE = fn_rlc_NMSE_2param(theta)
% fn_rlc_NMSE_2param  NMSE criterion for 2-parameter RLC model.
%   NMSE = fn_rlc_NMSE_2param(theta) returns the normalized mean squared
%   error between measured output y and model output ypred, given
%   parameters theta = [theta1 theta2] where
%       theta1 = L*C
%       theta2 = R*C
%
%   Globals:
%       t, u, y   - time vector, input pressure, measured alveolar pressure
%       ypred     - model-predicted alveolar pressure (updated here)

    global t u y ypred

    theta1 = theta(1);   % = L*C
    theta2 = theta(2);   % = R*C

    % basic positivity / magnitude constraints
    if (theta1 <= 0) || (theta2 <= 0) || ...
       (theta1 > 50) || (theta2 > 200)
        NMSE  = 1e6;                     % large penalty
        ypred = zeros(size(y));          % dummy to keep global defined
        return
    end

    % model: Y(s)/U(s) = 1 / (theta1*s^2 + theta2*s + 1)
    num = 1;
    den = [theta1  theta2  1];
    Hs  = tf(num, den);

    % simulate model response
    ypred = lsim(Hs, u, t);

    % normalized mean squared error
    e    = y - ypred;
    NMSE = var(e) / var(y);
end