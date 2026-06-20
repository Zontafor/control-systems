from sympy import symbols, Eq, Function

# Define symbols
G_star, I_star, G_fixed, beta = symbols('G_star I_star G_fixed beta', real=True, positive=True)
G_in, I_in = symbols('G_in I_in', real=True)
f1 = Function('f1')(G_star)
f2 = Function('f2')(G_star, I_star)
f3 = Function('f3')(G_star)
f4 = Function('f4')(I_star)

# 3a: Steady-state equations
eq1 = Eq(G_in, f1 + f2)
eq2 = Eq(I_in, f4 - beta * f3)

# 3b: Glucose clamp test
f3_fixed = Function('f3')(G_fixed)
f4_clamp = Function('f4')(I_star)
clamp_eq = Eq(f4_clamp, beta * f3_fixed)

# 3c: Diabetic case (beta = 0)
I_star_diabetic = 0

print("3a Steady-State Equations:")
print(eq1)
print(eq2)
print("\n3b Clamp Test Equation:")
print(clamp_eq)
print("\n3c Diabetic Case:")
print("I* =", I_star_diabetic)