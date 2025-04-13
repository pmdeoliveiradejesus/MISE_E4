%% Project C3_P1 
%% IELE4100 Planeamiento de Sistemas de POtencia (c) 2024
% Prof. Paulo M. De Oliveira pdeoliv@gmail.com 
clear all
clc
close all
global  etad etac T SOC0 a b cc RU01 RD01 RU02 RD02 RU03 RD03 RU04 RD04 RU05 RD05 Pl 
global Pg1 Pg2 Pg3 Pg4 Pg5 Pd Pc Pl SOC  PVcap PV Dmax
%% GenData
   %   a     b    c d e f  Pgmin Pgmax  Rup  Rdonw
   G=[ 0.14  44.0 0 0 0 0    30  300    45   45;
       0.13  43.7 0 0 0 0    25  390    35   45;
       0.14  45.5 0 0 0 0    35  390    35   35;
       0.12  34.1 0 0 0 0    25  360    55   45;
       0.16  35.1 0 0 0 0    25  360    35   55];
systemdata;%load and PV database
T=length(A);%time span
Pl=A(:,2)';%load pattern
PV=A(:,1)';%irradiance pattern
SOC0=100;%MWh Final SOC
C=300;%MWh Battery Capacity
PVcap=500;% MW PV farm capacity
SOCmax=0.9*C;%MWh
SOCmin=0.1*C;%MWh
Pdmin=0;
Pdmax=0.3*C;
Pcmin=0;
Pcmax=0.4*C;
etac=0.95;%charging efficiency
etad=0.92;%discharging efficiency
Dmax=1500;%MW Maximum Demand
a=[G(1,1)*ones(T,1);G(2,1)*ones(T,1);G(3,1)*ones(T,1);G(4,1)*ones(T,1);G(5,1)*ones(T,1)];
b=[G(1,2)*ones(T,1);G(2,2)*ones(T,1);G(3,2)*ones(T,1);G(4,2)*ones(T,1);G(5,2)*ones(T,1)];
cc=[G(1,3)*ones(T,1);G(2,3)*ones(T,1);G(3,3)*ones(T,1);G(4,3)*ones(T,1);G(5,3)*ones(T,1)];
Pgmin=[G(1,7)*ones(T,1);G(2,7)*ones(T,1);G(3,7)*ones(T,1);G(4,7)*ones(T,1);G(5,7)*ones(T,1)];
Pgmax=[G(1,8)*ones(T,1);G(2,8)*ones(T,1);G(3,8)*ones(T,1);G(4,8)*ones(T,1);G(5,8)*ones(T,1)];
RU01=[G(1,9)*ones(T,1)];
RD01=[G(1,10)*ones(T,1)];
RU02=[G(2,9)*ones(T,1)];
RD02=[G(2,10)*ones(T,1)];
RU03=[G(3,9)*ones(T,1)];
RD03=[G(3,10)*ones(T,1)];
RU04=[G(4,9)*ones(T,1)];
RD04=[G(4,10)*ones(T,1)];
RU05=[G(5,9)*ones(T,1)];
RD05=[G(5,10)*ones(T,1)];

%% OPTIMIZATION BEGINS HERE
time000=cputime;
%x0
x0(0*T+1:1*T)=SOCmax;%SOC
x0(1*T+1:2*T)=Pdmax;%Pdt
x0(2*T+1:3*T)=Pcmax;%Pct
x0(3*T+1:8*T)=Pgmax;%Pg
%Bounds
lb(0*T+1:1*T)=SOCmin-00;%SOC
lb(1*T+1:2*T)=Pdmin-00;%Pdt
lb(2*T+1:3*T)=Pcmin-00;%Pct
lb(3*T+1:8*T)=Pgmin-00;%Pg
ub(0*T+1:1*T)=SOCmax+00;%SOC
ub(1*T+1:2*T)=Pdmax+00;%Pdt
ub(2*T+1:3*T)=Pcmax+00;%Pct
ub(3*T+1:8*T)=Pgmax+00;%Pg
lb(T)=SOC0;%SOC0
ub(T)=SOC0;%SOC0
Aeq = [];
beq = [];
%FMINCON calculation
options = optimoptions('fmincon');
options.MaxFunctionEvaluations = 5000000;
options.ConstraintTolerance = 1.0000e-8;
options.MaxIterations = 100000;
options.OptimalityTolerance = 1.0000e-8;
options.StepTolerance = 1.0000e-8;
options.Display='iter';
options.Algorithm='interior-point';
%options.Algorithm='sqp';
[x,fval,exitflag,output,lambda,grad,hessian] = fmincon(@objective_func, x0, [], [], Aeq, beq, lb, ub, @network_model, options);
elapsedtime000=(cputime-time000)/3600 % Set simulation time
exitflag
SOC=x(0*T+1:1*T);%SOC
Pd=x(1*T+1:2*T);%Pdt
Pc=x(2*T+1:3*T);%Pct
Pg=x(3*T+1:8*T);%Pg
Pg1=x(3*T+1:4*T);%Pg1
Pg2=x(4*T+1:5*T);%Pg2
Pg3=x(5*T+1:6*T);%Pg3
Pg4=x(6*T+1:7*T);%Pg4
Pg5=x(7*T+1:8*T);%Pg5
Wg=sum(Pg)/1000;
Wl=Dmax*sum(Pl)/1000;
Wpv=sum(PV)*PVcap/1000;
Wc=sum(Pc)/1000;
Wd=sum(Pd)/1000;
Wg+Wpv-Wl+Wd-Wc
for k=1:T
    margPrice(k)=-lambda.eqnonlin(k); %Eur/MWh
