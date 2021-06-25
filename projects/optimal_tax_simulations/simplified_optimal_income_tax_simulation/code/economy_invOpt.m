classdef economy_invOpt < economy
    % Overrides baseline economy with redistributive preferences that 
    % rationalize US tax system
    
    methods
                
        function paretoWts = compute_pareto_weights(obj)
            % Compute implicit weights from US tax system in each state
            % using the inverse optimum approach
            
            FF = [0; obj.F];
            incMP = [0; (obj.income(1:end-1)+ ...
                obj.income(2:end))/2; obj.income(end)];
            ff = diff(FF)./diff(incMP);
            bandwidth = 4;
            numpoints = 1000;
            r = ksr_vw(log(obj.income),log(ff),bandwidth,numpoints);
            logz = r.x;
            logf = r.f;
            fElastRaw = diff(logf)./diff(logz); % elasts at the midpoints between bins
            xMP = (r.x(1:end-1)+r.x(2:end))/2;
            fElast = interpcon(xMP,fElastRaw,log(obj.income),'linear','extrap');
            alph = -(1 + fElast);
            fiscExt = -obj.laborElast*obj.inc_mtrs./ ...
                (1-obj.inc_mtrs).*alph;
            gg = 1 + fiscExt;
            r = ksr(obj.F,gg,0.1,1000);
            paretoWts = interpcon(r.x,r.f,obj.F,'linear','extrap');
           
        end
        
    end
    
end
