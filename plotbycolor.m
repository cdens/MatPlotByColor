function plotbycolor(x,y,z,varargin)

% plotbycolor(x,y,z)
% Author: Casey R. Densmore
%
% Plots a line of points specified by arrays x,y, colored by array z using
% contour values of zcontours and corresponding colors in zcolormap
%
% Input arguments:
%   o x,y: Arrays of x/y pair to be plotted
%   o z: Values by which the line for x/y will be colored
%
% Optional input arguments:
%   o contours: 
%   o colormap: 
%   o linewidth: 
%   o axes:
%


linewidthval = [];
cax = [];
zcontours = [];
zcolormap = [];

%parse any additional arguments
%parsing optional inputs
if nargin >= 4 %2 mandatory + at least 2 (key+value) optional inputs
    for n = 2:2:nargin-2
        key = varargin{n-1};
        value = varargin{n};
        
        switch(lower(key))
            case 'axes'
                if ~isa(value,'matlab.graphics.axis.Axes')
                    warning('Invalid argument passed for axes, using gca')
                else
                    cax = value;
                end
                
            case 'linewidth'
                if length(value) ~= 1 || ~isnumeric(value)
                    warning('Invalid argument passed for linewidth, using default value')
                else
                    linewidthval = value;
                end
                
            case 'contours'
                if length(value) <= 1 || ~isnumeric(value)
                    warning('Invalid argument passed for contours, using default value')
                else
                    zcontours = value;
                end
                
            case 'colormap'
                if size(value,2) ~= 3 || size(value,1) <= 1 || ~isnumeric(value)
                    warning('Invalid argument passed for colormap, using default value')
                else
                    zcolormap = value;
                end
        end
    end
end

%set defaults
if isempty(cax)
    cax = gca;
end
if isempty(linewidthval)
    linewidthval = 2;
end
if isempty(zcontours)
    zmin = min(z);
    zmax = max(z);
    zcontours = zmin:(zmax-zmin)/20:zmax;
end
if isempty(zcolormap)
    zcolormap = jet(length(zcontours)+1);
end

%check if axes hold is on, turn on if not and note to turn off at end of fxn
if ~ishold(cax)
    cla(cax)
    heldaxes = false;
    hold(cax,'on')
else
    heldaxes = true;
end

%making sure function is given good data
if length(x) ~= length(y) || length(x) ~= length(z) || ...
        length(zcontours) ~= size(zcolormap,1)-1 || length(linewidthval) ~= 1
    error('Incorrect Dimension of Input Arguments')
end

x = x(:);
y = y(:);
z = z(:);

for i = 1:length(zcontours)+1
    
    %getting all of the colors within the current color range
    if i == 1
        curplotind = z < zcontours(1);
    elseif i == length(zcontours)+1
        curplotind = z >= zcontours(end);
    else
        curplotind = z >= zcontours(i-1) & z < zcontours(i);
    end
    
    %finding all of the start points and end points within the current
    %color range
    sindc = 0;
    eindc = 0;
    
    if curplotind(1) == 1 %if it starts within current colorrange
        sindc = sindc + 1;
        sind(sindc) = 1;
    end
    for l = 2:length(curplotind)
        if curplotind(l-1) == 0 && curplotind(l) == 1
            sindc = sindc + 1;
            sind(sindc) = l-1;
        elseif curplotind(l-1) == 1 && curplotind(l) == 0
            eindc = eindc + 1;
            eind(eindc) = l;
        end
    end
    if curplotind(end) == 1 %if it ends within current colorrange
        eindc = eindc + 1;
        eind(eindc) = length(curplotind);
    end
    
    %they should be equal for this code to work but I haven't given
    %sufficient thought to whether that could be violated- throwing this
    %error in as a catch all for now
    if eindc ~= sindc
        error('Something here is messed up')
    end
    
    for s = 1:sindc %for each segment within the current color range
        
        if sind(s) == 1
            xstart = x(sind(s));
            ystart = y(sind(s));
        elseif sind(s) ~= length(x)
            xstart = 0.5*(x(sind(s))+x(sind(s)+1));
            ystart = 0.5*(y(sind(s))+y(sind(s)+1));
        else
            xstart = 0.5*(x(end)+x(end-1));
            ystart = 0.5*(y(end)+y(end-1));
        end
        
        if eind(s) == length(x)
            xend = x(eind(s));
            yend = y(eind(s));
        else
            xend = 0.5*(x(eind(s)-1)+x(eind(s)));
            yend = 0.5*(y(eind(s)-1)+y(eind(s)));
        end
        
        xcur = [xstart;x(sind(s)+1:eind(s)-1);xend];
        ycur = [ystart;y(sind(s)+1:eind(s)-1);yend];
        
        plot(cax,xcur,ycur,'color',zcolormap(i,:),'linewidth',linewidthval)
    end
end
    
%turn hold off if necessary
if ~heldaxes
    hold(cax,'off')
end
