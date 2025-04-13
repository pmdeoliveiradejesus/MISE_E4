#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr  4 21:47:24 2025

@author: pm.deoliveiradejes
"""

from scipy.optimize import minimize
import numpy as np

# Objective function
def objective(x):
    x1, x2, x3 = x
    return 2 * x1**2 + x1 * x2 + x2**2 + 1.5 * x3**2 + x1 - 2 * x2

# Constraints
def constraint1_eq(x):
    return x[0]**2 + x[1]**2 + x[2]**2 - 4  # equality constraint

def constraint2_ineq(x):
    return 1 - ((x[0] - 1)**2 + x[1]**2)    # inequality constraint

# Initial guess that satisfies the equality constraint
initial_guess = [1.0, 1.0, np.sqrt(2)]

# Define constraints
constraints = [
    {'type': 'eq', 'fun': constraint1_eq},
    {'type': 'ineq', 'fun': constraint2_ineq}
]

# Solve the problem
solution = minimize(objective, initial_guess, constraints=constraints)

# Print the results
print("Optimal x:", solution.x)
print("Objective value:", solution.fun)
