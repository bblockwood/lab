function dydx = derivative(y,x)
% Computes the derivative of y with respect to x, giving same number of elements.
% Uses linear extrapolation.

dydx_grid = diff(y)./diff(x);
x_midpoints = (x(1:end-1) + x(2:end))/2;

dydx = interpcon(x_midpoints,dydx_grid,x,'linear','extrap');

end
