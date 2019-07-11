function iota_theta = compute_iota_theta(prim,eqbm)
% Compute the derivative diota/dtheta
% here type is parameterized by earnings in this equilibrium

iota_theta = derivative(prim.iota,eqbm.income);

end
