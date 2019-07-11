function ssbTax = compute_simple_tax(prim,eqbm,fixedflag)
% Computes simple soda tax using sufficient statistics computed in status quo. 
% This uses the formula which appears in Corollary 1. 

elast = 1./prim.k .* ssbPrice ./ (ssbPrice + prim.iota);

s = eqbm.qsoda;
sPref = prim.sPref;
gamma = prim.gamma;
mvpfST = 1; % not focusing on alternative MVPFs of sin tax funds in this specification
g = compute_mswws(prim,eqbm,mvpfST);
p = prim.ssbPrice;
e = prim.externality;
zetaZ = prim.laborElast;
mtr = eqbm.inc_mtrs;
xiInc = prim.ssbIncElastRaw;

% Expectation and covariance operators under the population distribution
E = @(x) trapz(prim.F,x);
COV = @(x,y) E(x.*y) - E(x).*E(y);

sBar = E(s);
elastBar = E(elast); 
gBar = E(g);
gammaBar = E(gamma);

sigma = COV(g,(gamma .* elast .* s)./(gammaBar .* elastBar .* sBar));

switch fixedflag
    case 'fixed_income_tax'
        A = (gBar - 1)*sBar + COV(g,s) + E(mtr./(1-mtr) .* zetaZ .* s .* xiInc);
    case 'flex_income_tax'
        A = COV(g,sPref);
end

num = sBar .* elastBar .* (gammaBar .* (gBar + sigma) + e) - p.*A;
denom = sBar .* elastBar + A;

ssbTax = num ./ denom;

end
