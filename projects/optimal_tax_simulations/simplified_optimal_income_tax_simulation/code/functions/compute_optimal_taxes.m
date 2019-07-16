function eqbm = compute_optimal_taxes(prim,eqbm)
% Computes optimal tax schedule and updates equilibrium.

inc_mtrs_old = eqbm.inc_mtrs;
policy_change = 1;
idx = 1;

while (policy_change > 1e-4) || (idx < 5)
    % require at least 5 iterations, so that everything (including
    % consumption) gets updated
    
    % 1. Compute marginal social welfare weights (MSWWs)
    eqbm.msww = compute_mswws(prim,eqbm);
    
    % 2. Update optimal income tax
    eqbm.inc_mtrs = smooth(compute_income_tax(prim,eqbm));
    inc_mtrs_change = norm(eqbm.inc_mtrs - inc_mtrs_old);
    inc_mtrs_old = eqbm.inc_mtrs;
    
    % 3. Update labor supply, grant, and consumption
    eqbm.income = compute_income(prim,eqbm);
    inc_tax = cumtrapz(eqbm.income,eqbm.inc_mtrs);
    eqbm.grant = trapz(prim.F,inc_tax) - prim.revreq;
    eqbm.consump = eqbm.grant + eqbm.income - inc_tax;
    
    policy_change = inc_mtrs_change;
    
    idx = idx+1;
    if idx > 500, warning('exceeded iteration limit'); break; end
    
end

end
