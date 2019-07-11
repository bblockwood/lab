function psi_deriv = compute_psi(prim,eqbm)

psi_deriv = (1 + 1./prim.laborElast)^(-1) .* (eqbm.income ./ prim.wage).^(1 + 1./prim.laborElast);

end
