"""
Created on August 23, 2024

@author: Eljas Virtanen
"""

import gurobipy as gp
from gurobipy import GRB
import matplotlib.pyplot as plt
import pandas as pd

# Parameters
T = 72  # number of hours
C = 300  # Battery capacity MWh
#SOC_f = 100 # initial energy in battery MWh
#beta_min = 0.1  # Minimum SOC as a fraction of capacity
#beta_max = 0.9  # Maximum SOC as a fraction of capacity
#eta_c = 0.95  # Charging efficiency
#eta_d = 0.92  # Discharging efficiency
#P_c_max = 90    # Maximum charge power in MW
#P_d_max = 120    # Maximum discharge power in MW

# Coefficients for the generators
a = [44.0, 43.7, 45.5, 34.1, 35.1]  # Linear coefficients
b = [0.14, 0.13, 0.14, 0.12, 0.16]  # Quadratic coefficients

# Generator power limits
P_min = [30, 25, 35, 25, 25]  # Min power output for each generator
P_max = [300, 390, 390, 360, 360]  # Max power output for each generator
P_G_min = [[0] * 5 for _ in range(T)]
P_G_max = [[0] * 5 for _ in range(T)]
print(P_G_max)
print(P_G_min)
for i in range(5):
    for t in range(T):
        P_G_min[t][i] = P_min[i]  # Set the lower bound for each generator
        P_G_max[t][i] = P_max[i]  # Set the upper bound for each generator


# Ramp rates
R_up = [45, 35, 35, 55, 35]
R_down = [45, 45, 35, 45, 55]

# Demand and PV generation data
data = pd.read_csv('SystemData.csv')

P_Ldata = pd.to_numeric(data.iloc[:, 2], errors='coerce') # read data from file: Fraction of max load at times t=0...t=167 in MW
P_L = P_Ldata.dropna().to_list()
P_L = [value * 1500 for value in P_L] # load data

P_pvdata = pd.to_numeric(data.iloc[:, 1], errors='coerce') # read data from file: Fraction of max PV power at times t=0...t=167 in MW
P_pv = P_pvdata.dropna().to_list()
P_pv = [value * 500 for value in P_pv] # PV data

print(f"PV production data:{P_pv}")
print(f"Demand data: {P_L}")

# Create the model
model = gp.Model('OPEX_Optimization')

# Variables
P_G = model.addVars(5, T, lb=P_G_min, ub=P_G_max, name="P_G")
#P_c = model.addVars(T, lb=0, ub=P_c_max, name="P_c")  # Charging power
#P_d = model.addVars(T, lb=0, ub=P_d_max, name="P_d")  # Discharging power
#SOC = model.addVars(T, lb=beta_min * C, ub=beta_max * C, name="SOC")  # State of Charge

# Objective function
OPEX = gp.quicksum(b[i] * P_G[i, t] * P_G[i, t] + a[i] * P_G[i, t] for i in range(5) for t in range(T))
model.setObjective(OPEX, GRB.MINIMIZE)

# Constraints

# Power balance
power_balance = model.addConstrs((gp.quicksum(P_G[i, t] for i in range(5)) + P_pv[t] == P_L[t] for t in range(T)), "Power_Balance")

# Ramp-up constraints
model.addConstrs((P_G[i, t] - P_G[i, t-1] <= R_up[i] for i in range(5) for t in range(1, T)), "Ramp_Up")

# Ramp-down constraints
model.addConstrs((P_G[i, t-1] - P_G[i, t] <= R_down[i] for i in range(5) for t in range(1, T)), "Ramp_Down")

# Power generation limits
model.addConstrs((P_min[i] <= P_G[i, t] for i in range(5) for t in range(T)), "Gen_Limits_Min")
model.addConstrs((P_G[i, t] <= P_max[i] for i in range(5) for t in range(T)), "Gen_Limits_Max")

# State of Charge dynamics
#model.addConstr(SOC[0] == SOC_f + P_c[0] * eta_c - P_d[0] / eta_d, "SOC_Initial")
#model.addConstrs((SOC[t] == SOC[t-1] + P_c[t] * eta_c - P_d[t] / eta_d for t in range(1, T-1)), "SOC_Dynamics")
#model.addConstr(SOC[167] >= 100, "SOC_Final")

# SOC limits
#model.addConstrs((beta_min * C <= SOC[t] for t in range(T)), "SOC_Limits_Min")
#model.addConstrs((SOC[t] <= beta_max * C for t in range(T)), "SOC_Limits_Max")

# Optimize the model
model.optimize()

# Output results
if model.status == GRB.OPTIMAL:
    print("Optimal cost:", model.objVal)
    for i in range(5):
        print(f"Generator {i+1} output:")
        for t in range(T):
            print(f"Time {t+1}: {P_G[i,t].x} MW")
