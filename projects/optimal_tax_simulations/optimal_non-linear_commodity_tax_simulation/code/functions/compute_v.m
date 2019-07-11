function v = compute_v(prim,eqbm)

ab = compute_ab(prim,eqbm);
k = prim.k;

v = ab.*(eqbm.qsoda.^(1 - k) ./ (1 - k)) - prim.iota.*eqbm.qsoda;

end
