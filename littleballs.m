function [] = littleballs(subjectNo, doublebuffer, ifi, w, nframes, ...
    offset, vertbound, horizbound, vbl, center, waitframes, lag, gap, ...
    cond, delay, speed, radius, col1, col2)
    
    %-----------VARIABLE DESCRIPTIONS---------%
    
    %subjectNo: goes in the subject column for each trial in the file data.txt
    
    %doublebuffer: i don't know. *
    
    %ifi: i don't know. *

    %w: window index.  a lot of psychtoolbox functions need this to know where
    %	to display stuff.

    %nframes
    %	the minimum number of frames for the animation. later the 
    %	specific lag for this trial is added to nframes to get the total number
    %	of frames in the animation (nframes includes a delay before start of 
    %	the animation which is defined as one of the constants in superballs.m)
    
    %offset
    %	i think this is the vertical offset between the two balls
    
    %vertbound
    %	the farthest from center i can go vertically on my laptop's screen **
    
    %horizbound
    %	the farthest from center i can go horizontally on my laptop's screen **
    
    %vbl
    %	this has something to do with the display *
    
    %center
    %	coordinates for center of screen, which were found by psychtoolbox.
    %	there are 4 coordinates in center.  they are (in this order): left, 
    %	top, right, bottom
    
    %waitframes
    %	don't know. *
    
    %lag
    %	temporal lag between first ball reaching center and second ball
    %	initiating motion
    
    %gap
    %	spatial gap between the two balls along the axis of motion
    
    %cond
    %	my bad variable name for which display type (in the case of experiment
    %	1, 'cause' == experimental items and 'reverse' == filler)
    
    %delay
    %	the delay before the start of the animation while the balls are still
    %	in their initial positions on the screen
    
    %speed
    %	how fast in frames per iteration the balls are moving
    
    %radius
    %	radius of the balls
    
    %col1
    %	color of first ball given as a 1x3 array
    
    %col2
    %	color of second ball given as a 1x3 array

    % * i don't know what these are because these items were in the file i 
    %	edited to create littleballs.m.  It was a sample psychtoolbox script 
    %	called dots.m (or something)
    
    % ** i should totally not have hardcoded these.  i think psychtoolbox has
    %	ways of dealing with this, i just don't know them
    
    %-----------END VARIABLE DESCRIPTIONS-----------%

% possible extensions:
%   switch colors when they pass going towards each other (vertical)
%   spacebar to record segmentations
%	run multiple displays, one after the other (multiple trials in experiment)

% delay is number of frames before movement starts
% gap is the number of pixels that separate the balls
% color1 and color2 options are 'red', 'blue', 'green', and 'white'
% lag is the number of frames for the lag in between balls moving.
% cond is the condition.  so far i have made the conditions 'cause',
%   'no-cause', and 'vert'.
% speed and radius are optional arguments for the disks.

white = WhiteIndex(w);
c = clock;

year = num2str(c(1));
month = num2str(c(2));
day = num2str(c(3));
hour = num2str(c(4));
min = num2str(c(5));

time = [year '-' month '-' day ' ' hour ':' min];

printcond = cond;	%i change the value of cond during the script because that
					%was easier than figuring out the booleans.  however,
					%i want to print the original cond when i write to data.txt

switch cond
    case 'cause'
        firstBallStart = [-horizbound, 0];
        secondBallStart = [offset,0];
        change = [speed; 0; speed; 0];
    case 'vert'
        firstBallStart = [0,-vertbound];
        secondBallStart = [0,offset];
        change = [0; speed; 0; speed];
    case 'vert-switch'
        firstBallStart = [0,-vertbound];
        secondBallStart = [0,offset];
        change = [0; speed; 0; speed];
    case 'no-cause'
        firstBallStart = [-horizbound, -vertbound];
        secondBallStart = [horizbound,0];
        change = [speed; 0; speed; 0];
    case 'reverse'
        firstBallStart = [-horizbound, 0];
        secondBallStart = [horizbound,0];
        change = [speed; 0; speed; 0];
        cond = 'no-cause';
end
%fprintf('cause is cast\n');

firstBallCoord = getCoord(center, firstBallStart, radius);
secondBallCoord = getCoord(center, secondBallStart, radius);
ghostSecondBallCoord = getCoord(center, [offset,0], radius);

%fprintf('coords are cast\n');

Screen('FillOval', w, uint8(col1), firstBallCoord);
Screen('FillOval', w, uint8(col2), secondBallCoord);
Screen('DrawText', w, 'Press any button to continue.', 540, 300, white);
%fprintf('ovals filled\n');
Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')

%fprintf('some drawing happened\n');

vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
%fprintf('past vbl\n');
KbStrokeWait;
%fprintf('past kb\n');

