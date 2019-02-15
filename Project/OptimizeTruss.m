function [xopt, fopt, exitflag, output] = OptimizeTruss()

    % ------------Starting point and bounds------------
    %var = theta 1,L1,L2,L6,L7,Area    %design variables
    x0 = [60,1.5,1.5,1.5,1.5]; %starting point
    ub = [75,3,3,3,3]; %upper bound
    lb = [45,0.5,0.5,0.5,0.5]; %lower bound

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
        L1 = x(2);
        L2 = x(3);
        L6 = x(4);
        L7 = x(5);
        
        % area of cross section of beam (assuming square beam)
        Area = 0.15^2*pi;
        
        %---Constants---%
        
        % Yield strength - MPa
        Sy = 220;
        % Ultimate Tensile Strength - MPa
        Sut = 341;  
        % Density kg/m^3
        density = 7850;
        % Factor of Safety
        FOS = 1.5;
        
        % Degrees that angle of Forces will be shifted
        angle_s = 10;
                
        F1 = 10000; %N
        F2 = 15000; %N
        phiF1 = 90; %degrees
        phiF2 = 90; %degrees
        
        %---Design Functions---%
        
        % Calculate other truss dimensions
        L3 = lawCosinesLength(L1,L6,theta1);
        theta2 = lawCosinesAngle(L6,L1,L3);
        theta3 = lawCosinesAngle(L1,L6,L3);
        
        L4 = sqrt((L1*cosd(theta1)-L6)^2+(L1*sind(theta1))^2);
        theta4 = lawCosinesAngle(L4,L2,L3);
        theta5 = lawCosinesAngle(L2,L3,L4);
        theta6 = lawCosinesAngle(L3,L2,L4);
        
        theta8 = 180-theta3-theta5;
        L5 = lawCosinesLength(L4,L7,theta8);                
        theta7 = lawCosinesAngle(L7,L4,L5);
        theta9 = lawCosinesAngle(L4,L7,L5);
        
        all_member_stress = zeros(1,63);
        
        % Find Member Stress in all configurations
        phiF1 = [phiF1-angle_s,phiF1,phiF1+angle_s];
        phiF2 = [phiF2-angle_s,phiF2,phiF2+angle_s];
        iteration = 0;
        for index_phiF1 = 1:3
            for index_phiF2 = 1:3
                iteration = iteration+1;
                memberForces = calculateForces(F1,phiF1(index_phiF1),F2,phiF2(index_phiF2),theta1,theta3,theta6,theta8,theta9,L1,L6,L5);
                all_member_stress(7*iteration-6:7*iteration) = (memberForces./Area);
            end
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
            
            A_mat = [Ax;Ay;Bx;By;Cx;Cy;Dx;Dy;Ex;Ey];
            b_mat = [-F1*cosd(phiF1); F1*sind(phiF1); -F2*cosd(phiF2); F2*sind(phiF2); -Rx; -Ry; 0; 0; 0; -Qy];
            memberForces = mldivide(A_mat,b_mat);
        end

        %---Objective function---%
        weight = (L1+L2+L3+L4+L5+L6+L7)*Area*density;
        f = weight; %minimize weight
                
        %---Inequality constraints (c<=0)---%
        [constraint_number,~] = size(all_member_stress);
        c = zeros(constraint_number*2,1); % create column vector
        for index = 1:size(all_member_stress)
            c(2*index-1) = all_member_stress(index)-Sy/(FOS);
            c(2*index) = -Sut/(FOS)-all_member_stress(index);
        end
        theta = [theta1,theta2,theta3,theta4,theta5,theta6,theta7,theta8,theta9];
        c(64) = 35-theta2;
        c(65) = 35-theta3;
        c(66) = 35-theta5;
        c(67) = 35-theta6;
        c(68) = 35-theta7;
        c(69) = 35-theta9;
        ul = 85;
        c(70) = theta2 - ul;
        c(71) = theta3 - ul;
        c(72) = theta5 - ul;
        c(73) = theta6 - ul;
        c(74) = theta7 - ul;
        c(75) = theta9 - ul;
        % Height >1, <2.5
        c(76) = 1 - L1*(sind(theta1));
        c(77) = L1*(sind(theta1)) - 2.5;
        c(78) = L2-(L6+L7);
        
        %equality constraints (ceq=0)
        ceq = [];

    end

    % ------------Call fmincon------------
    options = optimoptions(@fmincon,'display','iter-detailed','Diagnostics','on','MaxFunctionEvaluations',50000,'OptimalityTolerance',1e-6);
    [xopt, fopt, exitflag, output] = fmincon(@obj, x0, A, b, Aeq, beq, lb, ub, @con, options);
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
    % Calculate other truss dimensions
    L3 = lawCosinesLength(L1,L6,theta1);
    theta2 = lawCosinesAngle(L6,L1,L3);
    theta3 = lawCosinesAngle(L1,L6,L3);

    L4 = sqrt((L1*cosd(theta1)-L6)^2+(L1*sind(theta1))^2);
    theta4 = lawCosinesAngle(L4,L2,L3);
    theta5 = lawCosinesAngle(L2,L3,L4);
    theta6 = lawCosinesAngle(L3,L2,L4);

    theta8 = 180-theta3-theta5;
    L5 = lawCosinesLength(L4,L7,theta8);                
    theta7 = lawCosinesAngle(L7,L4,L5);
    theta9 = lawCosinesAngle(L4,L7,L5);
 
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
        