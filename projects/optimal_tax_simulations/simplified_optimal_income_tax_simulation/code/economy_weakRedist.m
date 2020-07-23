classdef economy_weakRedist < economy
    % Overrides baseline economy with weaker redistributive preferences
    
    methods
        
        function paretoWts = compute_pareto_weights(obj)
            % Computes Pareto weights based on total consumption in US
            % status quo (these stay fixed)
            
            inequality_aversion_parameter = 0.25; % weak redist preferences
            paretoWts = obj.consump.^(-inequality_aversion_parameter);
            
        end
        
    end

end