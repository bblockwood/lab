function [tStarFixedIncTax, tStarOptIncTax, dw] = compute_sufficient_statistics(SPEC,ssbTaxForWelfareCalc)
% Computes optimal tax and welfare gains ($ per year per cap) using sufficient statistics formulas.
% The optional argument ssbTaxForWelfareCalc computes welfare gains 

global DATADIR OUTPUT LABORELAST;

kgToOz = 35.274;
timeConversion = 1/52; % 1/52 converts annual figures into weekly figures


%% LOAD INCOME BINS AND SSB CONSUMPTION

filename = [DATADIR '/input/ConsumptionByIncome.csv'];
formatSpec = '%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, inf, 'Delimiter', ',', 'HeaderLines', 1);
fclose(fileID);

z = dataArray{:, 1}*1000; % income bins

switch SPEC
    
    case 'selfReports' % PanelViews (self-reports)
        sKg = dataArray{:, 3}; % SSB consumption -- self reported from PanelViews
        
    otherwise
        sKg = dataArray{:, 2}; % SSB consumption (liters annually)
        
end

s = sKg*kgToOz*timeConversion;


%% LOAD U.S. INCOME DISTRIBUTION AND MARGINAL TAX RATE INFORMATION
[pmf,incPSZ,consumpPSZ] = load_income_dist(); % from Piketty Saez Zucman

F = cumsum(pmf);
N = length(incPSZ);

% construct schedule of tax rates: d(z-c)/dz, with kernel smoothing regression
mtrRaw = diff(incPSZ - consumpPSZ)./diff(incPSZ);
r = ksr(F(2:end),mtrRaw); % chooses optimal bandwidth automatically
mtrPSZ = interpcon(r.x,r.f,F,'linear','extrap');
mtr = interpcon(incPSZ,mtrPSZ,z);


%% CONSTRUCT MASS IN EACH INCOME BIN
zMP = (z(1:end-1)+z(2:end))/2; % midpoints between income bins

f = NaN(size(z));
f(1) = sum(pmf(incPSZ<zMP(1)));

for i=2:length(zMP)
    f(i) = sum(pmf(incPSZ > zMP(i-1) & incPSZ < zMP(i)));
end

f(end) = sum(pmf(incPSZ > zMP(end)));



%% LOAD SSB DEMAND ELASTICITY AND SSB INCOME ELASTICITY

filename = [DATADIR '/input/PriceElasticity_IncomeHet.csv'];
fileID = fopen(filename,'r');
formatSpec = '%f%f%f%f%[^\n\r]';
dataArray = textscan(fileID, formatSpec, inf, 'Delimiter', ',', 'HeaderLines', 1);
fclose(fileID);

elast0 = dataArray{:, 1}; % demand elasticity intercept
elastz = dataArray{:, 2}; % demand elasticity interaction with income (in $100,000s)
incElast0 = dataArray{:, 3};
incElastz = dataArray{:, 4};


switch SPEC 
    case 'lowElast'
        elast = ones(size(z));
    case 'highElast'
        elast = 2*ones(size(z));
    case 'steepElast'
        elastRaw = elast0 + (z/100000).*elastz;
        elastAvg = f'*elastRaw;
        steepness = 4; % use more steeply declining elasticity with income, preserving avg
        elast0steep = elastAvg - f'*((z/100000).*steepness.*elastz);
        elast = elast0steep + (z/100000).*steepness.*elastz;
    otherwise
        elast = elast0 + (z/100000).*elastz;
end


switch SPEC
    
    case 'prefHet'
        incElast = zeros(size(z));
        
    case 'incEffects'
        % compute income elasticity vector which would explain observed s consump profile
        
        incElast = derivative(log(s),log(z));        
        
    otherwise

        incElast = incElast0 + (z/100000).*incElastz;
        
end

%% LOAD MONEY-METRIC BIAS

filename = [DATADIR '/input/BiasByIncome.csv'];
fileID = fopen(filename,'r');
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
dataArray = textscan(fileID, formatSpec, inf, 'Delimiter', ',', 'HeaderLines', 1);
fclose(fileID);

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
                
    otherwise % HomeScan (includes measurement error adjustment)
        gammaLiters = dataArray{:, 14};
        
