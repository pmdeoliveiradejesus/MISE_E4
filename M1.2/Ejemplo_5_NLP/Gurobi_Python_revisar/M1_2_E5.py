#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep  3 22:49:20 2024

@author: pm.deoliveiradejes
"""

import gurobipy as gp
from gurobipy import GRB
import pandas as pd
import matplotlib.pyplot as plt

# Cargar datos desde el archivo
data = pd.read_excel('SystemData.xlsx', sheet_name='Sheet1')

# Asignar las series horarias a Ppv y PL
potencia_fotovoltaica = data['Ppv'].values
potencia_demanda = data['PL'].values
data
from gurobipy import Model, GRB, quicksum

# Crear el modelo
model = Model("Economic Dispatch")

# Parámetros
n_hours = len(potencia_demanda)  # Número de horas
n_units = 5  # Número de generadores térmicos
Pmin = [30, 25, 35, 25, 25]  # Potencias mínimas de los generadores
Pmax = [300, 390, 390, 360, 360]  # Potencias máximas de los generadores
Rup = [45, 35, 35, 55, 35]  # Rampas ascendentes
Rdown = [45, 45, 35, 45, 55]  # Rampas descendentes
eta_c = 0.95  # Eficiencia de carga
eta_d = 0.92  # Eficiencia de descarga
SOC_min = 0.1 * 300  # Mínimo SOC
SOC_max = 0.9 * 300  # Máximo SOC
Pmax_c = 0.3 * 300  # Potencia máxima de carga (300 MWh * 0.3 C-rate)
Pmax_d = 0.4 * 300  # Potencia máxima de descarga (300 MWh * 0.4 C-rate)
SOC_target = 100  # SOC objetivo al final del ciclo

# Variables de decisión
P_G = model.addVars(n_units, n_hours, name="P_G")  # Potencia generada por los térmicos
P_c = model.addVars(n_hours, name="P_c")  # Potencia de carga de la batería
P_d = model.addVars(n_hours, name="P_d")  # Potencia de descarga de la batería
SOC = model.addVars(n_hours, name="SOC")  # Estado de carga de la batería

# Función objetivo: minimizar el costo operativo (OPEX)
bcoef= [0.14, 0.13, 0.14, 0.12, 0.16]
acoef = [44.0, 43.7, 45.5, 34.1, 35.1]

OPEX = quicksum(
    quicksum(bcoef[i] * P_G[i, t] * P_G[i, t] + acoef[i] * P_G[i, t] for i in range(n_units))
    for t in range(n_hours)
)
model.setObjective(OPEX, GRB.MINIMIZE)

# Restricciones
# 1. Balance de potencia
for t in range(n_hours):
    model.addConstr(
        quicksum(P_G[i, t] for i in range(n_units)) + potencia_fotovoltaica[t] + P_d[t] == P_c[t] + potencia_demanda[t],
        name=f"balance_{t}"
    )

# 2. Restricciones de rampa
for i in range(n_units):
    for t in range(1, n_hours):
        model.addConstr(P_G[i, t] - P_G[i, t-1] <= Rup[i], name=f"ramp_up_{i}_{t}")
        model.addConstr(P_G[i, t-1] - P_G[i, t] <= Rdown[i], name=f"ramp_down_{i}_{t}")

# 3. Restricciones de SOC de la batería
model.addConstr(SOC[0] == SOC_target + P_c[0] * eta_c - P_d[0] / eta_d, name="SOC_initial")
for t in range(1, n_hours-1):
    model.addConstr(SOC[t] == SOC[t-1] + P_c[t] * eta_c - P_d[t] / eta_d, name=f"SOC_{t}")
model.addConstr(SOC[n_hours-1] == SOC_target, name="SOC_final")

# 4. Límites de potencia generada

for i in range(n_units):
    for t in range(n_hours):
        model.addConstr(P_G[i, t] >= Pmin[i], name=f"Pmin_{i}_{t}")
        model.addConstr(P_G[i, t] <= Pmax[i], name=f"Pmax_{i}_{t}")

# 5. Límites de carga y descarga de la batería
for t in range(n_hours):
    model.addConstr(P_c[t] >= 0, name=f"P_c_min_{t}")
    model.addConstr(P_c[t] <= Pmax_c, name=f"P_c_max_{t}")
    model.addConstr(P_d[t] >= 0, name=f"P_d_min_{t}")
    model.addConstr(P_d[t] <= Pmax_d, name=f"P_d_max_{t}")

# 6. Límites de SOC
for t in range(n_hours):
    model.addConstr(SOC[t] >= SOC_min, name=f"SOC_min_{t}")
    model.addConstr(SOC[t] <= SOC_max, name=f"SOC_max_{t}")

# Resolver el modelo
model.optimize()

# Verificar si la optimización fue exitosa
if model.status == GRB.OPTIMAL:
    print("Optimización completada con éxito.")
    # Extraer resultados
    P_G_values = model.getAttr('x', P_G)
    P_c_values = model.getAttr('x', P_c)
    P_d_values = model.getAttr('x', P_d)
    SOC_values = model.getAttr('x', SOC)
    LMP = [model.getConstrByName(f"balance_{t}").Pi for t in range(n_hours)]  # Precio marginal (LMP)
    
    # Crear DataFrame con los resultados
    results_df = pd.DataFrame({
        'Hour': range(n_hours),
        'P_G1': [P_G_values[0, t] for t in range(n_hours)],
        'P_G2': [P_G_values[1, t] for t in range(n_hours)],
        'P_G3': [P_G_values[2, t] for t in range(n_hours)],
        'P_G4': [P_G_values[3, t] for t in range(n_hours)],
        'P_G5': [P_G_values[4, t] for t in range(n_hours)],
        'P_c': [P_c_values[t] for t in range(n_hours)],
        'P_d': [P_d_values[t] for t in range(n_hours)],
        'SOC': [SOC_values[t] for t in range(n_hours)],
        'LMP': LMP
    })
    
    # Graficar el despacho económico por generadores
    plt.figure(figsize=(12, 8))
    plt.plot(results_df['Hour'], results_df['P_G1'], label='P_G1')
    plt.plot(results_df['Hour'], results_df['P_G2'], label='P_G2')
    plt.plot(results_df['Hour'], results_df['P_G3'], label='P_G3')
    plt.plot(results_df['Hour'], results_df['P_G4'], label='P_G4')
    plt.plot(results_df['Hour'], results_df['P_G5'], label='P_G5')
    plt.title('Despacho Económico de Generadores')
    plt.xlabel('Hora')
    plt.ylabel('Potencia (MW)')
    plt.legend()
    plt.grid(True)
    plt.show()

    # Graficar el despacho económico por batería
    plt.figure(figsize=(12, 8))
    plt.plot(results_df['Hour'], results_df['P_c'], label='P_c (Charge)')
    plt.plot(results_df['Hour'], results_df['P_d'], label='P_d (Discharge)')
    plt.plot(results_df['Hour'], results_df['SOC'], label='SOC')
    plt.title('Despacho Económico de Batería')
    plt.xlabel('Hora')
    plt.ylabel('Potencia (MW)')
    plt.legend()
    plt.grid(True)
    plt.show()


    # Graficar el precio marginal
    plt.figure(figsize=(12, 8))
    plt.plot(results_df['Hour'], results_df['LMP'], label='Precio Marginal (LMP)')
    plt.title('Precio Marginal del Sistema')
    plt.xlabel('Hora')
    plt.ylabel('Precio (€/MWh)')
    plt.legend()
    plt.grid(True)
    plt.show()
else:
    print("No se pudo encontrar una solución óptima.")