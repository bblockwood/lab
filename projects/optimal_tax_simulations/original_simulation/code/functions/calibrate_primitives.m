function [prim,eqbm] = calibrate_primitives(SPEC,internalizedHealthCost,gammaOverride,ssbElastOverride)
% Calibrates primitives of model.
% Returns two data structures:
%   prim: model primitive parameters (invariant to policy)
%   eqbm: policy params, endogenous choice variables (representing US equilibrium here)
% Optional "Override" arguments contain alternative values for bias (gamma) or ssb 
% elasticity for illustrative purposes. 

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
            
            case 'pigou'
                % no redistributive prefs
                inequality_aversion_parameter = 0;
                
            case 'weakRedist'
                inequality_aversion_parameter = 0.25;
                
            case 'strongRedist'
                inequality_aversion_parameter = 4;
                
            otherwise
                inequality_aversion_parameter = 1;
                
        end
        
        paretoWts = consumpUS.^(-inequality_aversion_parameter);
        
end

% INTERPOLATE SSB CONSUMPTION ACROSS DISCRETIZED US INCOME DISTRIBUTION
ssbConsumpUS = calibrate_ssb_consump(incUS,F,SPEC);


% INTERPOLATE SSB ELASTICITIES AND INCOME EFFECTS ACROSS DISCRETIZED US INCOME DIST.
[ssbElast,ssbIncElast] = load_ssb_elast(incUS,consumpUS,ssbConsumpUS,mtrUS,F,SPEC);


% COMPUTE SPREF, FOR PURPOSES OF SUFFICIENT STATISTICS CALCULATION
sMin = ssbConsumpUS(1);
sInc = sMin + cumtrapz(incUS,ssbIncElast.*ssbConsumpUS./incUS);
sPref = ssbConsumpUS - sInc;

% CALIBRATE BIAS: GAMMA = NEGATIVE INTERNALITY, IN DOLLARS, PER OUNCE OF SSB CONSUMP
switch SPEC
    case {'noInternality','noCorrection'}
        gamma = zeros(size(incUS));
    otherwise
        gamma = load_bias(incUS,F,SPEC);
end

% Impose override bias and elasticity, if present, for comparative static plots
if nargin > 2
    gamma = repmat(gammaOverride,N,1);
    ssbElast = ssbElastOverride;
end

% CALIBRATE INTERNALIZED PORTION OF (LINEAR) HEALTH COSTS, KAPPA
totHealthCosts = 0.1; % 10 cents per ounce, see discussion in appendix of Long et al 2015

if internalizedHealthCost == 1
    iota = totHealthCosts - gamma; % internalized health costs, dollars per ounce
else
    iota = zeros(size(incUS));
end

% SPECIFY EXTERNALITY, IN DOLLARS PER OUNCE
switch SPEC
    case {'noCorrection','figure'}
        externality = 0;
    otherwise
        externality = 0.0085; % from Wang et al Health affairs, dollars/oz
end


% LOAD SSB PRICE FROM DATA
ssbPrice = load_price()/100; % dollars per ounce (will remain fixed pre-tax price)



% STORE VALUES IN prim AND eqbm STRUCTURES

% PRIM
% scalars:
prim.ssbPrice = ssbPrice;
prim.laborElast = LABORELAST;
prim.externality = externality;
prim.revreq = rev_requirement;

% vectors:
prim.k = 1./ssbElast.*ssbPrice./(ssbPrice + iota);
prim.gamma = gamma;
prim.iota = iota;
prim.paretoWts = paretoWts;
prim.F = F;

% for use in sufficient statistic formulas
prim.ssbIncElastRaw = ssbIncElast; 
prim.sPref = sPref; 

% EQBM
% Store structure containing endogenous choice values for a given equilibrium
eqbm.soda_tax = 0;
eqbm.inc_mtrs = mtrUS;
eqbm.qsoda = ssbConsumpUS;
eqbm.consump = consumpUS - ssbConsumpUS*prim.ssbPrice; % consumption excluding SSBs
eqbm.income = incUS;
eqbm.grant = grant_US;
eqbm.msww_hat = zeros(N,1); % marginal social welfare weights (initialize to zero)
eqbm.msww = zeros(N,1);


% CALIBRATE INCOME EFFECTS VS PREFERENCE HETEROGENEITY

ab = (ssbPrice+iota).*ssbConsumpUS.^(prim.k);

switch SPEC

    case 'incEffectsStruc'
        a = ab;
        
    otherwise 
        a = ones(N,1); % pure preference heterogeneity, or starting point for iteration

end


% Iterate over a(c) to reach convergence consistent with observed income effects

etaTarget = ssbIncElast .* ssbConsumpUS ./ incUS;


for idx=1:10

    prim.b = ab ./ a;
    
    % can use log interpolation so never becomes negative
    log_a = log(a);
    log_cUS = log(consumpUS);
    prim.compute_a = @(c) exp(interpcon(log_cUS,log_a,log(c),'linear','extrap'));

    % Calibrate ability (wage) distribution
    v_c = compute_v_c(prim,eqbm);
    wage = (incUS.^(1./LABORELAST)./(1-mtrUS).*(1+v_c)).^(LABORELAST./(1+LABORELAST));
    prim.wage = wage;

    
    if strcmp(SPEC,'incEffectsStruc') || strcmp(SPEC,'prefHetStruc')
        break;
    end
    
    
    v_cc = compute_v_cc(prim,eqbm);
    SOC = compute_SOC(prim,eqbm);
    a_c_new = (ssbPrice .* v_cc - SOC .* (etaTarget ./ (1 - mtrUS))) ./ (prim.b .* ssbConsumpUS.^(-prim.k));
    
    aNew = a(1) + cumtrapz(consumpUS,a_c_new);
    aStep = 1;
    a = aStep*aNew + (1-aStep)*a;
    
    % Now update ab to reflect new calibration of v_c
    ab = (ssbPrice*(1 + v_c)+iota).*ssbConsumpUS.^(prim.k);
    
end

end
