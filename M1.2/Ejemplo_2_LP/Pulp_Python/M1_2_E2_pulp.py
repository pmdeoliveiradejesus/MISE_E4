#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat May 11 22:46:10 2024

@author: pm.deoliveiradejes
"""
#  M1_2_E1 
#  Paulo M. De Oliveira De Jesus pdeoliv@gmail.com

import pulp as lp

# Create a linear programming problem
model = lp.LpProblem(name="LP_Problem Primal", sense=lp.LpMinimize)

# Define decision variables
x1 = lp.LpVariable(name="x1", lowBound=None)  # x1 >= 0
x2 = lp.LpVariable(name="x2", lowBound=None)  # x2 >= 0


# Add constraints
model += (x1 + x2 == 600, "constraint1")
model += (x1      <= 400, "constraint2")
model += (     x2 <= 300, "constraint3")

# Define the objective function
model += 20 * x1 + 25 * x2, "objective"

# Solve the LP problem
model.solve()

# Print the results
print(f"Optimal value: {lp.value(model.objective)}")
print(f"Optimal solution for x1: {lp.value(x1)}")
print(f"Optimal solution for x2: {lp.value(x2)}")

# Create a linear programming problem
model = lp.LpProblem(name="LP_Problem Dual", sense=lp.LpMaximize)

# Define decision variables
y1 = lp.LpVariable(name="y1", lowBound=None)  # y1 >= 0
y2 = lp.LpVariable(name="y2", lowBound=None)  # y2 >= 0
y3 = lp.LpVariable(name="y3", lowBound=None)  # y3 >= 0
y4 = lp.LpVariable(name="y4", lowBound=None)  # y4 >= 0

# Add constraints
model += (-y1 + y2 + y3 <= 20, "constraint1")
model += (-y1 + y2 - y4 <= 25, "constraint2")
model += ( y1           <= 0, "constraint3")
model += ( y2           <= 0, "constraint4")
model += ( y3           <= 0, "constraint5")
model += ( y4           <= 0, "constraint6")

# Define the objective function
model += -600 * y1 +600 * y2 + 400 * y3 + 300 * y4 , "objective"

# Solve the LP problem
model.solve()

# Print the results
print(f"Optimal value: {lp.value(model.objective)}")
print(f"Optimal solution for y1: {lp.value(y1)}")
print(f"Optimal solution for y2: {lp.value(y2)}")
print(f"Optimal solution for y3: {lp.value(y3)}")
print(f"Optimal solution for y4: {lp.value(y4)}")


 