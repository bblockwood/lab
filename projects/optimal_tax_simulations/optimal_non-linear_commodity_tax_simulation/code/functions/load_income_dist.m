function [pmf,zFinal,cFinal] = load_income_dist()
% Loads income distribution data from Piketty Saez Zucman.

global DATADIR;

[~, ~, raw] = xlsread([DATADIR '/input/PSZ2017MainData.xlsx'],'DataFS40');
raw = raw(3:133,[2,15,23]);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells
data = reshape([raw{:}],size(raw));

cdf = data(2:end,1);
pmf = diff(cdf);

z = data(3:end,2); % pre-tax income
c = data(3:end,3); % post-tax income

% drop bottom tail with incomes below $500 (bottom 4% of population)
% also drop rows with pmf == 0, which comes from data error in original
% spreadsheet, which repeated rows for pctiles 99, 99.9, and 99.99
toKeep = (z > 500 & pmf > 0);
pmf = pmf(toKeep);
pmf = pmf/sum(pmf); % ensure sums exactly to 1
z = z(toKeep);
c = c(toKeep);


% Convert to 2015 dollars
CPI_2015 = 1;
CPI_2014 = .99880445;

zFinal = z*CPI_2015/CPI_2014;
cFinal = c*CPI_2015/CPI_2014;

end
