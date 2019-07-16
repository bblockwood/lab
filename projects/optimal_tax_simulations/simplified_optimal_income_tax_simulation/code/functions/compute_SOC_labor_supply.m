function SOC_z = compute_SOC_labor_supply(prim,eqbm)
% Second-order condition for labor supply choice

% compute 2nd deriv of tax function
mtr_deriv = derivative(eqbm.inc_mtrs,eqbm.income);

psi_deriv2 = (1./prim.laborElast) .* (eqbm.income ./ prim.wage).^(1./prim.laborElast - 1);

SOC_z = -1.*mtr_deriv - psi_deriv2./prim.wage.^2;

end
