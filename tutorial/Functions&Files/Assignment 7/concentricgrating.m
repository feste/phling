function M = concentricgrating(stimvhdim,ncycles,surroundcolor);

stepvect = -pi:(2*pi)/(stimvhdim-1):pi;
[x,y] = meshgrid(stepvect,stepvect);
radimap = sqrt(x.^2+y.^2);
M = 255*(1+sin(ncycles*radimap))*.5;

q = radimap>pi;
M(q) = surroundcolor;