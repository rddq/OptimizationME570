x = [2; 3];
f = [10; 20];
K = [5*x(1) 2*x(1)+3*x(2); 2*x(1)+3*x(2) 6*x(2)];
Kinv = inv(K);
fx = 0;
dKx1 = [5 2; 2 0];
dKx2 = [0 3; 3 6];
u = Kinv*f;
dudx1 = Kinv*(fx-dKx1*u);
dudx2 = Kinv*(fx-dKx2*u);