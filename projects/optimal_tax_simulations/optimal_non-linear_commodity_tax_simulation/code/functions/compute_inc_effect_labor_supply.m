function eta_z = compute_inc_effect_labor_supply(prim,eqbm)
% Compute income effect on labor supply. 
% How does a windfall of $1 of net income affect earnings?

SOC_z = compute_SOC_labor_supply(prim,eqbm);
v_cc = compute_v_cc(prim,eqbm);

eta_z = (1-eqbm.inc_mtrs).*v_cc ./ SOC_z;

end
