x1=10;
x2=10;
x3=10;

100*(x2-x1^2)^2+(1-x1)^2;
syms f(x) x1 x2 x3
f(x) = 100*(x2-x1^2)^2+(1-x1)^2 
grad1 = diff(f,x1)
grad2 = diff(f,x2)

f(x) = 20+3*x1-6*x2+8*x3+6*x1^2-(2*x1*x2)-(x1*x3)+x2^2+0.5*x3^2;
grad1 = diff(f,x1)
grad2 = diff(f,x2)
grad3 = diff(f,x3)
