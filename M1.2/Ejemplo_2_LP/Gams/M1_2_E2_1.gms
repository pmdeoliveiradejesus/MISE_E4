$title Economic Load Dispatch (LP model) M1_2_E1_1
* Paulo M. De Oliveira-De Jesus pdeoliv@gmail.com
Set Gen / g1*g2 /;
Scalar load / 600 /;
Table data(Gen,*)
        b   Pmin  Pmax
   G1   20  0     400
   G2   25  0     300
Variable P(gen), OF;
Equation eq1, eq2;
eq1.. OF =e= sum(gen, data(gen,'b')*P(gen));
eq2.. sum(gen,P(gen)) =g= load;
P.lo(gen) = data(gen,'Pmin');
P.up(gen) = data(gen,'Pmax');
Model ED / eq1, eq2 /;
solve ED using lp minimizing OF;
execute_unload 'Results M1_2_E1_1.gdx';
