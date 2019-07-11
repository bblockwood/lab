function mtr_new = compute_income_tax(prim,eqbm,mvpfST)
% Computes schedule of optimal marginal tax rates for a given equilibrium.

mtr_step = 0.05; % to ensure convergence

f = derivative(prim.F,eqbm.income); % income density

dzdt = compute_labor_supply_response(prim,eqbm); % compensated earnings response to dt
[msww,msww_hat] = compute_mswws(prim,eqbm,mvpfST);

gamma = compute_bias_soda(prim,eqbm);
eta = compute_inc_effect_soda(prim,eqbm);
e = prim.externality;

dM = mean(cumtrapz(prim.F,msww_hat),2) - prim.F; % mechanical effect, dim Nx1
dB = mean(eta.*(eqbm.soda_tax - msww.*gamma - e),2); % effect through ssb consump chng
mtr_raw = -1./(f.*dzdt) .* dM - dB;
mtr_raw = min(max(mtr_raw,-0.1),0.99); % limit for convergence

% smooth and dampen to facilitate convergence
mtr_new = mtr_step*smooth(mtr_raw) + (1 - mtr_step)*eqbm.inc_mtrs;

end
