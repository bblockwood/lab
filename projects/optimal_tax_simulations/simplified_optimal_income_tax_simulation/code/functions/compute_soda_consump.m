function qsoda = compute_soda_consump(prim,eqbm)
% Compute soda consumption using decision utility FOC

global VERBOSE;

N = length(prim.F);

ab = compute_ab(prim,eqbm);
b = prim.b;
a_c = compute_a_c(prim,eqbm);

k = prim.k;
iota = prim.iota;

v = @(s) ab .* s.^(1-k) ./ (1-k) - iota.*s;
v_s = @(s) ab .* s.^(-k) - iota;
v_c = @(s) a_c .* b .* (v(s)./ab); % last term is s.^(1-k) ./ (1-k) -- speeds computation

p = prim.ssbPrice;
t = eqbm.soda_tax;

dUtil_dSoda = @(s) -(p+t)*(1 + v_c(s)) + v_s(s);

opts = optimoptions('fsolve','Algorithm','trust-region-reflective',...
    'FunctionTolerance',1e-14,'OptimalityTolerance',1e-14,'JacobPattern',eye(N));

if ~VERBOSE, opts.Display = 'none'; end

s0 = eqbm.qsoda;
[qsoda,~,flag] = fsolve(dUtil_dSoda,s0,opts);

if flag <= 0
    warning(['compute_soda_consump did''t find solution, flag = ' num2str(flag)]);
end

end
