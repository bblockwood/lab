function gamma = load_bias(incUS,F,SPEC)
% Import SSB bias estimates

global DATADIR;

startRow = 2;
endRow = inf;

delimiter = ',';


filename = [DATADIR '/input/BiasByIncome.csv'];
fileID = fopen(filename,'r');
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
dataArray = textscan(fileID, formatSpec, inf, 'Delimiter', ',', 'HeaderLines', 1);
fclose(fileID);

incBinBias = dataArray{:, 1}*1000;

% Read in bias as computed from HomeScan and PanelViews data
switch SPEC
            
    case {'noInternality','noCorrection'}
        gammaLiters = zeros(size(z));
    
    case 'selfReports' % PanelViews (self-reports)
        gammaLiters = dataArray{:, 2};
        
    case 'knowledgeOnly' % only knowledge drives bias, no self control problems
        gammaLiters = dataArray{:, 15};
        
    case 'measError' % use measurement error correction for self control estimation 
        gammaLiters = dataArray{:, 16};

    case 'selfControlTwice' % self control coefficient doubled
        gammaLiters = dataArray{:, 17};

    case 'selfControlHalf' % self control coefficient reduced by half
        gammaP = dataArray{:, 14};
        gammaN = dataArray{:, 17};
        gammaLiters = gammaP - 0.5*(gammaN - gammaP);
        
    otherwise % HomeScan (baseline)
        gammaLiters = dataArray{:, 14};
        
end

% Converts bias from $/Liter to $/oz
conversion = 1/35.274; 
biasVec = gammaLiters*conversion;


% Need to interpolate to associate bias with each income point in simulated
% distribution, which is much finer than bias bins. Therefore, find the percentile in
% simulated income distribution that corresponds to each incbin level of bias estimates...
F_bias = interpcon(incUS,F,incBinBias);

% ...then use kernel smoothing to fill in bias across all percentiles of distribution
% gamma = interpcon(F_bias,biasVec,F,'linear','extrap');
rBias = ksr_vw(F_bias,biasVec); % allow optimal variable bandwidth
gamma = interpcon(rBias.x,rBias.f,F,'linear','extrap');

% ssbPrice = load_price()/100; % dollars per ounce
% gamma = biasPctSmooth.*ssbPrice./ssbElast;

switch SPEC
    case {'constBiasElast','incEffectsStruc','prefHetStruc','figure'}
        gamma = trapz(F,gamma)*ones(size(F));
end

end
