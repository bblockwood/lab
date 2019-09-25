function run_simulations()
% Simulate optimal nonlinear income tax using PSZ income distribution.

clear all;
addpath(genpath('./functions/'));
addpath(genpath('../../../../lib/matlab/'));

global DATADIR OUTPUT VERBOSE LABORELAST; 
DATADIR = '../data'; 
OUTPUT = '../output';
VERBOSE = false; % report verbose logging to console?

% global parameters
LABORELAST = 0.33; % from Chetty ECMA 2012

diaryfile = [OUTPUT '/logfile_new.txt'];
if (exist(diaryfile,'file')), delete(diaryfile); end
diary(diaryfile);

USPop = 0.311; % U.S. adult equivalents, in billions (see text)


%% Compute structural results

% Each specification stores results in a structure r, with 
%   r.spec: name of specification
%   r.desc: description (e.g., for exported table row titles)
%   r.prim: model primitives for this specification
%   r.eqbm: equilibrium values for this specification
%   r.eqbmOptIncTax: equilibrium when income tax is solved for optimum
% These results are then stored in a cell called Results.


% List of specifications to be run in the following simulations
specs = {...
    {'baseline','Baseline'}... 
    {'weakRedist','Weaker redistributive preferences'}... 
    {'strongRedist','Stronger redistributive preferences'}... 
    {'inverseOpt','Redistributive preferences rationalize U.S. income tax'}... 
};


% Loop over specifications to run
specRange = 1:length(specs);
    
    for iR = specRange
        
        clear r;
        iSpec = specs{iR};
        r.spec = iSpec{1}; % specification name
        r.desc = [num2str(iR) '. ' iSpec{2}]; % specification description (for Tex table)
        
        [r.prim,eqbm_US] = calibrate_primitives(r.spec);
        
        % Compute optimal income tax
        r.eqbmOptIncTax = compute_optimal_taxes(r.prim,eqbm_US);
        
        Results{iR} = r;
        
    end
    
    
%% Plot MSWWs across income distribution
for i = specRange
    plot(Results{i}.eqbmOptIncTax.income,Results{i}.eqbmOptIncTax.msww,'Marker','o','Markersize',5);
    hold on;
end

ubound = 3*10^5;
xlim([0 ubound]);
ylim([0 6]);
legend({'Baseline','Weak redistributive preferences','Strong redistributive preferences',...
    'Redistributive preferences rationalize U.S. income taxes'},'location','southeast');
set(gca,'fontsize',8);

xlabel('Income z');
ylabel('Marginal social welfare weights');

fname = [OUTPUT '/Figures/mswws.pdf'];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

print(fig,fname,'-dpdf');
close;    
   
    
%% Plot income CDF at optimum
for i = specRange
    plot(Results{i}.eqbmOptIncTax.income,Results{i}.eqbmOptIncTax.F,'Marker','o','Markersize',5);
    hold on;
end

ubound = 3*10^5;
xlim([0 ubound]);
ylim([0 1]);
legend({'Baseline','Weak redistributive preferences','Strong redistributive preferences',...
    'Redistributive preferences rationalize U.S. income taxes'},'location','southeast');
set(gca,'fontsize',8);

xlabel('Income z');
ylabel('F');

fname = [OUTPUT '/Figures/income_cdf.pdf'];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

print(fig,fname,'-dpdf');
close;

%% Plot consumption CDF at optimum
for i = specRange
    plot(Results{i}.eqbmOptIncTax.consump,Results{i}.eqbmOptIncTax.F,'Marker','o','Markersize',5);
    hold on;
end

ubound = 3*10^5;
xlim([0 ubound]);
ylim([0 1]);
legend({'Baseline','Weak redistributive preferences','Strong redistributive preferences',...
    'Redistributive preferences rationalize U.S. income taxes'},'location','southeast');
set(gca,'fontsize',8);

xlabel('Consumption c');
ylabel('F');

fname = [OUTPUT '/Figures/consumption_cdf.pdf'];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

print(fig,fname,'-dpdf');
close;


%% Plot marginal tax rate across income distribution
for i = specRange
    plot(Results{i}.eqbmOptIncTax.income,Results{i}.eqbmOptIncTax.inc_mtrs,'Marker','o','Markersize',5);
    hold on;
end

ubound = 3*10^5;
xlim([0 ubound]);
ylim([-.1 1]);
legend({'Baseline','Weak redistributive preferences','Strong redistributive preferences',...
    'Redistributive preferences rationalize U.S. income taxes'},'location','southeast');
% set(gca,'fontsize',14);
% 
xlabel('Wage income z');
ylabel('Marginal tax rate');

fname = [OUTPUT '/Figures/tax_rates.pdf'];
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

end
