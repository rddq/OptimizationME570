function [xopt, fopt, exitflag, output] = OptimizeTruss()

    % ------------Starting point and bounds------------
    clear
    clf
    % Set mins and maxes
    theta_min = 45;
    theta_max = 85;
    theta_init = 60;
    % Truss member length min and max
    mL_Min = 0.5;
    mL_Max = 3;
    mL_init = 1.5;
    
    %var = theta 1,L1,L2,L6,L7    %design variables
    x0 = [theta_init,mL_init,mL_init,mL_init,mL_init]; %starting point
    ub = [theta_max,mL_Max,mL_Max,mL_Max,mL_Max]; %upper bound
    lb = [theta_min,mL_Min,mL_Min,mL_Min,mL_Min]; %lower bound

    % ------------Linear constraints------------
    A = [];
    b = [];
    Aeq = [];
    beq = [];

    % ------------Objective and Non-linear Constraints------------
    function [f, c, ceq] = objcon(x)
        %---Design Variables---%   
        % Angle in degrees
        theta1 = x(1);             
        % Length in meters
        % Height is constrained with L1
        % Length is constrained with L2 and L6 L7
        L1 = x(2);
        L2 = x(3);
        L6 = x(4);
        L7 = x(5);       
             
        %---Constants---%
        % Area of cross section of beam m^2
        Area = 0.15^2*pi;
        
        % Annealed 1018 steel
        % Yield strength - MPa
        Sy = 220;
        % Ultimate Tensile Strength - MPa
        Sut = 341;  
        % Density kg/m^3
        density = 7850;
        
        FactorOfSafety = 1.5;
              
        F1 = 10000; %N
        F2 = 15000; %N
        phiF1 = 90; %degrees
        phiF2 = 90; %degrees
        
        %---Design Functions---%
        
        % Other Truss Dimensions
        [theta2,theta3,theta4,theta5,theta6,theta7,theta8,theta9,L3,L4,L5] = calculateOtherTrussDimensions(L1,L2,L6,L7,theta1);              
        
        % Find Member Stresses
        memberForces = calculateForces(F1,phiF1,F2,phiF2,theta1,theta3,theta6,theta8,theta9,L1,L6,L5);
        all_member_stress = (memberForces./Area);
             
        %---Objective function---%
        weight = (L1+L2+L3+L4+L5+L6+L7)*Area*density;
        f = weight; % minimize weight
                
        %---Inequality constraints (c<=0)---%
        % initialize constraint column vector 
        [numberOfMembers,~] = size(all_member_stress);
        c = zeros(numberOfMembers*2+16+3,1); 
        
        maxCompressiveForce = Sy/(FactorOfSafety);
        maxTensionForce = Sut/(FactorOfSafety);
        % Create min and max constraint for each member
        for index = 1:numberOfMembers
            c(2*index-1) = all_member_stress(index)-maxCompressiveForce;
            c(2*index) = -Sut/maxTensionForce-all_member_stress(index);
        end 
        
        % Create min and max constraint for each theta
        thetas = [theta2,theta3,theta5,theta6,theta7,theta9];
        offset = 2*numberOfMembers;
        for index = 1:6
            c(2*index+offset-1) = theta_min - thetas(index);
            c(2*index+offset) = thetas(index) - theta_max;
        end 
        
        % Height > 1, Height < 2.5 m
        c(32) = 0.5 - L1*(sind(theta1));
        c(33) = L1*(sind(theta1)) - 2.5;
        % Bottom of the truss is bigger than top of the truss
        c(34) = L2-(L6+L7);
        
        %equality constraints (ceq=0)
        ceq = [];

    end

    % ------------Call fmincon------------
    options = optimoptions(@fmincon,'display','iter-detailed','Diagnostics','on');
    [xopt, fopt, exitflag, output] = fmincon(@obj, x0, A, b, Aeq, beq, lb, ub, @con, options);
    [f, c, ceq] = objcon(xopt);
    xopt %design variables at the minimum
    fopt %objective function value at the minumum  fopt = f(xopt)
    plot_truss(xopt);

    % ------------Separate obj/con (do not change)------------
    function [f] = obj(x) 
        [f, ~, ~] = objcon(x);
    end
    function [c, ceq] = con(x) 
        [~, c, ceq] = objcon(x);
    end
