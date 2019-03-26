clear
%% Part A
syms f(x1,x2) x1 x2 g(x1,x2) lambda
f(x1,x2) = 4*x1 - 3*x2 + 2*x1^2 - 3*x1*x2 + 4*x2^2;
df1 = diff(f,x1);
df2 = diff(f,x2);

g(x1,x2) = 2*x1 - 1.5*x2 - 5;
dg1 = diff(g,x1);
dg2 = diff(g,x2);

solution = solve(df1 - lambda*dg1 == 0, df2 - lambda*dg2 == 0, g == 0);
lambda1 = double(solution.lambda)
x1_a = double(solution.x1)
x2_a = double(solution.x2)
minimum_value_a = double(f(x1_a,x2_a))

% The optimum agrees with the graphical optimum.

%% Part B
syms f(x1,x2) x1 x2 g(x1,x2) lambda
f(x1,x2) = 4*x1 - 3*x2 + 2*x1^2 - 3*x1*x2 + 4*x2^2;
df1 = diff(f,x1);
df2 = diff(f,x2);

g(x1,x2) = 2*x1 - 1.5*x2 - 5.1;
dg1 = diff(g,x1);
dg2 = diff(g,x2);

solution = solve(df1 - lambda*dg1 == 0, df2 - lambda*dg2 == 0, g == 0);
lambda = double(solution.lambda);
x1_b = double(solution.x1)
x2_b = double(solution.x2)
minimum_value_b = double(f(x1_b,x2_b))

real_change_f = minimum_value_b-minimum_value_a
approximated_change_f = lambda1*(5.1-5)
difference = real_change_f-approximated_change_f

% The lagrange multiplier predicts the change in objective pretty
% accurately, there is only a difference of 0.005 in the approximation to
% the real.

%% Part C
% If a problem has a quadratic objective and linear equality constraint,
% then the KKT constraints are linear. This is also true for a problem with a
% quadratic objective and a linear inequality constraint. This is because
% the KKT conditions are that the inequality and equality constraints are met and also
% $\sum_{1}^{n}(dfx_{n} - \sum_{1}^{m}\lambda_{m}*dg_{m}x_{n})$ where m is the number of
% constraints and n is the number of inputs.
% The derivative of a linear constraints will always be a constant, and the
% derivative of a quadratic will always be linear, therefore the KKT
% system of equations will always be linear in the situations described
% above.

