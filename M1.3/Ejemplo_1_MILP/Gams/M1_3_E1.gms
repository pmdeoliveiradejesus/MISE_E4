$title  (LP model) 
* Paulo M. De Oliveira-De Jesus pdeoliv@gmail.com
Variable x2, x3, z;
Integer Variable x1;
Positive Variables x2, x3;
Equation eq1, eq2, eq3;
eq1.. 1 * x1 + 2 * x2 + 1 * x3 =l= 10;
eq2.. 2 * x1 + 1 * x2 + 3 * x3 =l= 15;
eq3.. 3 * x1 + 5 * x2 + 2 * x3 =e= z;
Model MILP / all /;
solve MILP using mip maximizing z;
display x1.l, x2.l, x3.l, z.l;
execute_unload 'Results M1_3_MILP_E1.gdx';