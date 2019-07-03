function eqbm = compute_optimal_taxes(prim,eqbm,incTaxHeldFixed,mvpfST)
% Computes optimal tax system and updates equilibrium.
% The optional boolean argument incTaxHeldFixed (default: true) indicates whether the
% income tax should be optimized or held fixed at the US status quo. 
% The optional argument mvpfST (default: 1) rescales the Marginal Value of Public Funds
% for Sin Tax revenues, to be scaled higher or lower than the mvpf from income taxes.


inc_mtrs_old = eqbm.inc_mtrs;
soda_tax_old = eqbm.soda_tax;
soda_tax_change = 0;
policy_change = [1 1];
idx = 1;

if ~exist('incTaxHeldFixed','var'), incTaxHeldFixed = true; end
if ~exist('mvpfST','var'), mvpfST = 1; end

while (sum(policy_change) > 1e-4) || (idx < 5)
    % require at least 5 iterations, since under prefhet qsoda updates immediately, but we
    % need to run through an additional iteration so that everything (including
    % consumption) gets updated
    
    % 1. Compute MSWWs
    [eqbm.msww,eqbm.msww_hat] = compute_mswws(prim,eqbm,mvpfST);
    
    % 2. Update optimal income tax
    if ~incTaxHeldFixed
        eqbm.inc_mtrs = smooth(compute_income_tax(prim,eqbm,mvpfST));
    end
    
    inc_mtrs_change = norm(eqbm.inc_mtrs - inc_mtrs_old);
    inc_mtrs_old = eqbm.inc_mtrs;
    
    % 3. Update labor supply, grant, and consumption
    eqbm.income = compute_income(prim,eqbm);
    inc_tax = cumtrapz(eqbm.income,eqbm.inc_mtrs);
    eqbm.grant = trapz(prim.F,inc_tax) + ...
        eqbm.soda_tax * trapz(prim.F,eqbm.qsoda) - prim.revreq;
    eqbm.consump = eqbm.grant + eqbm.income ...
        - inc_tax - (prim.ssbPrice + eqbm.soda_tax)*eqbm.qsoda;
    
    % 4. Update soda consumption
    eqbm.qsoda = compute_soda_consump(prim,eqbm);
    
    
    % 5. Update soda tax if income tax has converged
    if inc_mtrs_change < 1e-2
        eqbm.soda_tax = compute_soda_tax(prim,eqbm,mvpfST);
    end
    soda_tax_change = eqbm.soda_tax - soda_tax_old;
    soda_tax_old = eqbm.soda_tax;
    
    
    qsoda_old = eqbm.qsoda;
    eqbm.qsoda = compute_soda_consump(prim,eqbm);
    qsoda_change = norm(eqbm.qsoda - qsoda_old);
    
    policy_change = [inc_mtrs_change soda_tax_change qsoda_change];
    
    idx = idx+1;
    if idx > 500, warning('exceeded iteration limit'); break; end
    
end

end
