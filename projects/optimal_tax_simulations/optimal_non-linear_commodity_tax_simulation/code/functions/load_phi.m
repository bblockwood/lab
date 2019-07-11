function phi = load_phi(SPEC)
% Import varphi parameter to account for subsitution patterns

global DATADIR;

startRow = 2;
endRow = inf;

delimiter = ',';

filename = [DATADIR '/input/varphi.csv'];
fileID = fopen(filename,'r');
formatSpec = '%f%f%[^\n\r]';
dataArray = textscan(fileID, formatSpec, inf, 'Delimiter', ',', 'HeaderLines', 1);
fclose(fileID);

switch SPEC 

    case 'subsCrossBorder25'
        % Substitution across local borders, based on Seiler et al. estimates
        phi = 0.25;
    
    case 'subsCrossBorder50'
        % Substitution across local borders, based on Seiler et al. estimates
        phi = 0.5;

    case 'subsDietGood'
        % Substitution to non-diet-drink goods
        phi = dataArray{:, 2};

    case 'subsDietBad'
        % Substitution to diet drinks
        phi = dataArray{:, 1} - dataArray{:, 2};

    otherwise
        % Substituting to all other goods
        phi = dataArray{:, 1};
        
end

end