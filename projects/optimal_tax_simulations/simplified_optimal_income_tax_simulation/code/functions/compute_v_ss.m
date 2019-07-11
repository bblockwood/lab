function v_ss = compute_v_ss(prim,eqbm)
% Computes second derivative of v wrt soda

ab = compute_ab(prim,eqbm);
k = prim.k;

v_ss = -ab .* k .* eqbm.qsoda.^(-k - 1);

end
