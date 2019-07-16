function [prim,eqbm] = calibrate_primitives(SPEC)
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


% CALIBRATE PARETO WEIGHTS 
% Compute Pareto weights based on total consumption in US status quo (these stay fixed)

switch SPEC 

    case 'inverseOpt'
        
        % Compute implicit weights from US tax system using inverse optimum approach
        FF = [0; F];
        incMP = [0; (incUS(1:end-1)+incUS(2:end))/2; incUS(end)];
        ff = diff(FF)./diff(incMP);
        bandwidth = 4;
        numpoints = 1000;
        r = ksr_vw(log(incUS),log(ff),bandwidth,numpoints);
        logz = r.x;
        logf = r.f;
        fElastRaw = diff(logf)./diff(logz); % elasts at the midpoints between bins
        xMP = (r.x(1:end-1)+r.x(2:end))/2;
        fElast = interpcon(xMP,fElastRaw,log(incUS),'linear','extrap');
        alpha = -(1 + fElast);
        fiscExt = -LABORELAST*mtrUS./(1-mtrUS).*alpha;
        gg = 1 + fiscExt;
        r = ksr(F,gg,0.1,1000);
        mswwInvOpt = interpcon(r.x,r.f,F,'linear','extrap');
        paretoWts = mswwInvOpt;
        
    otherwise
        
        % Compute Pareto weights based on total consumption in US status quo (these stay fixed)
        switch SPEC
                
            case 'weakRedist'
                inequality_aversion_parameter = 0.25;
                
            case 'strongRedist'
                inequality_aversion_parameter = 4;
                
            otherwise
                inequality_aversion_parameter = 1;
                
        end
        
        paretoWts = consumpUS.^(-inequality_aversion_parameter);
        
end


% STORE VALUES IN prim AND eqbm STRUCTURES

% PRIM
% scalars:
prim.laborElast = LABORELAST;
prim.revreq = rev_requirement;

% vectors:
prim.paretoWts = paretoWts;
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
