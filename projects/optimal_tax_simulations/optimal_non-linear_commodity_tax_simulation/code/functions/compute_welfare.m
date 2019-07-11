function [UtilVec,mvpf] = compute_welfare(prim,eqbm)
% Compute welfare and mvpf at a given equilibrium

alpha = compute_pareto_weights(prim,eqbm);

UtilVec = alpha .* (eqbm.consump + compute_v(prim,eqbm) ...
    - eqbm.qsoda.*prim.gamma - compute_psi(prim,eqbm));

mvpf = compute_mvpf(prim,eqbm);

end
