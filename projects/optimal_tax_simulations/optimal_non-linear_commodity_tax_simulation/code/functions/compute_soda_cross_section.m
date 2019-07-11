function dsdz = compute_soda_cross_section(prim,eqbm)
% Compute cross-sectional change in soda consumption with income 

dsdz = compute_inc_effect_soda(prim,eqbm) + compute_type_effect_soda(prim,eqbm);

end
