classdef InvOptWts < calibrate_paretoWts
    methods (Static)
        function paretoWts = compute_paretoWts(inequality_aversion_parameter,prim,eqbm)
        % Compute implicit weights from US tax system using inverse optimum approach
            global LABORELAST;
            FF = [0; prim.F];
            incMP = [0; (eqbm.income(1:end-1)+eqbm.income(2:end))/2; eqbm.income(end)];
            ff = diff(FF)./diff(incMP);
            bandwidth = 4;
            numpoints = 1000;
            r = ksr_vw(log(eqbm.income),log(ff),bandwidth,numpoints);
            logz = r.x;
            logf = r.f;
            fElastRaw = diff(logf)./diff(logz); % elasts at the midpoints between bins
            xMP = (r.x(1:end-1)+r.x(2:end))/2;
            fElast = interpcon(xMP,fElastRaw,log(eqbm.income),'linear','extrap');
            alpha = -(1 + fElast);
            fiscExt = -LABORELAST*eqbm.inc_mtrs./(1-eqbm.inc_mtrs).*alpha;
            gg = 1 + fiscExt;
            r = ksr(prim.F,gg,0.1,1000);
            paretoWts = interpcon(r.x,r.f,prim.F,'linear','extrap');
        end
    end
end  