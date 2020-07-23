classdef economy_strongRedist < economy
    % Overrides baseline economy with stronger redistributive preferences
    
    methods
        
        function paretoWts = compute_pareto_weights(obj)
            % Computes Pareto weights based on total consumption in US
            % status quo (these stay fixed)
            
            inequality_aversion_parameter = 4; % strong redist preferences
            paretoWts = obj.consump.^(-inequality_aversion_parameter);
            
        end
        
    end

end