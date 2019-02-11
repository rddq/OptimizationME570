function [] = ContourPlotRosenbrock(coordinates)
    clf

    %Rosenbrock code from https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/23972/versions/22/previews/chebfun/examples/opt/html/Rosenbrock.html
    f = @(x,y) (1-x).^2 + 100*(y-x.^2).^2;
    x = linspace(-1.5,1.5); y = linspace(-1,3);
    [xx,yy] = meshgrid(x,y); ff = f(xx,yy);
    levels = 10:10:300;
    LW = 'linewidth'; FS = 'fontsize'; MS = 'markersize';
    figure, contour(x,y,ff,levels,LW,1.2), colorbar
    axis([-1.5 1.5 -0.5 1.5]), axis square, hold on
    hold on;
    coordinates
    plot(coordinates(1,:),coordinates(2,:),'r');
end