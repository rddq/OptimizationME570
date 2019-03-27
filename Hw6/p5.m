clear
syms f(h,w) h w g1(h,w) g2(h,w) g3(h,w) lambda1 lambda2 lambda3

f(h,w) = -h*w;
dfh = diff(f,h);
dfw = diff(f,w);

g1(h,w) = -(h - 0.8);
dg1h = diff(g1, h);
dg1w = diff(g1, w);

g2(h,w) = -(w - 0.6);
dg2h = diff(g2, h);
dg2w = diff(g2, w);

g3(h,w) = - ((0.6 - w)/(0.4 - (h/2))) + 0.6;
dg3h = diff(g3, h);
dg3w = diff(g3, w);

solution = solve(dfh - lambda1*dg1h - lambda2*dg2h == 0,...
    dfw - lambda1*dg1w - lambda2*dg2w == 0, g1 == 0, g2 == 0)
solution.lambda1
solution.lambda2
h = solution.h
w = solution.w
