function income = compute_income(prim,eqbm)
% Retrieve income distribution from ability (wage) distribution

income = prim.wage.^(1+prim.laborElast) .* (1 - eqbm.inc_mtrs).^prim.laborElast;

end
