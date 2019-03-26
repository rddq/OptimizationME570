syms f(x1,x2,x3) x1 x2 x3 g1(x1,x2,x3) g2(x1,x2,x3) lambda1 lambda2
f(x1,x2,x3) = x1^2 + 2*x2^2 + 3*x3^2;
dfx1 = diff(f,x1);
dfx2 = diff(f,x2);
dfx3 = diff(f,x3);

g1(x1,x2,x3) = x1 + 5*x2 - 12;
dg1x1 = diff(g1,x1);
dg1x2 = diff(g1,x2);
dg1x3 = diff(g1,x3);

g2(x1,x2,x3) = -(-2*x1 + x2 - 4*x3 + 18);
dg2x1 = diff(g2,x1);
dg2x2 = diff(g2,x2);
dg2x3 = diff(g2,x3);

solution = solve(dfx1 - lambda1*dg1x1 - lambda2*dg2x1 == 0,...
    dfx2 - lambda1*dg1x2 - lambda2*dg2x2 == 0,...
dfx3 - lambda1*dg1x3 - lambda2*dg2x3 == 0, g1 == 0, g2 == 0);

lambda1 = double(solution.lambda1)
lambda2 = double(solution.lambda2)
x1 = double(solution.x1)
x2 = double(solution.x2)
x3 = double(solution.x3)
function_value = double(f(x1,x2,x3))
