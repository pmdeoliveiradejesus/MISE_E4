$title Despacho Económico Integrado con Renovables y Almacenamiento
$onText
IELE4100 - Planeamiento de Sistemas de Potencia
Proyecto M1_2_E5
$offText
Set
   t 'horas'              / t1*t72 /
   i 'unidades térmicas'  / Pg1*Pg5  /;
Table gdta(i,*) 'Tabla de dtos de los geeradores térmicos'
         a      b    Pgmin  Pgmax  Rup  Rdown
    Pg1  0.14  44.0  30     300    45   45
    Pg2  0.13  43.7  25     390    35   45
    Pg3  0.14  45.5  35     390    35   35
    Pg4  0.12  34.1  25     360    55   45
    Pg5  0.16  35.1  25     360    35   55;
Table sdta(t,*)
            PV      loadcurve    
t1         0.0000  0.676
t2         0.0000  0.702
t3         0.0000  0.683
t4         0.0000  0.676
t5         0.0000  0.682
t6         0.0000  0.720
t7         0.1545  0.851
t8         0.3471  0.903
t9         0.5489  0.974
t10        0.7240  0.965
t11        0.8527  0.983
t12        0.9598  0.999
t13        1.0000  0.991
t14        0.9228  0.921
t15        0.8733  0.903
t16        0.7250  0.947
t17        0.5469  0.939
t18        0.3481  1.000
t19        0.1462  0.956
t20        0.0000  0.939
t21        0.0000  0.815
t22        0.0000  0.771
t23        0.0000  0.764
t24        0.0000  0.720
t25        0.0000  0.6554
t26        0.0000  0.6805
t27        0.0000  0.6630
t28        0.0000  0.6554
t29        0.0000  0.6617
t30        0.0000  0.6980
t31        0.1468  0.8259
t32        0.3297  0.8760
t33        0.5215  0.9449
t34        0.6878  0.9362
t35        0.8101  0.9537
t36        0.9118  0.9687
t37        0.9500  0.9612
t38        0.8766  0.8936
t39        0.8297  0.8760
t40        0.6888  0.9186
t41        0.5195  0.9111
t42        0.3307  0.9700
t43        0.1389  0.9274
t44        0.0000  0.9111
t45        0.0000  0.7908
t46        0.0000  0.7482
t47        0.0000  0.7407
t48        0.0000  0.6980
t49        0.0000  0.6423
t50        0.0000  0.6669
t51        0.0000  0.6497
t52        0.0000  0.6423
t53        0.0000  0.6485
t54        0.0000  0.6841
t55        0.1321  0.8094
t56        0.2967  0.8585
t57        0.4693  0.9260
t58        0.6190  0.9174
t59        0.7291  0.9346
t60        0.8207  0.9494
t61        0.8550  0.9420
t62        0.7890  0.8757
t63        0.7467  0.8585
t64        0.6199  0.9002
t65        0.4676  0.8929
t66        0.2976  0.9506
t67        0.1250  0.9088
t68        0.0000  0.8929
t69        0.0000  0.7750
t70        0.0000  0.7332
t71        0.0000  0.7258
t72        0.0000  0.6841;
* -------GAMS académico solo soporta 1000 restricciones
Variable
   costototal   'Costo de Producción Eur/kWh'
   Pg(i,t)       'Generación Térmica MW'
   SOC(t)       'Estado de Carga MWh'
   Pdesc(t)     'Potencia de Descarga MW'
   Pcarg(t)     'Potencia de Carga MW';
* Dtos del problema
Scalar
   SOCfinal    / 100  /
   Capacidad   / 300  /
   eff_c      / 0.95 /
   eff_d      / 0.92 /
   CRte_carg / 0.3 /
   CRte_desc / 0.4 /
   PVcap     / 500 /
   Dmax      /1500/
   DoD       /0.8/;
* Limites
SOC.up(t)     = ((1-DoD)/2+DoD)*Capacidad;
SOC.lo(t)     = ((1-DoD)/2)*Capacidad;
Pg.up(i,t) = gdta(i,"Pgmax");
Pg.lo(i,t) = gdta(i,"Pgmin");
Pcarg.up(t) = Crte_carg*Capacidad; 
Pcarg.lo(t) = 0;
Pdesc.up(t) = Crte_desc*Capacidad;
Pdesc.lo(t) = 0;
* Nivel lde carga al final del ciclo
SOC.fx('t72') = SOCfinal; 
Equation r1, r2, r4, r3, objetivo;
objetivo.. costototal =e= sum((t,i), gdta(i,'a')*power(Pg(i,t),2) + gdta(i,'b')*Pg(i,t));
r1(i,t).. Pg(i,t+1) - Pg(i,t) =l= gdta(i,'Rup');
r2(i,t).. Pg(i,t-1) - Pg(i,t) =l= gdta(i,'Rdown');
r3(t)..   SOC(t) =e= SOCfinal$(ord(t)=1) + SOC(t-1)$(ord(t)>1) + Pcarg(t)*eff_c - Pdesc(t)/eff_d;
r4(t)..   sum(i, Pg(i,t)) + Pdesc(t) + sdta(t,'PV')*PVcap =e= sdta(t,'loadcurve')*Dmax+Pcarg(t);
Model modelo / all /;
solve modelo using qcp minimizing costototal;

 Parameter rep(t,*);
 rep(t,'Gen')  = sum(i,Pg.l(i,t));
 rep(t,'SOC')  = SOC.l(t);
 rep(t,'Pdesc')   = Pdesc.l(t);
 rep(t,'Pcarg')   = Pcarg.l(t);
 rep(t,'Carga') = sdta(t,'loadcurve')*Dmax;
 
execute_unload 'resultados_M1_2_E3.gdx';

