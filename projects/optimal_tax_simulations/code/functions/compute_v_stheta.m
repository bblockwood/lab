function v_stheta = compute_v_stheta(prim,eqbm)
% Computes cross partial derivative of v wrt consumption and theta

a = prim.compute_a(eqbm.consump);
b = prim.b;
b_theta = compute_b_theta(prim,eqbm);
k = prim.k;
k_theta = compute_k_theta(prim,eqbm);
s = eqbm.qsoda;
iota_theta = compute_iota_theta(prim,eqbm);

v_stheta = a .* s.^(-k) .* (b_theta - b .* log(k) .* k_theta) - iota_theta;

end
