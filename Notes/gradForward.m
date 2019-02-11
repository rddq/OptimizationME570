function [grad] = gradForward(x,fun,h)
    n = size(x);
    fb = fun(x);
    grad = zeros(n,1);
    for i=1:n
        xF = x;
        xF(i) = xF(i) + h;
        grad(i) = (fun(xF)-fb)/h;
    end
end
