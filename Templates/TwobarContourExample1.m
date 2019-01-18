% This program constructs a contour plot for the two-bar truss
% constants
clear; close all;
dens = 0.3;
modu = 30000;
load = 66.0;
wdth = 60;
thik = 0.15;
 
% design variables at mesh points
[hght,diam] = meshgrid(10:2:30,1:.3:3);
 
% equations
leng = ((wdth/2)^2 + hght.^2).^0.5;
area = pi .* diam .* thik;
iovera = (diam.^2 + thik^2)/8;
wght = 2 * dens .* leng .* area;
strs = load .* leng ./ (2 .* area .* hght);
buck = pi^2 .* modu .* iovera ./ (leng.^2);
defl = load .* leng.^3 ./ (2 * modu .* area .* hght.^2);
 
figure(1)
[C,h] = contour(hght,diam,wght,12:3:33,'k-');
clabel(C,h,'Labelspacing',250);
title('Two Bar Truss Contour Plot');
xlabel('Height');
ylabel('Diameter');
hold on;

% solid lines to show constraint boundaries
contour(hght,diam,strs,[100,100],'g-','LineWidth',2);
contour(hght,diam,defl,[0.25,0.25],'r-','LineWidth',2);
contour(hght,diam,(strs-buck),[0.0,0.0],'b-','LineWidth',2);

% show a legend
legend('Weight','Stress<100','Deflection<0.25','Stress-Buckling<0')
hold off;
