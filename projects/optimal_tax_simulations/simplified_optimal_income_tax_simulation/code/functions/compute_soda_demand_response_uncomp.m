function ds_dt_uncomp = compute_soda_demand_response_uncomp(prim,eqbm)
% Computes the compensated change in soda demand from a slight increase in soda_tax.

ds_dt_comp = compute_soda_demand_response(prim,eqbm);
eta = compute_inc_effect_soda(prim,eqbm); % gross income effect

ds_dt_uncomp = ds_dt_comp - eta ./ (1-eqbm.inc_mtrs) .* eqbm.qsoda; % Slutsky equation

end
