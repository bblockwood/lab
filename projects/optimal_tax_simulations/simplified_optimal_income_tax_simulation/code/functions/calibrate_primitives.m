function [prim,eqbm] = calibrate_primitives()
% Calibrates primitives of model.
% Returns two data structures:
%   prim: model primitive parameters (invariant to policy)
%   eqbm: policy params, endogenous choice variables (representing US equilibrium here)


global LABORELAST;


% IMPORT US INCOME DISTRIBUTION
[pmf,incUS,consumpUS] = load_income_dist();

F = cumsum(pmf);
N = length(incUS);


% CALIBRATE US TAX SCHEDULE: MARGINAL RATES, LUMP SUM GRANT, REVENUE REQUIREMENT
% construct schedule of tax rates: d(z-c)/dz, with kernel smoothing regression
mtrRaw = diff(incUS - consumpUS)./diff(incUS);
r = ksr(F(2:end),mtrRaw); % chooses optimal bandwidth automatically
mtrUS = interpcon(r.x,r.f,F,'linear','extrap');
rev_requirement = trapz(F,incUS - consumpUS);
grant_US = consumpUS(1);


% STORE VALUES IN prim AND eqbm STRUCTURES

% PRIM
% scalars:
prim.laborElast = LABORELAST;
prim.revreq = rev_requirement;

% vectors:
prim.F = F;


% EQBM
% Store structure containing endogenous choice values for a given equilibrium
eqbm.inc_mtrs = mtrUS;
eqbm.consump = consumpUS;
eqbm.income = incUS;
eqbm.grant = grant_US; 
eqbm.msww = zeros(N,1); % marginal social welfare weights (initialize to zero)


% Calibrate ability (wage) distribution
wage = (incUS.^(1./LABORELAST)./(1-mtrUS)).^(LABORELAST./(1+LABORELAST));
prim.wage = wage;


end
