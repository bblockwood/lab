classdef economy
    % Defines an economy with moderate redistributive preferences
    
    properties
                
        % Primitives
        revreq;             % revenue requirement
        F;                  % population distribution
        wage;               % skill distribution
        alpha;              % Pareto weights
        lambda;             % marginal value of public funds
        msww;               % marginal social welfare weights

        % Endogenous choice values for an equilibrium
        inc_mtrs;           % marginal tax rates
        consump;            % consumption distribution
        income;             % income distribution
        grant;              % lump-sum grant
        
        % Identifier
        specTitle;
        
    end
    
    properties (Constant)
        
        laborElast = 0.33;  % labor elasticity from Chetty ECMA 2012
        USPop = 0.311;      % U.S. adult equivalents, in billions
        
    end
    
    methods
        
        function obj = economy(data, title)
            % Calibrates model primitives to match data, then find equilibrium
            
            % Label with title
            obj.specTitle = title;
            
            % Calibrate model parameters
            obj = obj.calibrate(data);
            
            % Find equilibrium
            obj = obj.compute_optimal_taxes();
                        
        end
        
        function obj = calibrate(obj,status_quo)
            % Calibrates primitives of model
            
            obj.F = cumsum(status_quo.pmf);
            N = length(status_quo.incUS);
            
            % smooth empirical distributions
            status_quo.incUS = smooth(status_quo.incUS,'lowess');
            status_quo.consumpUS = smooth(status_quo.consumpUS,'lowess');
            
            % Calibrate US tax schedule
            % construct schedule of tax rates: d(z-c)/dz, with kernel
            % smoothing regression
            mtrRaw = diff(status_quo.incUS - status_quo.consumpUS)./ ...
                diff(status_quo.incUS);
            r = ksr(obj.F(2:end),mtrRaw); % chooses optimal bandwidth automatically
            obj.inc_mtrs = interpcon(r.x,r.f,obj.F,'linear','extrap');
            obj.revreq = trapz(obj.F,status_quo.incUS - status_quo.consumpUS);
            obj.grant = status_quo.consumpUS(1);
            
            % Initialize values
            obj.msww = zeros(N,1);
            obj.consump = status_quo.consumpUS;
            obj.income = status_quo.incUS;
            
            % Set primitives
            obj.alpha = obj.compute_pareto_weights();
            obj.wage = (obj.income.^(1./obj.laborElast)./ ...
                (1-obj.inc_mtrs)).^(obj.laborElast./(1+obj.laborElast));
                         
        end
        
        function paretoWts = compute_pareto_weights(obj)
            % Computes Pareto weights based on total consumption in US
            % status quo (these stay fixed)
            
            inequality_aversion_parameter = 1; % moderate redist preferences
            paretoWts = obj.consump.^(-inequality_aversion_parameter);
            
        end
        
        function obj = compute_optimal_taxes(obj)
            % Computes optimal tax schedule and updates equilibrium.
            
            inc_mtrs_old = obj.inc_mtrs;
            policy_change = 1;
            inc_mtrs_change = 1;
            idx = 1;
            
            while (policy_change > 1e-4) || ...
                (inc_mtrs_change > 1e-5) || (idx < 5)
                % require at least 5 iterations, so that everything
                % (including consumption) gets updated
                
                % 1. Compute marginal social welfare weights (MSWWs)
                obj = obj.compute_mswws();
                
                % 2. Update optimal income tax
                [obj.inc_mtrs, mtr_raw] = obj.compute_income_tax();
                inc_mtrs_change = norm(obj.inc_mtrs - inc_mtrs_old);
                policy_change = max(abs(((mtr_raw(1:end-1)) - ...
                    inc_mtrs_old(1:end-1)) ./ inc_mtrs_old(1:end-1)));
                inc_mtrs_old = obj.inc_mtrs;
                
                % 3. Update labor supply, grant, and consumption
                obj.income = obj.compute_income();
                inc_tax = cumtrapz(obj.income,obj.inc_mtrs);
                obj.grant = trapz(obj.F,inc_tax) - obj.revreq;
                obj.consump = obj.grant + obj.income - inc_tax;
                
                disp([idx policy_change inc_mtrs_change]);
                idx = idx+1;
                if idx > 5000, warning('exceeded iteration limit'); break; end
                
            end
            
        end
        
        function [mtr_new, mtr_raw] = compute_income_tax(obj)
            % Computes schedule of optimal marginal tax rates for a given equilibrium.
            
            mtr_step = 0.01; % to ensure convergence
            
            f = economy.derivative(obj.F,obj.income); % income density
            if f(1) < 0 % ensure positive density
                    fRaw = economy.derivative([0;obj.F],[0;obj.income]);
                    f = fRaw(2:end);
            end
            f = smooth(f,'lowess');
            
            dzdt = obj.compute_labor_supply_response(); % compensated earnings response to dt
            
            % Extend income distribution and MSWWs to zero for purposes of integration
            FExt = [0; obj.F];
            mswwExt = interpcon(obj.income,obj.msww,[0;obj.income],'linear','extrap');
            GExt = cumtrapz(FExt,mswwExt);
            G = GExt(2:end);
            G = G./G(end); % normalize so G integrates to 1 across full income distribution.
            
            dM = G - obj.F; % mechanical effect, dim Nx1
            denominator = smooth(f.*dzdt,'lowess');
            mtr_raw = -dM ./ denominator;
            mtr_raw = smooth(mtr_raw,'lowess');
            
            % smooth and dampen to facilitate convergence
            mtr_lim = min(max(mtr_raw,-0.1),1);
            mtr_new = mtr_step*mtr_lim + (1 - mtr_step)*obj.inc_mtrs;
            
        end
        
        function obj = compute_mswws(obj)
            % Computes marginal social welfare weights under a given equilibrium.
            
            obj = obj.compute_mvpf();
            obj.msww = obj.alpha ./ obj.lambda;
            
            % Check that msww average to ~1
            assert(norm(trapz(obj.F,obj.msww) - 1) < 1e-3);
            
        end
        
        function obj = compute_mvpf(obj)
            % Computes the marginal value of public funds.
                        
            obj.lambda = trapz(obj.F,obj.alpha);
            
        end
        
        function dzdt = compute_labor_supply_response(obj)
            % Computes compensated earnings response to a marginal tax rate perturbation.
            
            SOC_z = obj.compute_SOC_labor_supply();
            dzdt = 1./SOC_z;
            
        end
        
        function SOC_z = compute_SOC_labor_supply(obj)
            % Second-order condition for labor supply choice
            
            % compute 2nd deriv of tax function
            mtr_deriv = economy.derivative(obj.inc_mtrs,obj.income);
            
            psi_deriv2 = (1./obj.laborElast) .* ...
                (obj.income ./ obj.wage).^(1./obj.laborElast - 1);
            
            SOC_z = -1.*mtr_deriv - (psi_deriv2 ./ obj.wage.^2);
            
        end
        
        function income = compute_income(obj)
            % Retrieve income distribution from ability (wage) distribution
            
            income = obj.wage.^(1+obj.laborElast) .* ...
                (1 - obj.inc_mtrs).^obj.laborElast;
            
        end

    end
    
    methods(Static)
        
        function dydx = derivative(y,x)
            % Computes the derivative of y with respect to x, giving the
            % same number of elements. Uses linear extrapolation.
            
            dydx_grid = diff(y)./diff(x);
            x_midpoints = (x(1:end-1) + x(2:end))/2;
            dydx = interpcon(x_midpoints,dydx_grid,x,'linear','extrap');
            
        end
        
    end
    
end
