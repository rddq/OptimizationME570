% Part C
clear
syms f(x1,x2) x1 x2 g2(x1,x2) g3(x1,x2) lambda2 

f(x1,x2) = x1^2 + x2;
dfx1 = diff(f,x1);
dfx2 = diff(f,x2);

g2(x1,x2) = -(x1 + x2^2 - 1);
dg2x1 = diff(g2,x1);
dg2x2 = diff(g2,x2);

solution = solve(dfx1 - lambda2*dg2x1 == 0,...
    dfx2 - lambda2*dg2x2 == 0, g2 == 0);
lambda2 = double(solution.lambda2)
x1 = double(solution.x1)
x2 = double(solution.x2)

lambda2_real = 0.4516;
optimum_value = (-0.2258)^2 + -1.1072;
