clear
syms x1 x2 f(x1,x2) g(x1,x2) lambda

f(x1,x2) = x1^4 - 2*x2*x1^2 + x2^2 + x1^2 - 2*x1 + 5;
g(x1,x2) = -(x1 + 0.25)^2 + 0.75*x2;
dfx1 = diff(f,x1);
dfx2 = diff(f,x2);
dgx1 = diff(g,x1);
dgx2 = diff(g,x2);

x1 = [-1.695,2.157];
xn = x1;
% Determine values of f and grad f at point
fn1 = f(xn(1), xn(2));
gradfn1 = [dfx1(xn(1), xn(2)); dfx2(xn(1), xn(2))];

% Determine values of g and grad g at point
gn1 = double(g(xn(1),xn(2)));
gradgn1 = double([dgx1(xn(1), xn(2)); dgx2(xn(1), xn(2))]);

x2 = [-0.592,-1.162];
xn = x2;
% Determine values of f and grad f at point
fn2 = f(xn(1), xn(2));
gradfn2 = [dfx1(xn(1), xn(2)); dfx2(xn(1), xn(2))];

% Determine values of g and grad g at point
gn2 = double(g(xn(1),xn(2)));
gradgn2 = double([dgx1(xn(1), xn(2)); dgx2(xn(1), xn(2))]);
hl = [20.762,5.629;5.629,1.910];
lambda = 0;

cx1_prev = 1.104;
cx2_prev = -3.319;
% Find update hessian
gradlagr1 = gradfn1 - lambda*gradgn1;
gradlagr2 = gradfn2 - lambda*gradgn2;
gamma = double(gradlagr2 - gradlagr1);
cx = [cx1_prev; cx2_prev];
hl_1 = double(hl + (gamma*gamma.')/(gamma.'*cx) - (hl*cx*cx.'*hl)/(cx.'*hl*cx));
s = 0.230;
syms cx1 cx2 clambda cs
A = [18.5612, 5.1258, 0, -0.6840; 5.1258, 2.1849, 0, -0.75; 0, 0, 0, 0.23; 0.6840, 0.750, -1, 0];
b = -[-6.7655; -3.0249; -0.2; -1.2180];
x = mldivide(A,b)
xnew = [(x2(1) + x(1)), (x2(2) + x(2))];
f3 = double(f(xnew(1),xnew(2)))
g3 = double(g(xnew(1),xnew(2)))

