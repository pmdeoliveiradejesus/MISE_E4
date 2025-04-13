$title Economic Load Dispatch


Set Gen / g1*g2 /;

Scalar load / 600 /;

Table data(Gen,*)
       a     b      c       Pmin  Pmax
   G1  0.025 20     100     0     400
   G2  0.05  25     200     0     300


Variable P(gen), OF;
Equation eq1, eq2;

eq1.. OF =e= sum(gen, data(gen,'a')*P(gen)*P(gen) + data(gen,'b')*P(gen) + data(gen,'c'));

eq2.. sum(gen,P(gen)) =g= load;

P.lo(gen) = data(gen,'Pmin');
P.up(gen) = data(gen,'Pmax');

Model ED / eq1, eq2 /;
solve ED using qcp minimizing of;