else:
    print("No optimal solution found.")


results = [[0] * 10 for _ in range(T)]

marginal_prices = [power_balance[t].Pi for t in range(T)]

print(marginal_prices)

for t in range(T):
    results[t][0] = float(P_G[0,t].X)
    results[t][1] = float(P_G[1,t].X)
    results[t][2] = float(P_G[2,t].X)
    results[t][3] = float(P_G[3,t].X)
    results[t][4] = float(P_G[4,t].X)
    results[t][5] = float(P_pv[t])
    #results[t][6] = float(P_c[t].X)  # charging power
    #results[t][7] = float(P_d[t].X)  # discharging power
    #results[t][8] = float(SOC[t].X)  # state of charge
    results[t][9] = float(marginal_prices[t]) # marginal price of the hour



# Visualize the results for economic dispatch
hours_plot = list(range(0, T))
legend = ['Pg1', 'Pg2', 'Pg3', 'Pg4', 'Pg5', 'P_pv']

plt.figure(figsize=(12, 8))

for i in range(6):
    variable_data = [results[hour][i] for hour in range(T)]
    plt.plot(hours_plot, variable_data, linestyle='-', label=legend[i])

plt.xlabel('Hour')
plt.ylabel('Power (MW)')
plt.title('Economic dispatch of the system')
plt.legend()
plt.grid(True)

plt.show()

# Visualize the results for marginal price
legend1 = ['Marginal price']

plt.figure(figsize=(12, 8))

variable_data = [results[hour][9] for hour in range(T)]
plt.plot(hours_plot, variable_data, linestyle='-', label=legend1)

plt.xlabel('Hour')
plt.ylabel('Eur/MWh')
plt.title('Marginal power price of the system')
plt.legend()
plt.grid(True)

plt.show()

# Energy balance of the system
print(f"\nFor T: {T}")
print("\nEnergy balance:")
W_g = 0
for hour in range(T):
    for i in range(5):
        W_g += results[hour][i] # generation of the 5 thermal power plants
W_g = W_g/1000
print(f"W_g: {W_g:.2f} GWh")

W_pv = 0
for hour in range(T):
    W_pv += results[hour][5]
W_pv = W_pv/1000
print(f"W_pv: {W_pv:.2f} GWh")

#W_discharge = 0
#for hour in range(T):
#    W_discharge += results[hour][7]
#W_discharge = W_discharge/1000
#print(f"W_discharge: {W_discharge:.2f} GWh")

#W_charge = 0
#for hour in range(T):
#    W_charge += -results[hour][6]
#W_charge = W_charge/1000
#print(f"W_charge: {W_charge:.2f} GWh")

W_load = 0
for hour in range(T):
    W_load += -P_L[hour]
W_load = W_load/1000
print(f"W_load: {W_load:.2f} GWh")

Balance = W_g + W_pv + W_load
print(f"Balance: {Balance:.2f} GWh\n")

# Economic balance of the system
Prod_cost = model.ObjVal
Prod_cost = Prod_cost/1000000
print(f"Production costs: {Prod_cost:.3f} M Euros")

PV_revenue = 0
for hour in range(T):
    PV_revenue += results[hour][5] * results[hour][9] # PV generation multiplied by the marginal power price
PV_revenue = PV_revenue/1000000
print(f"PV Revenue: {PV_revenue:.3f} M Euros")

Thermal_revenue = 0
for hour in range(T):
    thermal_at_hour = sum(results[hour][i] for i in range(5))
    Thermal_revenue += thermal_at_hour * results[hour][9] # thermal generation multiplied by the marginal power price
Thermal_revenue = Thermal_revenue/1000000
print(f"Thermal Revenue: {Thermal_revenue:.3f} M Euros")

Thermal_profits = Thermal_revenue - Prod_cost
print(f"Thermal Profits: {Thermal_profits:.3f} M Euros")

energy_payments_by_demand = 0
for hour in range(T):
    energy_payments_by_demand += P_L[hour] * results[hour][9] # load multiplied by the marginal power price
energy_payments_by_demand = energy_payments_by_demand/1000000
print(f"Energy payments by demand: {energy_payments_by_demand:.3f} M Euros")

#BESS_profits = 0
#for hour in range(T):
#    if results[hour][6] > 0.001:
#        BESS_profits -= results[hour][6] * results[hour][9] # buy energy to charge -
#    elif results[hour][7] > 0.001:
#        BESS_profits += results[hour][7] * results[hour][9] # sell discharged energy +
#BESS_profits = BESS_profits/1000
#print(f"BESS profits: {BESS_profits:.2f} k Euros")