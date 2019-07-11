function dsdtheta = compute_type_effect_soda(prim,eqbm)
% Compute the type effect (parameterized over income changes) on soda consumption

v_ctheta = compute_v_ctheta(prim,eqbm);
v_stheta = compute_v_stheta(prim,eqbm);
SOC = compute_SOC(prim,eqbm);
p = prim.ssbPrice;
t = eqbm.soda_tax;

dsdtheta = 1./SOC .* ((p+t)*v_ctheta - v_stheta);

end
