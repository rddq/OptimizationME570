function [] = contour_plot(n, hf)
    [d, D] = meshgrid(0.01:0.001:0.2,0.04:0.001:0.8);
    
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
    k = (G.*d.^4)./(8*D.^3.*n);
    K = (4.*D-d)./(4.*(D-d))+0.62.*d./D;
    F_h0 = k.*(hf-h0); %Fmin
    F_hdef = k.*(hf-hdef); %Fmax
    tauh0 = (8.*F_h0.*D)./(pi.*d.^3).*K; %taumin
    tauhdef = (8.*F_hdef.*D)./(pi.*d.^3).*K; %taumax

    taum = (tauhdef+tauh0)./2;
    taua = (tauhdef-tauh0)./2;

    hs = n.*d;
    Fhs = k.*(hf-hs);
    tauhs = (8.*Fhs.*D)./(pi.*d.^3).*K;

    Sy = 0.44.*Q./(d.^w);
      
    figure(1)
    [C,h] = contour(d,D,F_h0,0:3.5:7,'b-');
    clabel(C,h,'Labelspacing',250);
    title('Spring Contour Plot');
    xlabel('Wire Diameter');
    ylabel('Coil Diameter');
    hold on;
    
%     c(1) = tauhs - Sy;                   
%     c(2) = taua - (Se/Sf);
%     c(3) = (taua+taum)-(Sy/Sf);   
%     c(4) = (D/d)-16;  
%     c(5) = 4-(D/d);  
%     c(6) = (D+d) - 0.75;
%     c(7) = hs - (hdef-0.05);
    
    contour(d,D,tauhs - Sy,[0,0],'r-','LineWidth',2);
    contour(d,D, taua - (Se./Sf),[0,0],'g-','LineWidth',2);
    contour(d,D, (taua+taum)-(Sy./Sf),[0,0],'k-','LineWidth',2);
    contour(d,D, (D./d)-16,[0,0],'y-','LineWidth',2);
    contour(d,D, 4-(D./d),[0,0],'y-','LineWidth',2);
    contour(d,D, (D+d) - 0.75,[0,0],'c-','LineWidth',2);
    contour(d,D,hs - (hdef-0.05),[0,0],'m-','LineWidth',2);
    
    legend('Fh0','tauhs<Sy','taua<Se/Sf','taua+taum<Sy/Sf','D/d<16','D/d>4','D+d<0.75','hs<hdef-0.05')
    
    

end