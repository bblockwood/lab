function income = compute_income(prim,eqbm)

v_c = compute_v_c(prim,eqbm);
income = prim.wage.^(1+prim.laborElast) .* ((1 - eqbm.inc_mtrs).*(1+v_c)).^prim.laborElast;

end
