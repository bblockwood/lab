function lambda = compute_mvpf(prim,eqbm)
% Computes the marginal value of public funds. 

v_c = compute_v_c(prim,eqbm);
alpha = compute_pareto_weights(prim,eqbm);

eta = compute_inc_effect_soda(prim,eqbm);
gamma = compute_bias_soda(prim,eqbm);
eta_z = compute_inc_effect_labor_supply(prim,eqbm);

inc_effect = eta.*(1./(1-eqbm.inc_mtrs) + eta_z);

num_arg = alpha .* (1+v_c) .* (1 - inc_effect.*gamma);
num = trapz(prim.F,num_arg);

fisc_arg = inc_effect.*eqbm.soda_tax + eta_z.*eqbm.inc_mtrs;
denom = 1 - trapz(prim.F,fisc_arg);

lambda = num/denom;

end
