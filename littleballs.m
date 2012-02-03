function [] = littleballs(doublebuffer, ifi, w, nframes, offset, vertbound, horizbound, vbl, center, ...
    waitframes, lag, gap, cond, delay, speed, radius, col1, col2)

%fprintf('you made it to littleballs\n');
% to do:
%   switch colors when they pass going towards each other (vertical)
%   center no-cause balls
%   spacebar to record segmentations
%	run multiple displays, one after the other (multiple trials in experiment)

% delay is number of frames before movement starts
% gap is the number of pixels that separate the balls
% color1 and color2 options are 'red', 'blue', 'green', and 'white'
% lag is the number of frames for the lag in between balls moving.
% cond is the condition.  so far i have made the conditions 'cause',
%   'no-cause', and 'vert'.
% speed and radius are optional arguments for the disks.
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
fprintf('ovals filled\n');
Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')

%fprintf('some drawing happened\n');

vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
fprintf('past vbl\n');
KbStrokeWait;
fprintf('past kb\n');

hasHit = false;
lagCounter = 0;
justHit = 2;

%fprintf('entering loop\n');

%waituntilspacepress;
% --------------
% animation loop
% --------------
for i = 1:nframes
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
end

function coordinates = getCoord(center, ball_coord, radius)
  coordinates = [center(1) + ball_coord(1) - radius;
                 center(2) + ball_coord(2) - radius;
                 center(1) + ball_coord(1) + radius;
                 center(2) + ball_coord(2) + radius];
end

function bool = inbounds(coord, vertbound, horizbound, center, radius)

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
