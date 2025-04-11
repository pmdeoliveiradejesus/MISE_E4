$title Economic Load Dispatch (LP model) M1_2_E1_2
* Paulo M. De Oliveira-De Jesus pdeoliv@gmail.com
Variable x1, x2, of;
Equation eq1, eq2, eq3, eq4;
eq1.. x1              =l= 400;
eq2.. x2              =l= 300;
eq3.. x1 + x2         =e= 600;
eq4.. 20 * x1 + 25 * x2 =e= of;
Model LP1 / all /;
solve LP1 using lp minimizing of;
display x1.l, x2.l, of.l;
execute_unload 'Results M1_2_E1_2.gdx';