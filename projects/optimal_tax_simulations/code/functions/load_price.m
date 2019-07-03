function ssbOzPrice = load_price()
% Load price of SSB, in cents per ounce

global DATADIR;

startRow = 2;
endRow = inf;

delimiter = ',';

formatSpec = '%f%f%[^\n\r]';

% read price
filename = [DATADIR '/input/AveragePrice.csv'];
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
ssbKgPrice = dataArray{:, 1};

ssbOzPrice = ssbKgPrice./35.274*100; % convert to cents per ounce

end
