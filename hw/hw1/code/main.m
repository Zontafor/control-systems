% main.m — Master script for analysis and visualization of all questions

disp('=== Question 1: Cardiac Steady-State Points ===');
load('cardiac_steady_state_results.mat');
disp(['Pre-transplant: P_ra = ', num2str(pra_a), ', Q = ', num2str(q_a)]);
disp(['Post-transplant: P_ra = ', num2str(pra_b), ', Q = ', num2str(q_b)]);
disp(['Double Resistance: P_ra = ', num2str(pra_c), ', Q = ', num2str(q_c)]);
disp(['+7 mmHg Volume: P_ra = ', num2str(pra_d), ', Q = ', num2str(q_d)]);
fprintf('\n');

disp('=== Question 2: Control System Gains ===');
load('control_system_gains.mat');
disp(['Open-loop gain G_OL = ', G_OL]);
disp(['Closed-loop gain G_CL = ', G_CL]);
fprintf('\n');

disp('=== Question 3: Glucose-Insulin Regulation ===');
load('glucose_insulin_model.mat');
disp(['Steady-state eqn 1: ', steady_state_eq1]);
disp(['Steady-state eqn 2: ', steady_state_eq2]);
disp(['Clamp test eqn: ', steady_state_clamp]);
disp(['Diabetic insulin level I* = ', I_star_diabetic]);
fprintf('\n');