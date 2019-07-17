classdef calibrate_paretoWts
    methods (Static)
        function paretoWts = compute_paretoWts(inequality_aversion_parameter,prim,eqbm)
        % Compute Pareto weights based on total consumption in US status quo (these stay fixed)
            paretoWts = eqbm.consump.^(-inequality_aversion_parameter);
        end
    end
end  