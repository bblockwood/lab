function dzdT = compute_labor_supply_response(prim,eqbm)
% Computes compensated earnings response to a marginal tax rate perturbation.

SOC_z = compute_SOC_labor_supply(prim,eqbm);

dzdT = 1./SOC_z;

end
