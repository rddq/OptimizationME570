clear
m = (0.628-0.5)*2;
n = (0.993-0.5)*2;
x = [4.959+m*0.5,-8.066+n*0.5];
f1 = x(1)^2-2*x(1)*x(2)+4*x(2)^2
changeE = 364.8-f1;

m = (0.885-0.5)*2;
n = (0.215-0.5)*2;
x = [x(1)+m*0.5,x(2)+n*0.5];
f2 = x(1)^2-2*x(1)*x(2)+4*x(2)^2
changeE2 = f2-f1;

Eavg = (35.4+changeE+changeE2)/3;
P = (-changeE2/(Eavg))