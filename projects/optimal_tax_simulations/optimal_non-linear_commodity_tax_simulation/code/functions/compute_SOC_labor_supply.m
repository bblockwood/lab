function SOC_z = compute_SOC_labor_supply(prim,eqbm)
% Second-order condition for labor supply choice

% compute 2nd deriv of tax function
mtr_deriv = derivative(eqbm.inc_mtrs,eqbm.income);

psi_deriv2 = (1./prim.laborElast) .* (eqbm.income ./ prim.wage).^(1./prim.laborElast - 1);

v_c = compute_v_c(prim,eqbm);
v_cc = compute_v_cc(prim,eqbm);
SOC_z = (1-eqbm.inc_mtrs).^2 .* v_cc - mtr_deriv.*(1+v_c) - psi_deriv2./prim.wage.^2;

end
