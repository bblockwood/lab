function soda_tax_pigou = compute_soda_tax_pigouvian(prim,eqbm)
% Computes Pigouvian optimal tax (no redistributive motive).

ds_dt = compute_soda_demand_response(prim,eqbm);
gamma = compute_bias_soda(prim,eqbm);

soda_tax_pigou = trapz(prim.F,gamma.*ds_dt) / trapz(prim.F,ds_dt);

end
