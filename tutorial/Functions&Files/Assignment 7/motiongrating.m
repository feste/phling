function M = motiongrating(vhdim,ncycles,surroundcolor,framestocycle);

framestep = 2*pi/framestocycle;

stepvect = -pi:(2*pi)/(vhdim-1):pi;
[x,y] = meshgrid(stepvect,stepvect);
radimap0 = sqrt(x.^2+y.^2);
q = radimap0>pi;

for i = 1:framestocycle
    radimap = sqrt(x.^2+y.^2);
    frame = 255*(1+sin((ncycles*radimap)+i*framestep))*.5;
    frame(q) = surroundcolor;
    M(:,:,i) = frame;
end