end
PVincome= sum(PV*PVcap.*margPrice)*1e-6;% Euro million
Gincome= sum((Pg1+Pg2+Pg3+Pg4+Pg5).*margPrice)*1e-6;% Euro million
Gprofit=Gincome-fval*1e-6;% Euro million
Dpayment=sum(Dmax*Pl.*margPrice)*1e-6;% Euro million
BESSprofit=sum((Pd-Pc).*margPrice*1e-6);% Euro million
%% --------------------------------
function [f] = objective_func(x)
global a b cc T  
SOC=x(0*T+1:1*T);%SOC
Pd=x(1*T+1:2*T);%Pdt
Pc=x(2*T+1:3*T);%Pct
Pg=x(3*T+1:8*T);%Pg
for t = 1:5*T
TC(t)=a(t)*Pg(t)^2+b(t)*Pg(t)+cc(t);
end
f=sum(TC);%Social Cost Minimization
end
%% -------------------------------
function [c,ceq] = network_model(x)
global etad etac T SOC0 Pl RU01 RD01 RU02 RD02 RU03 RD03 RU04 RD04 RU05 RD05  Pl ceq c
global Pg1 Pg2 Pg3 Pg4 Pg5 Pd Pc Pl SOC PVcap PV Dmax
SOC=x(0*T+1:1*T);%SOC
Pd=x(1*T+1:2*T);%Pdt
Pc=x(2*T+1:3*T);%Pct
Pg1=x(3*T+1:4*T);%Pg1
Pg2=x(4*T+1:5*T);%Pg2
Pg3=x(5*T+1:6*T);%Pg3
Pg4=x(6*T+1:7*T);%Pg4
Pg5=x(7*T+1:8*T);%Pg5
 
% Equality constraints
for t=1:T
ceq(t) = Pg1(t)+Pg2(t)+Pg3(t)+Pg4(t)+Pg5(t)+PVcap*PV(t)+Pd(t)-Pc(t)-Dmax*Pl(t);
end 
    ceq(1+T) = -SOC(1)+SOC0+Pc(1)*etac-Pd(1)/etad;
for t=2:T
    ceq(t+T) = -SOC(t)+SOC(t-1)+Pc(t)*etac-Pd(t)/etad;
end 
for t=2:T
c1(t)= Pg1(t)-Pg1(t-1)-RU01(t);
c2(t)= Pg2(t)-Pg2(t-1)-RU02(t);
c3(t)= Pg3(t)-Pg3(t-1)-RU03(t);
c4(t)= Pg4(t)-Pg4(t-1)-RU04(t);
c5(t)= Pg5(t)-Pg5(t-1)-RU05(t);
end
for t=2:T
c6(t-1)= Pg1(t-1)-Pg1(t)-RD01(t);
c7(t-1)= Pg2(t-1)-Pg2(t)-RD02(t);
c8(t-1)= Pg3(t-1)-Pg3(t)-RD03(t);
c9(t-1)= Pg4(t-1)-Pg4(t)-RD04(t);
c10(t-1)= Pg5(t-1)-Pg5(t)-RD05(t);
c=[c1,c2,c3,c4,c5,c6,c7,c8,c9,c10];
end
end





