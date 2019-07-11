function k_theta = compute_k_theta(prim,eqbm)
% Compute the derivative of k (which is 1/(compensated ssb elasticity)) wrt type.
% Here type is parameterized by earnings in this equilibrium

k_theta = derivative(prim.k,eqbm.income);

end
