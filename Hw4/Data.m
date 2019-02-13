%Ten bar truss of Venkaya
E = 1.e7;   % psi
dens = 0.1; % lbm/in^3
ndof = 12;  % degrees of freedom
nbc = 4;    % no. of boundary conditions
nnode = 6;  % no. of nodes
nelem = 10; % no. of elements

% format is node coordinate, then degree of freedom numbers
Node = [720 360 1 2; 720 0 3 4; 360 360 5 6; 360 0 7 8;...
    0 360 9 10; 0 0 11 12];

% Force for each degree of freedom (horizontal then vertical)
force = [0; 0; 0; -100000; 0; 0; 0; -100000; 0; 0; 0; 0];

% put boundary conditions in reverse order, highest to lowest
bc = [12, 11, 10, 9];

% format is start node to end node, area
Elem = [5 3 5.; 3 1 5.; 6 4 5.; 4 2 5.; 3 4 5.; 1 2 5; 5 4 5.; ...
    6 3 5.; 3 2 5.; 4 1 5.];
