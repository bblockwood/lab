function v_s = compute_v_s(prim,eqbm)
% Computes derivative of v wrt soda

ab = compute_ab(prim,eqbm);
k = prim.k;

v_s = ab .* eqbm.qsoda.^(-k) - prim.iota;

end
