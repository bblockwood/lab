function a_cc = compute_a_cc(prim,eqbm)
% Compute the 2nd derivative of a(c)

a_c = compute_a_c(prim,eqbm);
a_cc = derivative(a_c,eqbm.consump);

end
