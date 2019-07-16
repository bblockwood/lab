function mtr_new = compute_income_tax(prim,eqbm)
% Computes schedule of optimal marginal tax rates for a given equilibrium.

mtr_step = 0.05; % to ensure convergence

f = derivative(prim.F,eqbm.income); % income density

dzdt = compute_labor_supply_response(prim,eqbm); % compensated earnings response to dt
msww = compute_mswws(prim,eqbm);

dM = mean(cumtrapz(prim.F,msww),2) - prim.F; % mechanical effect, dim Nx1
mtr_raw = -1./(f.*dzdt) .* dM;
mtr_raw = min(max(mtr_raw,-0.1),0.99); % limit for convergence

% smooth and dampen to facilitate convergence
mtr_new = mtr_step*smooth(mtr_raw) + (1 - mtr_step)*eqbm.inc_mtrs;

end
