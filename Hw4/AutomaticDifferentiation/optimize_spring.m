% ------------Starting point and bounds------------
%var= d D n hf   %design variables
x0 = [0.07, 0.67 7.6 1.4]; %starting point
[Values, Jacobians] = getValues(x0)

function [Values, Jacobians] = getValues(x)

    %design variables
    d = x(1);  % height (in)
    D = x(2);  % diameter (in)
    n = x(3); % number of coils (treating as continuous for this example)
    hf = x(4); % free height (in)
    d = valder(d,[1,0,0,0]);
    D = valder(D,[0,1,0,0]);
    n = valder(n,[0,0,1,0]);
    hf = valder(hf,[0,0,0,1]);

    % Constants
    G = 12e6;  % psi
    Se = 45000; % psi
    w = 0.18;
    Sf = 1.5;
    Q= 150000; % psi

    % Analysis variables
    h0 = 1.0; % preload height
    delta0 = 0.4;

    % Output variables
    hdef = h0-delta0;
    k = (G*d^4)/(8*D^3*n);
    K = (4*D-d)/(4*(D-d))+0.62*d/D;
    F_h0 = k*(hf-h0); %Fmin
    F_hdef = k*(hf-hdef); %Fmax
    tauh0 = (8*F_h0*D)/(pi*d^3)*K; %taumin
    tauhdef = (8*F_hdef*D)/(pi*d^3)*K; %taumax

    taumean = (tauhdef+tauh0)/2;
    tauavg = (tauhdef-tauh0)/2;

    hs = n*d;
    Fhs = k*(hf-hs);
    tauhs = (8*Fhs*D)/(pi*d^3)*K;

    Sy = 0.44*Q/(d^w);

        
    %objective function
    f = F_h0; 
    Values = [k.val, K.val, F_h0.val, F_hdef.val, tauh0.val, tauhdef.val, taumean.val, tauavg.val, hs.val, Fhs.val, tauhs.val, Sy.val];
    Jacobians = [k.der, K.der, F_h0.der, F_hdef.der, tauh0.der, tauhdef.der, taumean.der, tauavg.der, hs.der, Fhs.der, tauhs.der, Sy.der];
end