end

gamma = gammaLiters*100/kgToOz;


%% SPECIFY WELFARE WEIGHTS

switch SPEC
    
    case 'inverseOpt' % compute weights to rationalize US income tax

        % interpolate a fine grid of incomes and densities 
        numpoints = 1000;
        FF = [0; F];
        incMP = [0; (incPSZ(1:end-1)+incPSZ(2:end))/2; incPSZ(end)]; % inc grid midpoints
        ff = diff(FF)./diff(incMP);
        bandwidth = 4;
        r = ksr_vw(log(incPSZ),log(ff),bandwidth,numpoints);
        logz = r.x;
        logf = r.f;
        
        % compute weights using Hendren's Efficient Welfare Weights formula
        fElastRaw = diff(logf)./diff(logz); % elasts at the midpoints between bins
        xMP = (r.x(1:end-1)+r.x(2:end))/2;
        fElast = interpcon(xMP,fElastRaw,log(incPSZ),'linear','extrap');
        alpha = -(1 + fElast);
        fiscExt = -LABORELAST*mtrPSZ./(1-mtrPSZ).*alpha;
        gg = 1 + fiscExt;
        r = ksr(F,gg,0.1,1000);
        ggInterp = interpcon(r.x,r.f,F,'linear','extrap');
        mswwRaw = interpcon(incPSZ,ggInterp,z);
        
    otherwise % compute weights based on CRRA utility function over consumption
        
        switch SPEC
            case 'weakRedist'
                redistStrength = -0.25;
            case 'strongRedist'
                redistStrength = -4;
            otherwise
                redistStrength = -1;
        end
        c = interpcon(incPSZ,consumpPSZ,z);
        mswwRaw = c.^(redistStrength);

end

