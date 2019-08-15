function mtr_new = compute_income_tax(prim,eqbm,mvpfST)
% Computes schedule of optimal marginal tax rates for a given equilibrium.

mtr_step = 0.05; % to ensure convergence

f = derivative(prim.F,eqbm.income); % income density

dzdt = compute_labor_supply_response(prim,eqbm); % compensated earnings response to dt
[msww,msww_hat] = compute_mswws(prim,eqbm,mvpfST);

gamma = compute_bias_soda(prim,eqbm);
eta = compute_inc_effect_soda(prim,eqbm);
e = prim.externality;

% Extend income distribution and MSWWs to zero for purposes of integration
FExt = [0; prim.F];
msww_hatExt = interpcon(eqbm.income,msww_hat,[0;eqbm.income],'linear','extrap');
GExt = cumtrapz(FExt,msww_hatExt);
G = GExt(2:end);
G = G./G(end); % normalize so G integrates to 1 across full income distribution.

dM = G - prim.F; % mechanical effect, dim Nx1
dB = mean(eta.*(eqbm.soda_tax - msww.*gamma - e),2); % effect through ssb consump chng
mtr_raw = -1./(f.*dzdt) .* dM - dB;
mtr_raw = min(max(mtr_raw,-0.1),0.99); % limit for convergence

% smooth and dampen to facilitate convergence
mtr_new = mtr_step*smooth(mtr_raw) + (1 - mtr_step)*eqbm.inc_mtrs;

end
