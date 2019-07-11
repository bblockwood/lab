function qsodaUS = calibrate_ssb_consump(incUS,F,SPEC)
% Interpolates SSB consumption (oz/yr) across incomes, estimated from Nielsen data.
% incomeGrid is the discretized grid of US incomes for simulations. 

global DATADIR;

filename = [DATADIR '/input/ConsumptionByIncome.csv'];
formatSpec = '%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, inf, 'Delimiter', ',', 'HeaderLines', 1, ...
    'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);

incomeBinSSB = dataArray{:, 1}*1000;

switch SPEC
    case 'optTaxSelfReports'
        sodaConsumpKg = dataArray{:, 3};
        sodaConsumpKgSD = dataArray{:, 5};
    otherwise
        sodaConsumpKg = dataArray{:, 2};
        sodaConsumpKgSD = dataArray{:, 4};
end

% Convert kg to ounces
sodaConsumpOz = 35.274*sodaConsumpKg; 
sodaConsumpOzSD = 35.274*sodaConsumpKgSD;

% Need to interpolate to associate consumption with each income point in simulated
% distribution, which is much finer than ssb data. Therefore, find the percentile in
% simulated income distribution that corresponds to each incbin level in ssb data...
F_SSB = interpcon(incUS,F,incomeBinSSB);

% ...then interpolate (& extrapolate) linearly to fill in projected soda consumption
% across all percentiles in simulated distribution.
qsodaUS = interpcon(F_SSB,sodaConsumpOz,F,'linear','extrap');

end
