function SOC = compute_SOC(prim,eqbm)
% Compute v function (soda) second-order condition

v_ss = compute_v_ss(prim,eqbm);
v_sc = compute_v_sc(prim,eqbm);
v_cc = compute_v_cc(prim,eqbm);

p = prim.ssbPrice;
t = eqbm.soda_tax;

SOC = v_ss - 2*v_sc*(p+t) + v_cc*(p+t)^2;

end
