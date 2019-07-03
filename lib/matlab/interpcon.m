function yi = interpcon(x,y,xi,varargin)
% Combines interp1 with consolidator to allow for non-strictly-increasing x.

try
    yi = interp1(x,y,xi,varargin{:});
catch
    [xCon,yCon] = consolidator(x,y,'min',1e-14);
    yi = interp1(xCon,yCon,xi,varargin{:});
end

end
