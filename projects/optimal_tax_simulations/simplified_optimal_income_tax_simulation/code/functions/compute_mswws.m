function msww = compute_mswws(prim,eqbm)
% Computes marginal social welfare weights under a given equilibrium.

alpha = compute_pareto_weights(prim,eqbm);
lambda = compute_mvpf(prim,eqbm);

msww = alpha./lambda;

% Check that msww average to ~1
assert(norm(trapz(prim.F,msww) - 1) < 1e-3);

end
