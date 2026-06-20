# main.py — cardiac, control, and glucose-insulin models

print("=== Question 1: Cardiac Steady-State Points ===")
exec(open("cardiac_steady_state_solver.py").read())

print("\n=== Question 2: Control System Gains ===")
exec(open("control_system_gains.py").read())

print("\n=== Question 3: Glucose-Insulin Regulation ===")
exec(open("glucose_insulin_model.py").read())