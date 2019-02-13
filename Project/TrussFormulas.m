% Material is Steel 1018 Annealed
% Compression is positive stress
% Tensile is negative stress

%---Constants---%
% Yield strength - MPa
Sy = 220;
% Ultimate Tensile Strength - MPa
Sut = 341;
L2 = 1; %m
Force1 = 1000; %N
Force2 = 1500; %N
phiF1 = 90; %degrees
phiF2 = 90; %degrees

% Design Variables
% Length in meters
L1
L3
L4
L5
L6
% Angle in degrees
theta1
theta2
theta3
theta4
theta5
theta6
theta7
theta8
theta9

%---Design Functions---%
% Reaction Forces
Rx = -(F1*cos(phiF1)+F2*cos(phiF2));
Qy = F1*sin(phiF1)*L1*cos(theta1)+F2*sin(phiF2)*(L6-L5*cos(theta9));
Ry = F1+F2-Qy;

Ax = [-cos(theta1) 1 cos(theta3) 0 0 0 0 ];
Ay = [sin(theta1) 0 sin(theta3) 0 0 0 0 ];
Bx = [0 -1 0 -cos(theta6) cos(theta9) 0 0 ];
By = [0 0 0 -sin(theta6) -sin(theta9) 0 0 ];
Cx = [cos(theta1) 0 0 0 0 1 0 ];
Cy = [sin(theta1) 0 0 0 0 0 0 ];
Dx = [0 0 -cos(theta3) cos(theta8) 0 -1 1];
Dy = [0 0 sin(theta3) sin(theta8) 0 0 0];
Ex = [0 0 0 0 -cos(theta9) 0 -1];
Ey = [0 0 0 0 sin(theta9) 0 0];

A = [Ax;Ay;Bx;By;Cx;Cy;Dx;Dy;Ex;Ey];
x = zeros(1,10);
b = [-F1*cos(phiF1); F1*sin(phiF1); -F2*cos(phiF2); F2*sin(phiF2); -Rx; -Ry; 0; 0; 0; -Qy];
x = b/A;

Factor_Of_Safety = 1.5;
% Tensile condition
if F/A > 0
    F/A < Sut/1.5;
end

% Buckling condition
if F/A < 0
    F/A > Sy/1.5;
end

angle_force = 5;
phiF1 < 90+angle_force;
phiF1 > 90-angle_force;
phiF2 < 90+angle_force;
phiF2 > 90-angle_force; 

theta6+theta7 > 90;
theta1+theta2+theta3 == 180;
theta4+theta5+theta6 == 180;
theta7+theta8+theta9 == 180;

% Minimum bar length?
% Maximum bar length?
L6>L2;

%---Plot the truss---%
NodeC = [0,0];
NodeA = [L1*cos(theta1),L1*sin(theta1)];
NodeB = [NodeA(1)+L2,NodeA(2)];
NodeE = [L6,0];
NodeD = [L6/2,0];

