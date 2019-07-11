function dzdT = compute_labor_supply_response(prim,eqbm)
% Computes compensated earnings response to a marginal tax rate perturbation.

v_c = compute_v_c(prim,eqbm);
SOC_z = compute_SOC_labor_supply(prim,eqbm);

dzdT = (1+v_c)./SOC_z;

end
