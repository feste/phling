function [txtRect]=HH_centerText(winID,txt,rect,txtCol,vertOffset)
% function [txtRect]=HH_centerText(winID,txt,rect,txtCol,[vertOffset])
%
% Calls the psychtoolbox Screen DrawText function to put the text in 'txt'
% onscreen, centered in 'rect'. You can use the first two coordinates in
% the returned txtRect in later calls to Screen DrawText. The optional
% 'vertOffset' moves the text up and down on the screen.

if nargin<5
    vertOffset=0;
end

oriX=10000;
oriY=10000;

[newX,newY] = SCREEN(winID,'DrawText',txt,oriX,oriY);
txtRect=centerrect([oriX oriY newX newY],rect);

SCREEN(winID,'DrawText',txt,txtRect(1),txtRect(2)+vertOffset,[txtCol]);


