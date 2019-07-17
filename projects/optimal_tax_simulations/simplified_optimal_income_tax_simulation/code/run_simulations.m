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
    {'baseline',1,@calibrate_paretoWts.compute_paretoWts}... 
    {'weakRedist',0.25,@calibrate_paretoWts.compute_paretoWts}... 
    {'strongRedist',4,@calibrate_paretoWts.compute_paretoWts}... 
    {'inverseOpt','',@InvOptWts.compute_paretoWts}... 
};


% Loop over specifications to run
specRange = 1:length(specs);
    
    for iR = specRange
        
        clear r;
        iSpec = specs{iR};
        r.spec = iSpec{1}; % specification name
        
        [r.prim,r.eqbm] = calibrate_primitives();

        % Calibrate Pareto Weights
        inequality_aversion_parameter = iSpec{2};
        calibration_fn = iSpec{3};
        r.prim.paretoWts = calibration_fn(inequality_aversion_parameter,r.prim,r.eqbm);
        
        % Compute optimal income tax
        r.eqbmOptIncTax = compute_optimal_taxes(r.prim,r.eqbm);
        
        Results{iR} = r;
        
    end
    
    

%% Plot marginal tax rate across income distribution
for i = 1:4
    plot(Results{i}.eqbmOptIncTax.income,Results{i}.eqbmOptIncTax.inc_mtrs,...
        'Marker','o','Markersize',5);
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
