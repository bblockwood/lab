function soda_tax_new = compute_soda_tax(prim,eqbm,mvpfST)
% Compute the tax which satisfies the optimality FOC in some equilibrium.

soda_tax_step = 0.1; % dampens to avoid non-convergence

t = eqbm.soda_tax; % old soda tax
s = eqbm.qsoda; 
F = prim.F;
dsdt = compute_soda_demand_response(prim,eqbm);
gamma = compute_bias_soda(prim,eqbm);
eta = compute_inc_effect_soda(prim,eqbm);
g = eqbm.msww;
gHat = eqbm.msww_hat;
e = prim.externality;
dzdT = compute_labor_supply_response(prim,eqbm);
mtr = eqbm.inc_mtrs;

E = @(x) mean(trapz(F,x),2); % expectation operator in this context

dsdtMean = E(dsdt);

dC = E(dsdt .* (g.*gamma + e)); % correction term
dI = E(dzdT .* eta .* (mtr + eta .* (mvpfST*t - g.*gamma - e))); % income effect term
dM = E(s .* (mvpfST - gHat));

soda_tax_optimal = (dC - dI - dM) ./ (mvpfST*dsdtMean);
soda_tax_new = soda_tax_step*(soda_tax_optimal) + (1 - soda_tax_step)*eqbm.soda_tax;

end