end

function a = lawCosinesLength(b,c,A)
            a = sqrt(b^2+c^2-2*b*c*cosd(A));
end
function angle = lawCosinesAngle(A,b,c)
    angle = acosd((-A^2+b^2+c^2)/(2*b*c));
end
function plot_truss(xopt)
    clf    
    theta1 = xopt(1);
    L1 = xopt(2);
    L2 = xopt(3);
    L6 = xopt(4);
    L7 = xopt(5);
    
    [theta2,theta3,theta4,theta5,theta6,theta7,theta8,theta9,L3,L4,L5]...
        = calculateOtherTrussDimensions(L1,L2,L6,L7,theta1);
    
    C = [0,0];
    A = [L1*cosd(theta1),L1*sind(theta1)];
    B = [A(1)+L2,A(2)];
    E = [L6+L7,0];
    D = [L6,0];
    
    figure(1);
    X = [C(1),A(1),B(1),E(1),C(1)];
    Y = [C(2),A(2),B(2),E(2),C(2)];
    plot(X,Y)
    xlim([0,2]);
    ylim([0,2]);
    hold on
    plot([A(1),D(1),B(1)],[A(2),D(2),B(2)])
end
function [theta2,theta3,theta4,theta5,theta6,theta7,theta8,theta9,L3,L4,L5] = calculateOtherTrussDimensions(L1,L2,L6,L7,theta1)
    % Calculate other truss dimensions
    L3 = lawCosinesLength(L1,L6,theta1);
    theta2 = lawCosinesAngle(L6,L1,L3);
    theta3 = lawCosinesAngle(L1,L6,L3);

    % Calculation for L4 guarantees that L2 is vertical
    L4 = sqrt((L1*cosd(theta1)-L6)^2+(L1*sind(theta1))^2);
    theta4 = lawCosinesAngle(L4,L2,L3);
    theta5 = lawCosinesAngle(L2,L3,L4);
    theta6 = lawCosinesAngle(L3,L2,L4);

    theta8 = 180-theta3-theta5;
    L5 = lawCosinesLength(L4,L7,theta8);                
    theta7 = lawCosinesAngle(L7,L4,L5);
    theta9 = lawCosinesAngle(L4,L7,L5);
end
function memberForces = calculateForces(F1,phiF1,F2,phiF2,theta1,theta3,theta6,theta8,theta9,L1,L6,L5)
    % Reaction Forces
    Rx = -(F1*cosd(phiF1)+F2*cosd(phiF2));
    Qy = F1*sind(phiF1)*L1*cosd(theta1)+F2*sind(phiF2)*(L6-L5*cosd(theta9));
    Ry = F1+F2-Qy;

    % Solve system of equations for member forces
    Ax = [-cosd(theta1), 1, cosd(theta3), 0, 0, 0, 0 ];
    Ay = [sind(theta1) 0 sind(theta3) 0 0 0 0 ];
    Bx = [0 -1 0 -cosd(theta6) cosd(theta9) 0 0 ];
    By = [0 0 0 -sind(theta6) -sind(theta9) 0 0 ];
    Cx = [cosd(theta1) 0 0 0 0 1 0 ];
    Cy = [sind(theta1) 0 0 0 0 0 0 ];
    Dx = [0 0 -cosd(theta3) cosd(theta8) 0 -1 1];
    Dy = [0 0 sind(theta3) sind(theta8) 0 0 0];
    Ex = [0 0 0 0 -cosd(theta9) 0 -1];
    Ey = [0 0 0 0 sind(theta9) 0 0];
    
    % Ax = b
    A_mat = [Ax;Ay;Bx;By;Cx;Cy;Dx;Dy;Ex;Ey];
    b_mat = [-F1*cosd(phiF1); F1*sind(phiF1); -F2*cosd(phiF2); F2*sind(phiF2); -Rx; -Ry; 0; 0; 0; -Qy];
    memberForces = mldivide(A_mat,b_mat);
end