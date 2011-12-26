function [xpos,ypos] = HH_hexSearchPositions(nrows,ncols,xspacing,jitter)

% [xpos,ypos] = HH_hexSearchPositions(nrows,ncols,xspacing,jitter)
% returns points on a hexagonal grid, centered on (0,0)
% nx:       number of rows
% nx:       number of columns
% xspacing: space between points
% jitter:   randomly shift points by up to this amount in any direction


yspacing=xspacing*tan(pi/6);
xOffset=-(ncols-0.5)*xspacing/2;
yOffset=-(nrows-1)*yspacing/2;

for i=1:nrows %step through the rows
    for j=1:ncols %step through the items in each row
        if mod(i,2)==1 %odd rows
            xpos(i,j)=xOffset+(j-1)*xspacing;
        elseif mod(i,2)==0 %even rows are staggered
            xpos(i,j)=xOffset+(j-0.5)*xspacing;
        end
        ypos(i,j) = yOffset+(i-1)*yspacing;
    end
end

if jitter %if necessary, jitter the locations randomly
    jitterDir=2*pi*rand(size(xpos));
    jitterAmp=jitter*rand(size(xpos));

    xpos=xpos+jitterAmp.*cos(jitterDir);
    ypos=ypos+jitterAmp.*sin(jitterDir);
end

ypos	= round(reshape(ypos,1,nrows*ncols));
xpos	= round(reshape(xpos,1,nrows*ncols));