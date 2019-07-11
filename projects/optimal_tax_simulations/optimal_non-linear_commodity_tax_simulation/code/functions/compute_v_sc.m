function v_sc = compute_v_sc(prim,eqbm)
% Computes cross partial derivative of v wrt soda and consumption

a_c = compute_a_c(prim,eqbm);
b = prim.b;
k = prim.k;

v_sc = a_c .* b .* eqbm.qsoda.^(-k);

end
