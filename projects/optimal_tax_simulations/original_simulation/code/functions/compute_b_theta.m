function b_theta = compute_b_theta(prim,eqbm)
% Compute the derivative of b wrt type
% here type is parameterized by earnings in this equilibrium

b_theta = derivative(prim.b,eqbm.income);

end
