clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

screennr = 0;
monitorfreq = 85;

presentationduration = 5;

stimvhdim = 300;
ncycles = 5;
backgroundcolor = 255/2;
framestocycle = 30;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stimulus computation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M = motiongrating(stimvhdim,ncycles,backgroundcolor,framestocycle);
presentationframes = round(presentationduration*monitorfreq);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% screen presentation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[w,screenrect] = Screen(screennr,'openwindow');
Screen(w,'fillrect',backgroundcolor);

sr = [0 0 stimvhdim stimvhdim];
dst = CenterRect(sr,screenrect);

for i = 1:framestocycle
    src(i)  = Screen(w,'OpenOffscreenWindow',0,sr);
    Screen(src(i),'PutImage',M(:,:,i),sr);
end

donotstop = 1;
teller = 0;
for frame = 1:presentationframes;
    Screen(w,'waitblanking');
    Screen('CopyWindow',src(1+mod(frame,framestocycle)),w,sr,dst);
end

Screen closeall;