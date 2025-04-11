$title  (NLP_QP model) 
* Paulo M. De Oliveira-De Jesus pdeoliv@gmail.com
Variable x1, x2, x3, z;
Positive Variables x1, x2, x3;
Equation eq1, eq2, eq3;
eq1.. 2*x1*x1 + x1*x2 + x2*x2 + 1.5*x3*x3 + x1 -2*x2 =e= z;
eq2.. x1*x1 +   x2*x2 +   x3*x3 =e= 4;
eq3.. x1*x1 - 2*x1 +x2*x2    =l= 0;
Model QP / all /;
solve QP using qcp minimizing z;
display x1.l, x2.l, x3.l, z.l;
execute_unload 'Results M1_1_NLP_QP_E1.gdx';