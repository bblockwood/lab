function run_simulations()
% Simulate optimal nonlinear income tax using PSZ income distribution.

clear all;
addpath(genpath('./functions/'));
addpath(genpath('../../../../lib/matlab/'));

global DATADIR OUTPUT VERBOSE; 
DATADIR = '../data'; 
OUTPUT = '../output';
VERBOSE = false; % report verbose logging to console?

diaryfile = [OUTPUT '/logfile_new.txt'];
if (exist(diaryfile,'file')), delete(diaryfile); end
diary(diaryfile);


%% Compute structural results

% Load PSZ income distribution data
D = load_data();

% Store results of different specifications in a cell
Results = { economy(D, 'baseline') ...
            economy_weakRedist(D, 'Weaker redistributive preferences') ...
            economy_strongRedist(D, 'Stronger redistributive preferences') ...
            economy_invOpt(D, 'Redistributive preferences rationalize U.S. income tax') };


%% Plot marginal tax rate across income distribution
for i = 1:4
    plot(Results{i}.income,Results{i}.inc_mtrs,'Marker','o','Markersize',5);
    hold on;
end

ubound = 3*10^5;
xlim([0 ubound]);
ylim([-.1 1]);
legend({'Baseline','Weak redistributive preferences','Strong redistributive preferences',...
    'Redistributive preferences rationalize U.S. income taxes'},'location','northeast');
% set(gca,'fontsize',14);
% 
xlabel('Wage income z');
ylabel('Marginal tax rate');

fname = [OUTPUT '/Figures/tax_rates_new.pdf'];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

print(fig,fname,'-dpdf');
close;


%% Display and export results

save([OUTPUT '/results_workspace.mat'],'Results');

disp('Finished.')
diary off;


%% Helper function for loading data

function status_quo = load_data()

    [~, ~, raw] = xlsread([DATADIR '/input/PSZ2017MainData.xlsx'],'DataFS40');
    raw = raw(3:133,[2,15,23]);
    raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
    R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
    raw(R) = {NaN}; % Replace non-numeric cells
    data = reshape([raw{:}],size(raw));

    cdf = data(2:end,1);
    pmf = diff(cdf);
    z = data(3:end ,2); % pre-tax income
    c = data(3:end,3); % post-tax income

    % drop bottom tail with incomes below $500 (bottom 4% of population;
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
    incUS = z*CPI_2015/CPI_2014;
    consumpUS = c*CPI_2015/CPI_2014;

    status_quo.pmf = pmf;
    status_quo.incUS = incUS;
    status_quo.consumpUS = consumpUS;

end

end
