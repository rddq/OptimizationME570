function [grad] = gradCentral(x,fun,h)
    n = size(x);
    grad = zeros(n,1);
    for i=1:n
        xF = x;
        xB = x;
        xF(i) = xF(i) + h;
        f_forward = fun(xF);
        xB(i) = xB(i) - h;
        f_backward = fun(xB);
        grad(i) = (f_forward-f_backward)/(2*h);
    end
end