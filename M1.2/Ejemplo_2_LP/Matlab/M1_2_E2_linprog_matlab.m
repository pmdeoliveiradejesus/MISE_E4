%  M1_2_E1_linprog_matlab
%  Paulo M. De Oliveira De Jesus pdeoliv@gmail.com
% Objective function coefficients
f = [20; 25];

% Inequality constraints (Ax <= b)
A = [1, 0; 0, 1]; % Coefficients of x1 and x2 in the inequality constraints
b = [400; 300];   % Right-hand side of the inequality constraints

% Equality constraints (Aeq*x = beq)
Aeq = [1, 1];   % Coefficients of x1 and x2 in the equality constraint
beq = 600;      % Right-hand side of the equality constraint

% Lower and upper bounds on variables (lb <= x <= ub)
lb = [0; 0];    % Lower bounds on x1 and x2 (both are non-negative)
ub = [];        % No upper bounds specified

% Solve the linear programming problem
%[x, fval, exitflag, output,lambda] = linprog(f, A, b, Aeq, beq, lb, ub);
[x, fval, exitflag, output,lambda] = glpk(f, A, b, Aeq, beq, lb, ub);
% Display the results
disp('Optimal solution:');
disp(['x1 = ', num2str(x(1)), ' MW']);
disp(['x2 = ', num2str(x(2)), ' MW']);
disp(['Optimal objective value: ', num2str(fval), ' $/h']);
disp(['Exit flag: ', num2str(exitflag)]);
disp(['Shadow price    Equality Const. 1: ', num2str(-lambda.eqlin(1)), ' $/MWh']);
disp(['Shadow price NonEquality Const. 2: ', num2str(lambda.ineqlin(1)), ' $/MWh']);
disp(['Shadow price NonEquality Const. 3: ', num2str(lambda.ineqlin(2)), ' $/MWh']);



