$title M1_4_E1 Despacho óptimo de una industria con equipamiento de almacenamiento y autoproducción de energía eléctrica

Set
   t 'hours'         / t1*t24 /;

Table data(t,*)
    lambda  Plu     Ppvu
 t1 0.11    0.68    0.00
 t2 0.11    0.70    0.00
 t3 0.11    0.68    0.00
 t4 0.11    0.68    0.00
 t5 0.11    0.68    0.00
 t6 0.12    0.72    0.00
 t7 0.15    0.85    0.15
 t8 0.17    0.90    0.35
 t9 0.18    0.97    0.55
t10 0.16    0.97    0.72
t11 0.15    0.98    0.85
t12 0.13    1.00    0.96
t13 0.13    0.99    1.00
t14 0.13    0.92    0.92
t15 0.14    0.90    0.87
t16 0.13    0.95    0.73
t17 0.18    0.94    0.55
t18 0.14    1.00    0.35
t19 0.14    0.96    0.15
t20 0.14    0.94    0.00
t21 0.15    0.82    0.00
t22 0.15    0.77    0.00
t23 0.15    0.76    0.00
t24 0.12    0.72    0.00;  
* -----------------------------------------------------

Variable
   Benefit     'Benefit USD/month'
   SOC(t)      'State of Charge  kWh'
   Pd(t)       'Power battery discharge  kW'
   Pc(t)       'Power battery charge  kW' 
   Pb(t)       'Power bought from the public grid kW'
   Ps(t)       'Power sold to the public grid kW'
   Pbmax       'Max Power bougth/sold to the public grid kW during a month';
      
Binary Variable
   w1(t)     
   w3(t);   
     
Scalar 
   Ppvmax    / 500/
   Plmax     / 1000 /
   SOC0      / 300  /
   C         / 3000  /
   eff_c     / 0.95 /
   eff_d     / 0.92 /
   R_c      / 0.3 /
   R_d      / 0.2 /
   DoD       /0.8/
   psi       /0.05/
   Pmax      /5000/
   kappa     /36/;
   
SOC.up(t)     = ((1-DoD)/2+DoD)*C;
SOC.lo(t)     = ((1-DoD)/2)*C;
SOC.fx('t24') = SOC0;
Pc.lo(t) = 0;
Pd.lo(t) = 0;
Pb.lo(t) = 0;
Ps.lo(t) = 0;

Equation Bcalc, balance1, r1, r2, r3, r4, r5, r6;

Bcalc..         Benefit =e=  -1*kappa*pbmax+30*sum((t), (data(t,'lambda')*ps(t)-(data(t,'lambda')+psi)*pb(t)));
balance1(t)..   Pd(t) + Pb(t) + Ppvmax*data(t,'Ppvu') =e= Pc(t) +Ps(t) + Plmax*data(t,'Plu');
r1(t)..         SOC(t) =e= SOC0$(ord(t)=1) + SOC(t-1)$(ord(t)>1) + Pc(t)*eff_c  - Pd(t)/eff_d;
r2(t)..  Pc(t) =l= R_c*C*w1(t);
r3(t)..  Pd(t) =l= R_d*C*(1-w1(t));
r4(t)..  Pb(t) =l= Pmax*w3(t);
r5(t)..  Ps(t) =l= Pmax*(1-w3(t));
r6(t)..  Pbmax =g= Pb(t)+Ps(t);

Model modelCe / all /;
solve modelCe using mip maximizing Benefit

execute_unload 'Results M1_4_E1.gdx';
