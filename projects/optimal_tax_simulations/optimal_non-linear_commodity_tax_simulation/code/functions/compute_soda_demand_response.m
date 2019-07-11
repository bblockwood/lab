function ds_dt = compute_soda_demand_response(prim,eqbm)
% Computes the compensated change in soda demand from a slight increase in soda_tax.

v_c = compute_v_c(prim,eqbm);
SOC = compute_SOC(prim,eqbm);

ds_dt = (1+v_c) ./ SOC;

end
