function lambda = compute_mvpf(prim,eqbm)
% Computes the marginal value of public funds.

alpha = compute_pareto_weights(prim,eqbm);

lambda = trapz(prim.F,alpha);

end
