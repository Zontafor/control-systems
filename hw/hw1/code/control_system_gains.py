from sympy import symbols, simplify

# Define symbols
G_A, G_B, G_D, G_E, G_F = symbols('G_A G_B G_D G_E G_F', real=True, positive=True)

# Define intermediate and final gains
G_C = G_A * G_B
G_OL = simplify(G_C * G_D)
G_CL = simplify((G_C * G_D) / (1 + G_C * G_E + G_C * G_D * G_F))

print("Open-loop gain G_OL = ", G_OL)
print("Closed-loop gain G_CL = ", G_CL)