g = mswwRaw/(f'*mswwRaw);


%% COMPUTE sPref

switch SPEC

    case 'prefHet'
        sPref = s;
        
    case 'incEffects'
        sPref = zeros(size(s));
        
    otherwise
        dlnz = diff(log(z));
        incElastMP = (incElast(1:end-1) + incElast(2:end))/2; % income elasticity midpoints
        dlns = dlnz.*incElastMP; % change in log SSB consump attributable to income effects
        lnsInc = cumsum([log(s(1)); dlns]);
        sInc = exp(lnsInc);
        sPref = s - sInc;
end



%% COMPUTE OPTIMAL TAX USING SUFFICIENT STATISTICS FORMULAS

p = load_price();
write_param('ssbprice',round(p,2));

switch SPEC
    case 'noCorrection'
        e = 0;
    otherwise
        e = 0.85;
end

E = @(x) f'*x;
COV = @(x,y) E(x.*y) - E(x)*E(y);

% Compute internalities and externalities accounting for substitution
switch SPEC
    case {'subsBaseline','subsDouble','subsHalf','subsDietGood','subsDietBad','subsCrossBorder25','subsCrossBorder50'}
        
        phi = load_phi(SPEC);
        gammaTilde = gamma./p; % price-normalized internality
        eTilde = e./p;
        
        switch SPEC
                
            case 'subsDouble'
                gammaTildeUntaxed = 2*gammaTilde; % internality of untaxed sin goods
                eTildeUntaxed = 2*eTilde; % externality of untaxed sin goods
                
            case 'subsHalf'
                gammaTildeUntaxed = 0.5*gammaTilde;
                eTildeUntaxed = 0.5*eTilde;
                
            otherwise
                gammaTildeUntaxed = gammaTilde; 
                eTildeUntaxed = eTilde; 
            
        end

        gamma = p*(gammaTilde - phi*gammaTildeUntaxed);
        e = p*(eTilde - phi*eTildeUntaxed);
        
end


sBar = E(s);
elastBar = E(elast.*s)./sBar; 
gammaBar = E(gamma.*elast.*s)./E(elast.*s);
gBar = E(g);
eti = LABORELAST;

switch SPEC
    case {'noInternality','noCorrection'}
        sigma = 0;
    otherwise
        sigma = COV(g,(gamma.*elast.*s)./(gammaBar*elastBar*sBar));
end

switch SPEC
    
    case 'pigou'
        tStarFixedIncTax = gammaBar + e;
        tStarOptIncTax = NaN;
        
    otherwise
        % Fixed income tax
        A = (gBar - 1)*sBar + COV(g,s) + E(mtr./(1-mtr) .* eti .* s .* incElast);
        num = sBar .* elastBar .* (gammaBar .* (gBar + sigma) + e) - p.*A;
        denom = sBar .* elastBar + A;
        tStarFixedIncTax = num ./ denom;
        
        % Optimal income tax
        AA = COV(g,sPref);
        num = sBar .* elastBar .* (gammaBar .* (gBar + sigma) + e) - p.*AA;
        denom = sBar .* elastBar + AA;
        tStarOptIncTax = num ./ denom;
        
        switch SPEC
            case {'subsCrossBorder25','subsCrossBorder50'}
                tStarOptIncTax = NaN; % no optimal income tax assumption for localized tax
        end
        
end

%% COMPUTE EQUIVALENT VARIATION AND WELFARE GAINS

% Scale factor to convert units to dollars per cap per year
conv = 1/100/timeConversion;

switch SPEC
    case 'fixedTax'
        t = ssbTaxForWelfareCalc;
    otherwise
        t = tStarFixedIncTax;
end

% LOGLINEAR APPROXIMATION
sNew = s.*((p+t)/p).^(-elast);

sReduc = s - sNew;

EV_dec = -(sNew.*(p+t) - s.*p)./(1-elast);
Int = gamma.*sReduc;
Rev = t.*E(sNew) - t.*E(mtr./(1-mtr) .* eti .* s .* incElast);
Ext = e*E(sReduc);

dw = (E(EV_dec.*g) + E(Int.*g) + Rev + Ext)*conv;

        
% Make welfare gains decomposition figure for desired specifications
% For now, print to console the data used to make welfare figure
% (Note: this will be made in Matlab, but for now jerry rigged in Excel)
switch SPEC
    case {'baseline','selfReports','noInternality'}

        dW_decomp = [EV_dec Int repmat([Rev Ext],length(z),1)]*conv;

        bar(dW_decomp(:,2)+dW_decomp(:,3)+dW_decomp(:,4),'FaceColor',[.1 .1 .5]); % externality
        hold on;
        bar(dW_decomp(:,2)+dW_decomp(:,3),'FaceColor',[.3 .3 .7]); % revenues
        bar(dW_decomp(:,2),'FaceColor',[.5 .5 .9]); % internality correction
        bar(dW_decomp(:,1),'FaceColor',[.7 .2 .2]); % EV decision utility
        plot(sum(dW_decomp,2),'ks-','LineWidth',4); % total
        hold off;
        
        xlabel('Income bin');
        ylabel('Dollars per capita, annually');
        
        switch SPEC
            case 'baseline'
                ylim([-60 60]);
            case 'selfReports'
                ylim([-150 150]);
        end
        
        ax = gca;
        ax.XTick = [1 2 3 4 5 6 7 8 9];
        ax.XTickLabels = {'$5k','$15k','$25k','$35k','$45k','$55k','$65k','$85k','$125k'};

        set(gca,'fontsize',14);
                
        lgd = legend('Externality correction','Redistributed Revenues',...
            'Internality Correction','Decision utility EV','Total','Location','southeast');
        lgd.FontSize = 10;
 
        fname = [OUTPUT '/Figures/welfare' SPEC '.pdf'];
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        
        print(fig,fname,'-dpdf');
        close;

end



%% EXPORT DATA TABLE FOR MANUAL COMPUTATION OF t^*

if strcmp(SPEC,'baseline')
      
    % Numbers used in text
    write_param('sBar',round(sBar,2));
    write_param('zetaBar',round(elastBar,2));
    write_param('gammaBar',round(gammaBar,2));
    write_param('sigma',round(sigma,2));
    write_param('sigma100',round(sigma,2)*100);
    write_param('covgs',round(COV(g,s),2));
    write_param('covgsPref',round(COV(g,sPref),2));
    write_param('fixedinctaxexpec',round(E(mtr./(1-mtr) .* eti .* s .* incElast),2));
    write_param('corrective',round(gammaBar .* (gBar + sigma) + e,2));
    write_param('intplusext',round(gammaBar + e,2));
    write_param('demandslope',round(elastBar.*sBar./p,2));
    
    dwlapprox = 0.5.*(elastBar.*sBar./p).*(gammaBar + e).^2;
    write_param('dwlapprox',round(dwlapprox,2));
    write_param('dwlapproxdollars',round(dwlapprox./100.*52,2));
    
    
    % Panel A
    tabA.data = [sBar; p; elastBar; eti;  gammaBar; e];
    tabA.dataFormat = {'%.2f',1};
    tabA.dataFormatMode = 'column';
    tabA.tableColumnAlignment = {'l','c'};
    tabA.tableColLabels = {'Value'};
    tabA.tableRowLabels = {'SSB consumption (ounces per week): $\bar s$','SSB price (cents per ounce): $p$','SSB demand elasticity: $\bar\zeta^c$','Elasticity of taxable income: $\bar\zeta_z$','Average marginal bias (cents per ounce): $\bar\gamma$','Externality (cents per ounce): $e$'};
    tabA.tableCaption = '';
    latex = latexTable(tabA);

    outFile = [OUTPUT '/manual_computation_table_A.tex'];
    fid = fopen(outFile,'wt');
    for ir=1:size(latex,1)
        fprintf(fid, '%s\n', latex{ir});
    end
    fclose(fid);

    
    
    % Panel B
    data = [z f s elast incElast gamma g mtr round(sPref,1)];
    
    tabB.tableColLabels = {'$z$','$f$','$\bar s(z)$','$\bar\zeta^c(z)$','$\xi(z)$',...
        '$\bar\gamma(z)$','$g(z)$','$T''(z)$','$s_{pref}(z)$'};
    tabB.tableCaption = '';
    % tab.tableRowLabels = {};
    tabB.data = data;
    tabB.dataFormat = {'%.0f',1,'%.2f',1,'%.1f',1,'%.2f',5,'%.1f',1};
    tabB.dataFormatMode = 'column';
    tabB.tableColumnAlignment = {'l','c','c','c','c','c','c','c','c'};
    
    latex = latexTable(tabB);
  
    
    % export version for slides
    outFile = [OUTPUT '/manual_computation_table_slides.tex'];
    fid = fopen(outFile,'wt');
    for ir=1:size(latex,1)
        fprintf(fid, '%s\n', latex{ir});
    end
    fclose(fid);
    
    
    % add final row with covariances
    sigmaText = ['$\sigma \approx ' num2str(round(sigma,2)) '$'];
    covgsText = ['$Cov\left[g(z),s_{pref}(z)\right] \approx ' num2str(round(COV(g,sPref),2)) '$'];
    fiscExtText = ['$\mathbb{E}\left[\frac{T''(z)}{1-T''(z)}\bar{\zeta}_{z}\bar{s}(z)\bar{\xi}_{inc}(z)\right] \approx ' num2str(round(E(mtr./(1-mtr) .* eti .* s .* incElast),2)) '$'];

    newRow = ['\multicolumn{9}{c}{' sigmaText ', ' covgsText ', ' fiscExtText '} \\'];

    latex = latex(1:end-3); % delete ending rows
    latex(end+1) = {'\hline'}; % tack on desired end rows
    latex(end+1) = {newRow};
    latex(end+1) = {'\hline'};
    latex(end+1) = {'\hline'};
    latex(end+1) = {'\end{tabular}'};
    
    outFile = [OUTPUT '/manual_computation_table_B.tex'];
    fid = fopen(outFile,'wt');
    for ir=1:size(latex,1)
        fprintf(fid, '%s\n', latex{ir});
    end
    fclose(fid);
    
end

end
