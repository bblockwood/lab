function v_ctheta = compute_v_ctheta(prim,eqbm)
% Computes cross partial derivative of v wrt consumption and theta

a_c = compute_a_c(prim,eqbm);
b = prim.b;
b_theta = compute_b_theta(prim,eqbm);
k_theta = compute_k_theta(prim,eqbm);

k = prim.k;
s = eqbm.qsoda;

v_ctheta = a_c .* (s.^(1-k) ./ (1-k)) .* (b_theta + b .* (1-k - log(1-k)) .* k_theta);

end
