function ab = compute_ab(prim,eqbm)

ab = prim.compute_a(eqbm.consump) .* prim.b;

end
