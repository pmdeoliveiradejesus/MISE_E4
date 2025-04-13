$title Decentralized Economic Dispatch (LP model) M1_2_E1
* Paulo M. De Oliveira-De Jesus pdeoliv@gmail.com
Set
   bg 'bloque de generacion'    / bg1*bg3 /
   bd 'bloque de demanda'       / bd1*bd4 /;

Table gen(bg,*)
         Eg1    Lg1  Eg2    Lg2     Eg3    Lg3
   bg1   5      1    8      4.5     10     8 
   bg2   12     3    8      5       10     9
   bg3   13     3.5  9      6       5      10;

Table dem(bd,*)
         Ed1    Ld1  Ed2    Ld2     
   bd1   8      20   7      18       
   bd2   5      15   4      16      
   bd3   5      7    4      11
   bd4   3      4    3      3;
* -----------------------------------------------------

Variable
   SW            'Beneficio Social $/h'
   Pd1(bd)       'Accepted bids MW'
   Pd2(bd)       'Accepted bids MW'
   Pg1(bg)       'Acccepted offers MW'
   Pg2(bg)       'Acccepted offers MW'
   Pg3(bg)       'Acccepted offers MW';
 
Pd1.lo(bd) = 0;
Pd2.lo(bd) = 0;
Pg1.lo(bg) = 0;
Pg2.lo(bg) = 0;
Pg3.lo(bg) = 0;

Equation obj, balance, r1, r2, r3, r4, r5;

obj..      SW =e= sum((bd), (dem(bd,'Ld1')*Pd1(bd))) + 
                   sum((bd), (dem(bd,'Ld2')*Pd2(bd))) -
                   sum((bg), (gen(bg,'Lg1')*Pg1(bg))) -
                   sum((bg), (gen(bg,'Lg2')*Pg2(bg))) -
                   sum((bg), (gen(bg,'Lg3')*Pg3(bg)));
balance..  sum((bd), Pd1(bd)+Pd2(bd)) -
           sum((bg), Pg1(bg)+Pg2(bg)+Pg3(bg)) =e= 0;
r1(bd)..   Pd1(bd) =l= dem(bd,'Ed1');
r2(bd)..   Pd2(bd) =l= dem(bd,'Ed2');
r3(bg)..   Pg1(bg) =l= gen(bg,'Eg1');
r4(bg)..   Pg2(bg) =l= gen(bg,'Eg2');
r5(bg)..   Pg3(bg) =l= gen(bg,'Eg3');

Model modelo / all /;
solve modelo using LP maximizing SW

execute_unload 'M1_2_E1.gdx';
