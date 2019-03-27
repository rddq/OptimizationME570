clear
syms f(h,w) h w g1(h,w) g2(h,w) g3(h,w) lambda1 lambda2 lambda3 lambda4 lambda5

f(h,w) = -(h*w);
dfh = diff(f,h);
dfw = diff(f,w);

g1(h,w) = -(h - 0.6);
dg1h = diff(g1, h);
dg1w = diff(g1, w);

g2(h,w) = -(w - 0.8);
dg2h = diff(g2, h);
dg2w = diff(g2, w);

hyp = sqrt(0.4^2+0.6^2);
side1 = 0.4;
side2 = 0.6;
a = hyp/sqrt((w/2)^2+h^2);
b = side1/(w/2);
c = side2/(h);

g3(h,w) = a-b;
dg3h = diff(g3, h);
dg3w = diff(g3, w);

g4(h,w) = (b-c);
dg4h = diff(g4, h);
dg4w = diff(g4, w);

g5(h,w) = (c-a);
dg5h = diff(g5, h);
dg5w = diff(g5, w);

solution = solve(dfh - lambda1*dg1h - lambda2*dg2h == 0 - lambda3*dg3h - lambda4*dg4h - lambda5*dg5h,...
    dfw - lambda1*dg1w - lambda2*dg2w - lambda3*dg3w - lambda4*dg4w - lambda5*dg5w == 0, g1 == 0, g2 == 0, g3 == 0, g4 ==0, g5 == 0)
lambda1 = solution.lambda1
lambda2 = solution.lambda2
lambda3 = solution.lambda3
lambda4 = solution.lambda4
lambda5 = solution.lambda5

h = solution.h/2
w = solution.w/2

