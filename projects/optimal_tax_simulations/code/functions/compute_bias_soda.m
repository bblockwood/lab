function gamma = compute_bias_soda(prim,eqbm)

v_c = compute_v_c(prim,eqbm);

gamma = prim.gamma ./ (1 + v_c);

end
