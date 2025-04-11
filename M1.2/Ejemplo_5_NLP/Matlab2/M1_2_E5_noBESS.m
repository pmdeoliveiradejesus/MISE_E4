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

     %PV  loadcurve 
A=[0.0000	0.676	;
0.0000	0.702	;
0.0000	0.683	;
0.0000	0.676	;
0.0000	0.682	;
0.0000	0.720	;
0.1545	0.851	;
0.3471	0.903	;
0.5489	0.974	;
0.7240	0.965	;
0.8527	0.983	;
0.9598	0.999	;
1.0000	0.991	;
0.9228	0.921	;
0.8733	0.903	;
0.7250	0.947	;
0.5469	0.939	;
0.3481	1.000	;
0.1462	0.956	;
0.0000	0.939	;
0.0000	0.815	;
0.0000	0.771	;
0.0000	0.764	;
0.0000	0.720	;
0.0000	0.6554	;
0.0000	0.6805	;
0.0000	0.6630	;
0.0000	0.6554	;
0.0000	0.6617	;
0.0000	0.6980	;
0.1468	0.8259	;
0.3297	0.8760	;
0.5215	0.9449	;
0.6878	0.9362	;
0.8101	0.9537	;
0.9118	0.9687	;
0.9500	0.9612	;
0.8766	0.8936	;
0.8297	0.8760	;
0.6888	0.9186	;
0.5195	0.9111	;
0.3307	0.9700	;
0.1389	0.9274	;
0.0000	0.9111	;
0.0000	0.7908	;
0.0000	0.7482	;
0.0000	0.7407	;
0.0000	0.6980	;
0.0000	0.6423	;
0.0000	0.6669	;
0.0000	0.6497	;
0.0000	0.6423	;
0.0000	0.6485	;
0.0000	0.6841	;
0.1321	0.8094	;
0.2967	0.8585	;
0.4693	0.9260	;
0.6190	0.9174	;
0.7291	0.9346	;
0.8207	0.9494	;
0.8550	0.9420	;
0.7890	0.8757	;
0.7467	0.8585	;
0.6199	0.9002	;
0.4676	0.8929	;
0.2976	0.9506	;
0.1250	0.9088	;
0.0000	0.8929	;
0.0000	0.7750	;
0.0000	0.7332	;
0.0000	0.7258	;
0.0000	0.6841	];
%systemdata;
T=length(A);
Pl=A(:,2)';
PV=A(:,1)';
SOC0=100;%MWh
C=300;%MWh
PVcap=500;
SOCmax=0.9*C;
SOCmin=0.1*C;
Pdmin=0;
Pdmax=0.3*C;
Pcmin=0;
Pcmax=0.4*C;
etac=0.95;
etad=0.92;
Dmax=1500;%MW Demanda Máxima
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
% x0(0*T+1:1*T)=SOCmax;%SOC
% x0(1*T+1:2*T)=Pdmax;%Pdt
% x0(2*T+1:3*T)=Pcmax;%Pct
x0(0*T+1:5*T)=Pgmax;%Pg
%Bounds
% lb(0*T+1:1*T)=SOCmin-00;%SOC
% lb(1*T+1:2*T)=Pdmin-00;%Pdt
% lb(2*T+1:3*T)=Pcmin-00;%Pct
lb(0*T+1:5*T)=Pgmin-00;%Pg
% ub(0*T+1:1*T)=SOCmax+00;%SOC
% ub(1*T+1:2*T)=Pdmax+00;%Pdt
% ub(2*T+1:3*T)=Pcmax+00;%Pct
ub(0*T+1:5*T)=Pgmax+00;%Pg
% lb(T)=SOC0;%SOC0
% ub(T)=SOC0;%SOC0
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
% SOC=x(0*T+1:1*T);%SOC
% Pd=x(1*T+1:2*T);%Pdt
% Pc=x(2*T+1:3*T);%Pct
Pg=x(0*T+1:5*T);%Pg
Pg1=x(0*T+1:1*T);%Pg1
Pg2=x(1*T+1:2*T);%Pg2
Pg3=x(2*T+1:3*T);%Pg3
Pg4=x(3*T+1:4*T);%Pg4
Pg5=x(4*T+1:5*T);%Pg5
Wg=sum(Pg)/1000;
Wl=Dmax*sum(Pl)/1000;
Wpv=sum(PV)*PVcap/1000;
% Wc=sum(Pc)/1000;
% Wd=sum(Pd)/1000;
Wg+Wpv-Wl
for k=1:T
    margPrice(k)=-lambda.eqnonlin(k); %Eur/MWh
end
PVincome= sum(PV*PVcap.*margPrice)*1e-6;% Euro million
Gincome= sum((Pg1+Pg2+Pg3+Pg4+Pg5).*margPrice)*1e-6;% Euro million
Gprofit=Gincome-fval*1e-6;% Euro million
Dpayment=sum(Dmax*Pl.*margPrice)*1e-6;% Euro million


function [f] = objective_func(x)
global a b cc T  
% SOC=x(0*T+1:1*T);%SOC
% Pd=x(1*T+1:2*T);%Pdt
% Pc=x(2*T+1:3*T);%Pct
Pg=x(0*T+1:5*T);%Pg

for t = 1:5*T
TC(t)=a(t)*Pg(t)^2+b(t)*Pg(t)+cc(t);
end
f=sum(TC);%Social Cost Minimization
end

function [c,ceq] = network_model(x)
global etad etac T SOC0 Pl RU01 RD01 RU02 RD02 RU03 RD03 RU04 RD04 RU05 RD05  Pl ceq c
global Pg1 Pg2 Pg3 Pg4 Pg5 Pd Pc Pl SOC PVcap PV Dmax
% SOC=x(0*T+1:1*T);%SOC
% Pd=x(1*T+1:2*T);%Pdt
% Pc=x(2*T+1:3*T);%Pct
Pg1=x(0*T+1:1*T);%Pg1
Pg2=x(1*T+1:2*T);%Pg2
Pg3=x(2*T+1:3*T);%Pg3
Pg4=x(3*T+1:4*T);%Pg4
Pg5=x(4*T+1:5*T);%Pg5
 
% Equality constraints

%for t=1:T 
% if t==1
%     ceq(t) = -SOC(t)+SOC0+Pc(t)*etac-Pd(t)/etad;
% else
%     ceq(t) = -SOC(t)+SOC(t-1)+Pc(t)*etac-Pd(t)/etad;
% end
%end 
for t=1:T
ceq(t) = Pg1(t)+Pg2(t)+Pg3(t)+Pg4(t)+Pg5(t)+PVcap*PV(t)-Dmax*Pl(t);
end 
%     ceq(1+T) = -SOC(1)+SOC0+Pc(1)*etac-Pd(1)/etad;
% for t=2:T
%     ceq(t+T) = -SOC(t)+SOC(t-1)+Pc(t)*etac-Pd(t)/etad;
% end 




 
%ceq(48+1) = SOC(24)-SOC0;
%ceq(25+1) = sum(Pc)-sum(Pd);
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





