function h = plot_comp_statics(biasVecMoneyMetric,elastVec,optTaxMat,actualBias)
% Plot optimal tax over values of bias, for a range of elasticities

global OUTPUT;

colors = get(groot,'DefaultAxesColorOrder');

h = plot(100*biasVecMoneyMetric',100*[biasVecMoneyMetric' optTaxMat]);
xlabel('Uninternalized harm (cents per ounce)');
ylabel('Optimal SSB tax (cents per ounce)');

set(h(1),'Color','k','Linewidth',1);
set(h(2),'Linestyle','-','Linewidth',2);
set(h(3),'Linestyle','--','Linewidth',2);
set(h(4),'Linestyle','-.','Linewidth',2);
set(h(5),'Linestyle',':','Linewidth',2);

legItems = {'No redistributive motives (45° line)'};
for i=1:size(optTaxMat,2)
    set(h(1+i),'Color',colors(i,:));
    if i==2
        legItems{i+1} = ['SSB demand elasticity = ' num2str(round(elastVec(i),2)) ' (avg in data)'];
    else
        legItems{i+1} = ['SSB demand elasticity = ' num2str(round(elastVec(i),2))];
    end
end

leg = legend(legItems,'location','northwest');

ylim([floor(min(100*optTaxMat(:))); ceil(max(100*optTaxMat(:)))]);

hold on;
h(end+1) = plot(100*[min(biasVecMoneyMetric); max(biasVecMoneyMetric)],[0; 0],'Linewidth',0.5,'Color','k');
h(end+1) = plot(100*[actualBias; actualBias],[-10; 10],'Linewidth',0.5,'Color','k','Linestyle','--');
hold off;

uistack(h(end-1:end),'bottom'); % place guide lines underneath main plots

set(gca,'fontsize',14);

text(100*actualBias,floor(min(100*optTaxMat(:)))+1,'\leftarrow Average estimated internality','FontSize',14);

fname = [OUTPUT '/Figures/opt_soda_tax.pdf'];

% crop to figure size, see https://www.mathworks.com/help/matlab/creating_plots/save-figure-with-minimal-white-space.html
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

print(fig,fname,'-dpdf');

end
