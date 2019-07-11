function a_c = compute_a_c(prim,eqbm)
% Compute the derivative da/dc

a_c = derivative(prim.compute_a(eqbm.consump),eqbm.consump);

end
