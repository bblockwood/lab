function [ssbElast,ssbIncElast] = load_ssb_elast(incUS,consumpUS,ssbConsumpUS,mtrUS,F,SPEC)
% Read in parameters from external files

global DATADIR;

filename = [DATADIR '/input/PriceElasticity_IncomeHet.csv'];
fileID = fopen(filename,'r');
formatSpec = '%f%f%f%f%[^\n\r]';
dataArray = textscan(fileID, formatSpec, inf, 'Delimiter', ',', 'HeaderLines', 1);
fclose(fileID);

elast0 = dataArray{:, 1}; % demand elasticity intercept
elastz = dataArray{:, 2}; % demand elasticity interaction with income (in $100,000s)
incElast0 = dataArray{:, 3};
incElastz = dataArray{:, 4};

ssbElastUnc = elast0 + elastz*(incUS/100000);
ssbIncElast = incElast0 + (incUS/100000).*incElastz;

ssbElastUnc = max(ssbElastUnc,0.5); % only happens at pctile 0.9995 -- prevents negative elast at top incomes
ssbIncElast = max(ssbIncElast,0);

ssbBudgetShare = trapz(F,ssbConsumpUS)./trapz(F,consumpUS);
ssbElast = ssbElastUnc + ssbIncElast*ssbBudgetShare./(1-mtrUS); % compensated elast


% Switch to alternative (constant) elasticity specification if necessary
switch SPEC

    case {'constBiasElast','prefHetStruc','incEffectsStruc','figure'}
        ssbElast = trapz(F,ssbElast);
        
    case 'highElast'
        ssbElast = 2;

    case 'lowElast'
        ssbElast = 0.9; % don't use exactly 1, since isoelastic fn is undefined there
        
end

end
