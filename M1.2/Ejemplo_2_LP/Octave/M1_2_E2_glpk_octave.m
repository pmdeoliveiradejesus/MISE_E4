%  M1_2_E1_glpk_matlab
%  Paulo M. De Oliveira De Jesus pdeoliv@gmail.com
% Objective function coefficients
clc
clear all
c = [20; 25];
% Inequality constraints (Ax <= b)
A = [1, 0; 0, 1;1,1]; % Coefficients of x1 and x2 in the  constraints
b = [400; 300;600];   % Right-hand side of the  constraints
% Lower and upper bounds on variables (lb <= x <= ub)
lb = [0; 0];    % Lower bounds on x1 and x2 (both are non-negative)
ub = [];        % No upper bounds specified
ctype = "UUS";
% Solve the linear programming problem
[x, fval, status, extra] = glpk(c, A, b, lb, ub, ctype);
% Display the results
disp('Optimal solution:');
disp(['x1 = ', num2str(x(1)), ' MW']);
disp(['x2 = ', num2str(x(2)), ' MW']);
disp(['Optimal objective value: ', num2str(fval), ' $/h']);
disp(['Status: ', num2str(extra.status)]);
disp(['Shadow price NonEquality Const. 1: ', num2str(extra.lambda(1)), ' $/MWh']);
disp(['Shadow price NonEquality Const. 2: ', num2str(extra.lambda(2)), ' $/MWh']);
disp(['Shadow price    Equality Const. 3: ', num2str(extra.lambda(3)), ' $/MWh']);
