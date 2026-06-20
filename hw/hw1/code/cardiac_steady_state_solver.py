import numpy as np
from scipy.interpolate import interp1d
from scipy.optimize import brentq

# Data
pra_vals = np.arange(14)
co_infarcted = np.array([0.0, 0.4, 1.2, 2.0, 2.2, 2.6, 3.0, 3.0, 3.2, 3.2, 3.4, 3.8, 3.8, 3.8])
co_transplanted = np.array([0.0, 0.4, 1.0, 2.4, 4.6, 7.0, 8.8, 10.4, 11.0, 11.2, 11.6, 12.0, 12.0, 12.0])

# Venous return functions
def vr_normal(p): return 14 - 2 * p
def vr_double_resistance(p): return 14 - 4 * p
def vr_shifted(p): return 21 - 4 * p

# Interpolation
f_infarcted = interp1d(pra_vals, co_infarcted, kind='linear')
f_transplanted = interp1d(pra_vals, co_transplanted, kind='linear')

# Root finding
def intersection(f1, f2, a, b): return brentq(lambda x: f1(x) - f2(x), a, b)

# Solve
pra_a = intersection(f_infarcted, vr_normal, 5, 6)
q_a = f_infarcted(pra_a)

pra_b = intersection(f_transplanted, vr_normal, 4, 5)
q_b = f_transplanted(pra_b)

pra_c = intersection(f_transplanted, vr_double_resistance, 2, 3)
q_c = f_transplanted(pra_c)

pra_d = intersection(f_transplanted, vr_shifted, 4.04, 4.07)
q_d = f_transplanted(pra_d)

# Print results
print("a (Pre-transplant):", pra_a, q_a)
print("b (Post-transplant):", pra_b, q_b)
print("c (Double Resistance):", pra_c, q_c)
print("d (Increased Blood Volume):", pra_d, q_d)