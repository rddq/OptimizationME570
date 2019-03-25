syms f(x1,x2) x1 x2 g(x1,x2) lambda
f(x1,x2) = 4*x1 - 3*x2 + 2*x1^2 - 3*x1*x2 + 4*x2^2;
df1 = diff(f,x1);
df2 = diff(f,x2);

% gx1
g(x1,x2) = 2*x1 - 1.5*x2 - 5;
dg1 = diff(g,x1);
dg2 = diff(g,x2);

solution = solve(df1 - lambda*dg1 == 0, df2 - lambda*dg2 == 0, g == 0);
lambda1 = double(solution.lambda);
x1 = double(solution.x1);
x2 = double(solution.x2);
answer1 = double(f(x1,x2));

% Part B
syms f(x1,x2) x1 x2 g(x1,x2) lambda
f(x1,x2) = 4*x1 - 3*x2 + 2*x1^2 - 3*x1*x2 + 4*x2^2;
df1 = diff(f,x1);
df2 = diff(f,x2);

% gx1
g(x1,x2) = 2*x1 - 1.5*x2 - 5.1;
dg1 = diff(g,x1);
dg2 = diff(g,x2);

solution = solve(df1 - lambda*dg1 == 0, df2 - lambda*dg2 == 0, g == 0);
lambda = double(solution.lambda);
x1 = double(solution.x1);
x2 = double(solution.x2);
answer2 = double(f(x1,x2));

real_change_f = answer2-answer1
approximated_change_f = lambda1*(5.1-5)

%If a problem has a quadratic objective and linear equality constraint,
%then the KKT constraint is linear. This is also true for a problem with a
%quadratic objective and a linear inequality constraint. This is because
%the KKT conditions are with respect to the derivatives  of the function,
% which means they will always be linear since the derivative of a
% quadratic function is always linear. 

