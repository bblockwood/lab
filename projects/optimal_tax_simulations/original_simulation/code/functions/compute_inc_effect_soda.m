function eta = compute_inc_effect_soda(prim,eqbm)
% Compute the gross income effect on soda consumption
% How much more SSB does someone buy if they get 1-T'(z) dollars of extra net income?

v_cc = compute_v_cc(prim,eqbm);
v_sc = compute_v_sc(prim,eqbm);
SOC = compute_SOC(prim,eqbm);
p = prim.ssbPrice;
t = eqbm.soda_tax;

eta = (1 - eqbm.inc_mtrs)./SOC .* ((p+t)*v_cc - v_sc);

end
