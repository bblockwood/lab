function v_cc = compute_v_cc(prim,eqbm)
% Computes second derivative of v wrt consumption

a_cc = compute_a_cc(prim,eqbm);
b = prim.b;
k = prim.k;
s = eqbm.qsoda;

v_cc = a_cc .* b .* (s.^(1-k) ./ (1-k));

end
