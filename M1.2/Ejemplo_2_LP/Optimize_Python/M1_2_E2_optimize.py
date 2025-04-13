#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat May 11 22:24:28 2024

@author: pm.deoliveiradejes
"""

#  M1_2_E1 
#  Paulo M. De Oliveira De Jesus pdeoliv@gmail.com

from scipy.optimize import linprog

# Objective function coefficients
c = [20, 25]

# Coefficients of the inequality constraints (left-hand side of inequalities)
A = [[1, 0], [0, 1]]

# Right-hand side of inequalities
b = [400, 300]

# Coefficients of the equality constraints (left-hand side of equalities)
A_eq = [[1, 1]]

# Right-hand side of equalities
b_eq = [600]

# Bounds for variables (x1 and x2)
x1_bounds = (0, 400)
x2_bounds = (0, 300)

# Solve the linear programming problem
result = linprog(c, A_ub=A, b_ub=b, A_eq=A_eq, b_eq=b_eq, bounds=[x1_bounds, x2_bounds], method='highs')

# Print the results
print("Optimal value:", result.fun)
print("Optimal solution:")
print("x1 =", result.x[0])
print("x2 =", result.x[1])

# shadow prices
λ_ineq = result['ineqlin']['marginals']
λ_eq   = result['eqlin']['marginals']
print(λ_eq) 
print(λ_ineq) 