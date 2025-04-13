%% Basic Financial Analysis
%%
clear all
clc
close all
Io=3000*.3*80+3000*300+500*700;% CAPEX USD
Rate=0.05;%Discount rate %
S=12*27259.92; %OPEX
n=20; %Lifetime
CashFlow=ones(1,n)*S;
NPV = -Io+pvfix(Rate,n,S)
TIR=irr([-Io,CashFlow])*100
BCratio=pvfix(Rate,n,S)/Io
% Define input parameters
PV = -Io; % Present Value (initial loan or investment amount)
PMT = S;  % Payment made each period (e.g., monthly)
rate = Rate; % Interest rate per period (annual interest rate divided by 12 for monthly)
FV = 0;     % Future Value (desired amount at the end of the periods, typically 0 for loans)
% Calculate the number of periods (NPER)
if rate == 0
    % Special case where interest rate is 0
    NPER = PV / PMT;
else
    % General formula for NPER
    NPER = log((PMT - rate * FV) / (PMT + rate * PV)) / log(1 + rate);
end
NPER