hasHit = false;
lagCounter = 0;
justHit = 2;

%fprintf('entering loop\n');

%waituntilspacepress;
% --------------
% animation loop
% --------------
for i = 1:nframes + lag
    if (i>0)
        %fprintf('in first if\n');
        noCause = strcmp(cond, 'no-cause');
        %vertSwitch = strcmp(cond, 'vert-switch');
        beforeMidPoint = abs(secondBallCoord(1) - ghostSecondBallCoord(1)) < speed;
        inBounds = inbounds(secondBallCoord, vertbound, horizbound, center, radius);
        if ~(noCause && beforeMidPoint) && inBounds && (i>delay)
            %fprintf('in second if\n');
            if (hasHit == false)
                %fprintf('in third if\n');
                firstBallCoord = firstBallCoord + change;
                vertCond = strcmp(cond, 'vert') || strcmp(cond, 'vert-switch');
                vertTouch = abs(firstBallCoord(4) - secondBallCoord(2)) < speed + gap;
                horizTouch = abs(firstBallCoord(3) - ghostSecondBallCoord(1)) < speed + gap;
                if ((vertCond && vertTouch) || (~vertCond && horizTouch))
                    hasHit = true;
                    justHit = 0;
                end
            else
                lagCounter = lagCounter + 1;
                if (lagCounter > lag)
                    if strcmp(cond, 'no-cause')
                        secondBallCoord = secondBallCoord - change;
                    else
                        secondBallCoord = secondBallCoord + change;
                    end
                end
            end
        end
        %fprintf('out of some ifs\n');
        %if (vertSwitch && justHit == 1)
        %    old1 = col1;
        %    old2 = col2;
        %    col1 = old2;
        %    col2 = old1;
        %end
        justHit = justHit + 1;
        Screen('FillOval', w, uint8(col1), firstBallCoord);
        Screen('FillOval', w, uint8(col2), secondBallCoord);
        Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
        %fprintf('some stuff has been drawn\n');
    end;
    
    %    [mx, my, buttons]=GetMouse(screenNumber);
    %    if KbCheck | any(buttons) % break out of loop
    %        break;
    %      end;
    if (doublebuffer==1)
        vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
    end;
    %    fprintf('done with first it');
end

%QUESTION GOES HERE
dataFile=fopen(sprintf('data.txt'),'a');
Screen(w,'fillrect',0);
right = 270;
top = 180;
step = 40;
Screen('TextSize', w, 14);
Screen('DrawText', w, 'strongly disagree                      disagree                  somewhat disagree         neighter agree nor disagree         somewhat agree                    agree                         strongly agree',right - 150,top+step*8,white);
Screen('TextSize', w, 24);
Screen('DrawText', w, '1                       2                       3                       4                       5                       6                       7',right - 100,top+step*9,white);
Screen('Flip',w);
% Wait for the user to input something meaningful
inLoop=true;
while inLoop
    [keyIsDown,finish,keyCode]=KbCheck;
    if keyIsDown
        keyCode = find(keyCode);
        if (11 <= keyCode) & (keyCode <= 17)
            inLoop=false;
            response = keyCode - 10
            fprintf(dataFile, '\n%i\t%s\t%i\t%i\t%s', subjectNo, printcond, lag, response, time);
        else
            inLoop=true;
        end
    end
end
%pause(1);
%END QUESTION

end

function coordinates = getCoord(center, ball_coord, radius)
%this function tells you what the left-top-right-bottom coordinates of a ball 
%with respect to center are if you only know the x-y coordinates on the screen
%---variables---%
%ball_coord : x-y coordinates of the ball
%center : center of screen
%radius : radius of ball
%---end variables---%
coordinates = [center(1) + ball_coord(1) - radius;
    center(2) + ball_coord(2) - radius;
    center(1) + ball_coord(1) + radius;
    center(2) + ball_coord(2) + radius];
end

function bool = inbounds(coord, vertbound, horizbound, center, radius)
%checks whether a ball is inside the comfortably viewable window that i
%hardcoded for my laptop's screen
%---variables---%
%coord : coordinates (left, top, right, bottom) of the ball's center
%vertbound : hardcoded max vertical distance from center
%horizbound : hardcoded max horizontal distance from center
%center : found by psychtoolbox, center of screen
%radius : radius of the ball
%---end variables---%

rightbound = -horizbound + center(1);
leftbound = horizbound + center(1);
topbound = -vertbound + center(2);
bottombound = vertbound + center(2);

right = coord(1) + radius >= rightbound;
left = coord(3) - radius <= leftbound;
top = coord(2) + radius >= topbound;
bottom = coord(4) - radius <= bottombound;

bool = right && left && top && bottom;
end
