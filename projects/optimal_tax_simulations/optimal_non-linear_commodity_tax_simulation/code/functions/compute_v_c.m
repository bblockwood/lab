function v_c = compute_v_c(prim,eqbm)
% Computes derivative of v wrt consumption

ab = compute_ab(prim,eqbm);
b = prim.b;
a_c = compute_a_c(prim,eqbm);

v = compute_v(prim,eqbm);

v_c = a_c .* b .* (v./ab); % last term is s.^(1-k) ./ (1-k) -- speeds computation

end
