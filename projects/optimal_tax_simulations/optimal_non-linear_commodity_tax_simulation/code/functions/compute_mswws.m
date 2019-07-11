function [msww,msww_hat] = compute_mswws(prim,eqbm,mvpfST)
% Computes marginal social welfare weights under a given equilibrium.

v_c = compute_v_c(prim,eqbm);
alpha = compute_pareto_weights(prim,eqbm);
e = prim.externality;
lambda = compute_mvpf(prim,eqbm);

msww = alpha.*(1+v_c)./lambda;

eta = compute_inc_effect_soda(prim,eqbm);
gamma = compute_bias_soda(prim,eqbm);
eta_z = compute_inc_effect_labor_supply(prim,eqbm);

inc_effect = eta.*(1./(1-eqbm.inc_mtrs) + eta_z);

msww_hat = msww + inc_effect.*(mvpfST*eqbm.soda_tax - gamma.*msww - e) + ...
    eta_z.*eqbm.inc_mtrs;

% Check that msww_hat average to ~1
% assert(norm(trapz(prim.F,msww_hat) - 1) < 1e-3);

end
